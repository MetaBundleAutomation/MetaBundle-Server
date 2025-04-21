# Start the MetaBundle Infrastructure Backend
param(
    [switch]$UseVenv,
    [switch]$SetupVenv,
    [switch]$Docker,
    [switch]$TestMode
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Function to create and setup virtual environment
function Setup-VirtualEnvironment {
    Write-Host "Setting up virtual environment..." -ForegroundColor Cyan
    
    # Check if Python is installed
    try {
        python --version
    }
    catch {
        Write-Host "Python is not installed or not in PATH. Please install Python 3.9+ and try again." -ForegroundColor Red
        exit 1
    }
    
    # Create virtual environment if it doesn't exist
    if (-not (Test-Path "$root\venv")) {
        Write-Host "Creating virtual environment..." -ForegroundColor Cyan
        python -m venv "$root\venv"
    }
    
    # Activate virtual environment
    Write-Host "Activating virtual environment..." -ForegroundColor Cyan
    & "$root\venv\Scripts\Activate.ps1"
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    pip install -r "$root\requirements.txt"
    
    Write-Host "Virtual environment setup complete!" -ForegroundColor Green
}

# Function to activate existing virtual environment
function Activate-VirtualEnvironment {
    if (-not (Test-Path "$root\venv")) {
        Write-Host "Virtual environment not found. Use -SetupVenv to create one." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Activating virtual environment..." -ForegroundColor Cyan
    & "$root\venv\Scripts\Activate.ps1"
}

# Function to build and run Docker container
function Start-DockerContainer {
    Write-Host "Building and starting Docker container..." -ForegroundColor Cyan
    
    # Navigate to Docker directory
    $dockerDir = "$root\deploy\docker"
    
    # Check if docker is installed
    if (-not $TestMode) {
        try {
            docker --version
        }
        catch {
            Write-Host "Docker is not installed or not in PATH. Please install Docker and try again." -ForegroundColor Red
            exit 1
        }
    }
    
    # Build and start container
    Push-Location $dockerDir
    try {
        if (-not $TestMode) {
            Write-Host "Building Docker image..." -ForegroundColor Cyan
            docker-compose -f infrastructure-backend-compose.yml build
            
            Write-Host "Starting Docker container..." -ForegroundColor Cyan
            docker-compose -f infrastructure-backend-compose.yml up -d
        } else {
            Write-Host "Simulating Docker build and start..." -ForegroundColor Yellow
        }
        
        if (-not $TestMode) {
            Write-Host "Docker container started successfully!" -ForegroundColor Green
            Write-Host "API is available at: http://localhost:8000" -ForegroundColor Cyan
            Write-Host "WebSocket is available at: ws://localhost:8001" -ForegroundColor Cyan
        }
    }
    finally {
        Pop-Location
    }
}

# Function to check if a port is available
function Test-PortAvailable {
    param (
        [int]$Port
    )
    
    $result = $true
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("127.0.0.1", $Port)
        $tcpClient.Close()
        $result = $false
    } catch {
        $result = $true
    }
    
    return $result
}

# Function to load environment variables from .env file
function Load-EnvFile {
    param (
        [string]$EnvFile
    )
    
    if (Test-Path $EnvFile) {
        Write-Host "Loading environment variables from $EnvFile..." -ForegroundColor Green
        Get-Content $EnvFile | ForEach-Object {
            if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith('#')) {
                $name, $value = $_.Split('=', 2)
                if (-not [string]::IsNullOrWhiteSpace($name) -and -not [string]::IsNullOrWhiteSpace($value)) {
                    Set-Item -Path "env:$name" -Value $value
                    Write-Host "Set $name environment variable" -ForegroundColor Gray
                }
            }
        }
        return $true
    } else {
        Write-Host "Environment file $EnvFile not found" -ForegroundColor Red
        return $false
    }
}

# Check if .env file exists, create from example if not
if (-not (Test-Path "$root\.env")) {
    Write-Host "Creating .env file from example..." -ForegroundColor Cyan
    Copy-Item "$root\.env.example" "$root\.env"
    Write-Host "Please update the .env file with your GitHub token and organization" -ForegroundColor Yellow
    exit
}

# Load environment variables from .env file
Load-EnvFile -EnvFile "$root\.env"

# Check if required ports are available
$ApiPort = $env:API_PORT
if (-not $ApiPort) {
    $ApiPort = 8000
}

$WebSocketPort = $env:WEBSOCKET_PORT
if (-not $WebSocketPort) {
    $WebSocketPort = 8001
}

$ApiPortAvailable = Test-PortAvailable -Port $ApiPort
$WebSocketPortAvailable = Test-PortAvailable -Port $WebSocketPort

if (-not $ApiPortAvailable) {
    Write-Host "ERROR: API port $ApiPort is already in use. Please specify a different port in the .env file." -ForegroundColor Red
    Write-Host "You can set API_PORT environment variable to a different value, or terminate the process using that port." -ForegroundColor Yellow
    exit 1
}

if (-not $WebSocketPortAvailable) {
    Write-Host "ERROR: WebSocket port $WebSocketPort is already in use. Please specify a different port in the .env file." -ForegroundColor Red
    Write-Host "You can set WEBSOCKET_PORT environment variable to a different value, or terminate the process using that port." -ForegroundColor Yellow
    exit 1
}

# Handle different execution modes
if ($SetupVenv) {
    Setup-VirtualEnvironment
}

# Set environment variables for test mode
if ($TestMode) {
    $env:METABUNDLE_TEST_MODE = "true"
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "  RUNNING IN TEST MODE - DOCKER OPERATIONS SIMULATED" -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
}

# Start the application
$ApiDir = Join-Path $root "services\api\src"
if (-not (Test-Path $ApiDir)) {
    Write-Host "API directory not found at $ApiDir" -ForegroundColor Red
    exit 1
}

Write-Host "Starting MetaBundle Infrastructure API..." -ForegroundColor Green
Write-Host "API Port: $ApiPort, WebSocket Port: $WebSocketPort" -ForegroundColor Gray

if ($UseVenv) {
    # Check if virtual environment exists
    $venvPath = Join-Path $root "venv"
    if (-not (Test-Path $venvPath)) {
        Write-Host "Virtual environment not found. Please run setup with -SetupVenv first." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Using Python virtual environment..." -ForegroundColor Green
    & "$venvPath\Scripts\Activate.ps1"
    
    # Now run with active virtual environment
    if ($TestMode) {
        Write-Host "Starting API in TEST MODE with virtual environment..." -ForegroundColor Green
    } else {
        Write-Host "Starting API with virtual environment..." -ForegroundColor Green
    }
    
    # Run the application
    & python $ApiDir\infrastructure_api.py
} 
elseif ($Docker) {
    if ($TestMode) {
        Write-Host "WARNING: Test mode is not compatible with Docker mode. Running in Docker mode only." -ForegroundColor Yellow
    }
    
    Write-Host "Starting with Docker..." -ForegroundColor Green
    Push-Location $root\deploy\docker
    docker-compose -f infrastructure-backend-compose.yml up --build
    Pop-Location
} 
else {
    # Run directly without virtual environment
    if ($TestMode) {
        Write-Host "Starting API in TEST MODE..." -ForegroundColor Green
    } else {
        Write-Host "Starting API..." -ForegroundColor Green
    }
    
    # Check for Python
    try {
        $pythonVersion = python --version
        Write-Host "Using Python: $pythonVersion" -ForegroundColor Gray
    } catch {
        Write-Host "Python not found. Please install Python or use virtual environment with -UseVenv." -ForegroundColor Red
        exit 1
    }
    
    # Run the application
    Push-Location $ApiDir
    & python -m uvicorn infrastructure_api:app --host 0.0.0.0 --port $ApiPort --reload
    Pop-Location
}

# Handle exit
Write-Host "Infrastructure Backend stopped" -ForegroundColor Yellow

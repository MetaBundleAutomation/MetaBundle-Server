# Rebuild Docker Containers for MetaBundle Infrastructure
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dockerDir = "$root\deploy\docker"

Write-Host "Starting Docker container rebuild process..." -ForegroundColor Cyan

# Check if docker is installed
try {
    docker --version
}
catch {
    Write-Host "Docker is not installed or not in PATH. Please install Docker and try again." -ForegroundColor Red
    exit 1
}

# Check if .env file exists
if (-not (Test-Path "$root\.env")) {
    Write-Host "Creating .env file from example..." -ForegroundColor Cyan
    Copy-Item "$root\.env.example" "$root\.env"
    Write-Host "Please edit the .env file with your GitHub token and organization" -ForegroundColor Yellow
    exit
}

# Navigate to Docker directory
Push-Location $dockerDir
try {
    # Stop existing containers
    Write-Host "Stopping existing containers..." -ForegroundColor Cyan
    docker-compose -f infrastructure-backend-compose.yml down

    # Remove old images
    Write-Host "Removing old images..." -ForegroundColor Cyan
    $imageName = "infrastructure-api"
    $images = docker images --format "{{.Repository}}:{{.Tag}}" | Where-Object { $_ -like "*$imageName*" }
    
    if ($images) {
        docker rmi $images -f
        Write-Host "Removed old images." -ForegroundColor Green
    }
    else {
        Write-Host "No old images to remove." -ForegroundColor Cyan
    }

    # Build new images
    Write-Host "Building new Docker images..." -ForegroundColor Cyan
    docker-compose -f infrastructure-backend-compose.yml build --no-cache

    # Start containers
    Write-Host "Starting Docker containers..." -ForegroundColor Cyan
    docker-compose -f infrastructure-backend-compose.yml up -d

    Write-Host "Docker containers rebuilt and started successfully!" -ForegroundColor Green
    Write-Host "API is available at: http://localhost:8000" -ForegroundColor Cyan
    Write-Host "WebSocket is available at: ws://localhost:8001" -ForegroundColor Cyan
}
catch {
    Write-Host "Error rebuilding Docker containers: $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

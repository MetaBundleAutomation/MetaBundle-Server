# MetaBundle CLI Tool
# A streamlined command-line interface for managing the MetaBundle environment

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("setup", "start", "stop", "status", "update", "repo", "env", "help")]
    [string]$Command = "help",
    
    [Parameter(Mandatory=$false)]
    [string]$SubCommand,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Color configuration for consistent output styling
$colors = @{
    Title = "Cyan"
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "White"
    Subtitle = "Magenta"
}

# Display the MetaBundle banner
function Show-Banner {
    Write-Host "`n===================================================" -ForegroundColor $colors.Title
    Write-Host "             METABUNDLE CLI TOOL                    " -ForegroundColor $colors.Title
    Write-Host "===================================================" -ForegroundColor $colors.Title
    Write-Host "Current Directory: $root" -ForegroundColor $colors.Info
    Write-Host "---------------------------------------------------`n" -ForegroundColor $colors.Title
}

# Display help information
function Show-Help {
    Show-Banner
    
    Write-Host "AVAILABLE COMMANDS:" -ForegroundColor $colors.Subtitle
    
    Write-Host "`n  setup" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Initial environment setup"
    Write-Host "    setup env      - Configure environment variables"
    Write-Host "    setup docker   - Set up Docker components"
    Write-Host "    setup all      - Complete setup of all components"
    
    Write-Host "`n  start" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Start services"
    Write-Host "    start all      - Start all services"
    Write-Host "    start <service> - Start a specific service"
    
    Write-Host "`n  stop" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Stop services"
    Write-Host "    stop all       - Stop all services"
    Write-Host "    stop <service>  - Stop a specific service"
    
    Write-Host "`n  status" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Check status"
    Write-Host "    status services - Check running services"
    Write-Host "    status ports    - Check port availability"
    
    Write-Host "`n  repo" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Repository management (shortcut to manage-repos.ps1)"
    Write-Host "    repo list      - List all repositories"
    Write-Host "    repo clone     - Clone repositories"
    Write-Host "    repo update    - Update repositories"
    Write-Host "    repo status    - Check repository status"
    Write-Host "    repo auto-update - Auto-update repositories"
    
    Write-Host "`n  env" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Environment variable management"
    Write-Host "    env show       - Show current environment variables"
    Write-Host "    env edit       - Edit environment variables"
    Write-Host "    env reset      - Reset to default environment"
    
    Write-Host "`n  update" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Update MetaBundle components"
    
    Write-Host "`n  help" -ForegroundColor $colors.Success -NoNewline
    Write-Host " - Show this help information"
    
    Write-Host "`nEXAMPLES:" -ForegroundColor $colors.Subtitle
    Write-Host "  .\metabundle-cli.ps1 setup all" -ForegroundColor $colors.Info
    Write-Host "  .\metabundle-cli.ps1 start all" -ForegroundColor $colors.Info
    Write-Host "  .\metabundle-cli.ps1 repo clone --all" -ForegroundColor $colors.Info
    Write-Host "  .\metabundle-cli.ps1 status services" -ForegroundColor $colors.Info
    
    Write-Host "`n===================================================" -ForegroundColor $colors.Title
}

# Environment setup functions
function Setup-Environment {
    param(
        [string]$SetupType = "env"
    )
    
    Show-Banner
    
    switch ($SetupType) {
        "env" {
            Write-Host "Setting up environment variables..." -ForegroundColor $colors.Subtitle
            
            if (-not (Test-Path ".env")) {
                Write-Host "Creating .env file from template..." -ForegroundColor $colors.Info
                Copy-Item ".env.example" ".env"
                Write-Host "Created .env file. You may want to customize it with 'env edit'." -ForegroundColor $colors.Success
            } else {
                Write-Host ".env file already exists." -ForegroundColor $colors.Warning
                $decision = Read-Host "Do you want to reset to defaults? (y/N)"
                if ($decision -eq "y" -or $decision -eq "Y") {
                    Copy-Item ".env.example" ".env" -Force
                    Write-Host "Reset .env file to defaults." -ForegroundColor $colors.Success
                }
            }
        }
        
        "docker" {
            Write-Host "Setting up Docker components..." -ForegroundColor $colors.Subtitle
            
            # Check if Docker is installed and running
            try {
                docker info | Out-Null
                Write-Host "Docker is running." -ForegroundColor $colors.Success
            }
            catch {
                Write-Host "Error: Docker is not running or not installed." -ForegroundColor $colors.Error
                Write-Host "Please install Docker Desktop and start it before continuing." -ForegroundColor $colors.Warning
                return
            }
            
            Write-Host "Docker setup complete." -ForegroundColor $colors.Success
        }
        
        "all" {
            Setup-Environment -SetupType "env"
            Setup-Environment -SetupType "docker"
            
            # Clone repositories if needed
            $repoStatus = Invoke-Expression ".\manage-repos.ps1 -Action list"
            if ($repoStatus -match "\[ \]") {
                Write-Host "`nSome repositories are not cloned." -ForegroundColor $colors.Warning
                $decision = Read-Host "Do you want to clone all repositories? (Y/n)"
                if ($decision -ne "n" -and $decision -ne "N") {
                    Invoke-Expression ".\manage-repos.ps1 -Action clone -All"
                }
            }
            
            Write-Host "`nMetaBundle setup complete!" -ForegroundColor $colors.Success
        }
        
        default {
            Write-Host "Unknown setup type: $SetupType" -ForegroundColor $colors.Error
            Write-Host "Available options: env, docker, all" -ForegroundColor $colors.Warning
        }
    }
}

# Service management functions
function Start-Services {
    param(
        [string]$Service = "all"
    )
    
    Show-Banner
    
    if ($Service -eq "all") {
        Write-Host "Starting all services with Docker Compose..." -ForegroundColor $colors.Subtitle
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "All services started successfully." -ForegroundColor $colors.Success
        } else {
            Write-Host "Error starting services." -ForegroundColor $colors.Error
        }
    }
    else {
        Write-Host "Starting service: $Service..." -ForegroundColor $colors.Subtitle
        docker-compose up -d $Service
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Service $Service started successfully." -ForegroundColor $colors.Success
        } else {
            Write-Host "Error starting service $Service." -ForegroundColor $colors.Error
        }
    }
}

# Stop services function
function Stop-Services {
    param(
        [string]$Service = "all"
    )
    
    Show-Banner
    
    if ($Service -eq "all") {
        Write-Host "Stopping all services..." -ForegroundColor $colors.Subtitle
        docker-compose down
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "All services stopped successfully." -ForegroundColor $colors.Success
        } else {
            Write-Host "Error stopping services." -ForegroundColor $colors.Error
        }
    }
    else {
        Write-Host "Stopping service: $Service..." -ForegroundColor $colors.Subtitle
        docker-compose stop $Service
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Service $Service stopped successfully." -ForegroundColor $colors.Success
        } else {
            Write-Host "Error stopping service $Service." -ForegroundColor $colors.Error
        }
    }
}

# Check service status
function Check-Status {
    param(
        [string]$StatusType = "services"
    )
    
    Show-Banner
    
    switch ($StatusType) {
        "services" {
            Write-Host "Checking service status..." -ForegroundColor $colors.Subtitle
            docker-compose ps
        }
        
        "ports" {
            Write-Host "Checking port usage..." -ForegroundColor $colors.Subtitle
            
            $usedPorts = @()
            $configuredPorts = @()
            
            # Get ports from docker-compose.yml
            if (Test-Path "docker-compose.yml") {
                $composeContent = Get-Content "docker-compose.yml" -Raw
                $portMatches = [regex]::Matches($composeContent, '(\d+):(\d+)')
                
                foreach ($match in $portMatches) {
                    $hostPort = $match.Groups[1].Value
                    $configuredPorts += $hostPort
                }
                
                Write-Host "Configured ports in docker-compose.yml:" -ForegroundColor $colors.Info
                foreach ($port in ($configuredPorts | Sort-Object -Unique)) {
                    Write-Host "  - $port" -ForegroundColor $colors.Info
                }
            }
            
            # Check if ports are in use
            Write-Host "`nChecking if ports are in use..." -ForegroundColor $colors.Info
            foreach ($port in ($configuredPorts | Sort-Object -Unique)) {
                $connection = Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                
                if ($connection) {
                    Write-Host "  - Port $port: " -NoNewline -ForegroundColor $colors.Info
                    Write-Host "IN USE" -ForegroundColor $colors.Error
                    $usedPorts += $port
                } else {
                    Write-Host "  - Port $port: " -NoNewline -ForegroundColor $colors.Info
                    Write-Host "Available" -ForegroundColor $colors.Success
                }
            }
            
            if ($usedPorts.Count -gt 0) {
                Write-Host "`nSome required ports are already in use. You may need to free them before starting services." -ForegroundColor $colors.Warning
            } else {
                Write-Host "`nAll required ports are available." -ForegroundColor $colors.Success
            }
        }
        
        default {
            Write-Host "Unknown status type: $StatusType" -ForegroundColor $colors.Error
            Write-Host "Available options: services, ports" -ForegroundColor $colors.Warning
        }
    }
}

# Repository management wrapper
function Manage-Repositories {
    Show-Banner
    
    if (-not $SubCommand) {
        $SubCommand = "list"
    }
    
    $repoArgs = ""
    if ($Args.Count -gt 0) {
        if ($Args -contains "--all") {
            $repoArgs = "-All"
        } else {
            $repoArgs = "-RepoName " + $Args[0]
        }
    }
    
    # Map the CLI subcommands to manage-repos.ps1 actions
    $repoAction = switch ($SubCommand) {
        "list" { "list" }
        "clone" { "add" }    # map "clone" to "add" for submodules
        "add" { "add" }
        "update" { "update" }
        "status" { "status" }
        "init" { "init" }
        "remove" { "remove" }
        "auto-update" { "auto-update" } # Add auto-update option
        default { $SubCommand }
    }
    
    $command = ".\manage-repos.ps1 -Action $repoAction $repoArgs"
    Write-Host "Executing: $command" -ForegroundColor $colors.Info
    Invoke-Expression $command
}

# Environment variable management
function Manage-Environment {
    param(
        [string]$Action = "show"
    )
    
    Show-Banner
    
    switch ($Action) {
        "show" {
            if (Test-Path ".env") {
                Write-Host "Current environment variables (.env):" -ForegroundColor $colors.Subtitle
                $envContent = Get-Content ".env"
                foreach ($line in $envContent) {
                    # Skip empty lines and comments
                    if ($line -and -not $line.StartsWith("#")) {
                        Write-Host "  $line" -ForegroundColor $colors.Info
                    }
                }
            } else {
                Write-Host "No .env file found. Run 'setup env' to create one." -ForegroundColor $colors.Warning
            }
        }
        
        "edit" {
            if (Test-Path ".env") {
                Write-Host "Opening .env file for editing..." -ForegroundColor $colors.Subtitle
                Start-Process notepad ".env"
            } else {
                Write-Host "No .env file found. Creating from template..." -ForegroundColor $colors.Warning
                Copy-Item ".env.example" ".env"
                Start-Process notepad ".env"
            }
        }
        
        "reset" {
            Write-Host "Resetting environment variables to defaults..." -ForegroundColor $colors.Subtitle
            
            if (Test-Path ".env") {
                $decision = Read-Host "This will overwrite your current .env file. Continue? (y/N)"
                if ($decision -eq "y" -or $decision -eq "Y") {
                    Copy-Item ".env.example" ".env" -Force
                    Write-Host "Environment variables reset to defaults." -ForegroundColor $colors.Success
                } else {
                    Write-Host "Operation cancelled." -ForegroundColor $colors.Info
                }
            } else {
                Copy-Item ".env.example" ".env"
                Write-Host "Created new .env file from template." -ForegroundColor $colors.Success
            }
        }
        
        default {
            Write-Host "Unknown environment action: $Action" -ForegroundColor $colors.Error
            Write-Host "Available options: show, edit, reset" -ForegroundColor $colors.Warning
        }
    }
}

# Update MetaBundle components
function Update-MetaBundle {
    Show-Banner
    
    Write-Host "Updating MetaBundle components..." -ForegroundColor $colors.Subtitle
    
    # Update repositories
    Write-Host "`nUpdating repositories..." -ForegroundColor $colors.Info
    Invoke-Expression ".\manage-repos.ps1 -Action update -All"
    
    # Pull latest Docker images
    Write-Host "`nPulling latest Docker images..." -ForegroundColor $colors.Info
    docker-compose pull
    
    Write-Host "`nUpdate completed." -ForegroundColor $colors.Success
}

# Main command router
switch ($Command) {
    "setup" {
        if (-not $SubCommand) { $SubCommand = "env" }
        Setup-Environment -SetupType $SubCommand
    }
    
    "start" {
        if (-not $SubCommand) { $SubCommand = "all" }
        Start-Services -Service $SubCommand
    }
    
    "stop" {
        if (-not $SubCommand) { $SubCommand = "all" }
        Stop-Services -Service $SubCommand
    }
    
    "status" {
        if (-not $SubCommand) { $SubCommand = "services" }
        Check-Status -StatusType $SubCommand
    }
    
    "repo" {
        Manage-Repositories
    }
    
    "env" {
        if (-not $SubCommand) { $SubCommand = "show" }
        Manage-Environment -Action $SubCommand
    }
    
    "update" {
        Update-MetaBundle
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor $colors.Error
        Show-Help
    }
}

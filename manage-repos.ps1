# MetaBundle Repository Management Script
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("add", "update", "init", "status", "list", "remove")]
    [string]$Action = "status",
    
    [Parameter(Mandatory=$false)]
    [string]$RepoName,
    
    [Parameter(Mandatory=$false)]
    [switch]$All
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectsDir = Join-Path $root "projects"
$servicesDir = Join-Path $root "services"

# Project repositories configuration
$projectRepos = @(
    @{
        Name = "Bloomberg-Terminal"
        Url = "https://github.com/MetaBundleAutomation/Bloomberg-Terminal"
        Branch = "main"
        Type = "project"
    },
    @{
        Name = "Dashboard"
        Url = "https://github.com/MetaBundleAutomation/Dashboard"
        Branch = "main"
        Type = "project"
    },
    @{
        Name = "DataProcessor"
        Url = "https://github.com/MetaBundleAutomation/Data-Processor"
        Branch = "main"
        Type = "project"
    },
    @{
        Name = "Scraper"
        Url = "https://github.com/MetaBundleAutomation/Scraper-Setup"
        Branch = "master"
        Type = "project"
    }
)

# Service repositories configuration
$serviceRepos = @(
    @{
        Name = "nginx"
        Url = "https://github.com/MetaBundleAutomation/nginx-config"
        Branch = "main"
        Type = "service"
    }
)

# Combine all repositories
$repos = $projectRepos + $serviceRepos

# Ensure directories exist
if (-not (Test-Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
}
if (-not (Test-Path $servicesDir)) {
    New-Item -ItemType Directory -Path $servicesDir | Out-Null
}

# Function to get repository directory
function Get-RepoDirectory {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    if ($Repository.Type -eq "project") {
        return Join-Path $projectsDir $Repository.Name
    } else {
        return Join-Path $servicesDir $Repository.Name
    }
}

# Function to get submodule path relative to root
function Get-SubmodulePath {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    if ($Repository.Type -eq "project") {
        return "projects/$($Repository.Name)"
    } else {
        return "services/$($Repository.Name)"
    }
}

# Function to add a repository as a submodule
function Add-Submodule {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $submodulePath = Get-SubmodulePath -Repository $Repository
    $repoPath = Get-RepoDirectory -Repository $Repository
    
    if (Test-Path $repoPath) {
        # Check if it's already a submodule
        $gitModules = Get-Content -Path ".gitmodules" -ErrorAction SilentlyContinue
        if ($gitModules -match $submodulePath) {
            Write-Host "Submodule $($Repository.Name) already exists at $submodulePath" -ForegroundColor Yellow
            return
        } else {
            Write-Host "Directory $($Repository.Name) exists but is not a submodule." -ForegroundColor Yellow
            $decision = Read-Host "Do you want to replace it with a submodule? (y/N)"
            if ($decision -ne "y" -and $decision -ne "Y") {
                Write-Host "Operation cancelled." -ForegroundColor Yellow
                return
            }
            Remove-Item -Path $repoPath -Recurse -Force
        }
    }
    
    Write-Host "Adding submodule $($Repository.Name) from $($Repository.Url)..." -ForegroundColor Cyan
    git submodule add -f -b $Repository.Branch $Repository.Url $submodulePath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to add submodule $($Repository.Name)" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Successfully added submodule $($Repository.Name) to $submodulePath" -ForegroundColor Green
    
    # Create REPOSITORY.md if it doesn't exist
    $repoMdPath = Join-Path $repoPath "REPOSITORY.md"
    if (-not (Test-Path $repoMdPath)) {
        Copy-Item -Path (Join-Path $root "REPOSITORY.md.template") -Destination $repoMdPath
        Write-Host "Created REPOSITORY.md template in $($Repository.Name)" -ForegroundColor Green
        
        # Commit the change within the submodule
        Push-Location $repoPath
        try {
            git add REPOSITORY.md
            git commit -m "Add REPOSITORY.md template"
            git push origin $Repository.Branch
        } catch {
            Write-Host "Could not commit REPOSITORY.md to the submodule." -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    }
    
    return $true
}

# Function to update a submodule
function Update-Submodule {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $submodulePath = Get-SubmodulePath -Repository $Repository
    $repoPath = Get-RepoDirectory -Repository $Repository
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "Submodule $($Repository.Name) does not exist. Add it first." -ForegroundColor Yellow
        return $false
    }
    
    # Check if it's a submodule
    $gitModules = Get-Content -Path ".gitmodules" -ErrorAction SilentlyContinue
    if (-not ($gitModules -match $submodulePath)) {
        Write-Host "Directory $($Repository.Name) exists but is not a submodule." -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "Updating submodule $($Repository.Name)..." -ForegroundColor Cyan
    
    # Update the submodule
    git submodule update --remote --merge $submodulePath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to update submodule $($Repository.Name)" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Successfully updated submodule $($Repository.Name)" -ForegroundColor Green
    return $true
}

# Function to initialize submodules
function Initialize-Submodules {
    Write-Host "Initializing all submodules..." -ForegroundColor Cyan
    
    # Check if .gitmodules exists
    if (-not (Test-Path ".gitmodules")) {
        Write-Host "No submodules defined yet. Use 'add' command to add submodules." -ForegroundColor Yellow
        return
    }
    
    # Initialize and update all submodules
    git submodule init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to initialize submodules" -ForegroundColor Red
        return
    }
    
    git submodule update
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to update submodules" -ForegroundColor Red
        return
    }
    
    Write-Host "All submodules initialized successfully." -ForegroundColor Green
}

# Function to remove a submodule
function Remove-Submodule {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $submodulePath = Get-SubmodulePath -Repository $Repository
    
    Write-Host "Removing submodule $($Repository.Name)..." -ForegroundColor Cyan
    
    # De-initialize the submodule
    git submodule deinit -f $submodulePath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to deinitialize submodule $($Repository.Name)" -ForegroundColor Red
        return $false
    }
    
    # Remove from .git/modules
    git rm -f $submodulePath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to remove submodule $($Repository.Name) from git" -ForegroundColor Red
        return $false
    }
    
    # Remove from .git/modules
    $gitModulesPath = Join-Path (Join-Path $root ".git") "modules"
    $submoduleGitPath = Join-Path $gitModulesPath $submodulePath
    if (Test-Path $submoduleGitPath) {
        Remove-Item -Path $submoduleGitPath -Recurse -Force
    }
    
    Write-Host "Successfully removed submodule $($Repository.Name)" -ForegroundColor Green
    return $true
}

# Function to check submodule status
function Get-SubmoduleStatus {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $submodulePath = Get-SubmodulePath -Repository $Repository
    $repoPath = Get-RepoDirectory -Repository $Repository
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Not added" -ForegroundColor Red
        return
    }
    
    # Check if it's a submodule
    $gitModules = Get-Content -Path ".gitmodules" -ErrorAction SilentlyContinue
    if (-not ($gitModules -match $submodulePath)) {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Directory exists but is not a submodule" -ForegroundColor Yellow
        return
    }
    
    # Get submodule status
    $status = git submodule status $submodulePath
    
    if ($status -match "^\+") {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Needs update (commit changed)" -ForegroundColor Yellow
    } elseif ($status -match "^-") {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Not initialized" -ForegroundColor Red
    } elseif ($status -match "^U") {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Merge conflicts" -ForegroundColor Red
    } else {
        # Get current branch
        Push-Location $repoPath
        try {
            $branch = git rev-parse --abbrev-ref HEAD
            Write-Host "$($Repository.Name) ($($Repository.Type)): Up to date (branch: $branch)" -ForegroundColor Green
        } catch {
            Write-Host "$($Repository.Name) ($($Repository.Type)): Error checking branch" -ForegroundColor Red
        } finally {
            Pop-Location
        }
    }
}

# List repositories
function List-Repositories {
    Write-Host "Available repositories:" -ForegroundColor Cyan
    
    # Check if .gitmodules exists
    $hasGitModules = Test-Path ".gitmodules"
    
    Write-Host "`nProjects:" -ForegroundColor Magenta
    foreach ($repo in $projectRepos) {
        $repoPath = Get-RepoDirectory -Repository $repo
        $submodulePath = Get-SubmodulePath -Repository $repo
        $exists = Test-Path $repoPath
        $isSubmodule = $hasGitModules -and ((Get-Content -Path ".gitmodules" -ErrorAction SilentlyContinue) -match $submodulePath)
        
        if ($exists -and $isSubmodule) {
            Write-Host "  [X] $($repo.Name) (submodule)" -ForegroundColor Green
        } elseif ($exists) {
            Write-Host "  [?] $($repo.Name) (directory exists but not a submodule)" -ForegroundColor Yellow
        } else {
            Write-Host "  [ ] $($repo.Name)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nServices:" -ForegroundColor Magenta
    foreach ($repo in $serviceRepos) {
        $repoPath = Get-RepoDirectory -Repository $repo
        $submodulePath = Get-SubmodulePath -Repository $repo
        $exists = Test-Path $repoPath
        $isSubmodule = $hasGitModules -and ((Get-Content -Path ".gitmodules" -ErrorAction SilentlyContinue) -match $submodulePath)
        
        if ($exists -and $isSubmodule) {
            Write-Host "  [X] $($repo.Name) (submodule)" -ForegroundColor Green
        } elseif ($exists) {
            Write-Host "  [?] $($repo.Name) (directory exists but not a submodule)" -ForegroundColor Yellow
        } else {
            Write-Host "  [ ] $($repo.Name)" -ForegroundColor Gray
        }
    }
}

# Main script logic
switch ($Action) {
    "add" {
        if ($All) {
            foreach ($repo in $repos) {
                Add-Submodule -Repository $repo
            }
        } elseif ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Add-Submodule -Repository $repository
            } else {
                Write-Host "Repository $RepoName not found in configuration" -ForegroundColor Red
            }
        } else {
            Write-Host "Please specify a repository name or use -All" -ForegroundColor Yellow
        }
    }
    
    "update" {
        if ($All) {
            foreach ($repo in $repos) {
                Update-Submodule -Repository $repo
            }
        } elseif ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Update-Submodule -Repository $repository
            } else {
                Write-Host "Repository $RepoName not found in configuration" -ForegroundColor Red
            }
        } else {
            Write-Host "Please specify a repository name or use -All" -ForegroundColor Yellow
        }
    }
    
    "init" {
        Initialize-Submodules
    }
    
    "status" {
        if ($All -or (-not $RepoName)) {
            foreach ($repo in $repos) {
                Get-SubmoduleStatus -Repository $repo
            }
        } elseif ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Get-SubmoduleStatus -Repository $repository
            } else {
                Write-Host "Repository $RepoName not found in configuration" -ForegroundColor Red
            }
        }
    }
    
    "list" {
        List-Repositories
    }
    
    "remove" {
        if ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Remove-Submodule -Repository $repository
            } else {
                Write-Host "Repository $RepoName not found in configuration" -ForegroundColor Red
            }
        } else {
            Write-Host "Please specify a repository name to remove" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nMetaBundle repository management completed" -ForegroundColor Cyan

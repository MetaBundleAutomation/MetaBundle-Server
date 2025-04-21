# MetaBundle Repository Management Script
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("clone", "update", "status", "list")]
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
        Branch = "main"
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

# Function to clone a repository
function Clone-Repository {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $repoPath = Get-RepoDirectory -Repository $Repository
    
    if (Test-Path $repoPath) {
        Write-Host "Repository $($Repository.Name) already exists at $repoPath" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Cloning $($Repository.Name) from $($Repository.Url)..." -ForegroundColor Cyan
    git clone --branch $Repository.Branch $Repository.Url $repoPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to clone $($Repository.Name)" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Successfully cloned $($Repository.Name) to $repoPath" -ForegroundColor Green
    
    # Create REPOSITORY.md if it doesn't exist
    $repoMdPath = Join-Path $repoPath "REPOSITORY.md"
    if (-not (Test-Path $repoMdPath)) {
        Copy-Item -Path (Join-Path $root "REPOSITORY.md.template") -Destination $repoMdPath
        Write-Host "Created REPOSITORY.md template in $($Repository.Name)" -ForegroundColor Green
    }
    
    return $true
}

# Function to update a repository
function Update-Repository {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $repoPath = Get-RepoDirectory -Repository $Repository
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "Repository $($Repository.Name) does not exist. Clone it first." -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "Updating $($Repository.Name)..." -ForegroundColor Cyan
    Push-Location $repoPath
    
    try {
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to update $($Repository.Name)" -ForegroundColor Red
            return $false
        }
        
        Write-Host "Successfully updated $($Repository.Name)" -ForegroundColor Green
        return $true
    }
    finally {
        Pop-Location
    }
}

# Function to check repository status
function Get-RepositoryStatus {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Repository
    )
    
    $repoPath = Get-RepoDirectory -Repository $Repository
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Not cloned" -ForegroundColor Red
        return
    }
    
    Push-Location $repoPath
    
    try {
        $status = git status --porcelain
        $branch = git rev-parse --abbrev-ref HEAD
        
        if ($status) {
            Write-Host "$($Repository.Name) ($($Repository.Type)): Modified (branch: $branch)" -ForegroundColor Yellow
        } else {
            Write-Host "$($Repository.Name) ($($Repository.Type)): Clean (branch: $branch)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "$($Repository.Name) ($($Repository.Type)): Error checking status" -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
}

# List repositories
function List-Repositories {
    Write-Host "Available repositories:" -ForegroundColor Cyan
    
    Write-Host "`nProjects:" -ForegroundColor Magenta
    foreach ($repo in $projectRepos) {
        $repoPath = Get-RepoDirectory -Repository $repo
        $exists = Test-Path $repoPath
        
        if ($exists) {
            Write-Host "  [X] $($repo.Name)" -ForegroundColor Green
        } else {
            Write-Host "  [ ] $($repo.Name)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nServices:" -ForegroundColor Magenta
    foreach ($repo in $serviceRepos) {
        $repoPath = Get-RepoDirectory -Repository $repo
        $exists = Test-Path $repoPath
        
        if ($exists) {
            Write-Host "  [X] $($repo.Name)" -ForegroundColor Green
        } else {
            Write-Host "  [ ] $($repo.Name)" -ForegroundColor Gray
        }
    }
}

# Main script logic
switch ($Action) {
    "clone" {
        if ($All) {
            foreach ($repo in $repos) {
                Clone-Repository -Repository $repo
            }
        } elseif ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Clone-Repository -Repository $repository
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
                Update-Repository -Repository $repo
            }
        } elseif ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Update-Repository -Repository $repository
            } else {
                Write-Host "Repository $RepoName not found in configuration" -ForegroundColor Red
            }
        } else {
            Write-Host "Please specify a repository name or use -All" -ForegroundColor Yellow
        }
    }
    
    "status" {
        if ($All -or (-not $RepoName)) {
            foreach ($repo in $repos) {
                Get-RepositoryStatus -Repository $repo
            }
        } elseif ($RepoName) {
            $repository = $repos | Where-Object { $_.Name -eq $RepoName }
            if ($repository) {
                Get-RepositoryStatus -Repository $repository
            } else {
                Write-Host "Repository $RepoName not found in configuration" -ForegroundColor Red
            }
        }
    }
    
    "list" {
        List-Repositories
    }
}

Write-Host "`nMetaBundle repository management completed" -ForegroundColor Cyan

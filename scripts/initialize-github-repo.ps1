# Initialize GitHub Repository for MetaBundle Server
# This script will set up your local git repository and push to GitHub

$ErrorActionPreference = "Stop"
$repoUrl = "https://github.com/MetaBundleAutomation/MetaBundle-Server.git"

Write-Host "`n=== Setting up MetaBundle Server GitHub Repository ===`n" -ForegroundColor Cyan

# Check if git is already initialized
if (Test-Path ".git") {
    Write-Host "Git repository already initialized." -ForegroundColor Yellow
    
    # Check if remote exists
    $remotes = git remote -v
    if ($remotes -match "origin") {
        Write-Host "Remote 'origin' already exists. Updating URL..." -ForegroundColor Yellow
        git remote set-url origin $repoUrl
    } else {
        Write-Host "Adding remote 'origin'..." -ForegroundColor Green
        git remote add origin $repoUrl
    }
} else {
    # Initialize git repository
    Write-Host "Initializing git repository..." -ForegroundColor Green
    git init
    
    # Add remote
    Write-Host "Adding remote 'origin'..." -ForegroundColor Green
    git remote add origin $repoUrl
}

# Stage all files
Write-Host "`nStaging files..." -ForegroundColor Green
git add .

# Initial commit
Write-Host "Creating initial commit..." -ForegroundColor Green
git commit -m "Initial commit of MetaBundle Server infrastructure"

# Push to GitHub
$pushChoice = Read-Host "`nDo you want to push to GitHub now? (Y/n)"
if ($pushChoice -ne "n" -and $pushChoice -ne "N") {
    Write-Host "Pushing to GitHub..." -ForegroundColor Green
    git push -u origin main
    
    Write-Host "`n=== Setup Complete ===`n" -ForegroundColor Cyan
    Write-Host "Your MetaBundle Server repository has been initialized and pushed to GitHub." -ForegroundColor Green
    Write-Host "Repository URL: $repoUrl" -ForegroundColor Cyan
} else {
    Write-Host "`n=== Setup Partially Complete ===`n" -ForegroundColor Yellow
    Write-Host "Your local repository has been initialized but not pushed to GitHub." -ForegroundColor Yellow
    Write-Host "To push later, run: git push -u origin main" -ForegroundColor Cyan
}

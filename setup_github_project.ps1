#!/usr/bin/env powershell
# GitHub Project SSH Key Setup Script
# 为GitHub项目配置专门的SSH密钥

param(
    [string]$Action = "setup",
    [string]$ProjectName = "",
    [string]$RepoUrl = ""
)

# Color output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

function Show-Help {
    Write-Info "Usage:"
    Write-Info "  .\setup_github_project.ps1 -Action setup -ProjectName myproject -RepoUrl git@github.com:user/repo.git"
    Write-Info ""
    Write-Info "Actions:"
    Write-Info "  setup      - Create new key pair for project"
    Write-Info "  configure  - Configure existing project to use specific key"
    Write-Info "  test       - Test SSH connection"
    Write-Info "  list       - List all SSH keys"
    Write-Info ""
    Write-Info "Examples:"
    Write-Info "  # Create new key for project"
    Write-Info "  .\setup_github_project.ps1 -Action setup -ProjectName my-awesome-repo"
    Write-Info ""
    Write-Info "  # Configure project directory"
    Write-Info "  cd C:\path\to\project"
    Write-Info "  .\setup_github_project.ps1 -Action configure -ProjectName my-awesome-repo -RepoUrl git@github.com:username/repo.git"
}

function New-ProjectSSHKey {
    param([string]$ProjectName)
    
    if (-not $ProjectName) {
        Write-Error "[ERROR] Project name required"
        return $false
    }
    
    $keyPath = "$env:USERPROFILE\.ssh\github_$ProjectName"
    
    # Check if key already exists
    if (Test-Path "$keyPath.pub") {
        Write-Warning "[WARN] Key already exists for '$ProjectName'"
        Write-Info "Key path: $keyPath"
        return $true
    }
    
    Write-Info "Generating new SSH key pair for project: $ProjectName"
    
    # Generate new key
    ssh-keygen -t rsa -b 4096 -f $keyPath -N "" -C "github-$ProjectName"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[OK] Key pair generated successfully"
        Write-Info "Private key: $keyPath"
        Write-Info "Public key: $keyPath.pub"
        Write-Info ""
        Write-Info "Public key content:"
        Write-Info "-------------------------------------------"
        $pubKey = Get-Content "$keyPath.pub"
        Write-Host $pubKey -ForegroundColor Yellow
        Write-Info "-------------------------------------------"
        Write-Info ""
        
        # Copy to clipboard
        $pubKey | Set-Clipboard
        Write-Success "[OK] Public key copied to clipboard"
        Write-Info ""
        Write-Warning "Next steps:"
        Write-Info "1. Visit https://github.com/settings/keys"
        Write-Info "2. Click 'New SSH key'"
        Write-Info "3. Title: github_$ProjectName"
        Write-Info "4. Paste the public key (already in clipboard)"
        Write-Info "5. Click 'Add SSH key'"
        Write-Info ""
        
        return $true
    }
    else {
        Write-Error "[ERROR] Failed to generate SSH key"
        return $false
    }
}

function Set-ProjectSSHConfig {
    param([string]$ProjectName)
    
    if (-not $ProjectName) {
        Write-Error "[ERROR] Project name required"
        return $false
    }
    
    $configFile = "$env:USERPROFILE\.ssh\config"
    $hostName = "github-$ProjectName"
    
    # Create config directory if not exists
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir | Out-Null
    }
    
    # Check if config already has this host
    if ((Test-Path $configFile) -and (Select-String -Path $configFile -Pattern "Host $hostName" -ErrorAction SilentlyContinue)) {
        Write-Warning "[WARN] Host '$hostName' already exists in SSH config"
        return $true
    }
    
    # Create SSH config entry
    $keyPath = "$env:USERPROFILE\.ssh\github_$ProjectName"
    
    if (-not (Test-Path "$keyPath.pub")) {
        Write-Error "[ERROR] Private key not found: $keyPath"
        Write-Info "Run: .\setup_github_project.ps1 -Action setup -ProjectName $ProjectName"
        return $false
    }
    
    $configEntry = @"

Host $hostName
    User git
    HostName github.com
    IdentityFile $keyPath

"@
    
    # Append to config file
    if (-not (Test-Path $configFile)) {
        $configEntry | Set-Content $configFile -Encoding UTF8
    }
    else {
        $configEntry | Add-Content $configFile -Encoding UTF8
    }
    
    Write-Success "[OK] SSH config updated"
    Write-Info "Host: $hostName"
    Write-Info "Key: $keyPath"
    
    return $true
}

function Configure-ProjectGit {
    param(
        [string]$ProjectName,
        [string]$RepoUrl
    )
    
    if (-not (Test-Path ".git")) {
        Write-Error "[ERROR] Not in a git repository"
        Write-Info "Run this command in your project directory"
        return $false
    }
    
    if (-not $RepoUrl) {
        Write-Error "[ERROR] Repository URL required (e.g., git@github-$ProjectName:user/repo.git)"
        return $false
    }
    
    # Configure git remote
    Write-Info "Configuring git remote..."
    
    # Remove existing origin if present
    git remote remove origin 2>$null
    
    # Add new origin with specific host
    git remote add origin $RepoUrl
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[OK] Git remote configured"
        git remote -v
        
        # Optionally configure project-specific git user
        Write-Info ""
        Write-Warning "Configure project-specific Git user? (optional)"
        Write-Info "This will set user.name and user.email only for this project"
        
        $response = Read-Host "Enter 'y' to configure, or press Enter to skip"
        
        if ($response -eq 'y') {
            $name = Read-Host "Git user name"
            $email = Read-Host "Git user email"
            
            git config user.name $name
            git config user.email $email
            
            Write-Success "[OK] Project-specific git config set"
        }
        
        return $true
    }
    else {
        Write-Error "[ERROR] Failed to configure git remote"
        return $false
    }
}

function Test-SSHConnection {
    param([string]$ProjectName)
    
    if (-not $ProjectName) {
        Write-Error "[ERROR] Project name required"
        return $false
    }
    
    $hostName = "github-$ProjectName"
    
    Write-Info "Testing SSH connection to $hostName..."
    Write-Info ""
    
    ssh -T git@$hostName 2>&1
    
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
        Write-Success "[OK] SSH connection successful"
        return $true
    }
    else {
        Write-Error "[ERROR] SSH connection failed"
        return $false
    }
}

function List-AllKeys {
    Write-Info "SSH Keys in ~/.ssh:"
    Write-Info ""
    
    Get-ChildItem "$env:USERPROFILE\.ssh" -Filter "*_key.pub" | ForEach-Object {
        $name = $_.BaseName -replace "_key$"
        Write-Host "  - $name" -ForegroundColor Cyan
    }
    
    Write-Info ""
    Write-Info "SSH Config Hosts:"
    Write-Info ""
    
    $configFile = "$env:USERPROFILE\.ssh\config"
    if (Test-Path $configFile) {
        Select-String -Path $configFile -Pattern "^Host " | ForEach-Object {
            Write-Host "  " + $_.Line -ForegroundColor Cyan
        }
    }
    else {
        Write-Warning "No SSH config file found"
    }
}

# Main script logic
switch ($Action) {
    "setup" {
        if (-not $ProjectName) {
            $ProjectName = Read-Host "Enter project name (e.g., my-awesome-repo)"
        }
        
        Write-Info "Setting up SSH key for project: $ProjectName"
        Write-Info ""
        
        # Generate key
        if (New-ProjectSSHKey $ProjectName) {
            # Update SSH config
            if (Set-ProjectSSHConfig $ProjectName) {
                Write-Success "[OK] Project SSH setup complete!"
                Write-Info ""
                Write-Info "Next step: Configure your Git repository"
                Write-Info "Usage: cd C:\path\to\project"
                Write-Info "       .\setup_github_project.ps1 -Action configure -ProjectName $ProjectName -RepoUrl git@github-$ProjectName:username/repo.git"
            }
        }
    }
    
    "configure" {
        if (-not $ProjectName -or -not $RepoUrl) {
            $ProjectName = Read-Host "Enter project name"
            $RepoUrl = Read-Host "Enter repository URL (e.g., git@github-$ProjectName:username/repo.git)"
        }
        
        Write-Info "Configuring git repository..."
        Write-Info ""
        
        if (Configure-ProjectGit $ProjectName $RepoUrl) {
            Write-Success "[OK] Project configured successfully!"
        }
    }
    
    "test" {
        if (-not $ProjectName) {
            $ProjectName = Read-Host "Enter project name"
        }
        
        Test-SSHConnection $ProjectName
    }
    
    "list" {
        List-AllKeys
    }
    
    default {
        Show-Help
    }
}

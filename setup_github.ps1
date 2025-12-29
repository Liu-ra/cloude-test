# GitHub SSH Key Setup - Automated Script

param(
    [string]$PublicKeyPath = "$env:USERPROFILE\.ssh\aliyun_key.pub"
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

Write-Info "=========================================="
Write-Info "GitHub SSH Key Configuration"
Write-Info "=========================================="
Write-Info ""

# Check if public key exists
if (-not (Test-Path $PublicKeyPath)) {
    Write-Error "[ERROR] Public key not found: $PublicKeyPath"
    exit 1
}

Write-Success "[OK] Public key file found"

# Read public key content
$publicKey = Get-Content $PublicKeyPath
Write-Info ""
Write-Info "Your SSH Public Key (copy this content):"
Write-Info "-------------------------------------------"
Write-Host $publicKey -ForegroundColor Yellow
Write-Info "-------------------------------------------"
Write-Info ""

# Copy to clipboard
$publicKey | Set-Clipboard
Write-Success "[OK] Public key copied to clipboard"
Write-Info ""

# GitHub steps
Write-Warning "STEPS: GitHub Configuration (Manual):"
Write-Info ""
Write-Info "1. Open browser: https://github.com/settings/keys"
Write-Info ""
Write-Info "2. In GitHub:"
Write-Info "   - Click avatar (top right) -> Settings"
Write-Info "   - Click 'SSH and GPG keys'"
Write-Info "   - Click 'New SSH key'"
Write-Info ""
Write-Info "3. Fill the form:"
Write-Info "   - Title: 'Aliyun Server SSH Key' (or any description)"
Write-Info "   - Key type: Authentication Key"
Write-Info "   - Key: Paste the public key content above"
Write-Info ""
Write-Info "4. Click 'Add SSH key'"
Write-Info ""
Write-Info "5. May need to verify GitHub password"
Write-Info ""

# Open GitHub settings page
Write-Info "Opening GitHub SSH Key Settings page..."
Start-Process "https://github.com/settings/keys"

Write-Info ""
Write-Info "Waiting 3 seconds..."
Start-Sleep -Seconds 3

Write-Info ""
Write-Success "[OK] Please follow the steps in the browser to add SSH key"
Write-Info ""

# Test connection
Write-Info "Testing GitHub SSH connection in 10 seconds..."
Start-Sleep -Seconds 10

Write-Info ""
Write-Info "Testing GitHub connection..."
ssh -T git@github.com 2>&1

Write-Info ""
Write-Success "[OK] Configuration complete!"

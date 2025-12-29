# 私钥配置自动化脚本
# 功能: 一键配置SSH私钥、Agent和Git

param(
    [ValidateSet('setup', 'test', 'info', 'cleanup')]
    [string]$Action = 'setup',
    
    [string]$PrivateKeyPath = "C:\Users\刘露霆\.ssh\aliyun_key",
    [string]$ServerIP = "123.56.84.70"
)

$ErrorActionPreference = 'Continue'

# 颜色输出
function Write-Success {
    Write-Host "[✓]" -ForegroundColor Green -NoNewline
    Write-Host " $args"
}

function Write-Error {
    Write-Host "[✗]" -ForegroundColor Red -NoNewline
    Write-Host " $args"
}

function Write-Info {
    Write-Host "[ℹ]" -ForegroundColor Cyan -NoNewline
    Write-Host " $args"
}

function Write-Step {
    Write-Host "[→]" -ForegroundColor Yellow -NoNewline
    Write-Host " $args"
}

# 主函数
function Setup-PrivateKey {
    Write-Host "`n" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "          私钥配置 - 自动化脚本" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Green
    
    # 第1步: 验证私钥
    Write-Step "验证私钥文件..."
    if (-not (Test-Path $PrivateKeyPath)) {
        Write-Error "私钥文件不存在: $PrivateKeyPath"
        exit 1
    }
    Write-Success "私钥文件存在"
    
    # 第2步: 创建SSH config
    Write-Step "配置SSH config文件..."
    $sshDir = Split-Path $PrivateKeyPath
    $configPath = Join-Path $sshDir "config"
    
    $configContent = @"
Host aliyun
    HostName $ServerIP
    User root
    IdentityFile $PrivateKeyPath
    Port 22
    StrictHostKeyChecking accept-new
    UserKnownHostsFile $(Join-Path $sshDir 'known_hosts')

Host github.com
    HostName github.com
    User git
    IdentityFile $PrivateKeyPath
    Port 22
    StrictHostKeyChecking accept-new
"@
    
    $configContent | Set-Content $configPath -Encoding UTF8
    Write-Success "SSH config已创建: $configPath"
    
    # 第3步: 启动SSH Agent
    Write-Step "启动SSH Agent..."
    try {
        $agent = Get-Service ssh-agent -ErrorAction Stop
        if ($agent.Status -ne 'Running') {
            Start-Service ssh-agent
            Write-Success "SSH Agent已启动"
        } else {
            Write-Success "SSH Agent已在运行"
        }
    } catch {
        Write-Error "SSH Agent启动失败: $_"
        Write-Info "请在管理员权限下运行此脚本"
    }
    
    # 第4步: 添加私钥到Agent
    Write-Step "添加私钥到Agent..."
    $addKeyOutput = ssh-add $PrivateKeyPath 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "私钥已添加到Agent"
    } else {
        Write-Info "私钥添加结果: $addKeyOutput"
    }
    
    # 第5步: 验证Agent中的密钥
    Write-Step "验证Agent中的密钥..."
    $keys = ssh-add -l 2>&1
    if ($keys -match "4096") {
        Write-Success "密钥已在Agent中: $(($keys | Select-Object -First 1).Substring(0, 60))..."
    } else {
        Write-Info "Agent密钥列表: $keys"
    }
    
    # 第6步: 配置Git（可选）
    Write-Step "配置Git用户信息..."
    Write-Info "请输入Git用户名 (默认: claude):"
    $gitName = Read-Host
    if ([string]::IsNullOrWhiteSpace($gitName)) { $gitName = "claude" }
    
    Write-Info "请输入Git邮箱 (默认: claude@example.com):"
    $gitEmail = Read-Host
    if ([string]::IsNullOrWhiteSpace($gitEmail)) { $gitEmail = "claude@example.com" }
    
    git config --global user.name $gitName
    git config --global user.email $gitEmail
    Write-Success "Git配置完成: $gitName <$gitEmail>"
    
    # 完成
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Success "私钥配置完成！"
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Green
    
    Write-Info "下一步: 运行 .\private_key_config.ps1 -Action test 测试连接"
}

function Test-Connection {
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "          连接测试" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
    
    # 测试SSH Agent
    Write-Step "检查SSH Agent..."
    $keys = ssh-add -l 2>&1
    if ($keys -match "4096|3072|2048") {
        Write-Success "SSH Agent中有密钥"
        Write-Info $keys
    } else {
        Write-Error "SSH Agent中没有密钥"
    }
    
    # 测试SSH连接
    Write-Step "测试SSH连接到阿里云..."
    Write-Info "运行命令: ssh aliyun echo 'SSH连接成功'"
    $sshResult = ssh aliyun "echo 'SSH连接成功'" 2>&1
    
    if ($sshResult -match "成功|命令|echo") {
        Write-Success "SSH连接成功！"
        Write-Info $sshResult
    } else {
        Write-Error "SSH连接失败"
        Write-Info "输出: $sshResult"
        Write-Info "尝试运行: ssh -vvv aliyun 进行详细调试"
    }
    
    # 测试Git
    Write-Step "检查Git配置..."
    $gitName = git config --global user.name 2>&1
    $gitEmail = git config --global user.email 2>&1
    
    if ([string]::IsNullOrWhiteSpace($gitName)) {
        Write-Error "Git用户名未配置"
    } else {
        Write-Success "Git用户: $gitName <$gitEmail>"
    }
    
    Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Show-Info {
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "          配置信息" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
    
    Write-Info "私钥配置路径:"
    Write-Host "  $PrivateKeyPath" -ForegroundColor Gray
    
    $sshDir = Split-Path $PrivateKeyPath
    Write-Info "SSH目录:"
    Write-Host "  $sshDir" -ForegroundColor Gray
    
    Write-Info "配置文件:"
    Write-Host "  $(Join-Path $sshDir 'config')" -ForegroundColor Gray
    
    Write-Info "SSH Agent状态:"
    $agent = Get-Service ssh-agent -ErrorAction SilentlyContinue
    if ($agent.Status -eq 'Running') {
        Write-Host "  ✓ 运行中" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 未运行" -ForegroundColor Red
    }
    
    Write-Info "Agent中的密钥:"
    ssh-add -l 2>&1 | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    
    Write-Info "Git配置:"
    Write-Host "  用户名: $(git config --global user.name)" -ForegroundColor Gray
    Write-Host "  邮箱: $(git config --global user.email)" -ForegroundColor Gray
    
    Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Cleanup {
    Write-Host "`n" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "          清理SSH Agent密钥" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Yellow
    
    Write-Step "移除所有Agent中的密钥..."
    ssh-add -D 2>&1
    Write-Success "已清理"
    
    Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Yellow
}

# 主程序
switch ($Action) {
    'setup' { Setup-PrivateKey }
    'test' { Test-Connection }
    'info' { Show-Info }
    'cleanup' { Cleanup }
    default {
        Write-Error "未知操作: $Action"
        Write-Info "可用操作:"
        Write-Host "  setup   - 配置私钥（默认）" -ForegroundColor Gray
        Write-Host "  test    - 测试连接" -ForegroundColor Gray
        Write-Host "  info    - 显示配置信息" -ForegroundColor Gray
        Write-Host "  cleanup - 清理Agent中的密钥" -ForegroundColor Gray
    }
}

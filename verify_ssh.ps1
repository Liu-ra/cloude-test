# SSH连接验证脚本

function Write-Success { Write-Host "[✓]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Fail { Write-Host "[✗]" -ForegroundColor Red -NoNewline; Write-Host " $args" }
function Write-Info { Write-Host "[ℹ]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }
function Write-Warning { Write-Host "[⚠]" -ForegroundColor Yellow -NoNewline; Write-Host " $args" }

Write-Info "=========================================="
Write-Info "SSH连接验证工具"
Write-Info "=========================================="
Write-Info ""

# 检查SSH工具
Write-Info "检查SSH工具..."
$sshPath = Get-Command ssh -ErrorAction SilentlyContinue
if ($null -eq $sshPath) {
    Write-Fail "SSH客户端未找到"
    exit 1
} else {
    Write-Success "SSH客户端已安装: $($sshPath.Source)"
}

Write-Info ""

# 检查密钥文件
Write-Info "检查密钥文件..."
$keyPath = "$env:USERPROFILE\.ssh\aliyun_key"
$pubKeyPath = "$env:USERPROFILE\.ssh\aliyun_key.pub"

if (Test-Path $keyPath) {
    Write-Success "私钥文件存在: $keyPath"
} else {
    Write-Fail "私钥文件不存在: $keyPath"
}

if (Test-Path $pubKeyPath) {
    Write-Success "公钥文件存在: $pubKeyPath"
} else {
    Write-Fail "公钥文件不存在: $pubKeyPath"
}

Write-Info ""

# 检查SSH config
Write-Info "检查SSH配置文件..."
$sshConfigPath = "$env:USERPROFILE\.ssh\config"
if (Test-Path $sshConfigPath) {
    Write-Success "SSH配置文件存在"
    Write-Info "配置内容:"
    Get-Content $sshConfigPath | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Warning "SSH配置文件不存在，建议创建: $sshConfigPath"
}

Write-Info ""

# 测试阿里云连接
Write-Info "测试阿里云服务器连接..."
Write-Info "地址: 123.56.84.70"
Write-Info "用户: root"
Write-Info ""
Write-Info "执行命令: ssh -i $keyPath root@123.56.84.70 'echo SSH Connection Successful'"
Write-Info ""

try {
    $result = ssh -i $keyPath root@123.56.84.70 "echo 'SSH Connection Successful'" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "阿里云连接成功"
        Write-Info "服务器响应: $result"
    } else {
        Write-Fail "阿里云连接失败"
        Write-Info "错误信息: $result"
    }
} catch {
    Write-Fail "阿里云连接异常: $_"
}

Write-Info ""

# 测试GitHub连接
Write-Info "测试GitHub连接..."
Write-Info "执行命令: ssh -T git@github.com"
Write-Info ""

try {
    $result = ssh -T git@github.com 2>&1
    
    if ($result -match "successfully authenticated") {
        Write-Success "GitHub连接成功"
        Write-Info "响应: $result"
    } else {
        Write-Fail "GitHub连接失败"
        Write-Info "响应: $result"
    }
} catch {
    Write-Fail "GitHub连接异常: $_"
}

Write-Info ""
Write-Info "=========================================="
Write-Info "验证完成"
Write-Info "=========================================="

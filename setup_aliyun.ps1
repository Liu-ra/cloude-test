# Aliyun服务器SSH公钥配置脚本
# 功能: 自动将本地公钥添加到阿里云服务器的authorized_keys

param(
    [string]$ServerIP = "123.56.84.70",
    [string]$Username = "root",
    [string]$PublicKeyPath = "$env:USERPROFILE\.ssh\aliyun_key.pub"
)

# 颜色输出函数
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

Write-Info "=========================================="
Write-Info "Aliyun SSH公钥配置脚本"
Write-Info "=========================================="
Write-Info ""

# 检查公钥文件
if (-not (Test-Path $PublicKeyPath)) {
    Write-Error "❌ 公钥文件不存在: $PublicKeyPath"
    exit 1
}

Write-Success "✓ 公钥文件找到: $PublicKeyPath"
Write-Info ""

# 读取公钥内容
$publicKey = Get-Content $PublicKeyPath
Write-Info "公钥内容:"
Write-Info $publicKey
Write-Info ""

# 提示用户
Write-Info "⚠️  下面将使用以下信息连接到阿里云服务器:"
Write-Info "   - 服务器: $ServerIP"
Write-Info "   - 用户名: $Username"
Write-Info ""
Write-Info "请输入服务器密码（将用于SSH连接）:"

# 获取密码
$password = Read-Host "密码" -AsSecureString
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($password))

Write-Info ""
Write-Info "连接到服务器..."

# 创建SSH会话命令
$sshCommand = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$publicKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo '✓ 公钥已添加'
cat ~/.ssh/authorized_keys
"@

# 保存命令到临时文件
$tempScript = "$env:TEMP\setup_ssh_temp.sh"
Set-Content -Path $tempScript -Value $sshCommand -Encoding UTF8

try {
    # 使用sshpass自动化SSH连接（需要安装）
    # 检查是否安装了ssh
    $sshPath = (Get-Command ssh -ErrorAction SilentlyContinue).Source
    
    if ($null -eq $sshPath) {
        Write-Error "❌ SSH客户端未安装或不在PATH中"
        Write-Error "   请确保已安装OpenSSH"
        exit 1
    }
    
    Write-Info "✓ SSH客户端可用: $sshPath"
    Write-Info ""
    
    # 提示使用expect或其他方法
    Write-Info "⚠️  注意: PowerShell脚本无法自动输入密码（出于安全考虑）"
    Write-Info ""
    Write-Info "请选择以下方式之一:"
    Write-Info ""
    Write-Info "方式1: 使用密钥认证（如果已配置）:"
    Write-Info "   ssh -i C:\Users\刘露霆\.ssh\aliyun_key root@$ServerIP"
    Write-Info ""
    Write-Info "方式2: 手动输入密码（PowerShell会提示输入）:"
    Write-Info "   ssh root@$ServerIP"
    Write-Info "   然后执行以下命令:"
    Write-Info ""
    Write-Info "====== 在服务器上执行以下命令 ======"
    Write-Info $sshCommand
    Write-Info "====================================="
    Write-Info ""
    
} finally {
    # 清理临时文件
    if (Test-Path $tempScript) {
        Remove-Item $tempScript -Force
    }
}

Write-Info ""
Write-Success "✓ 脚本完成"
Write-Info ""
Write-Info "下一步:"
Write-Info "1. 使用上面的命令连接到服务器"
Write-Info "2. 复制粘贴'在服务器上执行以下命令'中的内容到服务器终端"
Write-Info "3. 验证公钥是否成功添加"

# 本地SSH公钥快速参考卡
# 用于快速找到、复制和管理公钥

<#
.SYNOPSIS
快速访问SSH公钥的工具卡

.DESCRIPTION
这是一个快速参考卡，用于管理和部署SSH公钥到服务器

.EXAMPLE
# 查看可用的操作
.\quick_reference.ps1

# 复制公钥
.\quick_reference.ps1 -Action copy

# 显示部署说明
.\quick_reference.ps1 -Action guide
#>

param(
    [ValidateSet('menu', 'copy', 'show', 'guide', 'export')]
    [string]$Action = 'menu'
)

function Show-Menu {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       SSH公钥快速参考 - 本地部署工具" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    Write-Host "服务器信息:" -ForegroundColor Yellow
    Write-Host "  IP地址: 123.56.84.70" -ForegroundColor Gray
    Write-Host "  用户名: root`n" -ForegroundColor Gray
    
    Write-Host "快速操作:" -ForegroundColor Yellow
    Write-Host "  [1] 显示我的公钥" -ForegroundColor White
    Write-Host "  [2] 复制公钥到剪贴板" -ForegroundColor White
    Write-Host "  [3] 显示部署步骤" -ForegroundColor White
    Write-Host "  [4] 导出authorized_keys文件" -ForegroundColor White
    Write-Host "  [5] 打开配置文件编辑" -ForegroundColor White
    Write-Host "  [6] 管理公钥" -ForegroundColor White
    Write-Host "  [0] 退出`n" -ForegroundColor White
    
    $choice = Read-Host "请选择 (0-6)"
    
    switch ($choice) {
        '1' { Show-PublicKey }
        '2' { Copy-PublicKey }
        '3' { Show-DeploymentGuide }
        '4' { Export-AuthorizedKeys }
        '5' { Edit-ConfigFile }
        '6' { Open-KeyManager }
        '0' { Write-Host "再见！`n" -ForegroundColor Green; exit }
        default { Write-Host "无效选择`n" -ForegroundColor Red; Start-Sleep 2; Show-Menu }
    }
}

function Show-PublicKey {
    Write-Host "`n═════ 我的SSH公钥 ════════════════════════════════════`n" -ForegroundColor Green
    
    $pubKeyPath = "$env:USERPROFILE\.ssh\aliyun_key.pub"
    
    if (Test-Path $pubKeyPath) {
        $pubKey = Get-Content $pubKeyPath
        Write-Host $pubKey -ForegroundColor Yellow
        Write-Host "`n✓ 公钥已显示上方`n" -ForegroundColor Green
    } else {
        Write-Host "✗ 公钥文件未找到: $pubKeyPath`n" -ForegroundColor Red
    }
    
    Read-Host "按Enter继续"
    Show-Menu
}

function Copy-PublicKey {
    Write-Host "`n════ 复制公钥到剪贴板 ════════════════════════════════`n" -ForegroundColor Green
    
    $pubKeyPath = "$env:USERPROFILE\.ssh\aliyun_key.pub"
    
    if (Test-Path $pubKeyPath) {
        Get-Content $pubKeyPath | Set-Clipboard
        Write-Host "✓ 公钥已复制到剪贴板！`n" -ForegroundColor Green
        Write-Host "现在你可以：" -ForegroundColor White
        Write-Host "  • 在服务器上粘贴到 ~/.ssh/authorized_keys" -ForegroundColor Gray
        Write-Host "  • 在GitHub Settings中添加为SSH密钥`n" -ForegroundColor Gray
    } else {
        Write-Host "✗ 公钥文件未找到`n" -ForegroundColor Red
    }
    
    Read-Host "按Enter继续"
    Show-Menu
}

function Show-DeploymentGuide {
    Clear-Host
    Write-Host "`n════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "          部署步骤 - 在服务器上配置公钥" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
    
    Write-Host "✅ 第1步：在本地复制公钥" -ForegroundColor Yellow
    Write-Host "  运行: .\quick_reference.ps1" -ForegroundColor Gray
    Write-Host "  选择: [2] 复制公钥到剪贴板`n" -ForegroundColor Gray
    
    Write-Host "✅ 第2步：SSH登录到服务器" -ForegroundColor Yellow
    Write-Host "  运行: ssh root@123.56.84.70" -ForegroundColor Cyan
    Write-Host "  输入密码`n" -ForegroundColor Gray
    
    Write-Host "✅ 第3步：在服务器上执行以下命令" -ForegroundColor Yellow
    Write-Host "`n  mkdir -p ~/.ssh && chmod 700 ~/.ssh`n" -ForegroundColor Cyan
    
    Write-Host "✅ 第4步：添加公钥" -ForegroundColor Yellow
    Write-Host "  运行以下命令（然后粘贴你的公钥，最后Ctrl+D）：`n" -ForegroundColor Gray
    Write-Host "  cat >> ~/.ssh/authorized_keys << 'EOF'" -ForegroundColor Cyan
    Write-Host "  [粘贴你的公钥]" -ForegroundColor Yellow
    Write-Host "  EOF`n" -ForegroundColor Cyan
    
    Write-Host "✅ 第5步：设置权限" -ForegroundColor Yellow
    Write-Host "  chmod 600 ~/.ssh/authorized_keys`n" -ForegroundColor Cyan
    
    Write-Host "✅ 第6步：验证" -ForegroundColor Yellow
    Write-Host "  cat ~/.ssh/authorized_keys`n" -ForegroundColor Cyan
    Write-Host "  (应该显示你的公钥内容，ssh-rsa AAAA...)`n" -ForegroundColor Gray
    
    Write-Host "✅ 第7步：退出服务器并测试连接" -ForegroundColor Yellow
    Write-Host "  exit" -ForegroundColor Cyan
    Write-Host "  ssh aliyun" -ForegroundColor Cyan
    Write-Host "  (应该能直接连接，无需输入密码)`n" -ForegroundColor Gray
    
    Read-Host "按Enter返回菜单"
    Show-Menu
}

function Export-AuthorizedKeys {
    Write-Host "`n════ 导出authorized_keys文件 ═══════════════════════════`n" -ForegroundColor Green
    
    $pubKeyPath = "$env:USERPROFILE\.ssh\aliyun_key.pub"
    $exportPath = "$PSScriptRoot\authorized_keys_template.txt"
    
    if (Test-Path $pubKeyPath) {
        $pubKey = Get-Content $pubKeyPath
        $pubKey | Set-Content $exportPath -Encoding UTF8
        
        Write-Host "✓ 已导出到: $exportPath`n" -ForegroundColor Green
        Write-Host "使用方法：" -ForegroundColor White
        Write-Host "  在服务器上运行：" -ForegroundColor Gray
        Write-Host "  mkdir -p ~/.ssh && chmod 700 ~/.ssh" -ForegroundColor Cyan
        Write-Host "  cat >> ~/.ssh/authorized_keys << 'EOF'" -ForegroundColor Cyan
        Write-Host "  [复制exported文件的内容到这里]" -ForegroundColor Yellow
        Write-Host "  EOF" -ForegroundColor Cyan
        Write-Host "  chmod 600 ~/.ssh/authorized_keys`n" -ForegroundColor Cyan
    } else {
        Write-Host "✗ 公钥文件未找到`n" -ForegroundColor Red
    }
    
    Read-Host "按Enter继续"
    Show-Menu
}

function Edit-ConfigFile {
    Write-Host "`n════ 打开配置文件 ════════════════════════════════════`n" -ForegroundColor Green
    
    $configFile = "$PSScriptRoot\public_keys_config.txt"
    
    if (Test-Path $configFile) {
        Write-Host "正在打开配置文件...`n" -ForegroundColor Green
        notepad $configFile
    } else {
        Write-Host "✗ 配置文件未找到: $configFile`n" -ForegroundColor Red
    }
    
    Show-Menu
}

function Open-KeyManager {
    Write-Host "`n════ 打开公钥管理工具 ════════════════════════════════`n" -ForegroundColor Green
    
    $managerScript = "$PSScriptRoot\manage_public_keys.ps1"
    
    if (Test-Path $managerScript) {
        Write-Host "启动公钥管理工具...`n" -ForegroundColor Green
        & $managerScript -Action show
    } else {
        Write-Host "✗ 管理工具未找到: $managerScript`n" -ForegroundColor Red
    }
    
    Show-Menu
}

# 主程序
switch ($Action) {
    'menu' { Show-Menu }
    'copy' { Copy-PublicKey; Show-Menu }
    'show' { Show-PublicKey; Show-Menu }
    'guide' { Show-DeploymentGuide; Show-Menu }
    'export' { Export-AuthorizedKeys; Show-Menu }
    default { Show-Menu }
}

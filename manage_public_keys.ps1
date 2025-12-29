# SSH公钥本地管理脚本
# 功能：管理、预览、导出公钥配置

param(
    [ValidateSet('show', 'copy', 'export', 'validate', 'add')]
    [string]$Action = 'show',
    
    [string]$KeyFile = "$env:USERPROFILE\.ssh\aliyun_key.pub",
    [string]$ConfigFile = "$PSScriptRoot\public_keys_config.txt",
    [string]$NewKeyPath = ""
)

# 颜色函数
function Write-Success { Write-Host "[✓]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Error { Write-Host "[✗]" -ForegroundColor Red -NoNewline; Write-Host " $args" }
function Write-Info { Write-Host "[ℹ]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }
function Write-Warning { Write-Host "[⚠]" -ForegroundColor Yellow -NoNewline; Write-Host " $args" }

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "          SSH公钥本地管理工具" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# 检查配置文件
if (-not (Test-Path $ConfigFile)) {
    Write-Error "配置文件不存在: $ConfigFile"
    exit 1
}

switch ($Action) {
    'show' {
        Write-Info "显示当前公钥配置`n"
        
        # 提取公钥内容（跳过注释）
        $publicKeys = Get-Content $ConfigFile | Where-Object { $_ -match '^ssh-' }
        
        if ($publicKeys.Count -eq 0) {
            Write-Warning "未找到公钥"
        } else {
            Write-Success "找到 $($publicKeys.Count) 个公钥：`n"
            
            $publicKeys | ForEach-Object {
                $keyStart = $_ -match '(ssh-\w+\s+[A-Za-z0-9+/=]+)'
                $keyPreview = $_.Substring(0, [Math]::Min(50, $_.Length)) + "..."
                Write-Host "  • $keyPreview" -ForegroundColor Gray
            }
        }
    }
    
    'copy' {
        Write-Info "复制所有公钥到剪贴板`n"
        
        $publicKeys = @()
        $inComment = $false
        
        Get-Content $ConfigFile | ForEach-Object {
            if ($_ -match '^ssh-') {
                $publicKeys += $_
            }
        }
        
        if ($publicKeys.Count -eq 0) {
            Write-Error "未找到公钥"
        } else {
            $publicKeys -join "`n" | Set-Clipboard
            Write-Success "已复制 $($publicKeys.Count) 个公钥到剪贴板`n"
            Write-Info "可以粘贴到以下位置："
            Write-Host "  • 服务器 ~/.ssh/authorized_keys" -ForegroundColor Gray
            Write-Host "  • GitHub Settings → SSH Keys" -ForegroundColor Gray
        }
    }
    
    'export' {
        Write-Info "导出公钥到文件`n"
        
        $publicKeys = Get-Content $ConfigFile | Where-Object { $_ -match '^ssh-' }
        
        if ($publicKeys.Count -eq 0) {
            Write-Error "未找到公钥"
            exit 1
        }
        
        $exportFile = Join-Path $PSScriptRoot "authorized_keys.txt"
        $publicKeys | Set-Content $exportFile -Encoding UTF8
        
        Write-Success "已导出 $($publicKeys.Count) 个公钥到: $exportFile`n"
        Write-Info "可以直接使用此文件："
        Write-Host "  ssh root@123.56.84.70 < authorized_keys.txt" -ForegroundColor Gray
    }
    
    'validate' {
        Write-Info "验证公钥格式`n"
        
        $publicKeys = Get-Content $ConfigFile | Where-Object { $_ -match '^ssh-' }
        
        if ($publicKeys.Count -eq 0) {
            Write-Warning "未找到公钥"
            exit 0
        }
        
        $validCount = 0
        $publicKeys | ForEach-Object {
            if ($_ -match '^ssh-(rsa|ed25519|ecdsa)(\s+[A-Za-z0-9+/=]+)+$') {
                $validCount++
            } else {
                Write-Error "无效的公钥格式: $($_.Substring(0, 50))..."
            }
        }
        
        if ($validCount -eq $publicKeys.Count) {
            Write-Success "所有 $validCount 个公钥格式有效`n"
        } else {
            Write-Error "$($publicKeys.Count - $validCount) 个公钥格式有效问题"
        }
    }
    
    'add' {
        if (-not $NewKeyPath) {
            Write-Error "请指定新密钥文件: -NewKeyPath 'C:\path\to\key.pub'"
            exit 1
        }
        
        if (-not (Test-Path $NewKeyPath)) {
            Write-Error "密钥文件不存在: $NewKeyPath"
            exit 1
        }
        
        Write-Info "添加新公钥`n"
        
        $newPublicKey = Get-Content $NewKeyPath
        
        Write-Host "新公钥内容:`n$newPublicKey`n" -ForegroundColor Gray
        Write-Warning "此操作将修改 $ConfigFile"
        
        $confirm = Read-Host "是否继续? (y/n)"
        
        if ($confirm -eq 'y') {
            "`n# ===== 新密钥 =====" | Add-Content $ConfigFile
            "# 添加日期: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" | Add-Content $ConfigFile
            $newPublicKey | Add-Content $ConfigFile
            
            Write-Success "已添加新公钥到配置文件`n"
            Write-Info "下一步：在服务器上执行: cat >> ~/.ssh/authorized_keys << 'EOF'`n$newPublicKey`nEOF"
        } else {
            Write-Info "已取消"
        }
    }
    
    default {
    
    default {
        Write-Error "未知操作: $Action"
        Write-Info ""
        Write-Info "可用的操作："
        Write-Host "  show     - 显示公钥配置" -ForegroundColor Gray
        Write-Host "  copy     - 复制公钥到剪贴板" -ForegroundColor Gray
        Write-Host "  export   - 导出公钥到文件" -ForegroundColor Gray
        Write-Host "  validate - 验证公钥格式" -ForegroundColor Gray
        Write-Host "  add      - 添加新公钥 (-NewKeyPath path\to\key.pub)" -ForegroundColor Gray
    }
}

Write-Host "`n════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

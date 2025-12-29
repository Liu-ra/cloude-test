# SSH公钥本地管理脚本 - 简化版本

param(
    [ValidateSet('show', 'copy', 'export', 'validate')]
    [string]$Action = 'show',
    [string]$ConfigFile = "$PSScriptRoot\public_keys_config.txt"
)

# 颜色函数
function Write-Success { Write-Host "[OK]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Fail { Write-Host "[ERROR]" -ForegroundColor Red -NoNewline; Write-Host " $args" }
function Write-Tip { Write-Host "[INFO]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }

Write-Host "" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "          SSH公钥本地管理工具" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 检查配置文件
if (-not (Test-Path $ConfigFile)) {
    Write-Fail "配置文件不存在"
    exit 1
}

# 提取公钥（所有以ssh-开头的行）
$publicKeys = @()
Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match '^ssh-') {
        $publicKeys += $_
    }
}

switch ($Action) {
    'show' {
        Write-Tip "显示当前公钥配置`n"
        
        if ($publicKeys.Count -eq 0) {
            Write-Fail "未找到公钥"
        } else {
            Write-Success "找到 $($publicKeys.Count) 个公钥：`n"
            $publicKeys | ForEach-Object {
                $keyPreview = $_.Substring(0, [Math]::Min(60, $_.Length)) + "..."
                Write-Host "  * $keyPreview" -ForegroundColor Gray
            }
        }
    }
    
    'copy' {
        Write-Tip "复制公钥到剪贴板`n"
        
        if ($publicKeys.Count -eq 0) {
            Write-Fail "未找到公钥"
        } else {
            $publicKeys -join "`n" | Set-Clipboard
            Write-Success "已复制 $($publicKeys.Count) 个公钥到剪贴板`n"
            Write-Tip "可以粘贴到服务器的 ~/.ssh/authorized_keys"
        }
    }
    
    'export' {
        Write-Tip "导出公钥到文件`n"
        
        if ($publicKeys.Count -eq 0) {
            Write-Fail "未找到公钥"
            exit 1
        }
        
        $exportFile = Join-Path $PSScriptRoot "authorized_keys_export.txt"
        $publicKeys | Set-Content $exportFile -Encoding UTF8
        
        Write-Success "已导出到: $exportFile`n"
        Write-Tip "可以在服务器上使用此文件添加公钥"
    }
    
    'validate' {
        Write-Tip "验证公钥格式`n"
        
        if ($publicKeys.Count -eq 0) {
            Write-Tip "未找到公钥"
        } else {
            $validCount = 0
            $publicKeys | ForEach-Object {
                if ($_ -match '^ssh-(rsa|ed25519|ecdsa)(\s+[A-Za-z0-9+/=]+)+$') {
                    $validCount++
                }
            }
            
            if ($validCount -eq $publicKeys.Count) {
                Write-Success "所有 $validCount 个公钥格式有效"
            } else {
                Write-Fail "$($publicKeys.Count - $validCount) 个公钥格式有问题"
            }
        }
    }
    
    default {
        Write-Fail "未知操作: $Action`n"
        Write-Tip "可用操作:"
        Write-Host "  show     - 显示公钥配置" -ForegroundColor Gray
        Write-Host "  copy     - 复制到剪贴板" -ForegroundColor Gray
        Write-Host "  export   - 导出到文件" -ForegroundColor Gray
        Write-Host "  validate - 验证格式" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

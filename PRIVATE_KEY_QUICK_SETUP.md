# 🔐 私钥配置 - 快速参考

## ⚡ 5分钟快速配置

### 步骤1：创建SSH config文件
```powershell
# 如果config文件不存在，创建它
@"
Host aliyun
    HostName 123.56.84.70
    User root
    IdentityFile C:\Users\刘露霆\.ssh\aliyun_key
    Port 22
    StrictHostKeyChecking accept-new
"@ | Set-Content "C:\Users\刘露霆\.ssh\config" -Encoding UTF8

Write-Host "✓ Config已创建"
```

### 步骤2：启动SSH Agent
```powershell
# 启动SSH Agent（可能需要管理员权限）
Start-Service ssh-agent

Write-Host "✓ SSH Agent已启动"
```

### 步骤3：添加私钥到Agent
```powershell
# 添加私钥
ssh-add "C:\Users\刘露霆\.ssh\aliyun_key"

# 可能提示输入密钥密码（如果设置了的话），按提示输入

Write-Host "✓ 私钥已添加"
```

### 步骤4：测试连接
```powershell
# 测试SSH连接
ssh aliyun

# 应该能直接进入服务器，无需输入密码
# 如果显示欢迎信息，说明成功了！
```

---

## 🚀 一键配置脚本

如果你想自动完成所有步骤，运行：

```powershell
# 在项目目录运行
cd d:\claude\gzh\cloude-test

# 方式1: 使用自动化脚本
.\setup_private_key.ps1 -Action setup

# 方式2: 手动逐步执行
.\setup_private_key.ps1 -Action info    # 查看信息
.\setup_private_key.ps1 -Action test    # 测试连接
```

---

## 📋 常用命令

```powershell
# 检查SSH Agent状态
Get-Service ssh-agent | Select-Object Name, Status

# 启动SSH Agent
Start-Service ssh-agent

# 添加私钥到Agent
ssh-add "C:\Users\刘露霆\.ssh\aliyun_key"

# 查看Agent中的密钥
ssh-add -l

# 删除Agent中的所有密钥
ssh-add -D

# 连接到阿里云服务器
ssh aliyun

# 详细连接信息（用于调试）
ssh -vvv aliyun

# 测试GitHub连接
ssh -T git@github.com

# 配置Git用户信息
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 查看Git配置
git config --global --list | Select-String user
```

---

## ❓ 常见问题

### Q: 运行setup_private_key.ps1报错
**A**: 可能需要管理员权限，请用管理员PowerShell重新运行

### Q: Permission denied (publickey)
**A**: 说明公钥未正确添加到服务器 `~/.ssh/authorized_keys`，返回 SERVER_SETUP.md 检查

### Q: 每次都要输入密钥密码
**A**: 说明私钥密码未被Agent记住，再运行一次 `ssh-add` 即可

### Q: ssh-add找不到
**A**: SSH未正确安装，重启PowerShell或使用完整路径

---

## ✅ 完成检查

- [ ] SSH config文件已创建
- [ ] SSH Agent已启动
- [ ] 私钥已添加到Agent
- [ ] 可以用 `ssh aliyun` 连接
- [ ] Git用户信息已配置
- [ ] 连接不需要输入服务器密码

---

**快速检验一切是否正常**:
```powershell
ssh aliyun "whoami && pwd"

# 应该显示:
# root
# /root
```

完成了！现在你可以无密码地连接阿里云服务器了。🎉

# 📚 GitHub项目SSH配置指南 - 一个项目一个私钥

## 核心概念澄清

**重要：私钥永不上传到GitHub！**

- **公钥** → 上传到GitHub账户 (`Settings > SSH Keys`)
- **私钥** → 保留在本地，Git/SSH使用它来认证
- **项目级配置** → 为不同项目配置不同的密钥对

---

## 方案A：快速方案（推荐 - 已有密钥）

如果只有一个GitHub项目，直接使用已有的`aliyun_key`：

### 步骤1：将公钥添加到GitHub账户

已完成 ✅ (通过 `setup_github.ps1`)

### 步骤2：配置项目的Git来使用SSH

```powershell
# 进入你的项目目录
cd C:\path\to\your\github\repo

# 检查当前remote
git remote -v

# 如果是HTTPS，转换为SSH
git remote remove origin
git remote add origin git@github.com:your-username/your-repo.git

# 验证
git remote -v
```

### 步骤3：测试连接

```powershell
ssh -T git@github.com
# 应该输出: Hi your-username! You've successfully authenticated...

# 或者直接push测试
git push origin main
```

---

## 方案B：完整方案（一个项目一个私钥）

如果要为不同项目创建不同的密钥对（更安全）：

### 步骤1：为GitHub项目生成新的密钥对

```powershell
# 生成专门用于GitHub的密钥
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\github_key" -N ""

# 说明：
# -t rsa: RSA密钥类型
# -b 4096: 4096位强度
# -f: 输出文件路径
# -N "": 无密码保护（如需加密可改为密码）

# 查看生成的文件
ls "$env:USERPROFILE\.ssh\github_key*"
```

### 步骤2：获取新公钥内容

```powershell
# 显示公钥
Get-Content "$env:USERPROFILE\.ssh\github_key.pub"

# 复制到剪贴板
Get-Content "$env:USERPROFILE\.ssh\github_key.pub" | Set-Clipboard
```

### 步骤3：在GitHub账户中添加这个新公钥

1. 访问: https://github.com/settings/keys
2. 点击 "New SSH key"
3. **Title**: `github_key` 或 `My GitHub Project Key`
4. **Key type**: Authentication Key
5. **Key**: 粘贴上面复制的公钥
6. 点击 "Add SSH key"

### 步骤4：配置本地SSH识别这个新密钥

编辑 `C:\Users\刘露霆\.ssh\config`，添加：

```
Host github-project
    User git
    HostName github.com
    IdentityFile C:\Users\刘露霆\.ssh\github_key
```

### 步骤5：配置项目使用这个密钥

在你的项目目录中运行：

```powershell
# 进入项目目录
cd C:\path\to\your\github\repo

# 配置这个项目的remote使用custom host
git remote remove origin
git remote add origin git@github-project:your-username/your-repo.git

# 验证配置
git remote -v
```

### 步骤6：项目级Git配置（可选）

为这个项目单独配置Git用户信息：

```powershell
# 在项目目录内运行（不加--global）
git config user.name "Your Name"
git config user.email "your@email.com"

# 验证
git config --list | grep user
```

### 步骤7：测试连接

```powershell
# 测试连接到github-project
ssh -T git@github-project
# 应该输出: Hi your-username! You've successfully authenticated...

# 测试push
git push origin main
```

---

## 📊 多项目SSH密钥管理架构

如果有多个项目，每个都有专门的密钥：

```
~/.ssh/
├── aliyun_key (服务器用)
├── aliyun_key.pub
├── github_key (GitHub项目1)
├── github_key.pub
├── gitlab_key (GitLab或其他项目2)
├── gitlab_key.pub
└── config

~/.ssh/config:
─────────────────────────────
Host aliyun
    HostName 123.56.84.70
    User root
    IdentityFile ~/.ssh/aliyun_key

Host github-project
    User git
    HostName github.com
    IdentityFile ~/.ssh/github_key

Host gitlab-project
    User git
    HostName gitlab.com
    IdentityFile ~/.ssh/gitlab_key
─────────────────────────────

项目1 (.git/config):
git@github-project:user/repo1.git

项目2 (.git/config):
git@gitlab-project:user/repo2.git

服务器:
使用 aliyun_key 通过 SSH 连接
```

---

## 🔍 故障排查

### "Permission denied (publickey)"

**可能原因：**
1. 公钥未添加到GitHub账户
2. 私钥路径不正确
3. SSH Agent未启动

**解决：**
```powershell
# 1. 检查SSH Agent
Get-Service ssh-agent | Start-Service

# 2. 添加私钥到Agent
ssh-add "$env:USERPROFILE\.ssh\github_key"

# 3. 验证Agent中有密钥
ssh-add -l

# 4. 调试连接
ssh -vvv git@github.com
```

### "identity_file permission denied"

**可能原因：** 私钥文件权限过开放

**解决：**
```powershell
# Windows上不通常出现，但如果有问题：
# 右键文件 → Properties → Security → Advanced
# 只保留当前用户的完全控制权限
```

### "git push" 仍然要求输入密码

**可能原因：** 
1. Remote URL仍是HTTPS
2. 私钥未添加到Agent

**解决：**
```powershell
# 检查remote URL
git remote -v
# 应该显示: git@github... (不是 https://...)

# 如果是HTTPS，改为SSH
git remote set-url origin git@github-project:your-username/your-repo.git

# 添加私钥到Agent
ssh-add "$env:USERPROFILE\.ssh\github_key"
```

---

## ✅ 完整检查清单

- [ ] 为GitHub项目生成了密钥对（`github_key` 和 `github_key.pub`）
- [ ] 公钥已添加到 GitHub Settings > SSH and GPG keys
- [ ] SSH config文件已配置 `Host github-project`
- [ ] 项目的remote已改为 `git@github-project:username/repo.git`
- [ ] SSH Agent已启动并加载了私钥
  ```powershell
  Get-Service ssh-agent | Start-Service
  ssh-add "$env:USERPROFILE\.ssh\github_key"
  ```
- [ ] 测试连接成功
  ```powershell
  ssh -T git@github-project
  ```
- [ ] Git push/pull 无需输入密码

---

## 🚀 快速实现脚本

```powershell
# 一键为GitHub项目生成密钥
$repoName = Read-Host "输入项目名称 (例如: my-project)"

# 生成密钥
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\github_$repoName" -N ""

# 显示公钥
Write-Host "已生成密钥对。公钥内容：" -ForegroundColor Green
Get-Content "$env:USERPROFILE\.ssh\github_$repoName.pub"

# 复制到剪贴板
Get-Content "$env:USERPROFILE\.ssh\github_$repoName.pub" | Set-Clipboard

Write-Host "公钥已复制到剪贴板，现在：" -ForegroundColor Cyan
Write-Host "1. 访问 https://github.com/settings/keys"
Write-Host "2. New SSH key → 粘贴公钥 → Add"
Write-Host "3. 完成后，项目中配置："
Write-Host "   git remote add origin git@github-$repoName:username/repo.git"
```

---

## 📝 总结

| 场景 | 方案 | 时间 |
|------|------|------|
| 单个GitHub项目，无特殊安全要求 | **方案A** - 使用aliyun_key | 5分钟 |
| 多个GitHub项目，要求单独密钥 | **方案B** - 为每个项目生成密钥 | 15分钟 |
| 超高安全性要求 | 方案B + 密钥加密 + 定期轮换 | 30分钟 |

**推荐：** 如果只有一个GitHub项目，用**方案A**；如果有多个，用**方案B**。

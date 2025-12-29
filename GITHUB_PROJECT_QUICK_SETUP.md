# 🚀 一个项目一个私钥 - 快速操作指南

## ⚡ 3步完成配置

### 第1步：为项目生成专门的SSH密钥对

```powershell
# 在项目目录或任何位置运行
.\setup_github_project.ps1 -Action setup -ProjectName my-awesome-repo

# 脚本会自动：
# ✓ 生成 github_my-awesome-repo 密钥对
# ✓ 显示公钥内容
# ✓ 复制公钥到剪贴板
```

### 第2步：在GitHub中添加公钥

1. 访问: https://github.com/settings/keys
2. 点击 **New SSH key**
3. **Title**: `github_my-awesome-repo`
4. **Key type**: Authentication Key
5. **Key**: `Ctrl+V` 粘贴（已在剪贴板）
6. 点击 **Add SSH key**

### 第3步：配置项目Git仓库

```powershell
# 进入你的项目目录
cd C:\path\to\my-awesome-repo

# 配置remote（使用专门的Host）
.\setup_github_project.ps1 -Action configure `
  -ProjectName my-awesome-repo `
  -RepoUrl git@github-my-awesome-repo:your-username/my-awesome-repo.git

# 或者手动配置
git remote add origin git@github-my-awesome-repo:your-username/my-awesome-repo.git
```

---

## ✅ 验证成功

```powershell
# 测试SSH连接
.\setup_github_project.ps1 -Action test -ProjectName my-awesome-repo

# 预期输出：
# Hi your-username! You've successfully authenticated...

# 测试Git推送
git push origin main
# 应该无需输入密码
```

---

## 📊 管理多个项目

### 查看所有项目的SSH密钥

```powershell
.\setup_github_project.ps1 -Action list

# 输出示例：
# SSH Keys in ~/.ssh:
#   - my-awesome-repo
#   - another-project
#   - third-repo
#
# SSH Config Hosts:
#   Host github-my-awesome-repo
#   Host github-another-project
#   Host github-third-repo
```

### 为新项目重复步骤

```powershell
# 项目2
.\setup_github_project.ps1 -Action setup -ProjectName another-project
# → 在GitHub添加新公钥
# → 在项目目录中configure

# 项目3
.\setup_github_project.ps1 -Action setup -ProjectName third-repo
# → 在GitHub添加新公钥
# → 在项目目录中configure
```

---

## 🔍 工作流示例

### 场景：有3个GitHub项目，每个都用不同密钥

**项目1：my-awesome-repo**
```
~/.ssh/github_my-awesome-repo (私钥 - 本地)
~/.ssh/github_my-awesome-repo.pub (公钥 - GitHub上)
remote: git@github-my-awesome-repo:user/my-awesome-repo.git
```

**项目2：another-project**
```
~/.ssh/github_another-project (私钥 - 本地)
~/.ssh/github_another-project.pub (公钥 - GitHub上)
remote: git@github-another-project:user/another-project.git
```

**项目3：third-repo**
```
~/.ssh/github_third-repo (私钥 - 本地)
~/.ssh/github_third-repo.pub (公钥 - GitHub上)
remote: git@github-third-repo:user/third-repo.git
```

### SSH如何认证

```
当你 git push 时：
  git 查看 remote url: git@github-my-awesome-repo:user/my-awesome-repo.git
    ↓
  SSH 查看本地 ~/.ssh/config 中 Host github-my-awesome-repo
    ↓
  找到对应的 IdentityFile: ~/.ssh/github_my-awesome-repo
    ↓
  使用这个私钥对GitHub进行认证
    ↓
  GitHub验证通过（因为已添加了对应的公钥）
    ↓
  推送成功！
```

---

## 📝 常见命令速查

| 任务 | 命令 |
|------|------|
| 为新项目生成密钥 | `.\setup_github_project.ps1 -Action setup -ProjectName name` |
| 配置项目Git | `.\setup_github_project.ps1 -Action configure -ProjectName name -RepoUrl url` |
| 测试连接 | `.\setup_github_project.ps1 -Action test -ProjectName name` |
| 列出所有密钥 | `.\setup_github_project.ps1 -Action list` |
| 手动检查SSH Agent | `ssh-add -l` |
| 添加密钥到Agent | `ssh-add ~/.ssh/github_projectname` |
| 启动SSH Agent | `Get-Service ssh-agent \| Start-Service` |

---

## ❓ 我应该选择哪个方案？

### 方案A：一个密钥用于所有项目（简单）
**适合：** 个人学习项目，只有一个GitHub账户
```powershell
git remote add origin git@github.com:user/repo.git
```

### 方案B：一个项目一个密钥（推荐）✨
**适合：** 多个项目，不同的安全级别，企业开发
```powershell
git remote add origin git@github-my-project:user/repo.git
```

---

## 🎯 完整工作流示例

```powershell
# 1️⃣ 本地新建项目
mkdir C:\projects\my-awesome-repo
cd C:\projects\my-awesome-repo

# 2️⃣ 初始化Git
git init

# 3️⃣ 生成专门的SSH密钥
.\setup_github_project.ps1 -Action setup -ProjectName my-awesome-repo

# 4️⃣ 在GitHub上创建相同名称的仓库
# → https://github.com/new

# 5️⃣ 在GitHub Settings > SSH Keys 中添加公钥
# (脚本已复制到剪贴板，直接粘贴)

# 6️⃣ 配置项目的Git
.\setup_github_project.ps1 -Action configure `
  -ProjectName my-awesome-repo `
  -RepoUrl git@github-my-awesome-repo:your-username/my-awesome-repo.git

# 7️⃣ 验证连接
.\setup_github_project.ps1 -Action test -ProjectName my-awesome-repo

# 8️⃣ 开始使用
git config user.name "Your Name"
git config user.email "your@email.com"
echo "Hello World" > README.md
git add .
git commit -m "Initial commit"
git push origin main

# ✅ 完成！无需输入密码！
```

---

**更详细的说明请查看**: `GITHUB_PROJECT_SSH_SETUP.md`

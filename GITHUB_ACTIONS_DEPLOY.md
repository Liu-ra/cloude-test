# 🚀 GitHub Actions自动部署到Aliyun服务器

## 核心概念

使用GitHub Actions在提交代码时自动部署到Aliyun服务器。

**安全方式：**
- ✅ 私钥存储在GitHub Secrets（加密）
- ✅ 私钥永不在代码中显示
- ✅ GitHub Actions自动执行部署

---

## 📋 完整配置步骤

### 第1步：准备私钥内容

```powershell
# 获取私钥内容
Get-Content "$env:USERPROFILE\.ssh\aliyun_key" | Set-Clipboard

# 或者显示内容
cat "$env:USERPROFILE\.ssh\aliyun_key"
```

保持这个私钥内容在剪贴板中。

---

### 第2步：在GitHub仓库中添加Secrets

1. 访问你的GitHub仓库: `https://github.com/your-username/your-repo`
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**

**添加以下Secrets：**

⚠️ **命名规则：** 只能使用字母、数字和下划线（_），必须以字母或下划线开头，不能有空格或特殊字符

| Secret名称 | 值 |
|-----------|-----|
| `ALIYUN_HOST` | `123.56.84.70` |
| `ALIYUN_USER` | `root` |
| `ALIYUN_PRIVATE_KEY` | 粘贴上面复制的私钥内容 |
| `ALIYUN_SSH_PORT` | `22` |

**详细操作：**

```
1️⃣ Name: ALIYUN_HOST
   Secret: 123.56.84.70
   
2️⃣ Name: ALIYUN_USER
   Secret: root
   
3️⃣ Name: ALIYUN_PRIVATE_KEY
   Secret: -----BEGIN RSA PRIVATE KEY-----
           MIIEpAIBAAKCAQEA...
           (完整的私钥内容)
           ...2EyA==
           -----END RSA PRIVATE KEY-----
           
4️⃣ Name: ALIYUN_SSH_PORT
   Secret: 22
```

✅ **重要：** 
- Secret名称：只用大写字母和下划线 ✅ `ALIYUN_PRIVATE_KEY`
- 不允许：空格、特殊字符、中文 ❌ `ALIYUN PRIVATE KEY` ❌ `阿里云_私钥`
- 私钥格式完整，包括 `-----BEGIN RSA PRIVATE KEY-----` 和 `-----END RSA PRIVATE KEY-----`

---

### 第3步：创建GitHub Actions工作流文件

在项目根目录创建文件：`.github/workflows/deploy.yml`

```yaml
name: Deploy to Aliyun

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:  # 允许手动触发

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ALIYUN_PRIVATE_KEY }}" > ~/.ssh/aliyun_key
          chmod 600 ~/.ssh/aliyun_key
          ssh-keyscan -H ${{ secrets.ALIYUN_HOST }} >> ~/.ssh/known_hosts 2>/dev/null
      
      - name: Deploy to server
        run: |
          ssh -i ~/.ssh/aliyun_key \
              -p ${{ secrets.ALIYUN_SSH_PORT }} \
              ${{ secrets.ALIYUN_USER }}@${{ secrets.ALIYUN_HOST }} \
              'cd /path/to/your/project && bash deploy.sh'
      
      - name: Cleanup SSH
        if: always()
        run: |
          rm -f ~/.ssh/aliyun_key
```

---

### 第4步：在服务器上创建部署脚本

在Aliyun服务器上创建 `/path/to/your/project/deploy.sh`：

```bash
#!/bin/bash
set -e

echo "Starting deployment..."

# 1. 更新代码
echo "Pulling latest code..."
cd /path/to/your/project
git pull origin main

# 2. 安装依赖（如果是Node.js项目）
echo "Installing dependencies..."
npm install

# 3. 构建项目（如果需要）
echo "Building project..."
npm run build

# 4. 重启服务（示例：使用PM2）
echo "Restarting services..."
npm install -g pm2  # 如果未安装
pm2 restart app     # app 是你的应用名称

# 5. 验证部署
echo "Verifying deployment..."
curl http://localhost:3000 || echo "Service check failed"

echo "Deployment completed successfully!"
```

**设置脚本可执行权限：**
```bash
chmod +x /path/to/your/project/deploy.sh
```

---

## 🔍 工作流示例详解

### 示例1：简单的Node.js项目部署

```yaml
name: Deploy Node.js App

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup SSH Key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ALIYUN_PRIVATE_KEY }}" > ~/.ssh/aliyun_key
          chmod 600 ~/.ssh/aliyun_key
          ssh-keyscan ${{ secrets.ALIYUN_HOST }} >> ~/.ssh/known_hosts 2>/dev/null
      
      - name: Deploy
        run: |
          ssh -i ~/.ssh/aliyun_key \
              root@${{ secrets.ALIYUN_HOST }} \
              'cd /app/myapp && git pull && npm install && npm run build && pm2 restart myapp'
```

### 示例2：多步骤部署流程

```yaml
name: Deploy with Steps

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ALIYUN_PRIVATE_KEY }}" > ~/.ssh/aliyun_key
          chmod 600 ~/.ssh/aliyun_key
          ssh-keyscan ${{ secrets.ALIYUN_HOST }} >> ~/.ssh/known_hosts 2>/dev/null
      
      - name: Pull latest code
        run: |
          ssh -i ~/.ssh/aliyun_key root@${{ secrets.ALIYUN_HOST }} \
              'cd /app && git pull origin main'
      
      - name: Install dependencies
        run: |
          ssh -i ~/.ssh/aliyun_key root@${{ secrets.ALIYUN_HOST }} \
              'cd /app && npm install'
      
      - name: Build
        run: |
          ssh -i ~/.ssh/aliyun_key root@${{ secrets.ALIYUN_HOST }} \
              'cd /app && npm run build'
      
      - name: Restart service
        run: |
          ssh -i ~/.ssh/aliyun_key root@${{ secrets.ALIYUN_HOST }} \
              'pm2 restart myapp'
      
      - name: Health check
        run: |
          ssh -i ~/.ssh/aliyun_key root@${{ secrets.ALIYUN_HOST }} \
              'curl -f http://localhost:3000 || exit 1'
      
      - name: Cleanup
        if: always()
        run: rm -f ~/.ssh/aliyun_key
```

### 示例3：Docker镜像构建并部署

```yaml
name: Build and Deploy Docker

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ALIYUN_PRIVATE_KEY }}" > ~/.ssh/aliyun_key
          chmod 600 ~/.ssh/aliyun_key
          ssh-keyscan ${{ secrets.ALIYUN_HOST }} >> ~/.ssh/known_hosts 2>/dev/null
      
      - name: Build and push Docker image
        run: |
          ssh -i ~/.ssh/aliyun_key root@${{ secrets.ALIYUN_HOST }} << 'EOF'
          cd /app/myapp
          git pull origin main
          docker build -t myapp:latest .
          docker stop myapp || true
          docker rm myapp || true
          docker run -d --name myapp -p 3000:3000 myapp:latest
          EOF
      
      - name: Cleanup
        if: always()
        run: rm -f ~/.ssh/aliyun_key
```

---

## ✅ 验证部署成功

### 查看GitHub Actions日志

1. 访问: `https://github.com/your-username/your-repo/actions`
2. 点击最新的workflow运行
3. 查看各个step的日志

### 常见日志输出

```
✓ Checkout code
✓ Setup SSH
✓ Deploy to server
  └─ Starting deployment...
  └─ Pulling latest code...
  └─ Installing dependencies...
  └─ Building project...
  └─ Restarting services...
  └─ Verifying deployment...
  └─ Deployment completed successfully!
✓ Cleanup SSH
```

---

## 🔧 故障排查

### "Permission denied (publickey)"

**原因：** 公钥未在服务器的 `~/.ssh/authorized_keys` 中

**解决：**
```bash
# 在服务器上检查
cat ~/.ssh/authorized_keys | grep "$(cat ~/.ssh/aliyun_key.pub)"

# 如果没有，添加
echo "$(cat ~/.ssh/aliyun_key.pub)" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### "Host key verification failed"

**解决：** 工作流中已包含，确保有这一行：
```yaml
ssh-keyscan -H ${{ secrets.ALIYUN_HOST }} >> ~/.ssh/known_hosts
```

### "Secret ALIYUN_PRIVATE_KEY is not available"

**原因：** Secret名称拼写错误或权限问题

**检查：**
1. 在GitHub Settings确认Secret名称正确
2. 在workflow中使用相同的名称

### "SSH key has invalid format"

**原因：** 私钥内容不完整或格式错误

**重新设置：**
```powershell
# 显示完整私钥（包括BEGIN和END）
Get-Content "$env:USERPROFILE\.ssh\aliyun_key"

# 重新复制到GitHub Secret中
# 确保包括所有行
```

---

## 📚 其他有用的GitHub Actions

### 自动通知部署状态

```yaml
      - name: Notify deployment
        if: failure()
        run: |
          echo "Deployment failed!" 
          # 可以在这里添加钉钉、Slack等通知
```

### 定时部署

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨2点
```

### 指定文件变化时部署

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'package.json'
      - '.github/workflows/deploy.yml'
```

---

## 📝 完整清单

- [ ] 获取 `aliyun_key` 私钥内容
- [ ] 在GitHub Secrets中添加4个Secrets
  - [ ] `ALIYUN_HOST`
  - [ ] `ALIYUN_USER`
  - [ ] `ALIYUN_PRIVATE_KEY`
  - [ ] `ALIYUN_SSH_PORT`
- [ ] 创建 `.github/workflows/deploy.yml` 文件
- [ ] 在Aliyun服务器上创建 `deploy.sh` 脚本
- [ ] 提交代码到GitHub
- [ ] 查看GitHub Actions运行日志
- [ ] 验证服务器成功部署

---

## 🎯 下一步

1. **配置Secrets** - 最重要！
2. **创建workflow文件** - `.github/workflows/deploy.yml`
3. **测试部署** - 提交代码触发自动部署
4. **监控日志** - 在GitHub Actions中查看进度

需要我帮你创建这些文件吗？

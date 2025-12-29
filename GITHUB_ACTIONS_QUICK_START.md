# ⚡ GitHub Actions自动部署 - 5分钟快速配置

## 🎯 目标
当你提交代码到GitHub时，自动部署到Aliyun服务器。

---

## 第1步：获取私钥（1分钟）

```powershell
# 显示私钥内容，全部复制
cat "$env:USERPROFILE\.ssh\aliyun_key"
```

或者一键复制到剪贴板：
```powershell
Get-Content "$env:USERPROFILE\.ssh\aliyun_key" | Set-Clipboard
```

---

## 第2步：在GitHub中添加Secrets（2分钟）

1. 打开你的GitHub仓库
2. **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**，添加以下4个：

⚠️ **命名规则：** 只能用大写字母、数字和下划线（_），不能有空格或特殊字符

```
1️⃣  ALIYUN_HOST
    123.56.84.70

2️⃣  ALIYUN_USER
    root

3️⃣  ALIYUN_PRIVATE_KEY
    (粘贴完整的私钥内容，包括 -----BEGIN RSA PRIVATE KEY----- 和 -----END RSA PRIVATE KEY-----)

4️⃣  ALIYUN_SSH_PORT
    22
```

✅ **检查清单：**
- Secret名称格式 ✓ `ALIYUN_HOST`（只有大写字母和下划线）
- 没有空格或特殊字符 ✓
- 私钥内容完整 ✓ 包括BEGIN和END行

---

## 第3步：创建部署工作流文件（2分钟）

在你的项目根目录创建这个文件：
`.github/workflows/deploy.yml`

```yaml
name: Deploy to Aliyun

on:
  push:
    branches: [main, master]
  workflow_dispatch:

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
          ssh-keyscan -H ${{ secrets.ALIYUN_HOST }} >> ~/.ssh/known_hosts 2>/dev/null
      
      - name: Deploy
        run: |
          ssh -i ~/.ssh/aliyun_key \
              -p ${{ secrets.ALIYUN_SSH_PORT }} \
              ${{ secrets.ALIYUN_USER }}@${{ secrets.ALIYUN_HOST }} \
              'cd /path/to/your/project && bash deploy.sh'
      
      - name: Cleanup
        if: always()
        run: rm -f ~/.ssh/aliyun_key
```

⚠️ **修改项目路径：** 将 `/path/to/your/project` 改为你在服务器上的项目路径

---

## 第4步：在服务器上创建部署脚本（1分钟）

在Aliyun服务器上创建 `/path/to/your/project/deploy.sh`：

```bash
#!/bin/bash
set -e

echo "Deploying..."
cd /path/to/your/project

# 拉取最新代码
git pull origin main

# 安装依赖（如果是Node.js）
npm install

# 构建
npm run build

# 重启服务（示例：PM2）
pm2 restart myapp

echo "Deployment complete!"
```

然后设置可执行权限：
```bash
chmod +x /path/to/your/project/deploy.sh
```

---

## ✅ 完成！测试部署

提交代码到GitHub：
```powershell
git add .
git commit -m "test deployment"
git push origin main
```

然后查看自动部署：
1. 访问: `https://github.com/your-username/your-repo/actions`
2. 看到绿色✓ = 部署成功！

---

## 🔍 出错了？

### "Permission denied"
→ 检查私钥是否完整，包括 `-----BEGIN` 和 `-----END`

### "deploy.sh: not found"
→ 检查服务器上deploy.sh的路径是否正确

### 日志看不清
→ 在GitHub Actions页面点击该step查看完整日志

---

## 📚 更详细的说明

查看 `GITHUB_ACTIONS_DEPLOY.md` 了解：
- 高级配置选项
- 多步骤部署流程
- Docker部署
- 故障排查

---

## 🎯 核心要点总结

```
代码提交 → GitHub → 自动触发Actions → SSH连接服务器 → 执行部署脚本 → ✅ 完成！
```

**关键点：**
- 🔐 私钥安全地存储在GitHub Secrets中
- 🔄 每次push都自动部署
- 📊 可在GitHub Actions中查看部署日志
- ⚡ 部署速度取决于脚本复杂度

需要帮助吗？

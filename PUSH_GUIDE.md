# 🚀 网络恢复后的推送指南

## 当网络恢复时，执行以下命令：

```powershell
cd D:\claude\gzh\cloude-test
git push origin main
```

---

## 推送后的验证步骤

### 1️⃣ 查看GitHub Actions运行

访问: https://github.com/Liu-ra/cloude-test/actions

预期看到：
- 最新的workflow run（状态为 "in progress" 或 "completed"）
- 部署日志实时更新

### 2️⃣ 查看部署日志

点击最新的workflow run，然后点击 "Deploy to server" step，查看：

```
✓ Checkout code
✓ Setup SSH
✓ Deploy to server
  └─ [INFO] 进入项目目录
  └─ [INFO] 从 main 分支拉取最新代码
  └─ [INFO] 安装项目依赖
  └─ [INFO] 构建项目
  └─ [INFO] 重启应用服务
  └─ [INFO] 验证应用状态
  └─ [SUCCESS] 部署完成！
✓ Cleanup SSH
```

### 3️⃣ 验证服务器更新

连接到服务器验证：

```bash
ssh -i ~/.ssh/aliyun_key root@123.56.84.70

# 检查应用状态
pm2 status

# 查看部署日志
pm2 logs app-name --lines 20

# 验证应用是否运行
curl http://localhost:3000
```

---

## 可能遇到的情况

### ✅ 部署成功（预期场景）
```
Status: ✓ Success
Logs: Deploy to server step 显示 [SUCCESS] 部署完成！
```

**对应操作**：
- 服务器上应用已自动重启
- 新代码已生效
- 一切正常！🎉

### ⚠️ 部署失败

**可能原因1**：deploy.sh脚本配置不正确
```
解决: 编辑项目中的 deploy.sh，修改：
  - PROJECT_DIR="/path/to/your/project"
  - APP_NAME="myapp"
  - PORT="3000"
  - BRANCH="main"
然后再次 git push
```

**可能原因2**：服务器上PM2未安装
```
解决: SSH连接到服务器
  npm install -g pm2
然后重新推送代码以触发部署
```

**可能原因3**：项目目录不存在或权限问题
```
解决: SSH连接到服务器，确保：
  - 项目目录存在
  - 有写入权限
  - deploy.sh 有执行权限 (chmod +x deploy.sh)
```

---

## 快速参考

| 命令 | 说明 |
|------|------|
| `git push origin main` | 推送本地代码到GitHub |
| `git log --oneline -5` | 查看最近5次提交 |
| `git status` | 查看当前状态 |
| `ssh root@123.56.84.70` | 连接到服务器 |
| `pm2 list` | 查看运行中的应用 |
| `pm2 logs` | 查看应用日志 |

---

## 关键时间点

```
你运行 git push
    ↓ (1秒)
代码到达GitHub
    ↓ (1-2秒)
GitHub Actions自动触发
    ↓ (10-30秒)
SSH连接Aliyun服务器
    ↓ (5-15秒，取决于网络和项目大小)
部署脚本执行 (git pull, npm install, npm run build, pm2 restart)
    ↓ (完成)
应用自动重启，新代码生效！
```

总耗时：**15-50秒** ⚡

---

## 后续自动部署

配置完成后，每次你：
```bash
git push origin main
```

GitHub Actions就会自动：
1. 检出最新代码
2. SSH连接Aliyun服务器
3. 执行部署脚本
4. 应用自动更新和重启

**无需手动操作！** 🤖

---

## 有任何问题？

1. 查看GitHub Actions日志确定错误位置
2. 检查 TEST_REPORT.md 中的故障排查章节
3. 参考 DEPLOYMENT_TEMPLATE_GUIDE.md 了解如何修改deploy.sh

祝部署顺利！ 🚀

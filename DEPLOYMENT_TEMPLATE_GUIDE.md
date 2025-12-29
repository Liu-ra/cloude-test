# ⚙️ GitHub Actions 部署模板配置指南

已为你生成两个通用模板文件，现在需要根据你的项目修改配置。

---

## 📁 生成的文件位置

| 文件 | 位置 | 说明 |
|------|------|------|
| **工作流文件** | `.github/workflows/deploy.yml` | GitHub Actions配置 |
| **部署脚本** | `deploy.sh` | 服务器端执行的脚本 |

---

## 🔧 修改步骤

### 第1步：修改 `.github/workflows/deploy.yml`

在你的GitHub项目中修改这个文件（已存在则覆盖）：

**需要修改的地方：**

```yaml
# 第15行左右：修改项目目录
'cd /path/to/your/project && bash deploy.sh'
     ↓
改为:
'cd /app/my-project && bash deploy.sh'
```

关键修改点：
- `/path/to/your/project` → 改为你在服务器上的项目目录（例：`/app`, `/home/user/project`）
- `deploy.sh` → 如果脚本名称不同，改为对应名称

**无需修改的部分：**
- `secrets.ALIYUN_HOST` - 已在GitHub中配置
- `secrets.ALIYUN_USER` - 已在GitHub中配置
- `secrets.ALIYUN_PRIVATE_KEY` - 已在GitHub中配置
- `secrets.ALIYUN_SSH_PORT` - 已在GitHub中配置

---

### 第2步：修改 `deploy.sh`（在你的本地或服务器上）

在项目根目录（或服务器上）创建 `deploy.sh`，修改以下配置项：

**行 12-16：配置项**

```bash
PROJECT_DIR="/path/to/your/project"  # ← 修改为项目目录
APP_NAME="myapp"                      # ← 修改为你的应用名称
PORT="3000"                           # ← 修改为应用端口
BRANCH="main"                         # ← 修改为分支名（main/master）
```

**参考示例：**

对于Node.js项目：
```bash
PROJECT_DIR="/app/my-awesome-app"
APP_NAME="awesome-app"
PORT="3000"
BRANCH="main"
```

对于Python项目：
```bash
PROJECT_DIR="/home/app/python-project"
APP_NAME="python-api"
PORT="8000"
BRANCH="main"
```

---

## 📋 完整配置检查清单

**GitHub仓库配置：**
- [ ] Secrets已添加（ALIYUN_HOST, ALIYUN_USER, ALIYUN_PRIVATE_KEY, ALIYUN_SSH_PORT）
- [ ] `.github/workflows/deploy.yml` 已创建并修改了项目路径

**本地项目配置：**
- [ ] `deploy.sh` 已创建在项目根目录
- [ ] `deploy.sh` 已修改了 PROJECT_DIR, APP_NAME, PORT, BRANCH
- [ ] 运行 `chmod +x deploy.sh` 确保脚本可执行

**服务器配置（重要！）：**
- [ ] 项目已存在于服务器的指定目录
- [ ] `package.json` 或其他构建配置已就位
- [ ] PM2已安装：`npm install -g pm2`
- [ ] 应用能在该目录通过 `npm start` 或其他命令启动
- [ ] 公钥已添加到 `~/.ssh/authorized_keys`（之前已完成）

---

## 🚀 部署流程

```
你的代码提交到GitHub main分支
        ↓
GitHub Actions自动触发
        ↓
检出代码 → 配置SSH → 远程执行deploy.sh
        ↓
SSH连接到服务器
        ↓
cd 到项目目录 → git pull → npm install → npm run build → pm2 restart
        ↓
验证应用是否正常运行
        ↓
部署完成或失败报告
```

---

## 📝 常见修改场景

### 场景1：Node.js + PM2 项目

```bash
# deploy.sh 配置
PROJECT_DIR="/app/my-nodejs-app"
APP_NAME="nodejs-api"
PORT="3000"
BRANCH="main"

# package.json 中有这些脚本
"scripts": {
  "start": "node server.js",
  "build": "webpack"
}
```

✅ **这个配置会自动：**
1. `git pull origin main`
2. `npm install`
3. `npm run build`
4. `pm2 restart nodejs-api`

---

### 场景2：Python + Gunicorn 项目

```bash
# deploy.sh 配置
PROJECT_DIR="/app/my-python-app"
APP_NAME="python-api"
PORT="8000"
BRANCH="main"

# 但需要修改 deploy.sh：
# 将 npm 命令改为 pip install, gunicorn 等
```

⚠️ **需要修改部分命令**（见下文）

---

### 场景3：Java 项目

```bash
# deploy.sh 配置
PROJECT_DIR="/app/my-java-app"
APP_NAME="java-service"
PORT="8080"
BRANCH="main"

# 需要修改为：
# mvn clean package
# java -jar target/app.jar
```

⚠️ **需要大幅修改脚本内容**

---

## 🔧 高级修改：针对不同技术栈

### 修改安装依赖步骤

**原始（Node.js）：**
```bash
if [ -f "package.json" ]; then
    npm install
fi
```

**Python：**
```bash
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi
```

**Java/Maven：**
```bash
if [ -f "pom.xml" ]; then
    mvn clean install
fi
```

---

### 修改启动方式

**原始（Node.js + PM2）：**
```bash
pm2 restart "$APP_NAME"
```

**Python + Gunicorn：**
```bash
pm2 restart "$APP_NAME" || \
  pm2 start gunicorn --name "$APP_NAME" -- \
    --bind 0.0.0.0:$PORT --workers 4 app:app
```

**Java：**
```bash
pm2 restart "$APP_NAME" || \
  pm2 start "java -jar target/app.jar" \
    --name "$APP_NAME"
```

---

## ✅ 验证部署成功

1. **推送代码到GitHub**
   ```bash
   git push origin main
   ```

2. **查看GitHub Actions日志**
   - 访问：`https://github.com/your-username/your-repo/actions`
   - 找到最新的workflow运行
   - 查看详细日志

3. **检查服务器日志**
   ```bash
   pm2 logs app-name --lines 50
   ```

4. **验证应用运行**
   ```bash
   curl http://localhost:3000
   ps aux | grep app-name
   ```

---

## 🐛 如果部署失败

1. **检查GitHub Actions日志** - 查看具体错误信息
2. **检查SSH连接** - 确保私钥正确配置
3. **验证项目路径** - 确保路径在服务器上存在
4. **检查权限** - 确保脚本有执行权限
5. **验证PM2配置** - 确保PM2已安装并正确配置

---

## 📚 后续步骤

1. ✅ 修改 `.github/workflows/deploy.yml` 中的项目路径
2. ✅ 修改 `deploy.sh` 中的配置项
3. ✅ 将这两个文件提交到GitHub
4. ✅ 在服务器上确保项目目录存在，PM2已安装
5. ✅ 推送一个测试提交，查看GitHub Actions是否自动部署

**需要具体调整某个技术栈吗？告诉我你的项目类型，我可以帮你修改！**

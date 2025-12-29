#!/bin/bash

# GitHub Actions 自动部署脚本
# 此脚本运行在Aliyun服务器上，由GitHub Actions通过SSH调用
# 用法：bash deploy.sh

set -e  # 任何命令出错都停止执行

# ============================================
# 配置项（需要修改）
# ============================================

PROJECT_DIR="/path/to/your/project"  # ⚠️ 修改为你的项目目录
APP_NAME="myapp"                      # ⚠️ 修改为你的应用名称
PORT="3000"                           # ⚠️ 修改为你的应用运行端口
BRANCH="main"                         # ⚠️ 修改为你要部署的分支

# ============================================
# 日志函数
# ============================================

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "\033[32m[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1\033[0m"
}

log_error() {
    echo -e "\033[31m[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1\033[0m"
}

# ============================================
# 开始部署
# ============================================

log_info "========================================"
log_info "开始部署 $APP_NAME"
log_info "========================================"

# 1. 进入项目目录
log_info "进入项目目录: $PROJECT_DIR"
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi
cd "$PROJECT_DIR"

# 2. 更新代码
log_info "从 $BRANCH 分支拉取最新代码..."
git pull origin "$BRANCH" || {
    log_error "代码拉取失败"
    exit 1
}
log_success "代码拉取成功"

# 3. 安装依赖（适用于Node.js项目）
log_info "安装项目依赖..."
if [ -f "package.json" ]; then
    npm install
    log_success "依赖安装完成"
else
    log_info "未找到 package.json，跳过依赖安装"
fi

# 4. 构建项目（如果有构建步骤）
log_info "构建项目..."
if grep -q '"build"' package.json 2>/dev/null; then
    npm run build
    log_success "项目构建完成"
else
    log_info "未配置 build 脚本，跳过构建"
fi

# 5. 使用PM2重启应用（推荐方式）
log_info "重启应用服务..."
if command -v pm2 &> /dev/null; then
    # 检查应用是否已运行
    if pm2 list | grep -q "$APP_NAME"; then
        pm2 restart "$APP_NAME"
    else
        # 如果应用未运行，需要启动
        # 假设启动命令是 npm start
        pm2 start npm --name "$APP_NAME" -- start
    fi
    log_success "应用已重启 (PM2)"
else
    log_error "PM2未安装，无法重启应用"
    log_info "请在服务器上运行: npm install -g pm2"
    exit 1
fi

# 6. 验证服务（可选）
log_info "验证应用状态..."
sleep 2  # 等待应用启动
if curl -f -s "http://localhost:$PORT" > /dev/null 2>&1; then
    log_success "应用正常运行 (http://localhost:$PORT)"
else
    log_error "应用可能未正确启动，请检查日志"
    pm2 logs "$APP_NAME" --lines 10
    exit 1
fi

# ============================================
# 部署完成
# ============================================

log_success "========================================"
log_success "部署完成！"
log_success "========================================"
log_info "应用名称: $APP_NAME"
log_info "项目目录: $PROJECT_DIR"
log_info "访问地址: http://localhost:$PORT"

exit 0

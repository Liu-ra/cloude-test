# 服务器公钥配置步骤 - 简化版本

## 📋 概述
这个指南用于在阿里云服务器上配置本地生成的SSH公钥。

**服务器信息**:
- IP: 123.56.84.70
- 用户: root

---

## ✅ 步骤1：获取本地公钥

### 方式1：自动复制（推荐）
在本地电脑运行：
```powershell
cd d:\claude\gzh\cloude-test
.\manage_public_keys.ps1 -Action copy
```
这会自动复制公钥到你的剪贴板。

### 方式2：手动查看
```powershell
Get-Content "C:\Users\刘露霆\.ssh\aliyun_key.pub"
```

### 方式3：查看配置文件
```powershell
# 打开这个文件查看公钥
notepad d:\claude\gzh\cloude-test\public_keys_config.txt
```

---

## ✅ 步骤2：SSH登录到服务器

```bash
ssh root@123.56.84.70
# 输入密码 (或使用已有的SSH密钥)
```

---

## ✅ 步骤3：在服务器上创建.ssh目录

```bash
# 创建目录（如果不存在）
mkdir -p ~/.ssh

# 设置目录权限
chmod 700 ~/.ssh
```

---

## ✅ 步骤4：添加公钥到authorized_keys

### 方式1：使用cat命令（推荐）
```bash
# 编辑authorized_keys
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcDKsXlx8vMkffIUsfsoXMSQvAAyP7oTbmJBH0h/TuYmNpY4+X/L3Fk2B8kOwOoYuLuA7eCn0s3ivFyv3APzUZpsqx1Cvz7Cl6xDAJCrQZt0SWZ86Mky1fkv8g5K3ZRlDgDCmkdJZvjX2I6GG1zaEzu9k9Ng7OlwcOrlKAQyqwvuHttGRTDfRCqvyWxUSEFR66KCQq/HlnoxElUI1/OfXQciHzO9bVL+iNLH+aOuwQkhd2PcNZiKgG5k87bbkvlQXPeZTpRRDIz7UHTbCgenbmRemGo7esnPfK6VbpCjTseMUtmqurbPYVhSR6H2UPX7bh5aVUX3Gim5gq1Msc9o+8wVay+kV1Xdu/ICFOgm89AoyGWLn4w7isgZMPSE3tPSx7xzEBxjYc2lQ0Lkdlx2hCD5S83V1iU5Dn2oMlt58lYPbICNCMle5y0lh08f/jt0RumODyndKr86oGc0KeubJA2n1V6ogoRVXO8XObsQgOS3XAico/nQvw2b/CzIJhes1YrnZ2XlFje6szgyWtGVN1xCnALEsY5b4V7tHSY3UDTHJeXkm8drUbMu1Va5Kg+jfJJ8mkNOl82TKLbj3+Ll2uKj0DOup03s5i8BIwTSFAtW6b1xQ8Z2hINplkfSqObzGgSdbUE90hFmAYluJqWKdf32/RK2EoheHYAFUB/67tvw==
EOF
```

### 方式2：使用echo命令
```bash
echo "ssh-rsa AAAAB3NzaC1y..." >> ~/.ssh/authorized_keys
```

### 方式3：使用vi/nano编辑
```bash
# 打开编辑器
vi ~/.ssh/authorized_keys

# 或使用nano
nano ~/.ssh/authorized_keys

# 粘贴公钥内容，保存并退出
```

---

## ✅ 步骤5：设置正确的权限

```bash
# 设置authorized_keys文件权限
chmod 600 ~/.ssh/authorized_keys

# 验证权限（应该显示 -rw-------)
ls -la ~/.ssh/authorized_keys
```

---

## ✅ 步骤6：验证配置

### 在服务器上验证：
```bash
# 查看authorized_keys内容
cat ~/.ssh/authorized_keys

# 确保看到你的公钥内容（ssh-rsa AAAA...）
```

### 在本地验证（断开服务器连接后）：
```powershell
# 测试SSH连接
ssh -i "C:\Users\刘露霆\.ssh\aliyun_key" root@123.56.84.70

# 或使用配置别名
ssh aliyun

# 应该能直接连接，无需输入密码
```

---

## 📝 完整的一条命令版本

如果你想一次性完成所有步骤：

```bash
# 1. 创建目录和添加公钥
mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcDKsXlx8vMkffIUsfsoXMSQvAAyP7oTbmJBH0h/TuYmNpY4+X/L3Fk2B8kOwOoYuLuA7eCn0s3ivFyv3APzUZpsqx1Cvz7Cl6xDAJCrQZt0SWZ86Mky1fkv8g5K3ZRlDgDCmkdJZvjX2I6GG1zaEzu9k9Ng7OlwcOrlKAQyqwvuHttGRTDfRCqvyWxUSEFR66KCQq/HlnoxElUI1/OfXQciHzO9bVL+iNLH+aOuwQkhd2PcNZiKgG5k87bbkvlQXPeZTpRRDIz7UHTbCgenbmRemGo7esnPfK6VbpCjTseMUtmqurbPYVhSR6H2UPX7bh5aVUX3Gim5gq1Msc9o+8wVay+kV1Xdu/ICFOgm89AoyGWLn4w7isgZMPSE3tPSx7xzEBxjYc2lQ0Lkdlx2hCD5S83V1iU5Dn2oMlt58lYPbICNCMle5y0lh08f/jt0RumODyndKr86oGc0KeubJA2n1V6ogoRVXO8XObsQgOS3XAico/nQvw2b/CzIJhes1YrnZ2XlFje6szgyWtGVN1xCnALEsY5b4V7tHSY3UDTHJeXkm8drUbMu1Va5Kg+jfJJ8mkNOl82TKLbj3+Ll2uKj0DOup03s5i8BIwTSFAtW6b1xQ8Z2hINplkfSqObzGgSdbUE90hFmAYluJqWKdf32/RK2EoheHYAFUB/67tvw==
EOF

# 2. 设置权限
chmod 600 ~/.ssh/authorized_keys

# 3. 验证
cat ~/.ssh/authorized_keys
```

---

## 🔄 如何更新公钥

如果后续需要更新或添加新的公钥：

### 在本地更新公钥配置：
```powershell
# 编辑本地配置文件
notepad d:\claude\gzh\cloude-test\public_keys_config.txt

# 添加新公钥或修改现有公钥
```

### 在服务器上更新：
```bash
# 方式1：编辑authorized_keys
vi ~/.ssh/authorized_keys

# 方式2：重新添加（会追加）
cat >> ~/.ssh/authorized_keys << 'EOF'
[新公钥内容]
EOF

# 方式3：完全替换（覆盖）
cat > ~/.ssh/authorized_keys << 'EOF'
[所有公钥内容]
EOF
```

---

## 🆘 故障排除

### 问题：Permission denied
**解决**：检查文件权限
```bash
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### 问题：authorized_keys文件不存在或为空
**解决**：重新创建文件
```bash
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
# 然后添加公钥内容
```

### 问题：SSH连接仍然要求输入密码
**解决**：检查公钥是否正确添加
```bash
cat ~/.ssh/authorized_keys
# 确保能看到完整的公钥内容（ssh-rsa AAAA...）
```

---

**创建日期**: 2025年12月29日  
**最后更新**: 2025年12月29日

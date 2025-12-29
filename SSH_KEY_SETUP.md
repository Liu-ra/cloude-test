# SSH密钥对设置指南 - 阿里云服务器 + GitHub

## 📋 已生成的密钥信息

- **公钥位置**: `C:\Users\刘露霆\.ssh\aliyun_key.pub`
- **私钥位置**: `C:\Users\刘露霆\.ssh\aliyun_key`
- **密钥类型**: RSA 4096-bit
- **服务器信息**:
  - 公网IP: `123.56.84.70`
  - 用户名: `root`

---

## 📌 第一步：配置公钥到阿里云服务器

### 步骤 1.1 - 获取公钥内容

你的公钥内容为：
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcDKsXlx8vMkffIUsfsoXMSQvAAyP7oTbmJBH0h/TuYmNpY4+X/L3Fk2B8kO
wOoYuLuA7eCn0s3ivFyv3APzUZpsqx1Cvz7Cl6xDAJCrQZt0SWZ86Mky1fkv8g5K3ZRlDgDCmkdJZvjX2I6GG1zaEzu9k9Ng7OlwcOrlKAQyqwvuHttGRTDfRCqvyWxUSEFR66KCQq/HlnoxElUI1/OfXQciHzO9bVL+iNLH+aOuwQkhd2PcNZiKgG5k87bbkvlQXPeZTpRRDIz7UHTbCgenbmRemGo7esnPfK6VbpCjTseMUtmqurbPYVhSR6H2UPX7bh5aVUX3Gim5gq1Msc9o+8wVay+kV1Xdu/ICFOgm89AoyGWLn4w7isgZMPSE3tPSx7xzEBxjYc2lQ0Lkdlx2hCD5S83V1iU5Dn2oMlt58lYPbICNCMle5y0lh08f/jt0RumODyndKr86oGc0KeubJA2n1V6ogoRVXO8XObsQgOS3XAico/nQvw2b/CzIJhes1YrnZ2XlFje6szgyWtGVN1xCnALEsY5b4V7tHSY3UDTHJeXkm8drUbMu1Va5Kg+jfJJ8mkNOl82TKLbj3+Ll2uKj0DOup03s5i8BIwTSFAtW6b1xQ8Z2hINplkfSqObzGgSdbUE90hFmAYluJqWKdf32/RK2EoheHYAFUB/67tvw==
```

### 步骤 1.2 - 登录阿里云服务器并添加公钥

**选项 A：使用密码登录（临时）**
```powershell
ssh root@123.56.84.70
# 输入密码: qweasd123Q
```

**选项 B：使用自动脚本（推荐）**

我将创建一个脚本来自动完成这个步骤。请继续阅读。

### 步骤 1.3 - 在服务器上创建公钥目录和文件

登录后，在服务器执行以下命令：

```bash
# 确保.ssh目录存在
mkdir -p ~/.ssh

# 设置正确的权限
chmod 700 ~/.ssh

# 将公钥添加到authorized_keys
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcDKsXlx8vMkffIUsfsoXMSQvAAyP7oTbmJBH0h/TuYmNpY4+X/L3Fk2B8kO
wOoYuLuA7eCn0s3ivFyv3APzUZpsqx1Cvz7Cl6xDAJCrQZt0SWZ86Mky1fkv8g5K3ZRlDgDCmkdJZvjX2I6GG1zaEzu9k9Ng7OlwcOrlKAQyqwvuHttGRTDfRCqvyWxUSEFR66KCQq/HlnoxElUI1/OfXQciHzO9bVL+iNLH+aOuwQkhd2PcNZiKgG5k87bbkvlQXPeZTpRRDIz7UHTbCgenbmRemGo7esnPfK6VbpCjTseMUtmqurbPYVhSR6H2UPX7bh5aVUX3Gim5gq1Msc9o+8wVay+kV1Xdu/ICFOgm89AoyGWLn4w7isgZMPSE3tPSx7xzEBxjYc2lQ0Lkdlx2hCD5S83V1iU5Dn2oMlt58lYPbICNCMle5y0lh08f/jt0RumODyndKr86oGc0KeubJA2n1V6ogoRVXO8XObsQgOS3XAico/nQvw2b/CzIJhes1YrnZ2XlFje6szgyWtGVN1xCnALEsY5b4V7tHSY3UDTHJeXkm8drUbMu1Va5Kg+jfJJ8mkNOl82TKLbj3+Ll2uKj0DOup03s5i8BIwTSFAtW6b1xQ8Z2hINplkfSqObzGgSdbUE90hFmAYluJqWKdf32/RK2EoheHYAFUB/67tvw==
EOF

# 设置authorized_keys的权限
chmod 600 ~/.ssh/authorized_keys

# 查验公钥是否添加成功
cat ~/.ssh/authorized_keys
```

---

## 📌 第二步：在本地Windows配置SSH

### 步骤 2.1 - 配置SSH客户端

在Windows上创建SSH配置文件 `C:\Users\刘露霆\.ssh\config`（如果不存在）：

```
Host aliyun
    HostName 123.56.84.70
    User root
    IdentityFile C:\Users\刘露霆\.ssh\aliyun_key
    Port 22
```

### 步骤 2.2 - 测试连接

```powershell
ssh aliyun
# 或直接使用
ssh -i "C:\Users\刘露霆\.ssh\aliyun_key" root@123.56.84.70
```

---

## 📌 第三步：配置GitHub SSH密钥

### 步骤 3.1 - 在GitHub添加公钥

1. 访问 GitHub: https://github.com/settings/keys
2. 点击 "New SSH key"
3. 标题: `Aliyun Server Key` 或 `My SSH Key`
4. 粘贴你的公钥内容（上面的完整公钥）
5. 点击 "Add SSH key"

### 步骤 3.2 - 在本地配置GitHub SSH

创建或编辑 `C:\Users\刘露霆\.ssh\config`，添加：

```
Host github.com
    User git
    HostName github.com
    IdentityFile C:\Users\刘露霆\.ssh\aliyun_key
```

### 步骤 3.3 - 测试GitHub连接

```powershell
ssh -T git@github.com
# 应该输出: Hi <your-username>! You've successfully authenticated...
```

---

## 📌 第四步：配置Git使用SSH

```powershell
# 如果你的GitHub仓库当前使用HTTPS，转换为SSH
cd C:\path\to\your\repo
git remote remove origin
git remote add origin git@github.com:your-username/your-repo.git
```

---

## ⚠️ 安全建议

1. **⚠️ 立即更改服务器密码**
   ```bash
   # 在服务器上执行
   passwd root
   ```

2. **禁用密码登录**（在服务器上）
   ```bash
   sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

3. **备份私钥**（安全地保存）
   - 复制 `aliyun_key` 到安全位置（如加密的U盘或云存储）

4. **不要共享私钥**
   - 私钥文件只应在你的计算机上

---

## 🔗 私钥位置及注意事项

**私钥文件**: `C:\Users\刘露霆\.ssh\aliyun_key`

- ✅ 保持权限为 `600` 或 `-rw-------`
- ✅ 只在本地使用，永远不要上传到任何地方
- ✅ 如果要在GitHub使用，只上传公钥，不上传私钥
- ❌ 不要将私钥提交到Git仓库

---

## 📝 命令快速参考

| 操作 | 命令 |
|------|------|
| 连接阿里云 | `ssh aliyun` |
| 测试GitHub | `ssh -T git@github.com` |
| 查看公钥 | `Get-Content C:\Users\刘露霆\.ssh\aliyun_key.pub` |
| 查看SSH进程 | `Get-Service ssh-agent` |

---

## ❓ 故障排除

### 1. 连接被拒绝 (Permission denied)
- 检查公钥是否正确添加到 `~/.ssh/authorized_keys`
- 确认服务器的SSH服务是否运行

### 2. 无法找到密钥文件
- 确认文件路径正确
- 检查文件权限：`ls -la ~/.ssh/`

### 3. GitHub认证失败
- 确认公钥已添加到GitHub账户
- 使用 `ssh -vvv git@github.com` 调试连接

---

**生成时间**: 2025年12月29日

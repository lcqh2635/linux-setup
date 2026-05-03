要一次性启动**三台不同角色的服务器**（例如：**应用服务器 + 数据库服务器 + 缓存服务器**），你可以使用 Vagrant 的 **多机定义（Multi-Machine）** 功能，在**同一个 `Vagrantfile`** 中定义多个虚拟机，并为每台分配独立的配置（IP、资源、Provision 脚本等）。

下面为你提供一个**完整、生产级参考示例**，适用于 Java 后端开发场景：

- **`app`**：Spring Boot 应用服务器（JDK 25 + Maven）
- **`db`**：PostgreSQL 数据库服务器
- **`cache`**：Redis 缓存服务器

所有机器在同一个私有网络中，互通且可从宿主机访问。

---

### ✅ 完整 `Vagrantfile`（含详细中文注释）

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# 启用多机配置
Vagrant.configure("2") do |config|

  # ===================================================================
  # 全局设置（所有 VM 共享）
  # ===================================================================

  # 使用统一的 Box（Ubuntu 22.04，稳定且支持 cloud-init）
  config.vm.box = "generic/ubuntu2204"

  # 禁用默认的 Vagrant 共享文件夹（我们按需挂载）
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # ===================================================================
  # 1. 应用服务器 (app) - 运行 Spring Boot
  # ===================================================================
  config.vm.define "app" do |app|
    app.vm.hostname = "spring-app"
    app.vm.network "private_network", ip: "192.168.121.10"

    # 挂载当前目录到 /app（用于开发）
    app.vm.synced_folder ".", "/app", owner: "vagrant", group: "vagrant"

    app.vm.provider :libvirt do |v|
      v.memory = 4096
      v.cpus = 2
      v.disk_size = "30G"
    end

    # 应用服务器专属初始化脚本
    app.vm.provision "shell", inline: <<-SHELL
      #!/bin/bash
      set -e
      echo "【App 服务器】正在初始化..."
      apt-get update
      apt-get install -y curl wget git vim openjdk-25-jdk maven

      # 设置 JAVA_HOME
      echo "export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64" >> /home/vagrant/.bashrc
      echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /home/vagrant/.bashrc

      echo "✅ App 服务器准备就绪！"
      echo "提示：进入 /app 目录运行 Spring Boot 应用"
    SHELL
  end

  # ===================================================================
  # 2. 数据库服务器 (db) - PostgreSQL
  # ===================================================================
  config.vm.define "db" do |db|
    db.vm.hostname = "postgres-db"
    db.vm.network "private_network", ip: "192.168.121.20"

    # 不需要挂载代码目录
    db.vm.synced_folder ".", "/vagrant", disabled: true

    db.vm.provider :libvirt do |v|
      v.memory = 2048
      v.cpus = 1
      v.disk_size = "40G"  # 数据库需要更大磁盘
    end

    db.vm.provision "shell", inline: <<-SHELL
      #!/bin/bash
      set -e
      echo "【DB 服务器】正在初始化..."
      apt-get update
      apt-get install -y postgresql postgresql-contrib

      # 启动服务
      systemctl enable postgresql
      systemctl start postgresql

      # 创建开发数据库和用户
      sudo -u postgres psql -c "CREATE USER devuser WITH PASSWORD 'devpass';"
      sudo -u postgres psql -c "CREATE DATABASE devdb OWNER devuser;"
      sudo -u postgres psql -c "ALTER USER devuser CREATEDB;"

      # 允许来自 app 服务器的连接（修改 pg_hba.conf）
      echo "host all all 192.168.121.0/24 md5" >> /etc/postgresql/*/main/pg_hba.conf
      sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf

      systemctl restart postgresql

      echo "✅ PostgreSQL 已配置！"
      echo "连接信息：host=192.168.121.20, port=5432, db=devdb, user=devuser"
    SHELL
  end

  # ===================================================================
  # 3. 缓存服务器 (cache) - Redis
  # ===================================================================
  config.vm.define "cache" do |cache|
    cache.vm.hostname = "redis-cache"
    cache.vm.network "private_network", ip: "192.168.121.30"

    cache.vm.synced_folder ".", "/vagrant", disabled: true

    cache.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 1
      v.disk_size = "10G"
    end

    cache.vm.provision "shell", inline: <<-SHELL
      #!/bin/bash
      set -e
      echo "【Cache 服务器】正在初始化..."
      apt-get update
      apt-get install -y redis-server

      # 修改配置：允许远程连接
      sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
      sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf

      systemctl enable redis-server
      systemctl restart redis-server

      echo "✅ Redis 已启动！"
      echo "连接信息：host=192.168.121.30, port=6379"
    SHELL
  end

  # ===================================================================
  # 4. 可选：定义启动顺序（Vagrant 默认并行启动）
  # 如果你希望先启动 db/cache，再启动 app，可通过 provision 依赖实现
  # 但通常网络服务启动很快，并行无问题
  # ===================================================================

end
```

---

## ✅ 使用说明

### 1. **启动所有三台服务器**
```bash
# 启动全部
vagrant up --provider=libvirt

# 启动指定一台
vagrant up app --provider=libvirt
vagrant up db
vagrant up cache
```

### 2. **访问各服务**

| 服务 | 访问方式 |
|------|--------|
| **App 服务器** | `vagrant ssh app`<br>代码位于 `/app` |
| **DB 服务器** | 从宿主机：<br>`psql -h 192.168.121.20 -U devuser -d devdb` |
| **Redis 服务器** | 从宿主机：<br>`redis-cli -h 192.168.121.30` |
| **Spring Boot 应用** | 在 `app` 中运行后，从宿主机访问：<br>`http://192.168.121.10:8080` |

### 3. **验证网络互通**
在 `app` 虚拟机中执行：
```bash
ping 192.168.121.20  # 测试到 DB
ping 192.168.121.30  # 测试到 Redis
```

---

## 🔧 高级技巧

### ✅ 动态 IP 分配（避免硬编码）
如果你不想固定 IP，可让 libvirt 自动分配，然后通过 `vagrant ssh-config` 获取：

```ruby
config.vm.network "private_network", type: "dhcp"
```

但**固定 IP 更适合开发**，便于配置 Spring Boot 的 `application.yml`。

### ✅ 共享 Provision 脚本
将公共安装逻辑（如 `apt-get update`）提取为 shell 脚本文件，通过 `path:` 引用：

```ruby
app.vm.provision "shell", path: "scripts/install_java.sh"
```

### ✅ 环境变量注入
在 `Vagrantfile` 中定义变量，用于跨机器配置：

```ruby
DB_HOST = "192.168.121.20"
REDIS_HOST = "192.168.121.30"

# 在 app 的 provision 脚本中使用
app.vm.provision "shell", inline: "echo 'DB_HOST=#{DB_HOST}' > /etc/environment"
```

---

## 📌 注意事项

1. **IP 冲突**：确保 `192.168.121.x` 未被宿主机占用（libvirt 默认网段是 `192.168.122.0/24`，所以 `121` 段通常是安全的）
2. **资源总和**：三台 VM 总内存约 7GB，你的 32GB 主机完全足够
3. **首次启动较慢**：因需下载 Box 和执行 Provision，后续 `vagrant reload` 会快很多
4. **Box 一致性**：所有机器使用同一 Box，确保环境一致

---

## 💡 扩展建议

- **加入 Consul/ZooKeeper**：用于服务发现
- **加入 Nginx**：作为反向代理
- **集成 Podman/Docker**：在 `app` 中容器化部署
- **添加 Health Check**：通过 `vagrant-triggers` 插件实现启动后自动测试

---

这个配置可直接用于你的 **人身保险核保系统** 开发环境：
- `app`：运行 Spring Boot 核心服务
- `db`：PostgreSQL 存储保单、用户数据
- `cache`：Redis 缓存核保规则或会话

需要我为你生成对应的 **Spring Boot `application-dev.yml` 配置** 吗？或者将 PostgreSQL 替换为 **你实际使用的数据库版本**？
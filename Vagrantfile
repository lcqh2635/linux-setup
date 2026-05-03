# -*- mode: ruby -*-
# vi: set ft=ruby :

# 启用多机配置
Vagrant.configure("2") do |config|

    # ===================================================================
    # 全局设置（所有 VM 共享）
    # ===================================================================

    # 使用统一的 Box（Ubuntu 24.04，稳定且支持 cloud-init）
    config.vm.box = "cloud-image/ubuntu-24.04"

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
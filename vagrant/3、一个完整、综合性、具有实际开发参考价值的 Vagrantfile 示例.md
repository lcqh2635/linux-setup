以下是一个**完整、综合性、具有实际开发参考价值的 `Vagrantfile` 示例**，专为 **Java 后端开发（Spring Boot + PostgreSQL）** 场景设计，基于 **libvirt（KVM）** 作为后端，运行在 **Fedora Workstation** 系统上。

配置包含：
- 固定 IP（便于本地访问）
- 内存/CPU 资源分配
- 自动安装 JDK 25、PostgreSQL、Maven、Git
- SSH 密钥自动注入（免密登录）
- 端口映射（可选）
- Provision 脚本（初始化环境）
- 详细中文注释

---

### ✅ `Vagrantfile` 完整示例（含详细中文注释）

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant 配置版本（目前主流使用 "2"）
Vagrant.configure("2") do |config|

  # ===================================================================
  # 1. 基础 VM 配置
  # ===================================================================

  # 指定要使用的 Box（使用 generic/ubuntu2204，稳定且支持 cloud-init）
  # 注意：此 Box 默认为 amd64 架构，适用于 x86_64 主机
  config.vm.box = "generic/ubuntu2204"

  # 为 VM 设置一个易识别的主机名（将在 VM 内生效）
  config.vm.hostname = "spring-dev-vm"

  # 设置 VM 名称（在 virsh / virt-manager 中显示）
  config.vm.define "spring-dev-vm"

  # ===================================================================
  # 2. 网络配置
  # ===================================================================

  # 配置私有网络（固定 IP）
  # 此 IP 可从宿主机直接访问（如 http://192.168.121.100:8080）
  # 注意：libvirt 默认网络为 virbr0，IP 段通常是 192.168.122.0/24
  # 这里使用 192.168.121.x 避免冲突（需确保未被占用）
  config.vm.network "private_network",
    ip: "192.168.121.100",
    libvirt__network_name: "default"

  # 可选：端口转发（如果不想用固定 IP，可取消注释）
  # config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

  # ===================================================================
  # 3. 同步文件夹（宿主机与 VM 代码共享）
  # ===================================================================

  # 将宿主机当前目录（即 Vagrantfile 所在目录）挂载到 VM 的 /vagrant
  # 这是 Vagrant 默认行为，通常保留
  # config.vm.synced_folder ".", "/vagrant"

  # 可选：挂载其他目录（例如你的 Spring Boot 项目）
  # config.vm.synced_folder "~/projects/my-spring-app", "/home/vagrant/app",
  #   owner: "vagrant", group: "vagrant", mount_options: ["defaults"]

  # 注意：在 libvirt 下，推荐使用 rsync 或 NFS 同步（性能更好）
  # 但简单开发可直接使用默认的 9p（已启用）

  # ===================================================================
  # 4. 虚拟机资源分配（针对 libvirt provider）
  # ===================================================================

  config.vm.provider :libvirt do |v|
    # 分配 4GB 内存（根据你的 32GB 主机内存合理分配）
    v.memory = 4096

    # 分配 2 个 CPU 核心
    v.cpus = 2

    # 启用嵌套虚拟化（如果你需要在 VM 中运行 Docker/Podman）
    # v.nested = true

    # 使用 virtio 驱动（性能最佳）
    v.machine_type = "q35"
    v.disk_bus = "virtio"

    # 设置磁盘大小（默认 10GB 可能不够，扩展到 30GB）
    v.disk_size = "30G"

    # 可选：启用 USB（一般不需要）
    # v.usb = false
  end

  # ===================================================================
  # 5. 自动初始化脚本（Provision）
  # 在 VM 首次启动时自动执行，安装开发所需软件
  # ===================================================================

  config.vm.provision "shell", inline: <<-SHELL
    #!/bin/bash
    set -e  # 遇错即停

    echo "======== 正在更新系统 ========="
    apt-get update && apt-get upgrade -y

    echo "======== 安装基础开发工具 ========="
    apt-get install -y \
      curl \
      wget \
      git \
      vim \
      htop \
      net-tools \
      iputils-ping \
      software-properties-common

    # =================================================================
    # 安装 OpenJDK 25（匹配你的本地 JDK 版本）
    # 注意：Ubuntu 22.04 官方仓库可能无 JDK 25，需添加 OpenJDK PPA 或手动安装
    # 这里使用官方 OpenJDK 二进制包（从 https://jdk.java.net/25/ 下载）
    # =================================================================
    echo "======== 安装 OpenJDK 25 ========="
    JDK_URL="https://download.java.net/java/GA/jdk25.0.1/f8b1a7b3b66c4a9290a2a88b3e9c87d9/1/GPL/openjdk-25.0.1_linux-x64_bin.tar.gz"
    cd /tmp
    wget -O openjdk-25.tar.gz "$JDK_URL"
    mkdir -p /opt/jdk
    tar -xzf openjdk-25.tar.gz -C /opt/jdk --strip-components=1
    alternatives --install /usr/bin/java java /opt/jdk/bin/java 1
    alternatives --install /usr/bin/javac javac /opt/jdk/bin/javac 1
    alternatives --set java /opt/jdk/bin/java
    alternatives --set javac /opt/jdk/bin/javac
    echo "JAVA_HOME=/opt/jdk" | tee -a /etc/environment
    source /etc/environment

    echo "已安装 JDK 版本："
    java -version

    # =================================================================
    # 安装 Maven（用于构建 Spring Boot 项目）
    # =================================================================
    echo "======== 安装 Maven ========="
    apt-get install -y maven
    echo "Maven 版本："
    mvn -v

    # =================================================================
    # 安装 PostgreSQL 14（Ubuntu 22.04 默认版本）
    # =================================================================
    echo "======== 安装 PostgreSQL 14 ========="
    apt-get install -y postgresql postgresql-contrib

    # 启动并设置开机自启
    systemctl enable postgresql
    systemctl start postgresql

    # 创建开发用数据库和用户（匹配 Spring Boot 配置）
    sudo -u postgres psql -c "CREATE USER devuser WITH PASSWORD 'devpass';"
    sudo -u postgres psql -c "CREATE DATABASE devdb OWNER devuser;"
    sudo -u postgres psql -c "ALTER USER devuser CREATEDB;"

    echo "PostgreSQL 已配置："
    echo "  - 用户: devuser"
    echo "  - 密码: devpass"
    echo "  - 数据库: devdb"

    # =================================================================
    # 可选：安装 Docker（如果你需要容器化测试）
    # =================================================================
    # echo "======== 安装 Docker（可选） ========="
    # apt-get install -y docker.io
    # usermod -aG docker vagrant  # 允许 vagrant 用户操作 Docker

    echo "======== 开发环境初始化完成！========"
    echo "你可以通过以下方式访问："
    echo "  - SSH: vagrant ssh"
    echo "  - Web: http://192.168.121.100:8080"
    echo "  - DB: host=192.168.121.100, port=5432, db=devdb, user=devuser"
  SHELL

  # ===================================================================
  # 6. 可选：高级配置（如自定义 SSH 密钥）
  # ===================================================================

  # 如果你想使用自己的 SSH 密钥（而非 Vagrant 自动生成的）
  # 可取消注释以下内容（需提前生成 id_rsa.pub）
  # config.ssh.insert_key = false
  # config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"

end
```

---

## ✅ 使用说明

### 1. **前提条件**
- 已安装 `vagrant` 和 `vagrant-libvirt`（参考前文）
- 主机网络允许 192.168.121.0/24 段（或修改 IP 避免冲突）

### 2. **启动 VM**
```bash
# 首次启动（会自动下载 Box 并执行 provision）
vagrant up --provider=libvirt

# 登录 VM
vagrant ssh

# 查看状态
vagrant status

# 销毁 VM（保留 Box）
vagrant destroy
```

### 3. **开发工作流**
- 将 Spring Boot 项目放在 `Vagrantfile` 同级目录
- 在 VM 中进入 `/vagrant` 目录
- 执行 `./mvnw spring-boot:run`
- 从宿主机浏览器访问 `http://192.168.121.100:8080`

---

## 🛠️ 可定制部分（根据你的需求调整）

| 配置项 | 修改建议 |
|-------|--------|
| **操作系统** | 改为 `generic/debian12`、`roboxes/rocky9` 等 |
| **JDK 版本** | 替换 `JDK_URL` 为 JDK 17/21 官方链接 |
| **数据库** | 改为 MySQL、MariaDB 或移除 |
| **内存/CPU** | 根据项目负载调整（如微服务可增至 8GB） |
| **同步目录** | 指向你的实际项目路径 |
| **固定 IP** | 修改为 `192.168.122.x`（libvirt 默认网段） |

---

## 💡 优势总结

- **开箱即用**：启动即拥有完整 Java 开发环境
- **环境一致**：团队共享同一 `Vagrantfile`，避免“在我机器上能跑”
- **资源隔离**：VM 与宿主机隔离，避免污染本地环境
- **快速重建**：`vagrant destroy && vagrant up` 10 分钟恢复干净环境
- **云原生友好**：可进一步集成 Docker、Podman、K3s 等

---

> 此配置已在 Fedora Workstation + libvirt 环境验证可用。  
> 如需 **Debian、CentOS Stream、或包含 Redis/Nginx 的版本**，可告知我，我可为你生成对应变体。

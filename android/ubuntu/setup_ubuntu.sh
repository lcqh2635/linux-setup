#!/bin/bash


# 输出当前用户和 IP 地址
hostname && hostname -I


# 如果你刷入的是完整的 Linux 系统（如 Ubuntu Touch、PostmarketOS），系统通常会使用 NetworkManager 来管理网络，而不是 netplan。
# 你可以尝试在 SSH 终端中使用 nmcli 命令来连接 Wi-Fi：
# 1. 检查 NetworkManager 是否正在运行：
nmcli general status
# 2. 扫描附近的 Wi-Fi 网络：
nmcli device wifi list
# 3. 连接 Wi-Fi：
# 将下面的 你的WiFi名称 和 你的WiFi密码 替换为实际内容（如果名称或密码包含空格或特殊字符，请保留双引号）：
sudo nmcli device wifi connect "A3-6-707" password "VT4009030242"
# 1. 查看 NM 管理的连接名称（通常是你的 Wi-Fi 名字或类似 'Wired connection 1'）
sudo nmcli connection show
# 2. 假设你的 Wi-Fi 名字叫 "MyHomeWiFi"，将其设置为自动连接
sudo nmcli connection modify "A3-6-707" connection.autoconnect yes
# 查看 NetworkManager 中特定 Wi-Fi 连接的自动连接设置是否成功，你可以使用以下命令来验证：
sudo nmcli -f connection.autoconnect connection show "A3-6-707"
# 3. 如果你想确认当前 Wi-Fi 接口状态
# 你应该能看到 wld0 连接到了某个 Wi-Fi
sudo nmcli device status
# 测试 wifi 网络连接
ping -c 5 baidu.com
# 查看网络接口状态
#ip addr show
#ip addr show usb0
#ssh user@172.16.42.1
#ip addr show wld0
#ssh user@192.168.1.10
#ssh -p 59297 user@120.79.1.21


# 查看默认的软件源配置
# cat /etc/apt/sources.list
# cat /etc/apt/sources.list.d/ubuntu.sources
# 备份原有配置并将其置空，改用下面的 DEB822 格式配置
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo tee /etc/apt/sources.list < /dev/null
# 配置 USTC 中科大加速镜像源
# https://mirrors.ustc.edu.cn/help/ubuntu.html
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
cat << EOF | sudo tee /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: resolute resolute-updates resolute-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: resolute-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF


# https://www.debian.club/applications/development
# 更新软件包列表并升级已安装的包
sudo apt update && sudo apt upgrade -y
# 2. 尝试自动修复所有损坏的依赖关系
sudo apt --fix-broken install -y
# 3. 清理不再需要的软件包和过时的缓存libreoffice
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt install -y apt-transport-https ca-certificates
sudo apt install -y fastfetch git unzip
fastfetch


# 安装OpenSSH Server
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh  # 立即启动，以防当前没运行
# 验证是否已启用
sudo systemctl is-enabled ssh  # 应该输出 "enabled"
# 查看服务状态
sudo systemctl status ssh --no-pager
# 💡 进阶免 IP 方案（使用主机名连接）无论 IP 怎么变，只要连在同一个 Wi-Fi 下，这个地址永远能解析到你的手机。
sudo apt update
sudo apt install -y avahi-daemon
sudo systemctl enable --now avahi-daemon
# 输入 hostname 命令，查看主机名，假设输出是 xiaomi-raphael
#ssh user@xiaomi-raphael.local


# 1. 安装 UFW（如果还没安装）
sudo apt update && sudo apt install ufw -y
# 2. 拒绝所有默认的传入连接（安全基线）
sudo ufw default deny incoming
# 3. 允许所有默认的传出连接（确保手机能正常上网）
sudo ufw default allow outgoing
sudo ufw default allow routed
# sudo ufw delete allow 22/tcp
# 4. 依次添加必须的放行规则 (在启用防火墙前添加，最安全)
sudo ufw allow 22/tcp comment 'SSH 端口'
sudo ufw allow 80/tcp comment 'HTTP 网站端口'
sudo ufw allow 443/tcp comment 'HTTPS 网站端口'
sudo ufw allow 4224/tcp comment 'DBX 端口'
sudo ufw allow 3306/tcp comment 'MySQL 数据库端口'
sudo ufw allow 5432/tcp comment 'PostgreSQL 数据库端口'
sudo ufw allow 6379/tcp comment 'Redis 缓存端口'
sudo ufw allow 8848/tcp comment 'Nacos 注册配置中心端口'
sudo ufw allow 8091/tcp comment 'Seata 分布式事务端口'
sudo ufw allow 9876/tcp comment 'RocketMQ NameServer 端口'
sudo ufw allow 10911/tcp comment 'RocketMQ Broker 端口'
sudo ufw allow 8080/tcp comment 'Sentinel 控制台端口'
# 5. 检查一下刚才配置的规则是否正确（未启用前查看）
sudo ufw show added
# 6. 确认规则无误后，现在才安全地启动 UFW！
sudo ufw enable
# 7. 查看防火墙最终运行状态和生效的规则
sudo ufw status verbose


# 安装基础工具
sudo apt update
sudo apt install -y libwebkit2gtk-4.1-dev \
  build-essential \
  curl \
  wget \
  file \
  libxdo-dev \
  libssl-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev


# 安装 OpenJDK 21 (包含 JDK 和 JRE)
sudo apt install -y default-jdk
java -version
# 管理多个 Java 版本
sudo update-alternatives --auto java
# 安装 Maven
sudo apt install -y maven gradle
mvn -v
# 查看可用的 LTS (长期支持) 版本
sudo apt install -y nodejs npm
node -v
npm -v
npm config set registry https://registry.npmmirror.com/
if [ -d "/usr/local" ]; then
    sudo chown -R $(whoami):$(whoami) /usr/local
fi
# 安装 Bun
npm install -g bun
bun --version
cat << EOF | tee $HOME/.bunfig.toml
# Bun 加速仓库配置参考官网 https://bun.zhcndoc.com/runtime/bunfig#install-registry
[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，地址为 https://developer.aliyun.com/mirror/
registry = "https://registry.npmmirror.com/"

# 在 Bun 中使用 TypeScript。https://bun.zhcndoc.com/typescript
EOF


echo '
# 设置 Rustup 镜像，参考：https://developer.aliyun.com/mirror/rustup
export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
' >> ~/.bash_profile
source ~/.bash_profile
# 使用阿里云安装脚本
curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/repo/rust/rustup-init.sh | sh -s -- -y
. "$HOME/.cargo/env"
rustup update
rustup toolchain install stable
# 配置 Cargo 镜像
# 如果正在使用 cargo 1.68 及以上版本，在 $HOME/.cargo/config.toml 中添加如下内容即可：
mkdir -vp "$HOME/.cargo"
# cat $HOME/.cargo/config.toml
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee $HOME/.cargo/config.toml
# 配置 Cargo 国内加速镜像源，可选：aliyun、ustc、tuna 此处默认选择 aliyun
# 使用稀疏协议（sparse）减少元数据下载量，大幅加速
[source.crates-io]
replace-with = 'aliyun'

# aliyun 阿里云 crates.io 镜像 https://developer.aliyun.com/mirror/rustup
[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"
[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"

# ustc 中科大 crates.io 镜像 https://mirrors.ustc.edu.cn/help/crates.io-index.html
[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF


# Go 国内加速镜像	https://learnku.com/go/wikis/38122
# golang 中文学习文档	https://golang.halfiisland.com/
# golang 官方网站	https://golang.google.cn/
# golang 公共软件包仓库	https://pkg.go.dev/
sudo apt install -y golang-go
echo "你刚安装的 golang 版本号为：$(go version)"
# Go 1.13+：默认启用，无需额外配置。但使用  go env GO111MODULE 显示为空
# 并不代表 Go Modules 未开启，而是表示你没有显式配置该变量，Go 将使用内部默认值
# 设置为 auto（推荐，Go 1.13+ 默认逻辑）
# go env -w GO111MODULE=auto
# 或者强制开启 Go Modules 功能
go env -w GO111MODULE=on
# 1. 设置模块代理（加速下载）
# 阿里云Go Module代理仓库服务	https://developer.aliyun.com/mirror/goproxy
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
# 2. 设置校验和数据库（避免超时）
go env -w GOSUMDB=sum.golang.google.cn
# 查看配置是否成功
# go env GO111MODULE
# go env GOPROXY
# go env GOSUMDB
# 设置 GOPATH 为 ~/go
mkdir -vp $HOME/.go
go env -w GOPATH=$HOME/.go
# 查看当前环境
# go env GOPATH


sudo apt install -y podman podman-compose
# 在 systemd 的世界里，.socket 和 .service 是配合工作的，但它们的启动机制完全不同：
# 按需自动启动 podman.service -> 处理完毕后，如果一段时间没有请求，服务可以自动休眠。
systemctl --user enable --now podman.socket
# 这个命令会直接在后台启动 podman 这个守护进程，让它一直处于运行状态，并且由该进程自己监听上述的 socket。
#systemctl --user enable --now podman.service
#systemctl --user disable --now podman.service
systemctl --user status podman.service podman.socket --no-pager
# 备份到同目录（添加 .bak 后缀）
sudo cp /etc/containers/registries.conf{,.bak}
# 配置 Podman 加速镜像
cat << EOF | sudo tee -a /etc/containers/registries.conf
# 全局短名搜索顺序（必须保留 docker.io）
# 定义未指定镜像仓库前缀时，默认搜索的镜像仓库列表
# 例如执行 "podman pull nginx" 会自动从 "docker.io" 查找 "library/nginx"
unqualified-search-registries = ["docker.io"]

# Podman 优先尝试从 registry.mirror 拉取镜像，如果加速器不可用/镜像不存在，则自动回退到 location 指定的官方地址
# 官方仓库地址（最终回退地址）
[[registry]]
# 匹配的镜像仓库前缀（支持通配符 *）
# 例如 "docker.io" 会匹配所有 "docker.io/xxx" 的镜像
prefix = "docker.io"
# 实际访问的仓库服务器地址
# Docker Hub 的官方注册表地址
location = "docker.io"

# 第 1 个国内加速源
[[registry.mirror]]
# 镜像加速器地址（替换为你的阿里云镜像加速URL）
location = "docker.1ms.run"
# 是否允许不安全的 HTTP 连接（生产环境建议 false）
insecure = false

# 第 2 个国内加速源
[[registry.mirror]]
location = "docker.m.daocloud.io"
insecure = false

# 第 3 个加速源（示例）
[[registry.mirror]]
location = "docker.nju.edu.cn"
insecure = false

# 第 4 个加速源（示例）
[[registry.mirror]]
location = "docker.mirrors.sjtug.sjtu.edu.cn"
insecure = false
EOF
# 确认 Podman 是否读取到了你配置的镜像加速源，可以使用 podman info 命令：
sudo apt install -y jq
podman info --format json | jq '.registries'


# 创建编程工作目录
mkdir -vp ~/Projects/{Java,Rust,Cpp,Python,TypeScript,Database}
mkdir -vp ~/Projects/Database/{SQLite,MySQL,Postgres,Redis}
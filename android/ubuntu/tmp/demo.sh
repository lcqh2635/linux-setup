#!/bin/bash
# ==============================================================================
# Ubuntu Server 开发环境一键初始化脚本
# ==============================================================================

# 遇到错误即退出，使用未定义变量即退出，管道命令中任何一个失败即报错
set -euo pipefail

# ------------------------------------------------------------------------------
# 全局变量配置 (请根据实际情况修改)
# ------------------------------------------------------------------------------
# 颜色输出定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ------------------------------------------------------------------------------
# 1. 基础网络配置
# ------------------------------------------------------------------------------
info "输出当前用户和 IP 地址..."
# 输出主机信息
echo "主机名：$(hostname)"
echo "IP 地址：$(hostname -I | awk '{print $2}')"

# Wi-Fi 配置变量
WIFI_SSID="A3-6-707"
WIFI_PASS="VT4009030242" # 建议：不要将真实密码提交到公开仓库

info "配置 Wi-Fi (NetworkManager)..."
if command -v nmcli &> /dev/null; then
    # 检查是否已连接
    if nmcli -t -f NAME,DEVICE connection show --active | grep -q "$WIFI_SSID"; then
        warn "Wi-Fi [$WIFI_SSID] 已连接，跳过配置。"
        sudo nmcli connection modify "$WIFI_SSID" connection.autoconnect yes
    else
        nmcli general status
        nmcli device wifi list
        info "正在连接 Wi-Fi: $WIFI_SSID ..."
        sudo nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS" || error "Wi-Fi 连接失败"
        sudo nmcli connection modify "$WIFI_SSID" connection.autoconnect yes
    fi
    nmcli device status
else
    warn "未检测到 nmcli，跳过 Wi-Fi 配置。"
fi

info "测试网络连接..."
ping -c 3 baidu.com || error "网络不可达，请检查网络配置"

# ------------------------------------------------------------------------------
# 2. 软件源换源与系统更新
# ------------------------------------------------------------------------------
info "配置国内加速镜像源 (USTC)..."
# 动态获取 Ubuntu 代号 (如 noble, jammy)
CODENAME=$(lsb_release -cs)
# 备份原有配置
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak 2>/dev/null || true
# 清空旧配置并写入 DEB822 格式新配置
sudo tee /etc/apt/sources.list > /dev/null << EOF
# 已由脚本置空，源配置在 /etc/apt/sources.list.d/ubuntu.sources 中
EOF
sudo tee /etc/apt/sources.list.d/ubuntu.sources > /dev/null << EOF
Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: ${CODENAME} ${CODENAME}-updates ${CODENAME}-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: ${CODENAME}-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
info "更新软件包列表并升级..."
sudo apt update && sudo apt upgrade -y
sudo apt --fix-broken install -y
sudo apt autoremove -y && sudo apt autoclean -y

# ------------------------------------------------------------------------------
# 3. 基础工具与 SSH
# ------------------------------------------------------------------------------
info "安装基础工具..."
sudo apt install -y apt-transport-https ca-certificates curl wget git unzip fastfetch jq lsb-release
info "配置 OpenSSH Server..."
if ! systemctl is-active --quiet ssh; then
    sudo apt install -y openssh-server
    sudo systemctl enable --now ssh
else
    warn "SSH 服务已运行，跳过安装。"
fi
info "配置 Avahi (主机名局域网解析)..."
if ! systemctl is-active --quiet avahi-daemon; then
    sudo apt install -y avahi-daemon
    sudo systemctl enable --now avahi-daemon
else
    warn "Avahi 已运行，跳过安装。"
fi

# ------------------------------------------------------------------------------
# 4. UFW 防火墙配置
# ------------------------------------------------------------------------------
info "配置 UFW 防火墙..."
sudo apt install -y ufw
# 安全基线
sudo ufw default deny incoming
sudo ufw default allow outgoing
# 开放端口 (按需开放，数据库端口谨慎开放外网)
sudo ufw allow 22/tcp comment 'SSH 端口'
sudo ufw allow 80/tcp comment 'HTTP 端口'
sudo ufw allow 443/tcp comment 'HTTPS 端口'
# 以下数据库端口建议仅允许本地或局域网访问，如需开放请明确指定来源IP
# sudo ufw allow from 192.168.1.0/24 to any port 3306 comment 'MySQL 局域网'
sudo ufw allow 4224/tcp comment 'DBX 端口'
sudo ufw allow 3306/tcp comment 'MySQL'
sudo ufw allow 5432/tcp comment 'PostgreSQL'
sudo ufw allow 6379/tcp comment 'Redis'
sudo ufw allow 8848/tcp comment 'Nacos'
sudo ufw allow 8091/tcp comment 'Seata'
sudo ufw --force enable # 防止交互式提示阻断脚本
sudo ufw status verbose

# ------------------------------------------------------------------------------
# 5. 开发环境：C/C++ 与 Tauri 依赖
# ------------------------------------------------------------------------------
info "安装 C/C++ 及桌面开发基础库 (包含 WebKit，如果是纯后端服务器可注释此段)..."
sudo apt install -y build-essential libssl-dev libwebkit2gtk-4.1-dev libxdo-dev \
    libayatana-appindicator3-dev librsvg2-dev

# ------------------------------------------------------------------------------
# 6. 开发环境：Java & Maven
# ------------------------------------------------------------------------------
info "安装 OpenJDK 与 Maven..."
sudo apt install -y default-jdk maven gradle
java -version
mvn -v
gradle -v
# 配置 Maven 阿里云镜像 (Java 后端必备)
mkdir -p ~/.m2
cat << 'EOF' > ~/.m2/settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>*</mirrorOf>
      <name>阿里云公共仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
info "Java & Maven (已配置阿里云镜像) 安装完成"

# ------------------------------------------------------------------------------
# 7. 开发环境：Node.js & Bun
# ------------------------------------------------------------------------------
info "安装 Node.js 与 Bun..."
# 安装 Node.js (此处仍使用系统源，建议有需要可换用 NodeSource)
sudo apt install -y nodejs npm
npm config set registry https://registry.npmmirror.com/
# 更改 /usr/local 权限，避免全局 npm 包需要 sudo
if [ -d "/usr/local" ]; then
    sudo chown -R $(whoami):$(whoami) /usr/local
fi
npm install -g bun
info "Node.js & Bun 安装完成"
# 配置 Bun 镜像 (防重复追加)
BUNFIG="$HOME/.bunfig.toml"
if [ ! -f "$BUNFIG" ] || ! grep -q 'registry.npmmirror.com' "$BUNFIG"; then
    tee "$BUNFIG" > /dev/null << EOF
[install]
registry = "https://registry.npmmirror.com/"
EOF
fi
nodejs -v
npm -v
bun -v

# ------------------------------------------------------------------------------
# 8. 开发环境：Rust
# ------------------------------------------------------------------------------
info "安装 Rust 与配置镜像..."
# 配置环境变量 (防重复追加)
BASHRC="$HOME/.bashrc"
if ! grep -q 'RUSTUP_DIST_SERVER' "$BASHRC"; then
    echo '' >> "$BASHRC"
    echo '# Rustup 国内镜像加速' >> "$BASHRC"
    echo 'export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup' >> "$BASHRC"
    echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup' >> "$BASHRC"
    source "$BASHRC"
fi
# 安装 Rustup
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/repo/rust/rustup-init.sh | sh -s -- -y
    source "$HOME/.cargo/env"
else
    warn "Rustup 已安装，跳过。"
fi
# 配置 Cargo 镜像 (直接覆盖，确保干净)
mkdir -vp "$HOME/.cargo"
tee "$HOME/.cargo/config.toml" > /dev/null << EOF
[source.crates-io]
replace-with = 'aliyun'

[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"

[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"
EOF
rustc -V
cargo -V


# ------------------------------------------------------------------------------
# 9. 开发环境：Go
# ------------------------------------------------------------------------------
info "安装 Golang 与配置代理..."
# 提示：Ubuntu apt 中的 Go 版本可能较旧，如需最新版请改为手动 wget 下载
sudo apt install -y golang-go

go env -w GO111MODULE=on
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
go env -w GOSUMDB=sum.golang.google.cn

mkdir -vp $HOME/.go
go env -w GOPATH=$HOME/.go

# ------------------------------------------------------------------------------
# 10. 容器环境：Podman
# ------------------------------------------------------------------------------
info "安装 Podman 与配置镜像加速..."
sudo apt install -y podman podman-compose
systemctl --user enable --now podman.socket
# 配置 Podman 镜像源 (先备份再覆盖写入，防止重复追加导致语法错误)
sudo cp /etc/containers/registries.conf{,.bak}
sudo tee /etc/containers/registries.conf > /dev/null << EOF
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.1ms.run"
insecure = false

[[registry.mirror]]
location = "docker.m.daocloud.io"
insecure = false

[[registry.mirror]]
location = "docker.nju.edu.cn"
insecure = false
EOF

podman -v
podman-compose -v
# 验证配置
podman info --format json | jq '.registries'

# ------------------------------------------------------------------------------
# 11. 创建工作目录
# ------------------------------------------------------------------------------
info "创建编程工作目录..."
mkdir -vp ~/Projects/{Java,Rust,Cpp,Python,TypeScript,Database}
mkdir -vp ~/Projects/Database/{SQLite,MySQL,Postgres,Redis}

info "=================================================="
info "所有配置已完成！建议执行 source ~/.bashrc 或重启终端以使所有环境变量生效。"
info "=================================================="

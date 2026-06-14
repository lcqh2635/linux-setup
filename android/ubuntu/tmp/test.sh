#!/bin/bash
# ==============================================================================
# Ubuntu Server 26.04 开发环境一键初始化脚本（优化版）
#
# 适用系统：Ubuntu 26.04 LTS (Resolute Raccoon) 及相近版本
# 主要功能：
#   1. 配置 Wi-Fi（NetworkManager）并测试网络
#   2. 切换 USTC 镜像源并更新系统
#   3. 安装基础工具、OpenSSH、Avahi
#   4. 配置 UFW 防火墙（默认仅开放 SSH/HTTP/HTTPS）
#   5. 安装 C/C++ 及 Tauri 桌面开发依赖（可按需注释）
#   6. 安装 Java/Maven/Gradle 并配置阿里云 Maven 镜像
#   7. 安装 Node.js/Bun 并配置国内镜像
#   8. 安装 Rust 并配置 Cargo/crates.io 镜像
#   9. 安装 Go 并配置 GOPROXY/GOSUMDB
#  10. 安装 Podman/_podman-compose_ 并配置国内镜像加速
#  11. 创建常用工作目录
#
# 使用方式：
#   sudo bash setup_ubuntu_server_2604.sh
# ==============================================================================

# 遇到错误即退出，使用未定义变量即退出，管道命令中任何一个失败即报错
set -euo pipefail

# 获取脚本所在目录（方便后续引用配置文件等）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------------------
# 全局变量配置 (请根据实际情况修改)
# ------------------------------------------------------------------------------

# Wi-Fi 配置（强烈建议不要把真实密码提交到公开仓库）
WIFI_SSID="A3-6-707"
WIFI_PASS="VT4009030242"

# 颜色输出定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# 打印错误时所在行号，方便调试
trap 'error "脚本在 $0 的第 $LINENO 行出错"' ERR

# ------------------------------------------------------------------------------
# 0. 系统基本信息与版本检测
# ------------------------------------------------------------------------------
info "========== 系统基本信息 =========="
info "主机名：$(hostname)"
info "IP 地址：$(hostname -I | awk '{print $1}')"
info "内核版本：$(uname -r)"
info "系统版本：$(lsb_release -d 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME || true)"

# 简单检测是否为 Ubuntu（可选，但更安全）
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    warn "当前系统似乎不是 Ubuntu，脚本可能不完全兼容，继续运行请自行承担风险。"
fi

# ------------------------------------------------------------------------------
# 1. 基础网络配置（Wi-Fi + 连通性测试）
# ------------------------------------------------------------------------------
info "========== 1. 基础网络配置 =========="

info "配置 Wi-Fi (NetworkManager)..."
if command -v nmcli &> /dev/null; then
    # 检查是否已连接指定 Wi-Fi
    if nmcli -t -f NAME,DEVICE connection show --active | grep -q "$WIFI_SSID"; then
        warn "Wi-Fi [$WIFI_SSID] 已连接，跳过连接步骤，仅设置自动连接。"
        sudo nmcli connection modify "$WIFI_SSID" connection.autoconnect yes
    else
        nmcli general status || true
        nmcli device wifi list || true
        info "正在连接 Wi-Fi: $WIFI_SSID ..."
        sudo nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS" || error "Wi-Fi 连接失败，请检查 SSID/密码/信号"
        sudo nmcli connection modify "$WIFI_SSID" connection.autoconnect yes
    fi
    nmcli device status || true
else
    warn "未检测到 nmcli，跳过 Wi-Fi 配置（如果是服务器有线网络则正常）。"
fi

info "测试网络连接..."
# 先测试网关，再测试外网
if ! ping -c 5 baidu.com &>/dev/null; then
    error "网络不可达，请检查网络配置（Wi-Fi/有线/代理）"
fi

# ------------------------------------------------------------------------------
# 2. 软件源换源与系统更新（适配 Ubuntu 26.04 Resolute）
# ------------------------------------------------------------------------------
info "========== 2. 软件源换源与系统更新 =========="

# 动态获取 Ubuntu 版本代号（如 resolute / noble / jammy）
CODENAME=$(lsb_release -cs 2>/dev/null || true)
if [[ -z "$CODENAME" ]]; then
    error "无法获取 Ubuntu 版本代号（lsb_release -cs 失败），请检查系统是否为 Ubuntu。"
fi

info "当前 Ubuntu 版本代号：$CODENAME"
info "配置国内加速镜像源 (USTC)..."

# 备份原有配置（尽量保留原文件，便于回滚）
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak 2>/dev/null || true

# 清空旧格式 sources.list，全部改用 DEB822 格式（.sources）
sudo tee /etc/apt/sources.list > /dev/null << 'EOF'
# 已由脚本置空，源配置在 /etc/apt/sources.list.d/ubuntu.sources 中
# 如果需要恢复传统格式，可以从备份恢复 /etc/apt/sources.list.bak
EOF

# 写入 DEB822 格式源（USTC 镜像）
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

# 注意：USTC 官方提示：镜像站同步安全更新可能有延迟，生产环境可考虑保留官方 security 源：
#   将上面的第二个 Types:deb 段改回：
#   URIs: http://security.ubuntu.com/ubuntu
# 详见：https://mirrors.ustc.edu.cn/help/ubuntu.html

info "更新软件包列表并升级系统..."
sudo apt-get clean
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get --fix-broken install -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# ------------------------------------------------------------------------------
# 3. 基础工具与 SSH/Avahi
# ------------------------------------------------------------------------------
info "========== 3. 基础工具与 SSH/Avahi =========="

info "安装基础工具（apt-transport-https, ca-certificates, curl, git, unzip, fastfetch, jq, lsb-release）..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    git \
    unzip \
    fastfetch \
    jq \
    lsb-release

info "配置 OpenSSH Server..."
if ! systemctl is-active --quiet ssh; then
    sudo apt-get install -y openssh-server
    sudo systemctl enable --now ssh
else
    warn "SSH 服务已运行，跳过安装。"
fi

info "配置 Avahi（主机名局域网解析，如 xiaomi-raphael.local）..."
if ! systemctl is-active --quiet avahi-daemon; then
    sudo apt-get install -y avahi-daemon
    sudo systemctl enable --now avahi-daemon
else
    warn "Avahi 已运行，跳过安装。"
fi

# ------------------------------------------------------------------------------
# 4. UFW 防火墙配置（默认仅开放 SSH/HTTP/HTTPS）
# ------------------------------------------------------------------------------
info "========== 4. UFW 防火墙配置 =========="
info "安装 UFW..."
sudo apt-get install -y ufw
info "设置默认策略：拒绝所有传入，允许所有传出..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
info "开放常用端口（按需调整）..."
sudo ufw allow 22/tcp  comment 'SSH 端口'
sudo ufw allow 80/tcp  comment 'HTTP 端口'
sudo ufw allow 443/tcp comment 'HTTPS 端口'
# 数据库端口默认不开放，仅作为示例（如需开放请严格限制来源 IP）
# 示例：仅允许局域网访问 MySQL
# sudo ufw allow from 192.168.1.0/24 to any port 3306 proto tcp comment 'MySQL 局域网'
sudo ufw allow 4224/tcp  comment 'DBX 端口'
sudo ufw allow 3306/tcp  comment 'MySQL'
sudo ufw allow 5432/tcp  comment 'PostgreSQL'
sudo ufw allow 6379/tcp  comment 'Redis'
sudo ufw allow 8848/tcp  comment 'Nacos'
sudo ufw allow 8091/tcp  comment 'Seata'
info "启用 UFW 防火墙..."
sudo ufw --force enable
info "当前 UFW 状态："
sudo ufw status verbose

# ------------------------------------------------------------------------------
# 5. 开发环境：C/C++ 与 Tauri 桌面开发依赖
# ------------------------------------------------------------------------------
info "安装编译工具与 WebKit/GTK 依赖（如果是纯后端服务器，可注释此段）..."
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

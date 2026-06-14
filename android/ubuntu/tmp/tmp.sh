#!/bin/bash
# ==============================================================================
# Ubuntu Server 开发环境一键初始化脚本 (美观交互版)
#
# 特性：自动识别 Ubuntu 版本 / 交互式隐私输入 / 安全 UFW 基线 / 幂等配置
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 全局变量与颜色定义
# ------------------------------------------------------------------------------
WIFI_SSID="A3-6-707"

# 颜色与样式
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 日志文件 (用于记录被静默的详细输出)
LOG_FILE="/tmp/ubuntu_init_$(date +%Y%m%d_%H%M%S).log"

# ------------------------------------------------------------------------------
# 工具函数
# ------------------------------------------------------------------------------
# 分割线
print_separator() { echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# 步骤标题
print_step() {
    echo -e "\n${BLUE}🚀 ${BOLD}[步骤 $1]${NC} ${BOLD}$2${NC}\n"
    print_separator
}

# 信息输出
info()    { echo -e "  ${GREEN}✔${NC} $*"; }
warn()    { echo -e "  ${YELLOW}⚡${NC} $*"; }
error()   { echo -e "  ${RED}✖${NC} $*"; exit 1; }

# 静默执行命令 (只显示成功/失败，失败时提示查看日志)
run_silent() {
    local desc="$1"
    shift
    echo -ne "  ${CYAN}⏳${NC} ${desc}...\r"
    if "$@" >> "$LOG_FILE" 2>&1; then
        echo -e "  ${GREEN}✔${NC} ${desc}    "
    else
        echo -e "  ${RED}✖${NC} ${desc} 失败！"
        echo -e "  ${RED}请查看日志获取详细错误：tail -n 50 $LOG_FILE${NC}"
        return 1
    fi
}

# ==============================================================================
# 开屏横幅
# ==============================================================================
clear
echo -e "${CYAN}"
cat << "EOF"
 ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗██████╗
██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██║   ██║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
██║   ██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
 ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "${BOLD}Ubuntu Server 开发环境一键初始化脚本${NC}"
echo -e "版本: 2.0 美化版 | 日志文件: ${CYAN}$LOG_FILE${NC}"
print_separator

# ==============================================================================
# 1. 基础网络配置
# ==============================================================================
print_step "1/12" "基础网络配置"

echo -e "  🖥️  主机名：${BOLD}$(hostname)${NC}"
echo -e "  🌐 IP 地址：${BOLD}$(hostname -I | awk '{print $1}')${NC}"

# 交互式读取 Wi-Fi 密码
if [ -z "${WIFI_PASS:-}" ]; then
    echo -ne "\n  🔑 请输入 Wi-Fi 密码 (SSID: ${BOLD}$WIFI_SSID${NC}): "
    read -rs WIFI_PASS
    echo # 换行
    [ -z "$WIFI_PASS" ] && error "Wi-Fi 密码不能为空"
fi

if command -v nmcli &> /dev/null; then
    if nmcli -t -f NAME,DEVICE connection show --active | grep -q "$WIFI_SSID"; then
        warn "Wi-Fi [$WIFI_SSID] 已连接，跳过配置。"
        sudo nmcli connection modify "$WIFI_SSID" connection.autoconnect yes
    else
        info "正在连接 Wi-Fi: $WIFI_SSID ..."
        sudo nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASS" >> "$LOG_FILE" 2>&1 || error "Wi-Fi 连接失败"
        sudo nmcli connection modify "$WIFI_SSID" connection.autoconnect yes
        info "Wi-Fi 连接成功！"
    fi
else
    warn "未检测到 nmcli，跳过 Wi-Fi 配置。"
fi

info "测试网络连接..."
if ping -c 3 baidu.com >> "$LOG_FILE" 2>&1; then
    info "网络连接正常"
else
    error "网络不可达，请检查网络配置"
fi

# ==============================================================================
# 2. 系统信息与源配置
# ==============================================================================
print_step "2/12" "系统信息与软件源配置"

sudo apt update >> "$LOG_FILE" 2>&1
run_silent "安装基础依赖" sudo apt install -y lsb-release

CODENAME=$(lsb_release -cs)
VERSION_ID=$(lsb_release -rs)
info "当前系统：Ubuntu ${BOLD}$VERSION_ID${NC} ($CODENAME)"

if [ -f /etc/apt/sources.list.d/ubuntu.sources ] && [ -s /etc/apt/sources.list.d/ubuntu.sources ]; then
    SOURCES_FILE="/etc/apt/sources.list.d/ubuntu.sources"
    SOURCES_FORMAT="deb822"
else
    SOURCES_FILE="/etc/apt/sources.list"
    SOURCES_FORMAT="traditional"
fi

sudo cp "$SOURCES_FILE" "${SOURCES_FILE}.bak" 2>/dev/null || true

if [ "$SOURCES_FORMAT" = "deb822" ]; then
    sudo tee "$SOURCES_FILE" > /dev/null << EOF
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
else
    sudo tee "$SOURCES_FILE" > /dev/null << EOF
deb https://mirrors.ustc.edu.cn/ubuntu ${CODENAME} main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu ${CODENAME}-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu ${CODENAME}-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu ${CODENAME}-security main restricted universe multiverse
EOF
fi

run_silent "更新软件包列表并升级系统" sudo apt update && sudo apt upgrade -y
run_silent "修复可能的依赖损坏" sudo apt --fix-broken install -y
run_silent "清理无用软件包" sudo apt autoremove -y && sudo apt autoclean -y

# ==============================================================================
# 3. 基础工具与 SSH
# ==============================================================================
print_step "3/12" "基础工具与 SSH 配置"

run_silent "安装常用工具" sudo apt install -y apt-transport-https ca-certificates curl wget git unzip fastfetch jq

if ! systemctl is-active --quiet ssh; then
    run_silent "安装并启动 OpenSSH Server" sudo apt install -y openssh-server
    sudo systemctl enable --now ssh
else
    warn "SSH 服务已运行，跳过安装。"
fi

if ! systemctl is-active --quiet avahi-daemon; then
    run_silent "安装 Avahi (主机名局域网解析)" sudo apt install -y avahi-daemon
    sudo systemctl enable --now avahi-daemon
else
    warn "Avahi 已运行，跳过安装。"
fi

# ==============================================================================
# 4. UFW 防火墙配置
# ==============================================================================
print_step "4/12" "UFW 防火墙安全基线配置"

run_silent "安装 UFW" sudo apt install -y ufw

sudo ufw default deny incoming >> "$LOG_FILE" 2>&1
sudo ufw default allow outgoing >> "$LOG_FILE" 2>&1

info "开放常用服务端口..."
sudo ufw limit 22/tcp comment 'SSH' >> "$LOG_FILE" 2>&1
sudo ufw allow 80/tcp comment 'HTTP' >> "$LOG_FILE" 2>&1
sudo ufw allow 443/tcp comment 'HTTPS' >> "$LOG_FILE" 2>&1

warn "数据库端口(3306/6379等)默认未开放，如需开启请限定来源IP。"

sudo ufw logging on >> "$LOG_FILE" 2>&1
sudo ufw --force enable >> "$LOG_FILE" 2>&1
info "UFW 防火墙已启动并应用安全规则"

# ==============================================================================
# 5. C/C++ 与 Tauri 依赖
# ==============================================================================
print_step "5/12" "C/C++ 与 Tauri 依赖 (纯后端可忽略)"

run_silent "安装编译工具与桌面基础库" sudo apt install -y build-essential libssl-dev libxdo-dev \
    libayatana-appindicator3-dev librsvg2-dev

# ==============================================================================
# 6. Java & Maven
# ==============================================================================
print_step "6/12" "Java 与 Maven 构建工具"

run_silent "安装 OpenJDK, Maven, Gradle" sudo apt install -y default-jdk maven gradle

mkdir -p ~/.m2
cat << 'EOF' > ~/.m2/settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
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
info "已配置 Maven 阿里云镜像"

# ==============================================================================
# 7. Node.js & Bun
# ==============================================================================
print_step "7/12" "Node.js 与 Bun 运行时"

run_silent "安装 Node.js 与 npm" sudo apt install -y nodejs npm
npm config set registry https://registry.npmmirror.com/ >> "$LOG_FILE" 2>&1

if [ -d "/usr/local" ]; then
    sudo chown -R "$(whoami):$(whoami)" /usr/local
fi

info "正在安装 Bun (官方安装脚本)..."
curl -fsSL https://bun.sh/install | bash >> "$LOG_FILE" 2>&1

BASHRC="$HOME/.bashrc"
if ! grep -q 'BUN_INSTALL' "$BASHRC"; then
    {
        echo ''
        echo '# Bun 安装路径与可执行文件'
        echo 'export BUN_INSTALL="$HOME/.bun"'
        echo 'export PATH="$BUN_INSTALL/bin:$PATH"'
    } >> "$BASHRC"
fi

BUNFIG="$HOME/.bunfig.toml"
if [ ! -f "$BUNFIG" ] || ! grep -q 'registry.npmmirror.com' "$BUNFIG"; then
    tee "$BUNFIG" > /dev/null << EOF
[install]
registry = "https://registry.npmmirror.com/"
EOF
fi

# 临时生效以验证
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
info "Bun 安装完成，镜像已配置"

# ==============================================================================
# 8. Rust
# ==============================================================================
print_step "8/12" "Rust 开发环境"

BASHRC="$HOME/.bashrc"
if ! grep -q 'RUSTUP_DIST_SERVER' "$BASHRC"; then
    {
        echo ''
        echo '# Rustup 国内镜像加速'
        echo 'export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup'
        echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup'
    } >> "$BASHRC"
fi
source "$BASHRC"

if ! command -v rustup &> /dev/null; then
    info "正在安装 Rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/repo/rust/rustup-init.sh | sh -s -- -y >> "$LOG_FILE" 2>&1
    source "$HOME/.cargo/env"
else
    warn "Rustup 已安装，跳过。"
fi

mkdir -vp "$HOME/.cargo" >> "$LOG_FILE" 2>&1
tee "$HOME/.cargo/config.toml" > /dev/null << EOF
[source.crates-io]
replace-with = 'aliyun'

[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"

[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"
EOF
info "Cargo 镜像已配置"

# ==============================================================================
# 9. Go
# ==============================================================================
print_step "9/12" "Golang 运行环境"

run_silent "安装 Golang" sudo apt install -y golang-go

go env -w GO111MODULE=on
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
go env -w GOSUMDB=sum.golang.google.cn
mkdir -vp "$HOME/.go" >> "$LOG_FILE" 2>&1
go env -w GOPATH="$HOME/.go"

info "Go Module 代理已配置"

# ==============================================================================
# 10. Podman
# ==============================================================================
print_step "10/12" "Podman 容器引擎"

run_silent "安装 Podman 及 Compose 插件" sudo apt install -y podman podman-compose
systemctl --user enable --now podman.socket >> "$LOG_FILE" 2>&1

sudo cp /etc/containers/registries.conf{,.bak} 2>/dev/null || true
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

info "Podman 镜像加速源已配置"

# ==============================================================================
# 11. 工作目录
# ==============================================================================
print_step "11/12" "创建编程工作目录"

mkdir -vp ~/Projects/{Java,Rust,Cpp,Python,TypeScript,Database} >> "$LOG_FILE" 2>&1
mkdir -vp ~/Projects/Database/{SQLite,MySQL,Postgres,Redis} >> "$LOG_FILE" 2>&1
info "工作目录 ~/Projects 创建完毕"

# ==============================================================================
# 完成横幅
# ==============================================================================
print_step "12/12" "环境验证与收尾"

# 验证关键工具版本并存入变量
V_NODE=$(node -v 2>/dev/null || echo "未安装")
V_JAVA=$(java -version 2>&1 | head -n 1 || echo "未安装")
V_GO=$(go version 2>/dev/null | awk '{print $3}' || echo "未安装")
V_RUST=$(rustc -V 2>/dev/null || echo "未安装")

echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════╗"
echo -e "║${GREEN}  🎉 Ubuntu Server 开发环境初始化完成！${NC}                        ║"
echo -e "╠══════════════════════════════════════════════════════════════╣"
echo -e "║${BOLD}  📦 核心环境版本检查:${NC}                                       ║"
echo -e "║    ☕ Java  : $V_JAVA"
echo -e "║    🟢 Node  : $V_NODE"
echo -e "║    🦀 Rust  : $V_RUST"
echo -e "║    🐹 Go    : $V_GO"
echo -e "╠══════════════════════════════════════════════════════════════╣"
echo -e "║${BOLD}  📌 后续建议操作:${NC}                                           ║"
echo -e "║  1. 执行 ${CYAN}source ~/.bashrc${NC} 使环境变量 (Bun/Rust) 立即生效  ║"
echo -e "║  2. 执行 ${CYAN}sudo ufw status verbose${NC} 检查防火墙规则          ║"
echo -e "║  3. 如遇安装错误，查看日志: ${CYAN}cat $LOG_FILE${NC}      ║"
echo -e "╚══════════════════════════════════════════════════════════════╝${NC}\n"

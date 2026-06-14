#!/bin/bash
# ==============================================================================
# 脚本名称：frpc 一键安装与配置脚本（优化版）
# 适用架构：自动检测 (ARM64 手机 / x86_64)
# 适用系统：Ubuntu / Debian 系 Linux
# 功能：下载 frpc -> 写入预设配置 -> 注册系统服务 -> 开机自启
# 使用方法：
#   chmod +x frpc_install.sh
#   sudo ./frpc_install.sh
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 全局变量与颜色定义
# ------------------------------------------------------------------------------
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[信息]${NC} $1"; }
warn()  { echo -e "${YELLOW}[警告]${NC} $1"; }
error() { echo -e "${RED}[错误]${NC} $1"; exit 1; }

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
  error "此脚本必须使用 sudo 或以 root 用户运行！"
fi

# ------------------------------------------------------------------------------
# 1. 检测系统架构与版本
# ------------------------------------------------------------------------------
info "正在检测系统架构..."
ARCH=$(uname -m)

case $ARCH in
    aarch64|arm64)
        FRP_ARCH="arm64"
        ;;
    x86_64|amd64)
        FRP_ARCH="amd64"
        ;;
    *)
        error "不支持的系统架构: $ARCH. 此脚本仅支持 arm64 和 amd64。"
        ;;
esac

info "检测到架构: $ARCH, 将下载 linux_${FRP_ARCH} 版本。"

# FRP 版本号（可按需修改）
FRP_VERSION="0.69.1"
FILE_NAME="frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz"

# GitHub 下载地址（可替换为自建代理）
GH_PROXY_PREFIX="https://gh-proxy.org/"
DOWNLOAD_URL="${GH_PROXY_PREFIX}https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}"

# ------------------------------------------------------------------------------
# 2. 交互式获取敏感配置
# ------------------------------------------------------------------------------
info "准备配置 frpc，请输入以下信息（建议不要把真实信息提交到版本库）："

# 服务端地址（公网 IP 或域名）
read -rp "请输入 frps 服务端地址（如 120.79.1.21）: " FRPS_SERVER_ADDR
[ -z "$FRPS_SERVER_ADDR" ] && error "frps 服务端地址不能为空"

# 服务端端口
read -rp "请输入 frps 服务端端口（默认 7000）: " FRPS_SERVER_PORT
FRPS_SERVER_PORT="${FRPS_SERVER_PORT:-7000}"

# 认证 token
read -rp "请输入 frps 的 auth token（与服务端保持一致）: " FRPS_AUTH_TOKEN
[ -z "$FRPS_AUTH_TOKEN" ] && error "auth token 不能为空"

# SSH 远程端口
read -rp "请输入 SSH 穿透的远程端口（如 59297）: " SSH_REMOTE_PORT
[ -z "$SSH_REMOTE_PORT" ] && error "SSH 远程端口不能为空"

# 本地 SSH 端口（默认 22）
read -rp "请输入本地 SSH 端口（默认 22）: " SSH_LOCAL_PORT
SSH_LOCAL_PORT="${SSH_LOCAL_PORT:-22}"

# ------------------------------------------------------------------------------
# 3. 下载与解压
# ------------------------------------------------------------------------------
info "准备下载 FRP v${FRP_VERSION}..."
warn "如果下载卡住（国内网络访问 GitHub 较慢），请按 Ctrl+C 退出，自行下载后放置。"

if [ -f "$FILE_NAME" ]; then
    info "检测到已存在安装包 ${FILE_NAME}，跳过下载。"
else
    info "开始下载 ${FILE_NAME} ..."
    if ! wget -c -t 3 -T 60 -O "$FILE_NAME" "$DOWNLOAD_URL"; then
        error "下载失败！请检查网络连接，或手动下载放置到当前目录。"
    fi
fi

EXTRACT_DIR="frp_${FRP_VERSION}_linux_${FRP_ARCH}"

info "正在解压安装包..."
rm -rf "$EXTRACT_DIR"  # 清理旧解压目录
tar -xzf "$FILE_NAME"

if [ ! -d "$EXTRACT_DIR" ]; then
    error "解压失败，找不到目录 ${EXTRACT_DIR}！"
fi

# ------------------------------------------------------------------------------
# 4. 安装 frpc 二进制文件
# ------------------------------------------------------------------------------
info "正在将 frpc 安装到 /usr/local/bin/ ..."
cp "${EXTRACT_DIR}/frpc" /usr/local/bin/frpc
chmod +x /usr/local/bin/frpc

# 创建配置文件目录
mkdir -p /etc/frp

info "frpc 程序安装完成！版本: $(/usr/local/bin/frpc -v)"

# ------------------------------------------------------------------------------
# 5. 写入 frpc.toml 配置文件
# ------------------------------------------------------------------------------
CONFIG_FILE="/etc/frp/frpc.toml"

info "正在将预设配置写入 ${CONFIG_FILE} ..."

# 注意：这里使用 auth.method + auth.token，符合 v0.52+ 新版 TOML 规范
cat > "$CONFIG_FILE" << EOF
# frpc 客户端配置

# 服务端连接配置
serverAddr = "${FRPS_SERVER_ADDR}"
serverPort = ${FRPS_SERVER_PORT}

# 认证配置（需与服务端 frps.toml 保持一致）
auth.method = "token"
auth.token = "${FRPS_AUTH_TOKEN}"

# 登录失败时不退出，便于服务自动重启
loginFailExit = false

# 代理隧道配置
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = ${SSH_LOCAL_PORT}
remotePort = ${SSH_REMOTE_PORT}
# 启用加密与压缩（建议开启，注意与服务端配置一致）
transport.useEncryption = true
transport.useCompression = true
EOF

info "配置文件写入成功！"
info "当前配置内容："
cat "$CONFIG_FILE"

# ------------------------------------------------------------------------------
# 6. 配置 Systemd 服务并启动
# ------------------------------------------------------------------------------
SERVICE_FILE="/etc/systemd/system/frpc.service"

info "正在配置 Systemd 开机自启服务..."
cat << EOF | tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Frp Client Service
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml

[Install]
WantedBy=multi-user.target
EOF

info "重新加载 systemd 配置..."
systemctl daemon-reload

info "设置 frpc 开机自启..."
systemctl enable frpc

info "启动 frpc 服务..."
systemctl restart frpc

info "检查 frpc 运行状态..."
systemctl status frpc --no-pager || true

# ------------------------------------------------------------------------------
# 7. 清理安装包与解压文件
# ------------------------------------------------------------------------------
info "正在清理安装包和解压文件..."
rm -rf "$EXTRACT_DIR"
rm -f "$FILE_NAME"

# ------------------------------------------------------------------------------
# 8. 最终状态与提示
# ------------------------------------------------------------------------------
echo "================================================================"
if systemctl is-active --quiet frpc; then
    info "恭喜！frpc 服务已成功启动并正在运行！"
else
    error "frpc 服务启动失败，请查看日志排查：journalctl -u frpc -n 20 --no-pager"
fi

info "【日常管理提示】"
echo -e "  1. 修改配置文件：${YELLOW}sudo nano /etc/frp/frpc.toml${NC}"
echo -e "  2. 修改配置后重启生效：${YELLOW}sudo systemctl restart frpc${NC}"
echo -e "  3. 查看运行状态：${YELLOW}sudo systemctl status frpc --no-pager${NC}"
echo -e "  4. 查看实时日志：${YELLOW}sudo journalctl -u frpc -f${NC}"
echo "================================================================"

# ------------------------------------------------------------------------------
# 参考资源（便于后续查阅）
# ------------------------------------------------------------------------------
# FRP 官方文档：https://gofrp.org/
# FRP GitHub 仓库：https://github.com/fatedier/frp
# GitHub 加速代理（gh-proxy）：https://gh-proxy.org/
# 零点 FRP（示例）：https://www.bilibili.com/video/BV1H4421X7Wg

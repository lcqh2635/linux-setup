#!/bin/bash

# ==============================================================================
# 脚本名称：frpc 一键静默安装与配置脚本 (非交互式)
# 适用架构：自动检测 (ARM64 手机 / x86_64)
# 适用系统：Ubuntu / Debian 系 Linux
# 脚本功能：下载 frpc -> 写入预设配置 -> 注册系统服务 -> 开机自启
# sudo nano frpc_install.sh   此时 nano 编辑器打开，长按终端屏幕（或右键鼠标），选择 “Paste”（粘贴）
# 按 Ctrl + O 保存，按 Enter 确认文件名，按 Ctrl + X 退出
# chmod +x frpc_install.sh && sudo ./frpc_install.sh
# echo "" > frpc_install.sh

# 内网穿透
# https://www.bilibili.com/video/BV1H4421X7Wg?spm_id_from=333.788.player.player_end_recommend_autoplay&vd_source=75333bb53891f589527eedfb7b2d5911&trackid=web_related_0.router-related-2589621-dpmnd.1780842559398.275

# https://www.cloudflare-cn.com/personal/
# https://zhuanlan.zhihu.com/p/638004070
# https://test-ipv6.com/
# https://ipv6.ddnspod.com/
# ==============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[信息]${NC} $1"; }
warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
error() { echo -e "${RED}[错误]${NC} $1"; exit 1; }

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
  error "此脚本必须使用 sudo 或以 root 用户运行！"
fi

# ==============================================================================
# 第一步：检测系统架构
# ==============================================================================
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

# FRP 版本号 (可按需修改)
FRP_VERSION="0.69.1"
FILE_NAME="frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz"
DOWNLOAD_URL="https://gh-proxy.org/https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}"

# ==============================================================================
# 第二步：下载与解压
# ==============================================================================
info "准备下载 FRP v${FRP_VERSION}..."
warn "如果下载卡住(国内网络访问 GitHub 较慢)，请按 Ctrl+C 退出自行下载放置。"

if [ -f "$FILE_NAME" ]; then
    info "检测到已存在安装包 ${FILE_NAME}，跳过下载。"
else
    if ! wget -O "$FILE_NAME" "$DOWNLOAD_URL"; then
        error "下载失败！请检查网络连接。"
    fi
fi

info "正在解压安装包..."
tar -xzf "$FILE_NAME"
EXTRACT_DIR="frp_${FRP_VERSION}_linux_${FRP_ARCH}"

if [ ! -d "$EXTRACT_DIR" ]; then
    error "解压失败，找不到目录 ${EXTRACT_DIR}！"
fi

# ==============================================================================
# 第三步：安装二进制文件
# ==============================================================================
sudo chattr -i /usr/local/bin/

info "正在将 frpc 安装到 /usr/local/bin/ ..."
sudo cp "${EXTRACT_DIR}/frpc" /usr/local/bin/frpc
sudo chmod +x /usr/local/bin/frpc

# 创建配置文件专用目录
sudo mkdir -p /etc/frp

info "frpc 程序安装完成！版本: $(/usr/local/bin/frpc -v)"

# ==============================================================================
# 第四步：使用 EOF 直接写入预设配置文件
# ==============================================================================
CONFIG_FILE="/etc/frp/frpc.toml"

info "正在将预设配置写入 ${CONFIG_FILE} ..."

# 利用 cat 和 EOF 将中间的内容原样写入配置文件
# ⚠️ 注意：如果你以后需要修改配置，只需执行 sudo nano /etc/frp/frpc.toml
cat > "$CONFIG_FILE" << 'EOF'
# ================= frpc 客户端基础配置 =================

# ================= 零点FRP 认证配置 =================
# 你的云服务器公网IP，也就是 frps 部署的公网主机地址
serverAddr = "120.79.1.21"
# 你的 frps 服务端绑定的端口
serverPort = 1210
user ="zfrQcUYsWthm"
loginFailExit = false
# 支持 tcp, kcp, quic, websocket 和 wss 协议, 默认传输协议为tcp
# 如果被限速可以尝试切换websocket协议（去掉下面一行的 '#' 号）
# transport.protocol = "websocket"

# 上面是认证信息，不要修改
# 下面的是一个完整连接的结构，其他协议请自行搜索frpc配置
# 请先创建隧道，系统将自动生成配置文件

# 在 ”零点 FRP“ 中一个隧道只会自动分配一个 remotePort 远程端口，远程端口不能自己乱写
# 如果在 frpc.toml 配置文件中同时多个 ”proxies 穿透服务“ 必须先在 ”零点 FRP“ 中创建多个隧道
# 然后，把多个隧道中提供的 frpc 配置文件中的 proxies 配置项聚集到单个 frpc.toml 文件中，再将这个配置文件配置单本地的 frpc 服务上
# 不要随意修改隧道 frpc 配置文件中提供的 proxies 配置项，原封不动的聚集到单个 frpc.toml 文件中即可

# ================= 代理隧道配置 =================

# --- 隧道1：SSH 远程连接 (22端口) ---
[[proxies]]
type = "tcp"
# 每个连接一个名称，不能修改
name="VjbLtGHE2DlD"
localIP = "127.0.0.1"
# 本地 SSH 端口
localPort = 22
# 每个隧道，零点FRP分配的一个远程端口，访问地址 serverAddr:remotePort
# 外网通过 120.79.1.21:59297 连接你的手机 SSH 命令如下：
# ssh -p 59297 user@120.79.1.21
remotePort = 59297
# 启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true
EOF

info "配置文件写入成功！"
# 输出当前配置供确认
cat "$CONFIG_FILE"

# ==============================================================================
# 第五步：配置 Systemd 服务并启动
# ==============================================================================
# 解除目录被锁死了，任何人不能写入：
# 1. 解锁 multi-user.target.wants 目录（这是 enable 写入链接的地方）
sudo chattr -i /etc/systemd/system/multi-user.target.wants/
# 2. 顺手解锁 frpc.service 文件本身（防止刚才写入时带了锁）
sudo chattr -i /etc/systemd/system/frpc.service
# 3. 确认一下解锁状态（应该看不到 i 了）
sudo lsattr -d /etc/systemd/system/multi-user.target.wants/
sudo lsattr /etc/systemd/system/frpc.service

SERVICE_FILE="/etc/systemd/system/frpc.service"

info "正在配置 Systemd 开机自启服务..."
cat << EOF | sudo tee "$SERVICE_FILE"
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

# 4. 重新加载 systemd 配置
sudo systemctl daemon-reload
# 5. 再次尝试启用开机自启
sudo systemctl enable frpc
# 6. 启动服务
sudo systemctl start frpc
# 7. 检查运行状态
sudo systemctl status frpc --no-pager

info "正在清理安装包和解压文件..."
rm -rf "$EXTRACT_DIR"
rm -f "$FILE_NAME"

# ==============================================================================
# 第六步：验证状态与提示
# ==============================================================================
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
#!/bin/bash
# ==============================================================================
# 脚本名称：frpc 一键静默安装与配置脚本 (非交互式)
# 适用架构：自动检测 (ARM64 手机 / x86_64)
# 适用系统：Ubuntu / Debian 系 Linux
# 脚本功能：下载 frpc -> 写入预设硬编码配置 -> 注册系统服务 -> 开机自启
# 使用方式：
# sudo nano setup_frpc.sh   此时 nano 编辑器打开，长按终端屏幕（或右键鼠标），选择 “Paste”（粘贴）
# 按 Ctrl + O 保存，按 Enter 确认文件名，按 Ctrl + X 退出
# sudo chmod +x setup_frpc.sh && sudo ./setup_frpc.sh
# 卸载方法：
#   sudo systemctl stop frpc && sudo systemctl disable frpc
#   sudo rm -f /usr/local/bin/frpc /etc/frp/frpc.toml /etc/systemd/system/frpc.service
#   sudo systemctl daemon-reload
#   ssh -p 59297 user@120.79.1.21
# ==============================================================================

# ======================== 安全选项 ========================
# -e: 任何命令返回非零状态码时立即退出
# -u: 使用未定义变量时报错
# -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail

# ======================== 颜色与日志函数 ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[信息]${NC} $1"; }
warn()  { echo -e "${YELLOW}[警告]${NC} $1"; }
error() { echo -e "${RED}[错误]${NC} $1"; exit 1; }
step()  { echo -e "${BLUE}[步骤]${NC} $1"; }

# ======================== Root 权限检查 ========================
if [[ $EUID -ne 0 ]]; then
    error "此脚本必须使用 sudo 或以 root 用户运行！"
fi

# ======================== FRP 版本与架构 ========================
# FRP 版本号 (可按需修改)
FRP_VERSION="0.69.1"

# 下载镜像源列表 (优先使用第一个，失败依次尝试下一个)
DOWNLOAD_MIRRORS=(
    "https://gh-proxy.org/https://github.com"
    "https://ghfast.top/https://github.com"
    "https://mirror.ghproxy.com/https://github.com"
    "https://github.com"
)

# ======================== 第一步：检测系统架构 ========================
step "1/6 检测系统架构..."

ARCH=$(uname -m)
case "${ARCH}" in
    aarch64|arm64)
        FRP_ARCH="arm64"
        ;;
    x86_64|amd64)
        FRP_ARCH="amd64"
        ;;
    *)
        error "不支持的系统架构: ${ARCH}。此脚本仅支持 arm64 和 amd64。"
        ;;
esac

info "检测到架构: ${ARCH}, 将下载 linux_${FRP_ARCH} 版本。"

# 构造下载文件名和解压目录名
FILE_NAME="frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz"
EXTRACT_DIR="frp_${FRP_VERSION}_linux_${FRP_ARCH}"

# ======================== 第二步：检查下载与解压依赖 ========================
step "2/6 检查系统依赖..."

# 检查下载工具：优先 wget，其次 curl
if command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget"
    info "检测到下载工具: wget"
elif command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl"
    info "检测到下载工具: curl"
else
    error "系统未安装 wget 或 curl，请先安装: sudo apt install wget -y"
fi

# 检查解压工具
if ! command -v tar &>/dev/null; then
    error "系统未安装 tar，请先安装: sudo apt install tar -y"
fi

info "依赖检查通过。"

# ======================== 第三步：停止旧服务 & 解锁关键目录 ========================
step "3/6 准备安装环境..."

# 如果已有 frpc 服务正在运行，先停止，防止端口占用或进程冲突
if systemctl is-active --quiet frpc 2>/dev/null; then
    warn "检测到 frpc 服务正在运行，正在停止..."
    sudo systemctl stop frpc || true
fi

# 如果已有 frpc 服务已注册，先禁用，防止旧服务干扰
if systemctl is-enabled --quiet frpc 2>/dev/null; then
    warn "检测到 frpc 服务已注册，正在禁用..."
    sudo systemctl disable frpc || true
fi

# 按照要求保留 chattr -i 操作，解除可能被锁死的目录和文件
# 某些安全脚本或极端情况下会给系统目录加上 +i (immutable) 属性导致无法写入
warn "正在尝试解除关键目录的 immutable 锁 (如果目录没被锁，此处报错属正常现象，可忽略)..."
sudo chattr -i /usr/local/bin/
info "安装环境准备完成。"

# ======================== 第四步：下载与解压 ========================
step "4/6 下载 FRP v${FRP_VERSION}..."

# 如果本地已存在安装包，跳过下载
if [ -f "${FILE_NAME}" ]; then
    info "检测到已存在安装包 ${FILE_NAME}，跳过下载。"
else
    # 依次尝试各镜像源下载
    DOWNLOAD_SUCCESS=false
    for MIRROR in "${DOWNLOAD_MIRRORS[@]}"; do
        DOWNLOAD_URL="${MIRROR}/fatedier/frp/releases/download/v${FRP_VERSION}/${FILE_NAME}"
        info "尝试下载: ${DOWNLOAD_URL}"
        warn "如果下载卡住(国内网络访问 GitHub 较慢)，请按 Ctrl+C 退出自行下载放置。"
        if [ "${DOWNLOAD_CMD}" = "wget" ]; then
            if wget -q --show-progress -O "${FILE_NAME}" "${DOWNLOAD_URL}"; then
                DOWNLOAD_SUCCESS=true
                break
            fi
        else
            if curl -L -o "${FILE_NAME}" "${DOWNLOAD_URL}"; then
                DOWNLOAD_SUCCESS=true
                break
            fi
        fi
        warn "该镜像源下载失败或超时，尝试下一个..."
        rm -f "${FILE_NAME}"
    done
    if [ "${DOWNLOAD_SUCCESS}" = false ]; then
        error "所有镜像源均下载失败！请检查网络或手动下载 ${FILE_NAME} 放至当前目录后重新运行。"
    fi
fi

# 校验下载文件的完整性，防止下载了空文件或错误页面
if [ ! -s "${FILE_NAME}" ]; then
    error "安装包 ${FILE_NAME} 为空文件，下载可能不完整，请删除后重试。"
fi

info "正在解压安装包..."
tar -xzf "${FILE_NAME}"

# 验证解压结果
if [ ! -d "${EXTRACT_DIR}" ]; then
    error "解压失败，找不到目录 ${EXTRACT_DIR}！"
fi

# ======================== 第五步：安装二进制文件与硬编码配置 ========================
step "5/6 安装 frpc 程序与配置文件..."

# --- 安装 frpc 二进制文件 ---
info "正在将 frpc 安装到 /usr/local/bin/ ..."
sudo cp "${EXTRACT_DIR}/frpc" /usr/local/bin/frpc
sudo chmod +x /usr/local/bin/frpc
# 创建配置文件专用目录
sudo mkdir -p /etc/frp
# 验证二进制文件是否可用
info "frpc 程序安装完成！版本: $(/usr/local/bin/frpc -v)"

# --- 写入硬编码的 frpc.toml 配置文件 ---
CONFIG_FILE="/etc/frp/frpc.toml"
info "正在将预设硬编码配置写入 ${CONFIG_FILE} ..."

# 利用 cat 和 'EOF' (带引号表示不解析内部变量) 将内容原样写入配置文件
# ⚠️ 注意：如果你以后需要修改配置，只需执行 sudo nano /etc/frp/frpc.toml
sudo tee "${CONFIG_FILE}" > /dev/null << 'EOF'
serverAddr = "120.79.1.21"
serverPort = 1210
user ="zfrQcUYsWthm"
loginFailExit = false
#支持 tcp, kcp, quic, websocket 和 wss 协议, 默认传输协议为tcp
#如果被限速可以尝试切换websocket协议（去掉下面一行的 '#' 号）
#transport.protocol = "websocket"

#上面是认证信息，不要修改
#下面的是一个完整连接的结构，其他协议请自行搜索frpc配置
#请先创建隧道，系统将自动生成配置文件

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="VjbLtGHE2DlD"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 22
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 59297
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="YPPhlAEWAAaw"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 8848
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 8848
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="3z5uD67jKPaA"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 7091
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 7091
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="7MWpujHVEeIj"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 3306
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 3306
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="Xp3RSRAW3UxN"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 5432
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 5432
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="246shA48l7Id"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 6379
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 6379
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="2FQjlYS2SFZs"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 5601
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 5601
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="Oyjn8tRyVeHL"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 8888
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 8888
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="cBK14t0uJymB"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 4224
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 4224
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true

[[proxies]]
type = "tcp"
#每个连接一个名称，不能修改
name="hYsGkypDmczX"
localIP = "127.0.0.1"
#请填写需要远程访问的本地端口
localPort = 10848
#每个连接一个远程端口，访问地址 serverAddr:remotePort
remotePort = 10848
#启动报错时尝试删除下面两行
transport.useEncryption = true
transport.useCompression = true
EOF
info "配置文件写入成功！"

# 输出当前配置供确认
echo "----------------------------------------------------------------"
cat "${CONFIG_FILE}"
echo "----------------------------------------------------------------"

# ======================== 第六步：配置 Systemd 服务并启动 ========================
step "6/6 配置 Systemd 开机自启服务..."
# --- 写入 Service 文件 ---
SERVICE_FILE="/etc/systemd/system/frpc.service"
info "正在写入服务文件 ${SERVICE_FILE} ..."
sudo tee "${SERVICE_FILE}" > /dev/null << EOF
[Unit]
# 服务描述
Description=Frp Client Service
# 依赖：网络就绪后再启动
After=network.target network-online.target
Wants=network-online.target

[Service]
# 服务类型：简单模式，ExecStart 即主进程
Type=simple
# 以 root 身份运行
User=root
# 进程异常退出后自动重启
Restart=on-failure
# 重启间隔 5 秒 (纯数字格式，兼容旧版 systemd)
RestartSec=5
# 启动命令
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml
# 优雅停止：发送 SIGTERM 信号
KillSignal=SIGTERM
# 等待 10 秒后强制杀死
TimeoutStopSec=10

[Install]
# 开机自启目标
WantedBy=multi-user.target
EOF
# 按照要求保留 chattr -i 操作，解锁 systemd 相关目录
warn "正在尝试解除 systemd 目录的 immutable 锁 (如果目录没被锁，此处报错属正常现象，可忽略)..."
# 1. 解锁 multi-user.target.wants 目录（这是 enable 写入链接的地方）
sudo chattr -i /etc/systemd/system/multi-user.target.wants/
# 2. 顺手解锁 frpc.service 文件本身（防止刚才写入时带了锁）
sudo chattr -i /etc/systemd/system/frpc.service
# 3. 确认一下解锁状态（应该看不到 i 了）
sudo lsattr -d /etc/systemd/system/multi-user.target.wants/ || true
sudo lsattr /etc/systemd/system/frpc.service || true
# 4. 重新加载 systemd 配置
sudo systemctl daemon-reload
# 5. 再次尝试启用开机自启
sudo systemctl enable frpc
# 6. 启动服务
info "正在启动 frpc 服务..."
sudo systemctl start frpc
sudo systemctl status frpc --no-pager
# 等待 2 秒让服务完成启动
sleep 2

# 7. 检查运行状态
echo "================================================================"
if systemctl is-active --quiet frpc; then
    info "恭喜！frpc 服务已成功启动并正在运行！"
else
    error "frpc 服务启动失败，请查看日志排查：journalctl -u frpc -n 50 --no-pager"
fi

# ======================== 清理安装临时文件 ========================
info "正在清理安装包和解压文件..."
rm -rf "${EXTRACT_DIR}"
rm -f "${FILE_NAME}"

# ======================== 使用提示 ========================
echo "================================================================"
info "【日常管理提示】"
echo -e " 1. 修改配置文件：${YELLOW}sudo nano /etc/frp/frpc.toml${NC}"
echo -e " 2. 修改配置后重启生效：${YELLOW}sudo systemctl restart frpc${NC}"
echo -e " 3. 查看运行状态：${YELLOW}sudo systemctl status frpc --no-pager${NC}"
echo -e " 4. 查看实时日志：${YELLOW}sudo journalctl -u frpc -f${NC}"
echo -e " 5. 停止服务：${YELLOW}sudo systemctl stop frpc${NC}"
echo -e " 6. 取消开机自启：${YELLOW}sudo systemctl disable frpc${NC}"
echo ""
info "【卸载方法】"
echo -e "  ${YELLOW}sudo systemctl stop frpc${NC}"
echo -e "  ${YELLOW}sudo systemctl disable frpc${NC}"
echo -e "  ${YELLOW}sudo rm -f /usr/local/bin/frpc /etc/frp/frpc.toml /etc/systemd/system/frpc.service${NC}"
echo -e "  ${YELLOW}sudo systemctl daemon-reload${NC}"
echo "================================================================"
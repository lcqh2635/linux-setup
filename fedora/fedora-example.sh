#!/bin/bash
# ==============================================================================
# 脚本名称: fedora-setup.sh
# 功能描述：Fedora 工作站自动化初始化、优化及开发环境配置脚本
# 适用系统：Fedora Workstation 40+ (兼容 DNF 4/5)
# 作者：龙茶清欢 (优化版)
# 版本：2.0.0
# 使用方法：
#   1. chmod +x fedora-setup.sh
#   2. ./fedora-setup.sh
#   (请勿直接使用 sudo 运行此脚本，脚本内部会自动提权需要 root 的操作)
# ==============================================================================

# ------------------------------------------------------------------------------
# 全局配置与安全设置
# ------------------------------------------------------------------------------
set -euo pipefail

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测是否以 root 运行整个脚本（不推荐，因为 gsettings 需要用户环境）
if [[ $EUID -eq 0 ]]; then
    log_error "请不要使用 sudo 运行此脚本。脚本会在需要时自动请求 sudo 权限。"
    exit 1
fi

# 获取当前用户
CURRENT_USER=$(whoami)
HOME_DIR="/home/${CURRENT_USER}"

# ------------------------------------------------------------------------------
# 辅助函数
# ------------------------------------------------------------------------------

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 询问用户确认
confirm_action() {
    local prompt="${1:-确定继续吗？}"
    read -p "${YELLOW}${prompt} (y/n): ${NC}" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "用户取消操作。"
        return 1
    fi
    return 0
}

# 等待网络连通性
wait_for_network() {
    log_info "检查网络连接..."
    if ! ping -c 1 -W 2 mirrors.ustc.edu.cn &> /dev/null; then
        log_warn "网络连接似乎有问题，请检查后重试。"
        # 不强制退出，尝试继续
    else
        log_success "网络连接正常。"
    fi
}

# ------------------------------------------------------------------------------
# 模块 1: 系统基础配置 (GNOME Settings)
# ------------------------------------------------------------------------------
configure_basics_gsettings() {
    log_info "正在配置 GNOME 桌面基础设置..."
    
    # 设置强调色为蓝色
    gsettings set org.gnome.desktop.interface accent-color 'blue'
    # 新窗口居中
    gsettings set org.gnome.mutter center-new-windows true
    # 显示星期
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    # 显示电量百分比
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    # 夜灯设置 (4000K)
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    # 窗口按钮布局 (右侧)
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    # 禁用动态工作区，固定为 3 个
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 3
    gsettings set org.gnome.desktop.wm.preferences workspace-names "['工作/代码', '浏览/文档', '娱乐/交流']"

    # 快捷键优化
    log_info "配置自定义快捷键..."
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "['<Alt>End']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Alt>1']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Alt>2']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Alt>3']"
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
    gsettings set org.gnome.desktop.wm.keybindings close "['<Super>c']"

    log_success "GNOME 基础配置完成。"
}

# ------------------------------------------------------------------------------
# 模块 2: 软件源加速与 DNF 优化
# ------------------------------------------------------------------------------
configure_repos_and_dnf() {
    log_info "正在配置软件源加速与 DNF 优化..."

    # 1. 备份并替换 Fedora 官方源为中科大镜像
    log_info "替换 Fedora 主仓库镜像 (USTC)..."
    if [ ! -f /etc/yum.repos.d/fedora.repo.bak ]; then
        sudo cp /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.bak
        sudo cp /etc/yum.repos.d/fedora-updates.repo /etc/yum.repos.d/fedora-updates.repo.bak
    fi

    sudo sed -e 's|^metalink=|#metalink=|g' \
             -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' \
             -i /etc/yum.repos.d/fedora.repo \
             /etc/yum.repos.d/fedora-updates.repo

    # 2. 安装 RPM Fusion 源 (使用 USTC 镜像)
    log_info "安装并配置 RPM Fusion 源..."
    FEDORA_VERSION=$(rpm -E %fedora)
    if [ ! -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
        sudo dnf install -y --nogpgcheck \
            https://mirrors.ustc.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm \
            https://mirrors.ustc.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm
    fi

    # 修改 RPM Fusion 源为 USTC
    if [ -f /etc/yum.repos.d/rpmfusion-free.repo ]; then
        sudo sed -e 's|^metalink=|#metalink=|g' \
                 -e 's|^#baseurl=http://download1.rpmfusion.org|baseurl=https://mirrors.ustc.edu.cn/rpmfusion|g' \
                 -i /etc/yum.repos.d/rpmfusion*.repo
    fi

    # 3. 启用 Google Chrome 仓库 (可选，按需开启)
    # sudo dnf install -y fedora-workstation-repositories
    # sudo dnf config-manager setopt google-chrome.enabled=1

    # 4. 清理并重建缓存
    log_info "重建 DNF 缓存..."
    sudo dnf clean all
    sudo dnf makecache

    # 5. 优化 DNF 速度 (并行下载 + 最快镜像)
    log_info "优化 DNF 下载速度..."
    # 兼容 DNF 4 和 DNF 5 的配置方式
    if check_command dnf; then
        # 直接修改配置文件以确保持久化
        if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
            echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
            echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
        fi
    fi

    log_success "软件源与 DNF 配置完成。"
}

# ------------------------------------------------------------------------------
# 模块 3: 系统更新与基础清理
# ------------------------------------------------------------------------------
system_update_and_cleanup() {
    log_info "正在更新系统并清理无用包..."
    sudo dnf upgrade --refresh -y
    sudo dnf autoremove -y
    
    # 移除预装但不常用的软件
    log_info "移除预装的冗余软件..."
    sudo dnf remove -y mediawriter libreoffice-* abrt* || true
    
    log_success "系统更新完成。"
}

# ------------------------------------------------------------------------------
# 模块 4: 开发环境与工具链安装
# ------------------------------------------------------------------------------
install_dev_tools() {
    log_info "正在安装基础开发工具链..."
    
    # 基础工具组
    sudo dnf group install -y "Development Tools" "C Development Tools and Libraries" "RPM Development Tools"
    
    # 常用命令行工具
    sudo dnf install -y \
        git wget curl unzip p7zip \
        fastfetch wl-clipboard \
        gnome-tweaks gnome-browser-connector \
        libadwaita-demo \
        podman podman-compose \
        kubernetes kubernetes-kubeadm kubernetes-client

    # 多媒体编解码器
    log_info "安装多媒体编解码器..."
    sudo dnf group install -y multimedia
    sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing
    sudo dnf install -y libva-utils vulkan-tools

    log_success "基础开发工具安装完成。"
}

configure_languages() {
    log_info "正在配置编程语言环境 (Node, Java, Go, Rust, Zig)..."

    # 1. Node.js & Bun & Web Tools
    log_info "配置 Node.js 生态..."
    sudo dnf install -y nodejs
    npm config set registry https://registry.npmmirror.com/
    
    # 修复 /usr/local 权限以便全局安装
    if [ -d "/usr/local" ]; then
        sudo chown -R $(whoami):$(whoami) /usr/local
    fi
    
    # 安装 Bun
    if ! check_command bun; then
        npm install -g bun
        cat << EOF > $HOME/.bunfig.toml
[install]
registry = "https://registry.npmmirror.com/"
EOF
        log_info "Bun 已安装: $(bun --version)"
    fi

    # 安装全局 Web 工具
    npm install -g typescript vite eslint prettier deno

    # 2. Java & Maven
    log_info "配置 Java 环境..."
    sudo dnf install -y java-21-openjdk maven # 建议使用 LTS 版本 21，而非最新的 25 (除非确实需要)
    mkdir -p $HOME/.m2
    if [ ! -f $HOME/.m2/settings.xml ]; then
        cat << EOF > $HOME/.m2/settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0">
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
    fi

    # 3. Go
    log_info "配置 Go 环境..."
    sudo dnf install -y golang
    go env -w GO111MODULE=on
    go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
    go env -w GOSUMDB=sum.golang.google.cn
    mkdir -p $HOME/go

    # 4. Rust
    log_info "配置 Rust 环境..."
    if ! check_command rustc; then
        export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
        export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
        curl --proto '=https' --tlsv1.2 -sSf https://mirrors.ustc.edu.cn/rust/rustup-init.sh | sh -s -- -y
        source "$HOME/.cargo/env"
        
        # 配置 Cargo 镜像
        mkdir -p $HOME/.cargo
        cat << EOF > $HOME/.cargo/config.toml
[source.crates-io]
replace-with = 'ustc'
[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF
        log_info "Rust 已安装: $(rustc --version)"
    fi

    # 5. Zig
    log_info "配置 Zig 环境..."
    sudo dnf install -y zig

    # 创建项目目录结构
    mkdir -p $HOME/Projects/{Java,Rust,Cpp,Python,TypeScript,Database}
    mkdir -p $HOME/Projects/Database/{SQLite,MySQL,Postgres,Redis}

    log_success "编程语言环境配置完成。"
}

# ------------------------------------------------------------------------------
# 模块 5: Flatpak 应用安装
# ------------------------------------------------------------------------------
configure_flatpak() {
    log_info "正在配置 Flatpak 并安装应用..."
    
    # 添加/更新 Flathub 源 (使用 USTC 镜像)
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
    flatpak update --appstream

    # 允许 Flatpak 访问主机主题
    sudo flatpak override --filesystem=xdg-data/themes:ro
    sudo flatpak override --filesystem=xdg-data/icons:ro
    sudo flatpak override --filesystem=$HOME/.themes:ro
    sudo flatpak override --filesystem=$HOME/.icons:ro

    # 定义要安装的应用列表
    FLATPAK_APPS=(
        "com.mattjakeman.ExtensionManager"
        "com.github.tchx84.Flatseal"
        "org.gnome.Evolution"
        "com.github.neithern.g4music"
        "com.github.gmg137.netease-cloud-music-gtk"
        "com.google.Chrome"
        "com.qq.QQ"
        "com.tencent.WeChat"
        "org.gnome.Builder"
        "com.usebottles.bottles"
        "io.github.marhkb.Pods"
    )

    for app in "${FLATPAK_APPS[@]}"; do
        log_info "安装 Flatpak 应用: $app"
        flatpak install -y flathub "$app" || log_warn "安装 $app 失败，跳过。"
    done

    log_success "Flatpak 应用安装完成。"
}

# ------------------------------------------------------------------------------
# 模块 6: 主题与美化 (WhiteSur)
# ------------------------------------------------------------------------------
install_theme_whitesur() {
    log_info "正在下载并安装 WhiteSur 主题..."
    
    THEME_DIR="$HOME/Downloads/WhiteSur-themes"
    mkdir -p "$THEME_DIR"
    cd "$THEME_DIR"

    # 克隆主题仓库 (使用浅克隆加速)
    REPOS=(
        "https://github.com/vinceliuice/WhiteSur-wallpapers.git"
        "https://github.com/vinceliuice/WhiteSur-cursors.git"
        "https://github.com/vinceliuice/WhiteSur-icon-theme.git"
        "https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
    )

    for repo in "${REPOS[@]}"; do
        name=$(basename "$repo" .git)
        if [ ! -d "$name" ]; then
            git clone --depth=1 "$repo"
        fi
    done

    # 安装壁纸
    cd WhiteSur-wallpapers && ./install-wallpapers.sh && sudo ./install-gnome-backgrounds.sh && cd ..
    
    # 安装光标
    cd WhiteSur-cursors && ./install.sh && cd ..
    
    # 安装图标
    cd WhiteSur-icon-theme && ./install.sh && cd ..

    # 安装 GTK 主题
    cd WhiteSur-gtk-theme
    # 简单处理 Firefox 进程，避免安装脚本报错
    if pgrep -x "firefox" > /dev/null; then
        log_warn "Firefox 正在运行，尝试关闭以应用主题..."
        pkill firefox
        sleep 2
    fi
    
    ./install.sh -l -o solid
    ./tweaks.sh -f flat -F -o solid
    
    # 应用自定义背景
    sudo ./tweaks.sh -g -b "$HOME/.local/share/backgrounds/wallpaper-noon.jpg"
    cd ..

    log_success "WhiteSur 主题安装完成。请在 GNOME Tweaks 中手动选择主题。"
}

apply_theme_settings() {
    log_info "应用主题设置..."
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
    gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
    gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.sound theme-name 'Yaru'
}

# ------------------------------------------------------------------------------
# 模块 7: JetBrains 工具箱 (官方安装)
# ------------------------------------------------------------------------------
install_jetbrains_toolbox() {
    log_info "正在安装 JetBrains Toolbox..."
    
    cd "$HOME/Downloads"
    # 获取最新正式版链接 (排除 arm64)
    DOWNLOAD_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | \
                   grep -o 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^\"]*\.tar\.gz' | \
                   grep -v 'arm64' | head -1)
    
    if [ -z "$DOWNLOAD_URL" ]; then
        log_error "无法获取 JetBrains Toolbox 下载链接。"
        return 1
    fi

    wget -O jetbrains-toolbox.tar.gz "$DOWNLOAD_URL"
    
    mkdir -p "$HOME/.apps"
    tar -xzf jetbrains-toolbox.tar.gz -C "$HOME/.apps"
    
    # 找到解压后的目录并运行
    TOOLBOX_DIR=$(find "$HOME/.apps" -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -1)
    if [ -n "$TOOLBOX_DIR" ]; then
        chmod +x "$TOOLBOX_DIR/jetbrains-toolbox"
        log_info "启动 JetBrains Toolbox..."
        # 在后台运行
        "$TOOLBOX_DIR/jetbrains-toolbox" &
        log_success "JetBrains Toolbox 已启动。请按照界面提示完成后续配置。"
        log_warn "注意：本脚本不包含自动激活破解补丁，请使用正版授权或学生认证。"
    else
        log_error "解压 JetBrains Toolbox 失败。"
    fi
}

# ------------------------------------------------------------------------------
# 模块 8: Git 配置
# ------------------------------------------------------------------------------
configure_git() {
    log_info "配置 Git..."
    # 这里使用占位符，实际使用时建议用户手动修改或通过参数传入
    read -p "请输入您的 Git 用户名 (默认 lcqh2635): " GIT_NAME
    GIT_NAME=${GIT_NAME:-lcqh2635}
    
    read -p "请输入您的 Git 邮箱 (默认 lcqh2635@gmail.com): " GIT_EMAIL
    GIT_EMAIL=${GIT_EMAIL:-lcqh2635@gmail.com}

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    
    if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
        log_info "生成 SSH 密钥..."
        ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_rsa" -N ""
        log_info "公钥内容已复制到剪贴板 (需 wl-clipboard)，请添加到 GitHub/Gitee。"
        cat "$HOME/.ssh/id_rsa.pub" | wl-copy
        cat "$HOME/.ssh/id_rsa.pub"
    else
        log_warn "SSH 密钥已存在，跳过生成。"
    fi
}

# ------------------------------------------------------------------------------
# 主执行流程
# ------------------------------------------------------------------------------
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Fedora 初始化配置脚本 v2.0${NC}"
    echo -e "${BLUE}  作者：龙茶清欢 (优化版)${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    wait_for_network

    if ! confirm_action "即将开始系统配置，过程中可能需要输入 sudo 密码。是否继续？"; then
        exit 0
    fi

    # 1. 基础 GNOME 设置
    configure_basics_gsettings

    # 2. 软件源与 DNF
    configure_repos_and_dnf

    # 3. 系统更新
    system_update_and_cleanup

    # 4. 开发工具
    install_dev_tools
    configure_languages
    configure_git

    # 5. Flatpak 应用
    configure_flatpak

    # 6. 主题美化 (可选)
    if confirm_action "是否安装 WhiteSur 主题并进行美化？"; then
        install_theme_whitesur
        apply_theme_settings
    else
        log_warn "跳过主题安装。"
    fi

    # 7. JetBrains Toolbox
    if confirm_action "是否安装 JetBrains Toolbox？"; then
        install_jetbrains_toolbox
    else
        log_warn "跳过 JetBrains Toolbox 安装。"
    fi

    # 8. 最终清理
    log_info "执行最终清理..."
    sudo dnf autoremove -y
    sudo dnf clean all

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  配置全部完成！${NC}"
    echo -e "${GREEN}  建议重启系统以应用所有更改。${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    read -p "是否立即重启？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl reboot
    fi
}

# 执行主函数
main "$@"
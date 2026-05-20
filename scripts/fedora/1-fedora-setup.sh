#!/bin/bash
# ==============================================================================
# 脚本名称: setup.sh
# 功能描述：Fedora 工作站自动化初始化、优化及开发环境配置脚本
# 适用系统：Fedora Workstation 40+ (兼容 DNF 4/5)
# 作者：龙茶清欢 (优化版)
# 版本：2.0.0
# 使用方法：chmod +x setup.sh && ./setup.sh
# (请勿直接使用 sudo 运行此脚本，脚本内部会自动提权需要 root 的操作)
# 仓库克隆：cd ~/下载 && git clone --depth=1 https://gitee.com/lcqh2635/linux-setup.git
# cd ~/文档 && git clone --depth=1 git@gitee.com:lcqh2635/linux-setup.git
# 仓库提交：cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push
# ==============================================================================

set -euo pipefail


# 检测是否以 root 运行整个脚本（不推荐，因为 gsettings 需要用户环境）
if [[ $EUID -eq 0 ]]; then
    echo "请不要使用 sudo 运行此脚本。脚本会在需要时自动请求 sudo 权限。"
    exit 1
fi

# 获取当前用户
CURRENT_USER=$(whoami)
HOME_DIR="/home/${CURRENT_USER}"

# 定义加速前缀 (可自行更换)
GITHUB_PROXY_URL="https://gh-proxy.org/"

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
        echo "用户取消操作。"
        return 1
    fi
    return 0
}

# ------------------------------------------------------------------------------
# 模块 1: 系统基础配置 (GNOME Settings)
# ------------------------------------------------------------------------------
configure_basics_gsettings() {
echo "正在配置 GNOME 桌面基础设置..."
cd ~/下载
# 显示登出菜单
gsettings set org.gnome.shell always-show-log-out true
# 设置强调色为蓝色
gsettings set org.gnome.desktop.interface accent-color 'blue'
# 设置新窗口居中显示
gsettings set org.gnome.mutter center-new-windows true
# 显示星期几
gsettings set org.gnome.desktop.interface clock-show-weekday true
# 设置电量百分比
gsettings set org.gnome.desktop.interface show-battery-percentage true
# 设置夜灯温度（色温，范围 1000~10000，默认约 2700 色温严重偏黄，越小越黄）
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
# 开启夜灯
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
# 设置窗口按钮位置 (右)
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
# 禁用动态工作区，会导致预览窗口出现 3 个小窗口，不建议关闭
# gsettings set org.gnome.mutter dynamic-workspaces false
# 设置工作区数量为3（奇数确保有中间位）
# gsettings set org.gnome.desktop.wm.preferences num-workspaces 3
# 预设工作区名称
gsettings set org.gnome.desktop.wm.preferences workspace-names "['工作/代码', '浏览/文档', '娱乐/交流']"
# 屏幕时间限制
gsettings set org.gnome.desktop.screen-time-limits daily-limit-enabled true
# 每日限制使用时长，从默认的 8 小时改为 10 小时
gsettings set org.gnome.desktop.screen-time-limits daily-limit-seconds 36000
# 桌面健康
gsettings set org.gnome.desktop.break-reminders selected-breaks "['eyesight', 'movement']"
# gsettings list-recursively org.gnome.desktop.break-reminders.movement
# 一个小时活动5分钟
gsettings set org.gnome.desktop.break-reminders.movement duration-seconds 300
gsettings set org.gnome.desktop.break-reminders.movement interval-seconds 3600
# 隐私与安全
gsettings set org.gnome.system.location enabled false
gsettings set org.gnome.desktop.privacy disable-camera true
gsettings set org.gnome.desktop.privacy disable-microphone true
# Nautilus 设置
# gsettings list-recursively org.gnome.nautilus.preferences
gsettings set org.gnome.nautilus.preferences date-time-format 'detailed'
gsettings set org.gnome.nautilus.preferences default-sort-order 'type'
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.preferences show-delete-permanently true
# Ptyxis 终端
gsettings set org.gnome.Ptyxis interface-style 'system'
gsettings set org.gnome.shell.weather automatic-location true
# 快捷键优化
echo "配置自定义快捷键..."
# 自定义快捷键优化，Alt 管理工作区、Super 管理窗口
# gsettings list-recursively org.gnome.desktop.wm.keybindings
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "['<Alt>End']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Alt>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Alt>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Alt>3']"
# 切换当前工作区所有的窗口的显示与隐藏，可以替代 Show Desktop Button 扩展插件的功能
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>Home']"
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
# gsettings set org.gnome.desktop.wm.keybindings close "['<Super>c']"
gsettings set org.gnome.desktop.wm.keybindings move-to-center "['<Super>c']"
# Alt + Super 移动当前工作取得窗口到左右其他工作区
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Super><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Alt>Right']"
# gsettings list-recursively org.gnome.shell.keybindings
if [ ! -d "$HOME/下载/linux-setup" ]; then
    git config --global user.name "lcqh2635"
    git config --global user.email "lcqh2635@gmail.com"
    ssh-keygen -t rsa -b 4096 -C "lcqh2635@gmail.com" -f "$HOME/.ssh/id_rsa" -N ""
    # cat "$HOME/.ssh/id_rsa.pub" | wl-copy
    git clone --depth=1 https://github.com/lcqh2635/linux-setup.git
    cp -r ~/下载/linux-setup/template/* /home/lcqh/模板/
    mkdir -vp ~/.local/share/backgrounds
    # nautilus ~/.local/share/backgrounds/
    # nautilus admin:/usr/share/backgrounds/
    cp -r ~/下载/linux-setup/wallpaper/* ~/.local/share/backgrounds/
    # cp -r ~/文档/linux-setup/wallpaper/* ~/.local/share/backgrounds/
    # gsettings list-recursively org.gnome.desktop.background
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-light.jpg"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/wallpaper-dark.jpg"
fi
# 甚至可以使用大括号展开来创建有规律的目录
mkdir -vp $HOME/编程/{Java,Rust,Cpp,Python,TypeScript,Database,Gnome,AndroidStudio}
mkdir -vp $HOME/编程/Database/{SQLite,MySQL,MariaDB,Postgres,Distributed,Redis}
echo "GNOME 基础配置完成。"
}


# ------------------------------------------------------------------------------
# 模块 5: Flatpak 应用安装
# ------------------------------------------------------------------------------
# shellcheck disable=SC2120
configure_flatpak_and_install_app() {

echo "正在配置 Flatpak 国内镜像源 (使用中科大 flatpak 镜像)..."
# 禁用 fedora 仓库，解决 gnome-software 初次加载时间过长的问题
sudo flatpak remote-modify --disable fedora
# sudo flatpak remote-modify --enable fedora

# flathub 官方在 Fedora 配置文件 https://flathub.org/zh-Hans/setup/Fedora
# 中国科技大学 flathub 镜像源 https://mirrors.ustc.edu.cn/help/flathub.html
# 在已有 flathub 远程源的基础上替换 Flatpak 默认的软件源
# Fedora默认安装了Flatpak，只要配置Flatpak加速镜像即可
# flatpak remotes --show-details
# 禁用 flathub 仓库
# flatpak remote-modify --disable flathub
# 添加 flathub 官方仓库
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# 修改 flathub 仓库地址为国内镜像源
# 1、上海交通大学 Flatpak 软件源镜像	https://mirrors.sjtug.sjtu.edu.cn/docs/flathub
# sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
# 2、中科大 Flatpak 镜像源（处于测试阶段） https://mirrors.ustc.edu.cn/help/flathub.html
sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
# 恢复默认值：
# sudo flatpak remote-modify flathub --url=https://dl.flathub.org/repo
# 允许 Flatpak 访问主机主题
# 将 WhiteSur 主题包连接到 Flatpak 仓库，可以解决部分应用无法使用 WhiteSur 主题问题，例如：Chrome、Edge
# xdg-data/themes 是 ~/.local/share/themes 的标准化路径别名（Flatpak 优先识别）
# :ro 表示只读权限，避免应用误修改主题文件。
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak override --filesystem=xdg-config/gtk-4.0:ro
sudo flatpak override --filesystem=xdg-data/themes:ro
sudo flatpak override --filesystem=xdg-data/icons:ro
sudo flatpak override --filesystem="$HOME"/.themes:ro
sudo flatpak override --filesystem="$HOME"/.icons:ro

}


# 模块 2: 软件源加速与 DNF 优化
# ------------------------------------------------------------------------------
configure_repos_and_dnf() {
echo "正在配置软件源加速与 DNF 优化..."
cd ~/下载
# 1. 优化 DNF 速度 (并行下载 + 最快镜像)
echo "优化 DNF 下载速度..."
# https://linuxcapable.com/increase-dnf-speed-on-fedora-linux/
# 当Fedora上DNF感觉很慢时，等待通常来自两个原因：保守的下载行为和镜像选择与你的网络路径不匹配。
# 要提高 Fedora 的 DNF 速度，可以启用并行下载并测试 fastestmirror，这样大规模更新和多包安装时可以减少一次只等待一个包的时间。
# 当前的Fedora版本使用DNF5，最简洁的更改方式是使用 dnf config-manager setopt，而不是先在编辑器中打开/etc/dnf/dnf.conf。
# 这样可以保持更改的可重复性，清晰显示当前运行时的值，并且方便之后降低max_parallel_downloads或关闭fastestmirror=true。
# https://mirrormanager.fedoraproject.org/
# https://dnf-plugins-core.readthedocs.io/en/latest/
# https://github.com/rpm-software-management/dnf5
# 在Fedora上，DNF默认为max_parallel_downloads=3，fastestmirror=False。这安全且可预测，但当连接稳定且镜像路径良好时，下载速度可能会明显受影响。
# Fedora已经给出了DNF工作镜像列表，所以fastestmirror=True值得测试，但不值得当作绝对标准。如果启用后刷新速度变慢，就关闭该选项，保持并行下载。
# 这会把数值写入你的主配置文件，地址是 /etc/dnf/dnf.conf。如果你之后检查文件，应该会在[main]下方看到这些行：
# sudo dnf config-manager setopt max_parallel_downloads=6 fastestmirror=True
# 如果下面配置使用了固定的阿里云加速镜像，则不要配置 fastestmirror=True
sudo dnf config-manager setopt max_parallel_downloads=10
# sudo dnf config-manager setopt fastestmirror=False
# ls /etc/dnf && cat /etc/dnf/dnf.conf
# 现在验证当前运行时的值，而不仅仅是检查文件内容：
dnf --dump-main-config | grep -E '^(fastestmirror|max_parallel_downloads) = '

# https://docs.fedoraproject.org/zh_Hans/quick-docs/adding-or-removing-software-repositories-in-fedora/
REPO_ID="copr:copr.fedorainfracloud.org:phracek:PyCharm"
REPO_FILE="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo"
sudo dnf config-manager setopt "$REPO_ID.enabled=0" 2>/dev/null
sudo rm -f "$REPO_FILE" 2>/dev/null

# 3. 备份并替换 Fedora 官方源为阿里云镜像
echo "替换 Fedora 主仓库镜像..."
# Fedora 默认使用 metalink 来根据用户发出请求的 IP 选择合适的镜像，通常情况下并不需要手动换源。操作前请做好相应备份
# 配置 Ubuntu 国内加速镜像，在所有的国内加速镜像中 ustc 中科大是同步更新最及时，并且下载速度也飞快的一个加速镜像站点，优先使用它！
# https://developer.aliyun.com/mirror/fedora
# https://mirrors.ustc.edu.cn/help/fedora.html
# https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora.repo
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora-updates.repo
# 将上述两个文件先做个备份，根据 Fedora 系统版本分别替换为下面内容，之后通过 sudo dnf makecache 命令更新本地缓存，即可使用所选择的软件源镜像。
if [ ! -f "/etc/yum.repos.d/fedora.repo.bak" ]; then
echo "⚠️  加速镜像仓库 'fedora' 还未配置，开始配置..."
# https://developer.aliyun.com/mirror/fedora
sudo sed -e 's|^metalink=|#metalink=|g' \
-e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.aliyun.com/fedora|g' \
-i.bak \
/etc/yum.repos.d/fedora.repo \
/etc/yum.repos.d/fedora-updates.repo 
fi  
# 4. 安装 RPM Fusion 源
echo "安装并配置 RPM Fusion 源..."
# RPM Fusion 默认使用 metalink 来根据用户发出请求的 IP 选择合适的镜像，通常情况下并不需要手动换源
# 阿里云 RPMFusion 镜像源		https://developer.aliyun.com/mirror/rpmfusion
# 中国科技大学 RPMFusion 镜像源	https://mirrors.ustc.edu.cn/help/rpmfusion.html
# 使用下列命令（在 bash 或兼容 shell 中），可以同时启用其 free 和 nonfree 软件源
sudo dnf install -y --nogpgcheck \
https://mirrors.aliyun.com/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://mirrors.aliyun.com/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# 修改 RPM Fusion 源为 USTC
# 安装成功后，可使用下列命令备份并修改 /etc/yum.repos.d/ 目录下以 rpmfusion 开头，以 .repo 结尾的文件。
# 具体而言，需要将文件中 metalink= 开头的行注释掉，取消 baseurl= 开头的行的注释
# 并将等号后面链接中的 http://download1.rpmfusion.org 替换为 https://mirrors.aliyun.com/rpmfusion
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/rpmfusion-free.repo
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/rpmfusion-free-updates.repo
if [ ! -f "/etc/yum.repos.d/rpmfusion-free.repo.bak" ]; then
echo "⚠️  加速镜像仓库 'rpmfusion' 还未配置，开始配置..."
sudo sed -e 's!^metalink=!#metalink=!g' \
-e 's!^mirrorlist=!#mirrorlist=!g' \
-e 's!^#baseurl=!baseurl=!g' \
-e 's!https\?://download1\.rpmfusion\.org/!https://mirrors.aliyun.com/rpmfusion/!g' \
-i.bak /etc/yum.repos.d/rpmfusion*.repo
fi
# 5、删除文件后，必须清理 DNF 缓存以生效，同时重建 DNF 缓存
echo "正在清理 DNF 缓存并重建 DNF 缓存..."
sudo dnf clean all
sudo dnf makecache
# 更新 dnf 包列表、升级 dnf 包、 删除无用依赖
echo "正在更新系统并清理无用包..."
sudo dnf upgrade --refresh -y && sudo dnf autoremove -y
echo "正在安装常用软件包..."
sudo dnf install -y gnome-tweaks \
gnome-browser-connector gnome-extensions-app \
libadwaita-demo timeshift
sudo dnf install -y gnome-builder
gsettings set org.gnome.builder projects-directory "$HOME/编程/Gnome"
# 浏览并安装GNOME Shell 扩展以定制你的桌面
flatpak install -y flathub com.mattjakeman.ExtensionManager

sudo dnf remove -y \
gnome-shell-extension-window-list \
gnome-shell-extension-launch-new-instance
sudo dnf install -y \
gnome-shell-extension-appindicator \
gnome-shell-extension-auto-move-windows \
gnome-shell-extension-background-logo \
gnome-shell-extension-blur-my-shell \
gnome-shell-extension-caffeine \
gnome-shell-extension-dash-to-dock \
gnome-shell-extension-forge \
gnome-shell-extension-gsconnect \
gnome-shell-extension-just-perfection \
gnome-shell-extension-drive-menu \
gnome-shell-extension-user-theme \
gnome-shell-extension-workspace-indicator
# Background Logo
# gsettings list-recursively org.fedorahosted.background-logo-extension
# gsettings reset-recursively org.fedorahosted.background-logo-extension
gsettings set org.fedorahosted.background-logo-extension logo-always-visible true 
# Blur My Shell
gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility true
gsettings set org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab blur false  
# Dash To Dock
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.5
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DASHES'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true 
# Forge
gsettings set org.gnome.shell.extensions.forge tiling-mode-enabled false
gsettings set org.gnome.shell.extensions.forge focus-border-toggle false
# Just Perfection
gsettings set org.gnome.shell.extensions.just-perfection accessibility-menu false
gsettings set org.gnome.shell.extensions.just-perfection world-clock false
gsettings set org.gnome.shell.extensions.just-perfection weather false
gsettings set org.gnome.shell.extensions.just-perfection events-button false
gsettings set org.gnome.shell.extensions.just-perfection workspace false
gsettings set org.gnome.shell.extensions.just-perfection workspace-wrap-around true
gsettings set org.gnome.shell.extensions.just-perfection window-demands-attention-focus true
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0
gsettings set org.gnome.shell.extensions.just-perfection animation 7
# 安装游戏平台
# sudo dnf install -y wine dxvk-native lutris steam
# https://developer.aliyun.com/mirror/google-chrome
# sudo dnf install -y google-chrome-stable
# 为 Linux 上的 Flathub 提供支持的 Flatpak 应用商店
flatpak install -y flathub io.github.kolunmi.Bazaar
# Flatseal 是一种图形工具，用于审查和修改 Flatpak 应用程序中的权限
flatpak install -y flathub com.github.tchx84.Flatseal
# Warehouse 提供了一个简单的用户界面来控制复杂的 Flatpak 选项，而且完全无需借助命令行
flatpak install -y flathub io.github.flattool.Warehouse
# 更改 GDM 设置； 应用主题和背景、更改光标主题、图标主题和夜灯设置等
flatpak install -y flathub io.github.realmazharhussain.GdmSettings
# Microsoft Edge 网络浏览器
flatpak install -y flathub com.microsoft.Edge
# Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
flatpak install -y flathub com.google.Chrome
}


# 还原上述固定加速镜像源配置
reset__mirror_configure() {
    # 还原上述 fedora 修改
    # 遍历 /etc/yum.repos.d/ 目录下所有以 fedora 开头且以 .bak 结尾的文件，并去除末尾的 .bak 后缀
    for i in /etc/yum.repos.d/fedora*.bak; do sudo mv "$i" "${i%.bak}"; done
    # 还原上述 RPM Fusion 修改
    # 遍历 /etc/yum.repos.d/ 目录下所有以 rpmfusion 开头且以 .bak 结尾的文件，并去除末尾的 .bak 后缀
    for i in /etc/yum.repos.d/rpmfusion*.bak; do sudo mv "$i" "${i%.bak}"; done
}


# 重置系统字体配置
reset_font() {
# dnf list *fonts*
# Noto Fonts（思源黑体/宋体 的谷歌版本）
# Noto Sans（无衬线体，类似思源黑体）：界面清晰，适合屏幕显示。
# Noto Serif（衬线体，类似思源宋体）：适合长篇文档阅读。
# JetBrains Mono JetBrains 公司专门为 IDE 设计的字体。字母宽度大，容易区分 1、l、I，默认支持连字符，非常耐看。
# 系统界面（中文）	Noto Sans CJK SC	谷歌思源黑体，字库全，笔画均衡，与 Inter 风格协调
# 文档阅读/写作	Noto Serif CJK SC	思源宋体，适合长时间阅读，衬线带来轻松的纸质感
# 编程/终端		JetBrains Mono		字母区分度高，支持连字，视觉疲劳度低
# fonts-noto-cjk 这个软件包直接提供了思源黑体和思源宋体在 Ubuntu 系统中的标准版本
# Noto Sans CJK SC （思源黑体——简体中文）
# Noto Serif CJK SC （思源宋体——简体中文）
sudo dnf install -y \
google-noto-sans-cjk-fonts \
google-noto-serif-cjk-fonts \
adobe-source-han-sans-cn-fonts \
adobe-source-han-serif-cn-fonts \
jetbrains-mono-fonts
# 设置 GNOME 桌面的默认界面字体，影响范围：应用程序菜单、按钮、标签、对话框等 UI 元素的字体
gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK SC Regular 11'
# 设置文档类内容的默认字体，影响范围：文本编辑器、帮助文档、网页内容（某些应用中）等以“文档”形式展示的内容
gsettings set org.gnome.desktop.interface document-font-name 'Noto Serif CJK SC Regular 11'
# 设置等宽字体，影响范围：终端、代码编辑器
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono Regular 11'
# 设置窗口标题栏字体，影响范围：所有应用程序窗口顶部的标题文字
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Noto Sans CJK SC Bold 11'
# 微调：full（较好）或 slight
gsettings set org.gnome.desktop.interface font-hinting 'slight'
# 抗锯齿：rggb（LCD 显示器常用）或 grayscale
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'

# 安装 Ubuntu 的声音主题
sudo dnf install -y yaru-sound-theme
gsettings set org.gnome.desktop.sound theme-name 'Yaru'

# https://github.com/lassekongo83/adw-gtk3
# 将 GNOME 最新的默认视觉风格（Libadwaita）移植到旧的 GTK 3 应用程序上
# 让那些基于 GTK 3 的老程序也能拥有和新一代 GNOME 应用（如设置、文件、终端等）几乎一模一样的外观。
sudo dnf install -y adw-gtk3-theme
}

# ------------------------------------------------------------------------------
# 模块 3: 系统更新与基础清理
# ------------------------------------------------------------------------------
system_update_and_cleanup() {
echo "正在更新系统并清理无用包..."
# 你刚刚修改了软件源（从官方 metalink 切换到了中科大/阿里云等固定镜像）。如果不加 --refresh，DNF 可能会继续使用旧的、缓存的元数据（这些元数据可能指向旧的镜像地址或包含旧的包列表），
# 导致升级失败、包找不到或仍然从旧源下载。--refresh 强制 DNF 忽略本地缓存，重新从新配置的镜像下载最新的元数据。
# 只有在以下特殊情况下，你才需要在日常更新时加上 --refresh：
    # 1、修改了 .repo 文件：比如你刚才手动启用/禁用了某个仓库，或者像我们脚本里那样换了镜像源
    # 2、怀疑缓存损坏：当你运行 dnf upgrade 报错，提示“元数据不匹配”、“GPG 校验失败”或“找不到包”，但你知道网络上肯定有这个包时。此时执行 sudo dnf upgrade --refresh 可以修复缓存
    # 3、急需刚刚发布的软件/安全补丁：假设某个严重安全漏洞在 10 分钟前修复并推送到仓库了，而你昨天的缓存还没过期。为了立刻拿到这个补丁，你可以强制刷新。但通常等待几小时让缓存自然过期也是可接受的
    # 4、长时间未开机：如果你这台电脑关机了几个月没开，本地缓存肯定过期了。虽然 DNF 会自动检测到过期并刷新，但显式加上 --refresh 也没坏处，只是略显多余
# 但是对于日常的系统更新，推荐命令：sudo dnf upgrade -y 这会直接读取本地缓存的元数据（通常只有几 MB），瞬间完成分析，然后只下载需要更新的软件包
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y
echo "系统更新完成。"
}


# ------------------------------------------------------------------------------
# 模块 4: 开发环境与工具链安装
# ------------------------------------------------------------------------------
install_dev_tools() {
echo "正在安装基础开发工具链..."
# 基础工具组
# development-tools 		是一个预定义的软件包组，包含一组常用的开发工具和库，用于支持软件开发工作。例如：git
# c-development			是简化C开发环境配置的包组，安装后即可获得编译、调试和构建C程序所需的核心工具。如果你需要开发C程序，安装它或对应的包组是第一步。例如：gcc、gcc-c++
# rpm-development-tools		是专门用于 RPM 包开发 的工具集，适合软件打包、维护或发布 RPM 格式的软件。例如：rpm-build、rpmdevtools
# dnf group install		旨在为开发者提供一个基础的开发环境，而无需手动安装每个工具。
# dnf group list		查看可用的软件包组
# dnf group list --installed	查看已安装的软件包组
# 查看软件包组的信息
# dnf group info development-tools
# sudo dnf group remove -y development-tools
sudo dnf group install -y development-tools
# dnf group info c-development
# sudo dnf group remove -y c-development
sudo dnf group install -y --with-optional c-development
# dnf group info rpm-development-tools
# sudo dnf group remove -y rpm-development-tools
sudo dnf group install -y --with-optional rpm-development-tools
# 安装虚拟化基础
# https://docs.fedoraproject.org/zh_Hans/quick-docs/virtualization-getting-started/
# dnf group info virtualization
# sudo dnf group remove -y virtualization
sudo dnf group install -y --with-optional virtualization
# dnf group info container-management
# sudo dnf group remove -y container-management
sudo dnf group install -y --with-optional container-management
# dnf group info vlc
# sudo dnf group remove -y vlc
sudo dnf group install -y --with-optional vlc
# 安装多媒体编解码器 https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-plugins-for-playing-movies-and-music/
# multimedia 包组提供了一套完整的音视频处理工具链，适合普通用户或开发者处理多媒体任务。例如：gstreamer1-plugin-* 以包含 gstreamer1-plugin-openh264 等
# 作为 Fedora 用户和系统管理员，您可以使用这些步骤来安装额外的多媒体插件，使您能够播放各种视频和音频类型。 
# 对于 fedora 41 及更高版本，安装用于播放电影和音乐的插件
# dnf group info multimedia
sudo dnf group install -y --with-optional multimedia
# dnf group info sound-and-video
# sudo dnf group remove -y sound-and-video
sudo dnf group install -y sound-and-video
# dnf group info libreoffice
# sudo dnf group remove -y libreoffice
sudo dnf group remove -y libreoffice
# https://docs.fedoraproject.org/zh_Hans/quick-docs/openh264/
# dnf list mozilla-*
# dnf list --available \*openh264\*
# 从 fedora-cisco-openh264 存储库安	dnf list gstreamer1-plugin-*
sudo dnf install -y mozilla-openh264 mozilla-ublock-origin
# 之后，您需要打开 Firefox，转到菜单 → 附加组件 → 插件 并启用 OpenH264 插件。
# 您可以在此页面 https://mozilla.github.io/webrtc-landing/pc_test.html 上对您的 H.264 是否在 RTC 中工作进行简单测试（检查需要 H.264 视频
# 安装fedora的多媒体组，以下内容参考 https://rpmfusion.org/Howto/Multimedia
# 切换到完整的 ffmpeg，使用 swap 命令为替换操作
# FFmpeg-Free 是 Fedora 默认提供的一个受限版本，仅包含开源且无专利限制的编解码器。
# FFmpeg 是一个功能强大的多媒体处理工具集，支持视频、音频的编码、解码、转码、流媒体传输等功能。
# 它支持广泛的编解码器（如 H.264、HEVC、AAC 等），包括一些专利保护的编解码器。 
# Fedora ffmpeg-free 在大多数时候都能正常工作，但有时会遇到版本不匹配的情况。切换到 rpmfusion 提供的 ffmpeg 构建，它得到了更好的支持。您仍然需要按照下一节了解与您可能已安装的软件包相关的其他编解码器或插件。
# 列出 ffmpeg-free 运行所必须依赖的其他包	dnf repoquery --requires ffmpeg-free
sudo dnf swap -y --allowerasing ffmpeg-free ffmpeg
# 硬件加速编解码器
# 使用 AMD（mesa）的硬件编解码器
# 使用 rpmfusion-free 部分这是从 Fedora 37 及更高版本开始需要的...主要关注 AMD 硬件，因为带有 nouveau 的 NVIDIA 硬件运行不佳 
# Mesa 是一个开源的图形驱动框架，提供了对 OpenGL、Vulkan、VA-API 和 VDPAU 等图形 API 的支持。
# Fedora 默认的 Mesa 驱动遵循严格的开源许可证，因此不包含对某些专利保护的编解码器（如 H.264 和 HEVC）的支持。
# Fedora 默认安装的是开源的 mesa-va-drivers 和 mesa-vdpau-drivers，这些驱动完全符合开源社区的标准，但可能缺少对某些专有编解码器（如 H.264 或 HEVC）的支持。
# RPM Fusion 提供了名为 mesa-*-drivers-freeworld 的替代版本，它们是基于 Mesa 的增强版本，支持更多的专有编解码器（如 H.264 和 HEVC）和性能优化
sudo dnf swap -y --allowerasing mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y --allowerasing mesa-vulkan-drivers mesa-vulkan-drivers-freeworld
# sudo dnf swap -y --allowerasing mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf install -y mesa-vdpau-drivers-freeworld.x86_64
# 安装 VA-API 和 VDPAU 驱动，一般默认已安装
# 查看 Mesa 驱动程序 freeworld 和原始驱动程序
# dnf list mesa*
# 提供 vainfo 命令的包
sudo dnf install -y libva-utils vulkan-tools
# vainfo
# vainfo | grep -E 'H264|H265'
# vulkaninfo | grep "GPU"
# 常用命令行工具
sudo dnf install -y fastfetch wl-clipboard clapper just
# Tauri 在 Linux 上进行开发需要各种系统依赖项。这些可能会有所不同，具体取决于你的发行版，在 Fedora 系统中需安装以下依赖：
# https://tauri.app/zh-cn/start/prerequisites/#linux
sudo dnf check-update
sudo dnf install -y \
webkit2gtk4.1-devel \
openssl-devel curl wget file \
libappindicator-gtk3-devel \
librsvg2-devel libxdo-devel
# 为了让扩展程序能够最佳运行，您需要安装以下依赖项：
# https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous
# sudo dnf install -y libgda libgda-sqlite
echo "基础开发工具安装完成。"
}


configure_languages() {
echo "正在配置编程语言环境 (Node, Java, Go, Rust, Zig)..."
echo "配置 Java、Maven 环境..."
# https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-java/
# whereis maven
# whereis maven4
# nautilus admin:/usr/share/maven
# sudo dnf install -y java-25-openjdk maven maven4 maven4-openjdk25 kotlin
# 使用 Android Studio 需要提前安装 gradle 和  kotlin
# https://sdkman.io/    执行以下命令时，推荐开启 VPN 否则容易失败并且下载速度极慢
rm -rf $HOME/.sdkman
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
# sdkman 自我检查更新，刷新 sdkman 候选者元数据、更新所有已经安装的工具，例如：java、gradle、maven 等
sdk selfupdate && sdk update && sdk upgrade
# 通过 SDKMAN! 安装的工具（Java、Kotlin、Maven、Gradle 等）完全不需要手动配置环境变量。SDKMAN! 的核心设计就是自动接管并动态注入这些变量。可以直接 echo $JAVA_HOME
# 通过运行以下命令来安装您选择的最新稳定版本SDK（例如Java JDK）：
sdk install java
echo $JAVA_HOME
sdk install maven
echo $MAVEN_HOME
sdk install mvnd
echo $MVND_HOME
sdk install kotlin
echo $KOTLIN_HOME
sdk install gradle
echo $GRADLE_HOME
sdk current
# 在脚本中使用SDKMAN时，获取SDK所在的绝对路径通常很有用（类似于macOS上的java_home命令）。为此，我们有home命令。
# sdk home java 25.0.3-tem
# /home/lcqh/.sdkman/candidates/java/current
# sdk home kotlin 2.3.21
# /home/lcqh/.sdkman/candidates/kotlin/current
# sdk home maven 3.9.15
# /home/lcqh/.sdkman/candidates/maven/current
# sdk home mvnd 1.0.5
# /home/lcqh/.sdkman/candidates/mvnd/current
# sdk home gradle 9.5.1
# /home/lcqh/.sdkman/candidates/gradle/current
echo "你刚安装的 java 版本号为：$(java --version)"
echo "你刚安装的 maven 版本号为：$(mvn --version)"
echo "你刚安装的 mvnd 版本号为：$(mvnd --version)"
echo "你刚安装的 kotlin 版本号为：$(kotlin -version)"
echo "你刚安装的 gradle 版本号为：$(gradle --version)"
# 配置 maven 阿里云 aliyun 加速镜像	https://maven.aliyun.com/mvn/guide
# -v (verbose)：详细模式。
# 作用：每创建一个目录，都会在终端打印一条提示信息。让用户知道命令到底执行了什么
# -p (parents)：父目录模式。
# 作用 ：如果指定的路径中父目录不存在，会自动递归创建。如果目录已经存在，不会报错，而是静默成功
mkdir -vp $HOME/.m2
if [ ! -f $HOME/.m2/settings.xml ]; then
# IDEA 配置 “Maven 主路径” 为 /usr/share/maven 直接复制到输入框即可
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee $HOME/.m2/settings.xml
<?xml version="1.0" encoding="UTF-8" ?>
<settings
    xmlns="http://maven.apache.org/SETTINGS/1.2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd"
>
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


echo "配置 Node.js 生态..."
sudo dnf install -y nodejs
# npm config get registry
# 执行后，npm 会自动帮你把配置写入 ~/.npmrc 文件，没必要手动编辑 ~/.npmrc 文件。
# 但需要注意的是，该配置的 npm 加速镜像只对当前用户有效，对于使用 sudo 的 npm 无效，例如  sudo npm install -g bun
# 配置 npm 国内阿里云 aliyun 加速镜像源，地址为	https://developer.aliyun.com/mirror/NPM
npm config set registry https://registry.npmmirror.com/
# 将目录所有权改为当前用户，否则如下命令将因为权限问题执行失败
# 修复 /usr/local 权限以便全局安装
if [ -d "/usr/local" ]; then
    sudo chown -R $(whoami):$(whoami) /usr/local
fi
# 安装 Bun
# npm 列出所有全局安装的包
# npm list -g --depth=0
# 执行更新命令，更新所有可更新的全局包
# npm update -g
# 安装 Bun 运行时环境	https://www.bunjs.cn/docs/installation
# bun - 现代的 JavaScript 运行时和包管理器
# https://www.npmjs.com/package/bun
npm install -g bun typescript
# bun create vite --help
# -i, --immediate	自动安装依赖并启动  dev 开发环境
# bun create vite my-vue-app --template vue-ts --immediate
# bun 自行升级	bun upgrade
# bun run config --help
# bun --config
echo "Bun 已安装: $(bun --version)"
# 将 bunfig.toml 作为隐藏文件添加到用户主目录	https://www.bunjs.cn/docs/runtime/bunfig
cat << EOF | tee "$HOME"/.bunfig.toml
# 使用配置文件 bunfig.toml 配置 Bun 的行为 https://bun.zhcndoc.com/runtime/bunfig
[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，
# 地址为 https://developer.aliyun.com/mirror/NPM
registry = "https://registry.npmmirror.com/"
EOF
# which node
# whereis node
# whereis bun
# 将 IDEA 的 JS/TS 默认运行时环境从 nodejs 改为 bun 操作如下：
# 1、设置 -> 语言和框架 -> Bun -> /usr/local/bin/bun
# 2、设置 -> 语言和框架 -> Node.js -> Node解释器 -> /usr/local/bin/bun

echo "配置 Rust 环境..."
# https://developer.fedoraproject.org/tech/languages/rust/rust-installation.html
# https://linuxcapable.com/how-to-install-rust-programming-language-on-fedora-linux/
# 设置 Rustup 镜像，参考：https://developer.aliyun.com/mirror/rustup
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
# 使用 Android Studio 需要提前安装 gradle 和  kotlin
# 创建 ANDROID_HOME 和 NDK_HOME 环境变量目录
mkdir -vp "$HOME/.android/Sdk/ndk"
# https://tauri.app/zh-cn/start/prerequisites/#android
# https://linuxcapable.com/how-to-set-java-environment-path-in-fedora-linux/
# 配置全局 Gradle 设置：Settings -> Build,Execution,Deploy -> Build Tools -> Gradle 修改如下内容：
# 1、Gradle user home：/home/lcqh/.sdkman/candidates/gradle/current
# 2、勾选启用，Enable parallel Gradle model fetching for Gradle 7.4+
# 3、Distribution：从默认的 Wrapper 改为 Local installation
# 4、Version：改为安装的 JDK 对应版本，例如 25

# Tauri 开发 Android 应用需要配置如下内容，具体参考：https://tauri.app/zh-cn/start/prerequisites/#android
# 使用 rustup 添加 Android 编译目标：
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
# 打开 Android Studio 、创建一个应用、点击设置、点击 SDK Manager、选择 SDK Tools 然后勾选下面 5 个工具
# Android SDK Platform
# Android SDK Platform-Tools
# NDK (Side by side)
# Android SDK Build-Tools
# Android SDK Command-line Tools

# No target device found.	错误处理
# 1、点击 Android Studio 右侧工具栏中的手机图标。
# 2、选择 " + " 号
# 3、点击 "Create Virtual Device"。
# 4、选择设备类型（如 Pixel 3a XL），点击 "Next"。
# 5、下载并安装系统镜像。

bun create tauri-app --help
bun create tauri-app tauri-app \
--template vue-ts \
--manager bun \
--yes

1、模板已创建！要开始，请运行：
cd tauri-app
bun install
bun run tauri android init
2、对于桌面开发，运行：
bun run tauri dev
3、对于 Android 开发，运行：
bun run tauri android dev
# 项目目录 src-tauri/gen/android/gradle/wrapper/gradle-wrapper.properties 中的 gradle 下载版本为 8.14.3
# 运行报错根本原因：你本地使用的是 JDK 25，但 Tauri 中使用的  Gradle 8.14.3 最高只支持运行在 Java 24 及以下 版本，解决办法如下：
# 安装 JDK 21（如果尚未安装）
sdk install java 21.0.11-tem
# 临时切换当前终端
sdk use java 21.0.11-tem
# 设置为默认版本（推荐）
sdk default java 21.0.11-tem


# 3. Go
echo "配置 Go 环境..."
# Go 国内加速镜像	https://learnku.com/go/wikis/38122
# golang 中文学习文档	https://golang.halfiisland.com/
# golang 官方网站	https://golang.google.cn/
# golang 公共软件包仓库	https://pkg.go.dev/
sudo dnf install -y golang
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


# 6. podman、podman-compose
echo "安装配置 podman、podman-compose 环境..."
sudo dnf install -y podman podman-compose
# 启用用户级 socket
systemctl --user enable --now podman.socket
systemctl --user status podman.socket --no-pager
# https://github.com/containers/podman/blob/cea9340242f3f6cf41f20fb0b6239aa3db5decd6/docs/tutorials/socket_activation.md
# cat /usr/lib/systemd/user/podman.socket
# ls $XDG_RUNTIME_DIR/podman/podman.sock
# unix:///run/user/1000/podman/podman.sock
# podman info
# 配置国内加速镜像仓库
# 主要用于 登录到容器镜像仓库（Registry），以便拉取（pull）私有镜像或推送（push）镜像到仓库
# lcqh2635@gmail.com
# podman login
# cat /etc/containers/registries.conf
# 备份到同目录（添加 .bak 后缀）
if [ -f "/etc/containers/registries.conf.bak" ]; then
    echo "registries.conf.bak 备份文件存在，不再重复备份"
else
echo "registries.conf.bak 备份文件不存在，开始备份"
sudo cp /etc/containers/registries.conf{,.bak}
# 检查 .bak 文件是否存在
# ls -l /etc/containers
# 从同目录 .bak 文件恢复
# nautilus admin:/etc/containers
# sudo cp /etc/containers/registries.conf{.bak,}
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | sudo tee -a /etc/containers/registries.conf
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
location = "registry-1.docker.io"

# 镜像加速器地址（优先使用的镜像源）
# 添加该仓库的镜像加速器（Mirror）以阿里云镜像加速为示例
[[registry.mirror]]
# 镜像加速器地址（替换为你的阿里云镜像加速URL）
location = "docker.1ms.run"
# 是否允许不安全的 HTTP 连接（生产环境建议 false）
insecure = false
EOF
fi
# kubelet 需要 CRI 接口调用容器运行时，Fedora 默认 Podman 不直接兼容 kubelet，推荐安装 CRI-O：
# 1. 安装 CRI-O（与 Podman 同生态，兼容性好）
sudo dnf install -y cri-o
# 2. 启用并启动 CRI-O
sudo systemctl enable --now crio
# 3. 验证 CRI 是否就绪
crictl info | head -20

# 创建网络
# podman network create podman-net
# Pods 是一个 podman 的前端。它的用户界面使用 libadwaita 并力求符合 GNOME 的设计原则
# 打开 Pods 软件，点击 “新建连接” 然后选择使用默认的 “Unix Socket” 点击 Connect
# IDEA 连接 Podman：按 Ctrl+Alt+S 打开设置，然后选择 构建、执行、部署 | Docker。点击 "添加"按钮 以添加 Docker 配置。选择  Podman 然后直接点击确定
    
    
# 在 Fedora 上使用 Kubernetes 官方文档 https://docs.fedoraproject.org/zh_Hans/quick-docs/using-kubernetes/
# Fedora 40（及更新版本）安装 Kubernetes 建议 https://docs.fedoraproject.org/zh_Hans/quick-docs/using-kubernetes-non-versioned/#sect-fedora-40-recommendations
# Kubelet 是节点上的 Kubernetes 运行时。对应 kubernetes 包
# Kubeadm 初始化集群并将新节点加入集群。这个rpm是可选的，但由Kubernetes团队推荐。如果使用，请在每个节点上安装。
# kubectl 命令行客户端。建议在任何配置为控制平面的节点上使用，因为它允许集群管理员从控制平面的SSH会话中对集群进行控制。在可以通过网络连接到集群的机器上安装。
# kubernetes-systemd 用于 Kubernetes 控制平面和/或节点的 Systemd 服务。对于大多数安装，不需要这些服务，因为 kubeadm 会将这些组件作为静态 Pod 安装。如果使用，则需要在所有节点上安装。
# 使用 systemctl 在所有节点上启用 kube-proxy。在控制平面节点上启用 kube-apiserver、kube-controller-manager 和 kube-scheduler。
sudo dnf install -y kubernetes kubernetes-kubeadm kubernetes-client
sudo systemctl enable --now kubelet
# sudo systemctl stop  kubelet
# 查看 kubelet 服务状态
systemctl status kubelet --no-pager
# kubelet 每个节点都在运行的服务，管理本节点上的所有 Pod 和容器
echo "🐍 你安装的 kubernetes 版本号为：$(kubelet --version)"
# Kubeadm 初始化集群并将新节点加入集群
echo "🐍 你安装的 kubernetes-kubeadm 版本号为：$(kubeadm version)"
# kubectl 是 Kubernetes 命令行客户端，由 kubernetes-client 包提供
echo "🐍 你安装的 k8s 命令行工具 kubectl 版本号为：$(kubectl version --client)"
# IDEA 添加 Kubernetes 集群，参考 jetbrains 官方文档 https://www.jetbrains.com/zh-cn/help/idea/kubernetes.html
# 在 设置 对话框（Ctrl + Alt + S ）中，选择 构建、执行、部署 | Kubernetes。测试好 kubectl（K8s 的命令行工具 CLI） 和 Helm（K8s 的“包管理器”） 
# 有关群集的信息存储在 kubeconfig 文件中。 IntelliJ IDEA 会检测默认的 kubeconfig 文件，这个文件通常位于 $HOME/.kube/config （此位置可以通过 KUBECONFIG 环境变量更改）。
# https://docs.fedoraproject.org/zh_Hans/quick-docs/using-kubernetes-kubeadm/
# 使用 kubeadm 初始化 Kubernetes 集群
echo "编程语言环境配置完成。"
}


# 所有系统级别（对所有用户有效）的主题都存放在以下根目录中：
# nautilus admin:/usr/share/themes
# nautilus admin:/usr/share/icons
# sudo rm -rf /usr/share/icons/WhiteSur*
# ------------------------------------------------------------------------------
# 模块 6: 主题与美化 (WhiteSur)
# ------------------------------------------------------------------------------
install_theme_whitesur() {
    # https://github.com/topics/macos-tahoe
    # https://github.com/kayozxo/GNOME-macOS-Tahoe
    # https://github.com/taj-ny/kwin-effects-forceblur
    
    # 帮助新手和专家一起轻松自动化构建终极 macOS 虚拟机，由 KVM 驱动。现在支持 macOS Tahoe
    # https://github.com/Coopydood/ultimate-macOS-KVM
    
    
    # MacTahoe-icon-theme 内包含 MacTahoe cursors theme，执行命令时，两种主题会一并安装
    # https://www.opendesktop.org/p/2299216/
    # https://github.com/vinceliuice/MacTahoe-icon-theme
    # https://github.com/vinceliuice/MacTahoe-icon-theme/tree/main/cursors
    git clone --depth=1 https://github.com/vinceliuice/MacTahoe-icon-theme.git && cd MacTahoe-icon-theme
    sudo ./install.sh -d /usr/share/icons -t default -b
    # sudo ./install.sh -r
    # nautilus admin:/usr/share/icons
    # sudo rm -rf /usr/share/icons/MacTahoe*
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git && cd WhiteSur-gtk-theme
    ./install.sh -l -o solid
    ./tweaks.sh -f flat
    ./tweaks.sh -F -o solid
    gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
    
    # MacTahoe-gtk-theme 内包含 MacTahoe wallpapers，但需要手动额外安装
    # https://www.gnome-look.org/p/2299211
    # https://github.com/vinceliuice/MacTahoe-gtk-theme
    # git clone --depth=1 https://github.com/vinceliuice/MacTahoe-gtk-theme.git
    # 使用 ACL 访问控制列表
    sudo dnf install acl
    # 赋予当前用户对系统指定目录的读写权限：
    sudo setfacl -R -m u:$USER:rw /usr/share/themes
    # nautilus ~/.config/gtk-4.0
    # nautilus admin:/usr/share/themes
    # sudo rm -rf /usr/share/themes/MacTahoe*
    ./install.sh -o solid -t all -b -l
    ./install.sh -t all -l --shell -i fedora -h smaller --round
    sudo cp -r ~/.themes/MacTahoe* /usr/share/themes/
    rm -rf ~/.themes
    # ./tweaks.sh -f monterey
    # sudo ./tweaks.sh -g -i fedora -b default
    sudo flatpak override --filesystem=xdg-config/gtk-3.0
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    ./tweaks.sh -F
    # MacTahoe-Dark-solid-blue
    gsettings set org.gnome.shell.extensions.user-theme name 'MacTahoe-Dark-solid-blue'
    gsettings set org.gnome.desktop.interface gtk-theme 'MacTahoe-Dark-solid-blue'
    gsettings set org.gnome.desktop.wm.preferences theme 'MacTahoe-Dark-solid-blue'
    # nautilus ~/.local/share/gnome-background-properties
    # mkdir -vp ~/.local/share/gnome-background-properties
    # ./wallpaper/install-gnome-backgrounds.sh
    
    # 弹出确认对话框：会弹出一个图形化的确认框，询问你是否真的要登出。
    # gnome-session-quit --logout


    # https://github.com/EliverLara/Space
    # https://www.gnome-look.org/p/2131750
    # gsettings set org.gnome.desktop.interface gtk-theme "Space"
    # gsettings set org.gnome.desktop.wm.preferences theme "Space"

    THEME_DIR="$HOME/下载/WhiteSur-themes"
    if [ ! -d "$THEME_DIR" ]; then
        echo "正在下载并安装 WhiteSur 主题..."
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        mkdir -vp "$THEME_DIR"
        cd "$THEME_DIR"
        # 克隆主题仓库 (使用浅克隆加速)
        REPOS=(
            "${GITHUB_PROXY_URL}https://github.com/vinceliuice/WhiteSur-cursors.git"
            "${GITHUB_PROXY_URL}https://github.com/vinceliuice/WhiteSur-icon-theme.git"
            "${GITHUB_PROXY_URL}https://github.com/vinceliuice/WhiteSur-gtk-theme.git"
        )
        for repo in "${REPOS[@]}"; do
            name=$(basename "$repo" .git)
            if [ ! -d "$name" ]; then
                git clone --depth=1 "$repo"
            fi
        done
        git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git && cd WhiteSur-gtk-theme
        # 安装光标
        cd WhiteSur-cursors && sudo ./install.sh && cd ..
        gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
        # 安装图标
        # cd WhiteSur-icon-theme && ./install.sh && cd ..
        # cd WhiteSur-icon-theme && sudo ./install.sh -d /usr/share/icons -t all && cd ..
        cd WhiteSur-icon-theme && sudo ./install.sh -d /usr/share/icons -t all && cd ..
        # -d --dest 指定主题目的地目录（默认：$HOME/.local/share/icons）
        # -t --theme 指定主题颜色变体 [默认/紫色/粉色/红色/橙色/黄色/绿色/灰色/all]（默认：蓝色 blue）
        # -b --bold 安装加粗面板图标版本
        # sudo ./install.sh -d /usr/share/icons -t all -b
        # sudo ./install.sh -r
        gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
        # 修改 Nautilus 侧边栏不透明度，参考 https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1127
        # grep '$opacity: ' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
        # sed -i 's/\$opacity: 0\.96/\$opacity: 1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
        sed -i 's/0\.96/1/g' WhiteSur-gtk-theme/src/sass/_colors.scss
        # 安装 GTK 主题
        cd WhiteSur-gtk-theme
        ./install.sh -l -o solid
        # nautilus ~/.config/gtk-4.0
        # 
        # Fix for libadwaita (not perfect)
        # https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/913
        # 白天：	ln -fs $HOME/.config/gtk-4.0/gtk-Light.css $HOME/.config/gtk-4.0/gtk.css
	# 晚上:		ln -fs $HOME/.config/gtk-4.0/gtk-Dark.css $HOME/.config/gtk-4.0/gtk.css
        # Do not run '-l --libadwaita' option with sudo!
        # ./install.sh -l -c dark        # Default is the dark theme for libadwaita
        # ./install.sh -l -c light       # install light theme for libadwaita
        # 将 /usr/share/themes 及其子文件的所有权都交给了你的用户账户
        # nautilus admin:/usr/share/themes
        ./install.sh -l -c dark -o solid && sudo ./install.sh -d /usr/share/themes -o solid -t all && cd ..
        # ./install.sh -l -c light && sudo ./install.sh -d /usr/share/themes -o solid -t all && cd ..
        
        gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
        gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
        gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
        # 简单处理 Firefox 进程，避免安装脚本报错
        if pgrep -x "firefox" > /dev/null; then
            echo "Firefox 正在运行，尝试关闭以应用主题..."
            pkill firefox
            sleep 2
        fi
        ./tweaks.sh -f flat
        ./tweaks.sh -F -o solid
        # 应用自定义背景
        sudo ./tweaks.sh -g -b "$HOME/.local/share/backgrounds/wallpaper-noon.jpg"
        rm -rf "$THEME_DIR"
        echo "WhiteSur 主题安装完成。请在 GNOME Tweaks 中手动选择主题。"
    else
        echo "WhiteSur 主题已经安装，无需再次安装。"
    fi
}

# 卸载主题
uninstall_theme() {
    cd ~/下载/WhiteSur-themes/WhiteSur-cursors && ./install.sh -r
    cd ~/下载/WhiteSur-themes/WhiteSur-icon-theme && ./install.sh -r
    cd ~/下载/WhiteSur-themes/WhiteSur-gtk-theme && ./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r
}


# ------------------------------------------------------------------------------
# 模块 7: JetBrains 工具箱 (官方安装)
# ------------------------------------------------------------------------------
install_jetbrains_toolbox() {
    cd "$HOME/下载"
    
    # 方法：尝试列出匹配的文件，如果有任何输出，说明存在
    if compgen -G "$HOME/.apps/jetbrains-toolbox-*" > /dev/null; then
        echo "✅ 已找到 JetBrains Toolbox 目录，跳过安装。"
    else
        echo "正在安装 JetBrains Toolbox..."
	# 获取最新正式版链接 (排除 arm64)
	DOWNLOAD_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | \
		grep -o 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^\"]*\.tar\.gz' | \
		grep -v 'arm64' | head -1)
	if [ -z "$DOWNLOAD_URL" ]; then
	    echo "无法获取 JetBrains Toolbox 下载链接。"
	    return 1
	fi
        wget -O jetbrains-toolbox.tar.gz "$DOWNLOAD_URL"
        mkdir -vp "$HOME/.apps"
        # jetbrains-toolbox 官方安装教程  https://www.jetbrains.com/help/toolbox-app/installation.html#manual_installation
        tar -xzf jetbrains-toolbox.tar.gz -C "$HOME/.apps"
	# 找到解压后的目录并运行
	TOOLBOX_DIR=$(find "$HOME/.apps" -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -1)
	if [ -n "$TOOLBOX_DIR" ]; then
	    chmod +x "$TOOLBOX_DIR/bin/jetbrains-toolbox"
	    echo "启动 JetBrains Toolbox..."
	    # 在后台运行
	    "$TOOLBOX_DIR/bin/jetbrains-toolbox" &
	    echo "JetBrains Toolbox 已启动。请按照界面提示完成后续配置。"
	    echo "注意：本脚本不包含自动激活破解补丁，请使用正版授权或学生认证。"
	else
	    echo "解压 JetBrains Toolbox 失败。"
	fi
        rm -rf jetbrains-toolbox*
        
        # https://3.jetbra.in/
        # https://github.com/jonssonyan/3.jetbra.in
        # https://account.jetbrains.com/licenses
        if compgen -G "$HOME/下载/jetbra-*" > /dev/null; then
            echo "✅ 已找到 jetbra 目录，跳过下载和安装。"
        else
            echo "正在安装 jetbra 工具x..."
            wget https://3.jetbra.in/files/jetbra-5a50fc03d68a014f893b7fc3aa465380d59f9095.zip
            unzip jetbra-*.zip && mv jetbra ~/.jetbra
            # nautilus ~/.jetbra
            rm -rf jetbra*
            # cat ~/.jetbra/vmoptions/idea.vmoptions
        fi
        echo "JetBrains Toolbox 已经安装"
    fi
    	    # https://plugins.jetbrains.com/
    	    # https://www.jetbrains.com/zh-cn/help/idea/tuning-the-ide.html
	    # https://www.jetbrains.com/zh-cn/help/idea/2026.1/getting-started.html?keymap=GNOME
	    # 生效机制：IntelliJ IDEA 启动时，会优先读取用户配置目录（~/.config/JetBrains/IntelliJIdea2026.1/）下的 idea64.vmoptions 文件。
	    # 如果这个文件存在，IDEA 就会忽略安装目录 （~/.local/share/JetBrains/Toolbox/apps/intellij-idea/）下的那个文件。
	    
	    # 全局默认配置，优先级低。仅当用户目录没有该文件时生效。
	    # 持久性：不稳定。使用 Toolbox 更新或重装 IDEA 时，该文件可能会被重置或覆盖。
	    # 作用：定义 IDEA 出厂时的默认内存、GC 策略等参数。作为用户自定义配置的参考
	    # ~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea64.vmoptions
	    # nautilus ~/.local/share/JetBrains/Toolbox/apps
	    
	    # 用户自定义配置，优先级高。启动时会覆盖安装目录的配置。
	    # 持久性：持久。独立于软件安装，更新 IDEA 版本后配置通常会保留或迁移。
	    # 作用：存放你修改后的个性化参数。
	    # ~/.config/JetBrains/IntelliJIdea2026.1/idea64.vmoptions
	    # nautilus ~/.local/share/JetBrains/Toolbox/apps
	    
	    # 自动配置  jetbrains 代码编辑器 vmoptions
	    
	    # IDEA 默认的虚拟机配置参数
	    # cat ~/.local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea64.vmoptions
	    # 用户自定义的 IDEA 虚拟机配置参数，可以扩展和覆盖 IDEA 默认的配置
	    # cat ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions
	    # https://3.jetbra.in/
	    # -javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains

}

# VPN 相关软件和订阅来源
# https://gitclone.com/
# https://gh-proxy.com/
install_vpn() {
    # 进入到下载目录
    cd ~/下载
    # Github 加速工具
    # https://github.com/docmirror/dev-sidecar
    # https://github.com/docmirror/dev-sidecar/releases
    
    # https://v2rayn.co/
    # https://github.com/2dust/v2rayN/releases
    # 使用教程	https://v2rayn.co/v2rayn-tutorial/
    
    
    # 从下面这两个节点网站一次性复制多条 v2rayN 节点，然后打开 v2rayN 点击配置项，然后点击 “从剪切板导入分享链接” 这会一次性批量导入节点
    # 然后鼠标右键，点击 “一键生成策略组 -> 全部配置项”，然后点击刚生成的 “策略组” 鼠标右键，点击 “编辑”， 
    # 然后可以选择 “策略组类型”，例如：最低延迟、故障转移、负载均衡，等等策略
    # https://v2raynode.github.io/
    # https://www.freeclashnode.com/
    # v2rayN 使用体验优化配置：点击 v2rayN “设置 -> 参数设置 -> v2rayN 设置” 打开 “启用流量统计“、”显示实时速度“ 这两个开关
    
    # 1、点击顶部菜单栏的 “订阅分组”，选择 “订阅分组设置”，在弹出的窗口中点击 "添加"，
    # 2、添加订阅节点完成后回到主界面，点击 “订阅分组” -> “更新全部订阅 (不通过代理)” 操作完成后，你应该能看到列表中出现了一排节点
    # 3、开启代理与模式选择。这是最关键的一步，决定了电脑是否已经处于代理加速状态
    	# 3.1、选择节点。 在节点列表中，点击上方的 “网络测速图标” 进行 “一键多线程测试延迟和速度”，选择网速最好的节点并将其设为活动，当节点的别名变色或显示“活动”状态时，表示已选中
    	# 3.2、设置系统代理。在软件界面的最底部图标栏，找到以下三项关键设置：
    		# 系统代理：将其设置为 自动配置系统代理。此时底部图标会变为红色
    		# 路由：将其设置为 绕过大陆。这可以确保访问百度、淘宝等国内网站时不走代理，访问 YouTube、Google 时才加速
    # 4、测试网络。打开浏览器，尝试访问 Google。如果能正常打开，恭喜，配置已成功
    # 5、v2rayN 高级设置说明：
    # TUN 模式，在软件底部可以找到 TUN 模式开关
    	# 作用：接管整机流量。对于一些不遵循系统代理的浏览器插件、游戏或特定软件非常有用
    	# 建议：普通网页浏览不需要开启，仅在某些软件无法正常代理时开启
    # 核心选择：v2rayN 支持切换 Xray-core、sing-box 等核心。目前大部分订阅链接都支持 Xray，保持默认即可
    if rpm -q "v2rayN" > /dev/null 2>&1; then
        echo "✅ v2rayN 已安装"
        # 这里可以执行后续操作
    else
        echo "❌ v2rayN 未安装，开始下载并安装 v2rayN"
        wget "$(curl -s https://api.github.com/repos/2dust/v2rayN/releases/latest | \
          grep -o 'https://github.com/2dust/v2rayN/releases/download/[^"]*v2rayN-linux-rhel-64\.rpm' | \
          head -n 1 | \
          sed "s|https://github.com|${GITHUB_PROXY_URL}https://github.com|")"
        sudo dnf install -y ./v2rayN-linux-rhel-64.rpm
    fi

# 为 Linux 上的 Flathub 提供支持的 Flatpak 应用商店
flatpak install -y flathub io.github.kolunmi.Bazaar
# Flatseal 是一种图形工具，用于审查和修改 Flatpak 应用程序中的权限
flatpak install -y flathub com.github.tchx84.Flatseal
# Warehouse 提供了一个简单的用户界面来控制复杂的 Flatpak 选项，而且完全无需借助命令行
flatpak install -y flathub io.github.flattool.Warehouse
# 更改 GDM 设置； 应用主题和背景、更改光标主题、图标主题和夜灯设置等
flatpak install -y flathub io.github.realmazharhussain.GdmSettings
# Microsoft Edge 网络浏览器
flatpak install -y flathub com.microsoft.Edge
# Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
flatpak install -y flathub com.google.Chrome
# 轻松地将磁盘镜像写入你的硬盘。选择一张图片，插入你的硬盘，就可以开始了
flatpak install -y flathub io.gitlab.adhami3310.Impression
# 一个易用的BitTorrent客户端。片段可以通过BitTorrent点对点文件共享协议传输文件，例如视频、音乐或Linux发行版的安装映像
flatpak install -y flathub de.haeckerfelix.Fragments
# 用干净、无干扰的标记删除编辑器专注于你的写作
flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe
# 忘记忘记事情
flatpak install -y flathub io.github.alainm23.planify
# 一款极简的Markdown阅读与写作应用
flatpak install -y flathub io.typora.Typora
# 你可以从拥有简洁友好的用户界面的在线来源获取字体。Sitra为安装、卸载和预览字体提供了无缝体验
flatpak install -y flathub io.github.sitraorg.sitra
# Refine 帮助发现 GNOME 中的高级和实验性功能
flatpak install -y flathub page.tesk.Refine
# Rewaita通过用流行的配色方案为您的Adwaita应用增添新意
flatpak install -y flathub io.github.swordpuffin.rewaita
# 一款用 GTK4 编写的轻量级音乐播放器，专注于大型音乐收藏
flatpak install -y flathub com.github.neithern.g4music
# 开启桌面歌词功能需要的依赖 https://github.com/osdlyrics/osdlyrics
# netease-cloud-music-gtk 是使用 Rust + GTK 开发的网易云音乐客户端，专为 Linux 系统打造
flatpak install -y flathub com.github.gmg137.netease-cloud-music-gtk
# 一个轻松管理 AppImages 的工具！齿轮杆可以帮你整理和管理 AppImage 文件，生成桌面条目和应用元数据，原地更新应用，或将多个版本并排保存
flatpak install -y flathub it.mijorus.gearlever
# Playhouse 让原型制作、教学、设计、学习和构建网页内容变得简单
flatpak install -y flathub re.sonny.Playhouse
# Workbench 是用来学习和用 GNOME 技术做原型设计的，无论是第一次动手还是构建和测试 GTK 用户界面
flatpak install -y flathub re.sonny.Workbench
flatpak install -y flathub com.github.marhkb.Pods
# flatpak install -y flathub dev.skynomads.Seabird
# Thunderbird 是一款免费且开源的电子邮件、新闻源、聊天和日历客户端
flatpak install -y flathub org.mozilla.Thunderbird
flatpak install -y flathub dev.zed.Zed
flatpak install -y flathub io.neovim.nvim

# 设置 Dock 栏应用图标
gsettings set org.gnome.shell favorite-apps "['org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop',
'org.gnome.Software.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Ptyxis.desktop',
'org.gnome.Settings.desktop', 'org.gnome.SystemMonitor.desktop', 'com.microsoft.Edge.desktop', 'org.gnome.tweaks.desktop']"

echo "Flatpak 应用安装完成。"
}

# ------------------------------------------------------------------------------
# 主执行流程
# ------------------------------------------------------------------------------
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Fedora 初始化配置脚本 v2.0${NC}"
    echo -e "${BLUE}  作者：龙茶清欢 (优化版)${NC}"
    echo -e "${BLUE}========================================${NC}"

    if ! confirm_action "即将开始系统配置，过程中可能需要输入 sudo 密码。是否继续？"; then
        exit 0
    fi
    
    # 1. 基础 GNOME 设置
    configure_basics_gsettings
    # 2. 软件源与 DNF
    configure_repos_and_dnf
    check_repo
    # 3. 系统更新
    # system_update_and_cleanup
    # 4. 开发工具
    install_dev_tools
    configure_languages
    configure_git
    # 5. Flatpak 应用
    configure_flatpak_and_install_app
    # 7. JetBrains Toolbox
    if confirm_action "是否安装 JetBrains Toolbox？"; then
        install_jetbrains_toolbox
    else
        echo "跳过 JetBrains Toolbox 安装。"
    fi
    # 6. 安装 Gnome Shell 扩展
    install_gnome_extensions
    # 7. 主题美化 (可选)
    if confirm_action "是否安装 WhiteSur 主题并进行美化？"; then
        install_theme_whitesur
    else
        echo "跳过主题安装。"
    fi
    # 8. 最终清理
    echo "执行最终清理..."
    sudo dnf autoremove -y
    sudo dnf clean all

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  配置全部完成！${NC}"
    echo -e "${GREEN}  建议重启系统以应用所有更改。${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    read -p "是否立即退出当前用户登录？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 想要彻底退出当前用户的所有程序并返回到登录屏幕（GDM）
        # 立即登出（不确认）：这会关闭所有打开的应用程序并返回到登录界面
        # gnome-session-quit --logout --no-prompt
        # 弹出确认对话框：会弹出一个图形化的确认框，询问你是否真的要登出。
        gnome-session-quit --logout
    fi
}

# 执行主函数
main "$@"

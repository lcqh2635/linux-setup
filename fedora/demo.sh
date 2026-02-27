#!/bin/bash

# 基础窗口优化
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.interface show-battery-percentage true
# 为了确保系统能够以最快的速度完成更新和软件安装，通常建议先配置加速镜像，再进行系统更新。

# 清华 Fedora 镜像源 https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
# 配置dnf以加快软件下载速度（启用最快的镜像）
echo "使用清华源配置Fedora的加速镜像..."
sudo sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora|g' \
    -i.bak \
    /etc/yum.repos.d/fedora.repo \
    /etc/yum.repos.d/fedora-updates.repo
# 最后运行 sudo dnf makecache 生成缓存
sudo dnf makecache
    
# 清华 RPMFusion 镜像源 https://mirrors.tuna.tsinghua.edu.cn/help/rpmfusion/
# 1、首先安装提供基础配置文件和 GPG 密钥的 rpmfusion-*.rpm。
sudo yum install --nogpgcheck https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# 2、安装成功后，修改链接指向镜像站   
sudo sed -e 's!^metalink=!#metalink=!g' \
         -e 's!^mirrorlist=!#mirrorlist=!g' \
         -e 's!^#baseurl=!baseurl=!g' \
         -e 's!https\?://download1\.rpmfusion\.org/!https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/!g' \
         -i.bak /etc/yum.repos.d/rpmfusion*.repo
    
# Fedora默认安装了Flatpak，只要配置Flatpak加速镜像即可
echo "开始配置Flatpak加速镜像..."
# 添加 Flathub 官方仓库
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# 修改 Flathub 仓库地址为国内镜像
# 1、上海交大 Flatpak 镜像源 https://mirrors.sjtug.sjtu.edu.cn/docs/flathub
# sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
# 2、中科大 Flatpak 镜像源（处于测试阶段） https://mirrors.ustc.edu.cn/help/flathub.html
sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub

# 更新系统并升级所有已安装的包
echo "开始系统..."
sudo dnf update -y && sudo dnf upgrade -y

# 安装常用软件
echo "安装系统基础软件..."
sudo dnf install -y \
git wl-clipboard \
fastfetch timeshift \
google-chrome-stable \
libreoffice-langpack-zh-Hans
# 配置Git（需要根据你的实际情况修改用户名和邮箱）
echo "配置 Git..."
# 安装基础依赖包 https://v2.tauri.app/zh-cn/start/prerequisites/#linux
sudo dnf install -y git wl-clipboard
git config --global user.name "龙茶清欢"
git config --global user.email "2320391937@qq.com"
ssh-keygen -t rsa -b 4096 -C "2320391937@qq.com"
# 需要安装 wl-clipboard 工具
cat ~/.ssh/id_rsa.pub | wl-copy
# https://gitee.com/profile/sshkeys
# https://github.com/settings/keys

# 安装 Firefox 相关组件
sudo dnf install -y \
mozilla-ublock-origin \
mozilla-openh264 \
gstreamer1-plugin-openh264

# 安装fedora的多媒体组，以下内容参考 https://rpmfusion.org/Howto/Multimedia
sudo dnf group install multimedia
# 安装必要的多媒体编解码器以支持高效的视频解码	about:support
sudo dnf install ffmpeg gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-libav -y
# FFmpeg-Free 是 Fedora 默认提供的一个受限版本，仅包含开源且无专利限制的编解码器。
# FFmpeg 是一个功能强大的多媒体处理工具集，支持视频、音频的编码、解码、转码、流媒体传输等功能。
# 它支持广泛的编解码器（如 H.264、HEVC、AAC 等），包括一些专利保护的编解码器。 
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
# 安装 VA-API 和 VDPAU 驱动，一般默认已安装
dnf list mesa*		# 查看 Mesa 驱动程序 freeworld 和原始驱动程序
sudo dnf install mesa-va-drivers mesa-vdpau-drivers libva-utils -y
# swap 命令为替换操作
# Mesa 是一个开源的图形驱动框架，提供了对 OpenGL、Vulkan、VA-API 和 VDPAU 等图形 API 的支持。
# Fedora 默认的 Mesa 驱动遵循严格的开源许可证，因此不包含对某些专利保护的编解码器（如 H.264 和 HEVC）的支持。
# Fedora 默认安装的是开源的 mesa-va-drivers 和 mesa-vdpau-drivers，这些驱动完全符合开源社区的标准，但可能缺少对某些专有编解码器（如 H.264 或 HEVC）的支持。
# RPM Fusion 提供了名为 mesa-*-drivers-freeworld 的替代版本，它们是基于 Mesa 的增强版本，支持更多的专有编解码器（如 H.264 和 HEVC）和性能优化
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf install libva-utils -y		# 提供 vainfo 命令的包
vainfo

# 图形界面工具: gnome-tweaks, gnome-extensions-app
sudo dnf install -y gnome-tweaks gnome-extensions-app
# 安装 Gnome 扩展管理
flatpak install -y flathub com.mattjakeman.ExtensionManager

# 安装配置系统字体
sudo dnf install -y \
adobe-source-han-sans-cn-fonts \
adobe-source-han-serif-cn-fonts \
jetbrains-mono-fonts
# 设置系统字体
gsettings set org.gnome.desktop.interface font-name '思源黑体 CN Medium 12'
gsettings set org.gnome.desktop.interface document-font-name '思源宋体 CN Medium 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono Medium 12'
gsettings set org.gnome.desktop.wm.preferences titlebar-font '思源黑体 CN Bold 12'
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
gsettings set org.gnome.desktop.interface font-hinting 'slight'

# 卸载自带的无用扩展插件
sudo dnf remove -y \
gnome-shell-extension-window-list \
gnome-shell-extension-launch-new-instance
# 系统必装 Gnome 扩展
sudo dnf install -y \
gnome-shell-extension-user-theme \
gnome-shell-extension-dash-to-dock \
gnome-shell-extension-blur-my-shell \
gnome-shell-extension-just-perfection \
gnome-shell-extension-drive-menu \
gnome-shell-extension-appindicator \
gnome-shell-extension-forge \
gnome-shell-extension-caffeine \
gnome-shell-extension-workspace-indicator \
gnome-shell-extension-auto-move-windows \
gnome-shell-extension-places-menu \
gnome-shell-extension-apps-menu

# 系统外观主题和Gnome扩展插件优化
# 在 Github 发现一个好项目 adw-gtk3	https://github.com/lassekongo83/adw-gtk3
sudo dnf install -y adw-gtk3-theme la-capitaine-cursor-theme
# 系统外观优化
gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
# dash-to-dock 扩展优化
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DASHES'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true
# blur-my-shell 扩展优化
gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility true
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1
gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.applications dynamic-opacity false
gsettings set org.gnome.shell.extensions.blur-my-shell.applications whitelist ['org.gnome.Settings', 'org.gnome.Software', 'org.gnome.TextEditor', 'org.gnome.SystemMonitor', 'org.gnome.tweaks', 'org.gnome.Extensions', 'org.gnome.Shell.Extensions', 'com.mattjakeman.ExtensionManager', 'org.gnome.Builder', 'org.gnome.Loupe', 'org.gnome.gitlab.somas.Apostrophe', 'io.github.alainm23.planify', 'com.github.tchx84.Flatseal', 'io.github.flattool.Warehouse']
gsettings set org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab blur false
# just-perfection 扩展优化
gsettings set org.gnome.shell.extensions.just-perfection accessibility-menu false
gsettings set org.gnome.shell.extensions.just-perfection world-clock false
gsettings set org.gnome.shell.extensions.just-perfection weather false
gsettings set org.gnome.shell.extensions.just-perfection events-button false
gsettings set org.gnome.shell.extensions.just-perfection window-demands-attention-focus true
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0


# 自定义快捷键优化，Super-管理窗口、Alt-管理工作区
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "['<Alt>End']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Alt>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Alt>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Alt>3']"
# 当前工作区内的窗口切换
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>T']"
# 窗口在工作区移动
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-last "['<Alt><Super>End']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Alt><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Alt><Super>Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Alt><Super>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Alt><Super>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Alt><Super>3']"
# 隐藏/显示当前工作区的所有窗口
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Alt><Super>h']"
# 键盘 F 功能键
# gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys
# 媒体声音控制
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['F2']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down "['F3']"
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up "['F4']"
# 弹出 U 盘
gsettings set org.gnome.settings-daemon.plugins.media-keys eject "['F5']"
# 播放器控制
gsettings set org.gnome.settings-daemon.plugins.media-keys next "['F8']"
gsettings set org.gnome.settings-daemon.plugins.media-keys play "['F9']"
gsettings set org.gnome.settings-daemon.plugins.media-keys previous "['F10']"

# 安装一些常用的Flatpak应用（如VSCode, LibreOffice）
echo "安装基础Flatpak应用程序..."
flatpak install -y flathub \
org.gnome.Evolution \
com.github.tchx84.Flatseal \
io.github.flattool.Warehouse \
io.github.realmazharhussain.GdmSettings \
io.github.vikdevelop.SaveDesktop \
io.github.seadve.Kooha \
org.gnome.seahorse.Application \
org.gnome.Firmware \
org.gnome.Gtranslator \
com.github.neithern.g4music \
de.haeckerfelix.Fragments \
org.gnome.gitlab.somas.Apostrophe \
com.github.gmg137.netease-cloud-music-gtk \
md.obsidian.Obsidian \
io.github.alainm23.planify

# 启用并启动防火墙服务
echo "启用和启动防火墙..."
# 在 Fedora 中，默认的防火墙 firewalld 已安装，但还需要自行安装图形化的防火墙管理工具
sudo dnf install firewall-config -y
sudo systemctl enable --now firewalld
# 配置防火墙规则（例如允许HTTP和HTTPS）
echo "配置防火墙规则..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# 安装电源管理 TLP 优化续航（笔记本用户）
sudo dnf install -y tlp tlp-rdw
sudo systemctl enable --now tlp
systemctl status tlp
# 查看电池信息
man tlp

# Development Tools  是一个预定义的软件包组，包含一组常用的开发工具和库，用于支持软件开发工作。
# 它旨在为开发者提供一个基础的开发环境，而无需手动安装每个工具。
sudo dnf group list		# 查看可用的软件包组
sudo dnf install @development-tools -y
# sudo dnf install @c-development -y
sudo dnf group info "Development Tools"
sudo dnf group info "C Development Tools and Libraries"

# 安装 nodejs 前端运行时环境
sudo dnf install -y nodejs
node --version
# 最新地址 淘宝 NPM 镜像站喊你切换新域名啦!
npm config set registry https://registry.npmmirror.com
npm config get registry
# 安装 bun 前端运行时环境
sudo npm install -g bun
bun --version
echo 你刚安装的 bun 版本号为： $(bun --version)
# 将 bunfig.toml 作为隐藏文件添加到用户主目录
echo '[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，地址为 https://developer.aliyun.com/mirror/
registry = "https://registry.npmmirror.com/"
' >> ~/.bunfig.toml
cat ~/.bunfig.toml

# 安装 SDKMAN!
curl -s "https://get.sdkman.io" | bash
source "/home/lcqh/.sdkman/bin/sdkman-init.sh"
# 安装 JDK（示例：默认安装 Temurin JDK 21）
sdk install java
# 安装 Maven/Gradle
sdk install maven
sdk install gradle

# 安装 Rust
echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup' >> ~/.bash_profile
echo 'export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup' >> ~/.bash_profile
sudo dnf install -y rust cargo
# 验证安装
rustc --version
cargo --version
# 安装虚拟机
sudo dnf install -y vagrant VirtualBox virtualbox-guest-additions

# 清理无用的包和缓存
echo "清理未使用的软件包和缓存..."
sudo dnf autoremove -y
sudo dnf clean all

echo "系统配置成功完成!"

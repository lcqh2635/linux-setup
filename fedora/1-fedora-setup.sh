#!/bin/bash
# ==============================================================================
# 脚本名称: 1-fedora-setup.sh
# 功能描述：自动安装并配置系统初始优化
# 适用系统：Fedora 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x 1-fedora-setup.sh && ./1-fedora-setup.sh
# ==============================================================================


# ------------------------------------------------------------------------------
# Fedora 操作系统 ISO 阿里云和中科大加速下载网址：
# https://mirrors.ustc.edu.cn/fedora/releases/
# https://mirrors.aliyun.com/fedora/releases/
# https://mirrors.tuna.tsinghua.edu.cn/fedora/releases/
# cd ~/下载 && git clone https://cdn.gh-proxy.org/https://github.com/lcqh2635/linux-setup.git
# cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Gnome 官方网站 https://www.gnome.org/zh-CN/
# Launchpad 主页：https://launchpad.net/
# 包搜索：https://packages.ubuntu.com/
# PPA 列表：https://launchpad.net/ubuntu/+ppas
# 特定 PPA：https://launchpad.net/~gnome-shell-extensions/+archive/ubuntu/ppa
# Launchpad 主页：https://launchpad.net/~gnome-shell-extensions/+archive/ubuntu/ppa
# Extensions 包列表：https://launchpad.net/~gnome-shell-extensions/+archive/ubuntu/ppa/+packages
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 1. 安全与规范设置 (Best Practices)
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
# gsettings list-schemas
# gsettings list-schemas | grep 'org.gnome.shell.extensions'
# gsettings list-recursively org.gnome.desktop.interface
# gsettings list-recursively org.gnome.desktop.wm.preferences
# 列出所有系统级扩展
# gnome-extensions list --system
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
# 列出所有用户级扩展
# gnome-extensions list --user
# 查看所有用户级扩展的文件目录
# nautilus ~/.local/share/gnome-shell/extensions

# 调整和优化系统基础布局和显示
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
# 设置强调色为蓝色
gsettings set org.gnome.desktop.interface accent-color 'blue'

# 取消面板模式，改为类似 MacOS 系统的 Dock 栏模式
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
# 配置 Ubuntu Dock (自定义Dock栏)
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
# 智能隐藏 Dock 栏
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.5
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DASHES'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 1.0
# 禁用系统自带的 Desktop Icons NG (DING) 扩展
gnome-extensions disable ding@rastersoft.com
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Fedora 默认使用 metalink 来根据用户发出请求的 IP 选择合适的镜像，通常情况下并不需要手动换源。操作前请做好相应备份
# 配置 Ubuntu 国内加速镜像，在所有的国内加速镜像中 ustc 中科大是同步更新最及时，并且下载速度也飞快的一个加速镜像站点，优先使用它！
# https://mirrors.ustc.edu.cn/help/fedora.html
# https://developer.aliyun.com/mirror/fedora
# https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora.repo
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora-updates.repo
# 将上述两个文件先做个备份，根据 Fedora 系统版本分别替换为下面内容，之后通过 sudo dnf makecache 命令更新本地缓存，即可使用所选择的软件源镜像。
sudo sed -e 's|^metalink=|#metalink=|g' \
         -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' \
         -i.bak \
         /etc/yum.repos.d/fedora.repo \
         /etc/yum.repos.d/fedora-updates.repo
# 更新本地缓存，即可使用所选择的软件源镜像
sudo dnf makecache
# 修改还原
# sudo mv /etc/yum.repos.d/fedora.repo.bak /etc/yum.repos.d/fedora.repo
# sudo mv /etc/yum.repos.d/fedora-updates.repo.bak /etc/yum.repos.d/fedora-updates.repo

# RPM Fusion 默认使用 metalink 来根据用户发出请求的 IP 选择合适的镜像，通常情况下并不需要手动换源
# 中国科技大学 RPMFusion 镜像源	https://mirrors.ustc.edu.cn/help/rpmfusion.html
# 使用下列命令（在 bash 或兼容 shell 中），可以同时启用其 free 和 nonfree 软件源
sudo dnf install -y https://mirrors.ustc.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.ustc.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# 安装成功后，可使用下列命令备份并修改 /etc/yum.repos.d/ 目录下以 rpmfusion 开头，以 .repo 结尾的文件。
# 具体而言，需要将文件中 metalink= 开头的行注释掉，取消 baseurl= 开头的行的注释
# 并将等号后面链接中的 http://download1.rpmfusion.org 替换为 https://mirrors.ustc.edu.cn/rpmfusion：
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/rpmfusion-free.repo
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/rpmfusion-free-updates.repo
sudo sed -e 's|^metalink=|#metalink=|g' \
         -e 's|^#baseurl=http://download1.rpmfusion.org|baseurl=https://mirrors.ustc.edu.cn/rpmfusion|g' \
         -i.bak \
         /etc/yum.repos.d/rpmfusion*.repo
# 修改完成后，清除并重建缓存：
sudo dnf clean all
sudo dnf makecache
# 还原上述 RPM Fusion 修改
# 遍历 /etc/yum.repos.d/ 目录下所有以 rpmfusion 开头且以 .bak 结尾的文件，并去除末尾的 .bak 后缀
# for i in /etc/yum.repos.d/rpmfusion*.bak; do sudo mv "$i" "${i%.bak}"; done

# 中国科技大学 Flathub 镜像源 https://mirrors.ustc.edu.cn/help/flathub.html
# 在已有 flathub 远程源的基础上替换 Flatpak 默认的软件源
# Fedora默认安装了Flatpak，只要配置Flatpak加速镜像即可
echo "开始配置Flatpak加速镜像..."
# flatpak remotes --show-details
# 添加 Flathub 官方仓库
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# 修改 Flathub 仓库地址为国内镜像
# 2、中科大 Flatpak 镜像源（处于测试阶段） https://mirrors.ustc.edu.cn/help/flathub.html
sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
# 恢复默认值：
# sudo flatpak remote-modify flathub --url=https://dl.flathub.org/repo
# 将 WhiteSur 主题包连接到 Flatpak 仓库，可以解决部分应用无法使用 WhiteSur 主题问题，例如：Chrome、Edge
# xdg-data/themes 是 ~/.local/share/themes 的标准化路径别名（Flatpak 优先识别）
# :ro 表示只读权限，避免应用误修改主题文件。
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak override --filesystem=xdg-config/gtk-4.0:ro
sudo flatpak override --filesystem=xdg-data/themes:ro
sudo flatpak override --filesystem=xdg-data/icons:ro
sudo flatpak override --filesystem=$HOME/.themes:ro
sudo flatpak override --filesystem=$HOME/.icons:ro

# 在 Fedora 上，我们默认使用 openh264 库，因此您需要显式启用存储库
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

# 更新系统并升级所有已安装的包
echo "开始更新系统并升级所有已安装的包..."
sudo dnf update -y && sudo dnf upgrade -y
echo "系统更新、升级完成..."
# ------------------------------------------------------------------------------

# 从 fedora-cisco-openh264 存储库安装
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264 mozilla-ublock-origin
# 之后，您需要打开 Firefox，转到菜单 → 附加组件 → 插件 并启用 OpenH264 插件。
# 您可以在此页面 https://mozilla.github.io/webrtc-landing/pc_test.html 上对您的 H.264 是否在 RTC 中工作进行简单测试（检查需要 H.264 视频）。
# 安装多媒体编解码器
echo "安装多媒体编解码器..."
# 作为 Fedora 用户和系统管理员，您可以使用这些步骤来安装额外的多媒体插件，使您能够播放各种视频和音频类型。 
# 对于 fedora 41 及更高版本，安装用于播放电影和音乐的插件 https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-plugins-for-playing-movies-and-music/
sudo dnf group install -y multimedia


# 安装fedora的多媒体组，以下内容参考 https://rpmfusion.org/Howto/Multimedia
# Fedora 上的多媒体
# 切换到完整的 ffmpeg，使用 swap 命令为替换操作
# FFmpeg-Free 是 Fedora 默认提供的一个受限版本，仅包含开源且无专利限制的编解码器。
# FFmpeg 是一个功能强大的多媒体处理工具集，支持视频、音频的编码、解码、转码、流媒体传输等功能。
# 它支持广泛的编解码器（如 H.264、HEVC、AAC 等），包括一些专利保护的编解码器。 
# Fedora ffmpeg-free 在大多数时候都能正常工作，但有时会遇到版本不匹配的情况。切换到 rpmfusion 提供的 ffmpeg 构建，它得到了更好的支持。您仍然需要按照下一节了解与您可能已安装的软件包相关的其他编解码器或插件。
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
# 安装其他编解码器，这将允许使用 gstreamer 框架和其他多媒体软件的应用程序播放其他受限编解码器：
# 以下命令将安装启用 gstreamer 的应用程序所需的补充多媒体包： 
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# 硬件加速编解码器
# 使用 AMD（mesa）的硬件编解码器
# 使用 rpmfusion-free 部分这是从 Fedora 37 及更高版本开始需要的...主要关注 AMD 硬件，因为带有 nouveau 的 NVIDIA 硬件运行不佳 
# Mesa 是一个开源的图形驱动框架，提供了对 OpenGL、Vulkan、VA-API 和 VDPAU 等图形 API 的支持。
# Fedora 默认的 Mesa 驱动遵循严格的开源许可证，因此不包含对某些专利保护的编解码器（如 H.264 和 HEVC）的支持。
# Fedora 默认安装的是开源的 mesa-va-drivers 和 mesa-vdpau-drivers，这些驱动完全符合开源社区的标准，但可能缺少对某些专有编解码器（如 H.264 或 HEVC）的支持。
# RPM Fusion 提供了名为 mesa-*-drivers-freeworld 的替代版本，它们是基于 Mesa 的增强版本，支持更多的专有编解码器（如 H.264 和 HEVC）和性能优化
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing
sudo dnf swap -y mesa-vulkan-drivers mesa-vulkan-drivers-freeworld --allowerasing
# 安装 VA-API 和 VDPAU 驱动，一般默认已安装
# dnf list mesa*		# 查看 Mesa 驱动程序 freeworld 和原始驱动程序
# 提供 vainfo 命令的包
sudo dnf install -y libva-utils vulkan-tools
# vainfo
# vainfo | grep -E 'H264|H265'
# vulkaninfo | grep "GPU"


## 5. 开发环境配置 =============================================
# 安装常用应用
echo "安装常用应用程序..."
sudo dnf install -y \
    git wl-clipboard \
    wget curl \
    unzip p7zip \
    fastfetch \
    flatpak \
    timeshift \
    evolution vlc obs-studio \
    gnome-tweaks \
    gnome-extensions-app \
    libreoffice-langpack-zh-Hans \
    vagrant VirtualBox virtualbox-guest-additions
# evolution配置qq邮箱授权码： embwnsuwkdjrebge

# 安装 Tauri 2 运行环境依赖包 https://tauri.app/zh-cn/start/prerequisites/#linux
sudo dnf check-update
sudo dnf install -y webkit2gtk4.1-devel \
  openssl-devel \
  curl \
  wget \
  file \
  libappindicator-gtk3-devel \
  librsvg2-devel
sudo dnf group install -y "c-development"
# dnf install -y @c-development
# Development Tools  是一个预定义的软件包组，包含一组常用的开发工具和库，用于支持软件开发工作。
# 它旨在为开发者提供一个基础的开发环境，而无需手动安装每个工具。
# sudo dnf group list		# 查看可用的软件包组
sudo dnf install -y @development-tools


# 配置 Git
# git config --global user.name "龙茶清欢"
# git config --global user.email "2320391937@qq.com"
# ssh-keygen -t rsa -b 4096 -C "2320391937@qq.com"
# 需要安装 wl-clipboard 工具
# cat ~/.ssh/id_rsa.pub | wl-copy
# 配置 Gitee 密钥	https://gitee.com/profile/sshkeys
# 配置 Github 密钥	https://github.com/settings/keys
# git add . && git commit -m 'backup' && git push


# 安装基础的 flatpak 应用软件
# 为 Linux 上的 Flathub 提供支持的 Flatpak 应用商店
sudo flatpak install -y flathub io.github.kolunmi.Bazaar
# Flatseal 是一种图形工具，用于审查和修改 Flatpak 应用程序中的权限
sudo flatpak install -y flathub com.github.tchx84.Flatseal
# Warehouse 提供了一个简单的用户界面来控制复杂的 Flatpak 选项，而且完全无需借助命令行
sudo flatpak install -y flathub io.github.flattool.Warehouse
# Evolution 是一款个人信息管理应用，提供集成的邮件、日历和地址簿功能
sudo flatpak install -y flathub org.gnome.Evolution
# 一款高级用户工具，允许在支持fwupd的设备上更新、重装和降级固件
sudo flatpak install -y flathub org.gnome.Firmware
# 更改 GDM 设置； 应用主题和背景、更改光标主题、图标主题和夜灯设置等
sudo flatpak install -y flathub io.github.realmazharhussain.GdmSettings
# 轻松地将磁盘镜像写入你的硬盘。选择一张图片，插入你的硬盘，就可以开始了！Impression 是热衷于发行的用户和普通电脑用户都非常有用的工具
sudo flatpak install -y flathub io.gitlab.adhami3310.Impression
# 用干净、无干扰的标记删除编辑器专注于你的写作
sudo flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe
# Save Desktop 可帮助您轻松备份、还原和同步整个桌面环境。它保存和导入您的主题，图标，字体，壁纸，扩展，桌面文件夹，Flatpak应用程序及其数据，
# 以及其他桌面设置-所有在一个存档。选择要包含的内容，并通过自动定期保存和同步来保持设备之间的设置一致
sudo flatpak install -y flathub io.github.vikdevelop.SaveDesktop
# Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
sudo flatpak install -y flathub com.google.Chrome
sudo flatpak install -y flathub com.qq.QQ
sudo flatpak install -y flathub com.tencent.WeChat


# ------------------------------------------------------------------------------
# apt list --installed | grep program_name
# 一些软件源配置可被改进为现代化的配置方法。请运行“apt modernize-sources”来进行此操作
sudo apt modernize-sources -y
# 🏆 最佳实践，完美组合
# 更新 APT 包列表、升级 APT 包、 删除无用依赖、清理无效缓存
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y && sudo apt autoclean -y
# 更新 Flatpak 应用、更新 Snap 应用
# sudo flatpak update -y && sudo snap refresh
# 查看可以升级的软件包	apt list --upgradable

# # 在 apt 命令中，添加 -y 或 --yes 参数即可实现自动确认（自动回答 "Yes"）
# 简单结论：推荐使用第二种（或者分两步走），因为它能更彻底地清理空间
# 动作：仅卸载主包，并删除其配置文件（purge 的作用）不会自动卸载它安装时带来的依赖包（例如解码器、字体等）
# sudo apt purge -y ubuntu-restricted-extras
# 动作：卸载主包 + 删除配置文件 + 自动清理不再需要的依赖包
# sudo apt autoremove --purge -y ubuntu-restricted-extras
# 和上面的效果等价
# sudo apt purge -y ubuntu-restricted-extras && sudo apt autoremove -y
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# build-essential 本质上是一个“元包”，本身不包含内容，而是依赖一系列具体的软件包。
# 因此，通过 APT 查询它的依赖关系，就能知道它会安装什么
# 包含：gcc, g++, make, libc6-dev, dpkg-dev 等
# 使用 APT 包管理器查询依赖关系 apt-cache depends build-essential
# iproute2 是 现代 Linux 网络配置和管理工具集，由 Stephen Hemminger 开发，旨在替代过时的 net-tools
sudo apt install -y \
git fastfetch wl-clipboard \
build-essential cmake \
curl wget file iproute2 \
libxdo-dev libssl-dev \
libwebkit2gtk-4.1-dev \
libayatana-appindicator3-dev \
librsvg2-dev
# 配置 Git 访问的 SSH 密钥
git config --global user.name 'lcqh2635' 
git config --global user.email '2320391937@qq.com'
# ssh-keygen -t rsa -b 4096 -C "2320391937@qq.com"
# 将上面生成的 SSH 密钥复制到剪切板，需要安装 wl-clipboard 工具
# cat ~/.ssh/id_rsa.pub | wl-copy
# 配置 Gitee 密钥	https://gitee.com/profile/sshkeys
# 配置 Github 密钥	https://github.com/settings/keys
# cd ~/文档 && git clone git@github.com:lcqh2635/linux-setup.git
# cd ~/下载 && git clone https://gh-proxy.org/https://github.com/lcqh2635/linux-setup.git

# 安装前端工具，下面的 Gnome Shell 扩展安装需要使用到
# https://ubuntu.com/toolchains
sudo apt install -y nodejs npm
# 最新地址 淘宝 NPM 镜像站喊你切换新域名啦!
npm config set registry https://registry.npmmirror.com

# Synaptic 是 Debian/Ubuntu 等 Linux 发行版中一款经典的图形化软件包管理工具，新立得软件包管理器
sudo apt install -y \
gnome-tweaks gnome-browser-connector \
gnome-system-monitor synaptic \
timeshift software-properties-gtk \
libadwaita-1-examples

# 模拟安装，查看依赖列表
# apt install --dry-run multimedia-all
# 或查看推荐依赖
# apt-cache depends multimedia-all
# 全部多媒体创作与处理工具，面向专业音频/视频制作、图形设计等场景。不推荐普通用户安装
# sudo apt install -y multimedia-all
# 安装额外的多媒体插件，使您能够播放各种视频和音频类型
sudo apt install -y ubuntu-restricted-extras
# 查询软件包的详细元数据信息，包括版本、描述、依赖关系、大小、来源等
# apt info ubuntu-restricted-extras
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 安装并配置 flatpak
sudo apt install -y \
gnome-software flatpak \
gnome-software-plugin-flatpak \
gnome-software-plugin-snap \
gnome-software-plugin-fwupd
# 设置 flatpak 加速镜像源
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
# 恢复默认值：
# sudo flatpak remote-modify flathub --url=https://dl.flathub.org/repo
# 将 WhiteSur 主题包连接到 Flatpak 仓库，可以解决部分应用无法使用 WhiteSur 主题问题，例如：Chrome、Edge
# xdg-data/themes 是 ~/.local/share/themes 的标准化路径别名（Flatpak 优先识别）
# :ro 表示只读权限，避免应用误修改主题文件。
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak override --filesystem=xdg-config/gtk-4.0:ro
sudo flatpak override --filesystem=xdg-data/themes:ro
sudo flatpak override --filesystem=xdg-data/icons:ro
sudo flatpak override --filesystem=$HOME/.themes:ro
sudo flatpak override --filesystem=$HOME/.icons:ro

# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 列出所有系统级扩展
# gnome-extensions list --system
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
# apt list gnome-shell-extension*
# apt list gnome-shell-ubuntu-extensions*
sudo apt install -y \
gnome-shell-extension-manager \
gnome-shell-extension-user-theme \
gnome-shell-extension-alphabetical-grid \
gnome-shell-extension-auto-move-windows \
gnome-shell-extension-drive-menu \
gnome-shell-extension-light-style \
gnome-shell-extension-workspace-indicator \
gnome-shell-extension-gsconnect \
gnome-shell-extension-gsconnect-browsers \
gnome-shell-extension-prefs


# 列出所有用户级扩展
# gnome-extensions list --user
# 查看所有用户级扩展的文件目录
# nautilus ~/.local/share/gnome-shell/extensions
sudo apt-get install -y gettext meson just
mkdir -p ~/下载/extensions && cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/Exeos/disable-unredirect.git
cd disable-unredirect && make install
cd ~/下载/extensions
    
git clone https://gh-proxy.com/https://github.com/tuxor1337/hidetopbar.git
cd hidetopbar && make && gnome-extensions install -f hidetopbar.zip
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/aunetx/blur-my-shell.git
cd blur-my-shell && make install
cd ~/下载/extensions
    
git clone https://gitlab.gnome.org/jrahmatzadeh/just-perfection.git
cd just-perfection && ./scripts/build.sh -i
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/lennart-k/gnome-rounded-corners.git
cd gnome-rounded-corners && make
gnome-extensions install -f Rounded_Corners@lennart-k.zip
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/flexagoon/rounded-window-corners.git
cd rounded-window-corners && just install
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/fthx/appmenu-is-back.git
zip -FSr appmenu-is-back.zip appmenu-is-back/* && gnome-extensions install -f appmenu-is-back.zip
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/Tommimon/add-to-desktop.git
cd add-to-desktop && ./build.sh
gnome-extensions install -f output/add-to-desktop@tommimon.github.com.v15.shell-extension.zip
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/maniacx/Bluetooth-Battery-Meter.git
cd Bluetooth-Battery-Meter && ./install.sh
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git
cd gnome-shell-extension-clipboard-indicator && make bundle && gnome-extensions install -f bundle.zip
cd ~/下载/extensions
    
git clone https://gh-proxy.com/https://github.com/hermes83/compiz-alike-magic-lamp-effect.git
cd compiz-alike-magic-lamp-effect && ./zip.sh
gnome-extensions install -f compiz-alike-magic-lamp-effect@hermes83.github.com.zip
cd ~/下载/extensions

git clone https://gitlab.com/smedius/desktop-icons-ng.git
cd desktop-icons-ng && ./scripts/local_install.sh
cd ~/下载/extensions

git clone https://gitlab.com/rmnvgr/nightthemeswitcher-gnome-shell-extension.git
cd nightthemeswitcher-gnome-shell-extension
meson setup builddir --prefix=~/.local && meson install -C builddir
cd ~/下载/extensions

git clone https://gh-proxy.com/https://github.com/icedman/search-light.git
cd search-light && make
cd ~/下载/extensions
    
git clone https://gh-proxy.com/https://github.com/amivaleo/Show-Desktop-Button.git
mv Show-Desktop-Button show-desktop-button@amivaleo
zip -r show-desktop-button@amivaleo.zip show-desktop-button@amivaleo
gnome-extensions install -f show-desktop-button@amivaleo.zip
cd ~/下载/extensions
    
git clone https://gitlab.com/p91paul/status-area-horizontal-spacing-gnome-shell-extension.git
cd status-area-horizontal-spacing-gnome-shell-extension && ./buildforupload.sh
gnome-extensions install -f status-area-horizontal-spacing@mathematical.coffee.gmail.com.zip
cd ~/下载/extensions
    
    # 解决用户 Gnome 扩展无法使用 gsettings 的问题
    for EXT_DIR in ~/.local/share/gnome-shell/extensions/*/; do
        EXT_ID=$(basename "$EXT_DIR")
        echo "处理扩展: $EXT_ID"
        if [ -d "$EXT_DIR/schemas" ]; then
            glib-compile-schemas "$EXT_DIR/schemas"
            mkdir -p ~/.local/share/glib-2.0/schemas/
            cp "$EXT_DIR/schemas"/*.xml ~/.local/share/glib-2.0/schemas/
        fi
    done
    glib-compile-schemas ~/.local/share/glib-2.0/schemas/
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
# ------------------------------------------------------------------------------
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y && sudo apt autoclean -y


# apt list *fonts*
# Noto Fonts（思源黑体/宋体 的谷歌版本）
# Noto Sans（无衬线体，类似思源黑体）：界面清晰，适合屏幕显示。
# Noto Serif（衬线体，类似思源宋体）：适合长篇文档阅读。
# JetBrains Mono JetBrains 公司专门为 IDE 设计的字体。字母宽度大，容易区分 1、l、I，默认支持连字符，非常耐看。

# 系统界面（中文）	Noto Sans CJK SC	谷歌思源黑体，字库全，笔画均衡，与 Inter 风格协调
# 文档阅读/写作		Noto Serif CJK SC	思源宋体，适合长时间阅读，衬线带来轻松的纸质感
# 编程/终端		JetBrains Mono		字母区分度高，支持连字，视觉疲劳度低

# fonts-noto-cjk 这个软件包直接提供了思源黑体和思源宋体在 Ubuntu 系统中的标准版本
# Noto Sans CJK SC （思源黑体——简体中文）
# Noto Serif CJK SC （思源宋体——简体中文）
# 安装：sudo apt install -y fonts-noto-cjk fonts-jetbrains-mono

sudo apt install -y fonts-noto-cjk fonts-jetbrains-mono
# 设置 GNOME 桌面的默认界面字体，影响范围：应用程序菜单、按钮、标签、对话框等 UI 元素的字体
gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK SC Regular 11'
# 设置文档类内容的默认字体，影响范围：文本编辑器、帮助文档、网页内容（某些应用中）等以“文档”形式展示的内容
gsettings set org.gnome.desktop.interface document-font-name 'Noto Serif CJK SC Regular 11'
# 设置等宽字体，影响范围：终端、代码编辑器
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono Regular 11'
# 设置窗口标题栏字体，影响范围：所有应用程序窗口顶部的标题文字
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Noto Sans CJK SC Bold 11'
# 抗锯齿：rggb（LCD 显示器常用）或 grayscale
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
# 微调：full（较好）或 slight
gsettings set org.gnome.desktop.interface font-hinting 'slight'


reset_font() {
gsettings reset org.gnome.desktop.interface font-name
gsettings reset org.gnome.desktop.interface document-font-name
gsettings reset org.gnome.desktop.interface monospace-font-name
gsettings reset org.gnome.desktop.wm.preferences titlebar-font
gsettings reset org.gnome.desktop.interface font-antialiasing
gsettings reset org.gnome.desktop.interface font-hinting
}

uninstall_theme() {
./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r
}

# 安装字体、图标、主题
install_themes_and_icons() {
    print_info "正在安装并配置系统字体..."
    echo "正在安装WhiteSur主题..."
    cd ~/下载
    git clone https://cdn.gh-proxy.org/https://github.com/vinceliuice/WhiteSur-wallpapers.git --depth=1
    git clone https://cdn.gh-proxy.org/https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1
    git clone https://cdn.gh-proxy.org/https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
    git clone https://cdn.gh-proxy.org/https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
    # 修改 Nautilus 侧边栏不透明度，参考 https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1127
    # grep '$opacity: ' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    # sed -i 's/\$opacity: 0\.96/\$opacity: 1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    sed -i 's/0\.96/1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    sed -i 's/0\.95/1/g' ~/下载/WhiteSur-gtk-theme/other/firefox/WhiteSur/colors/light.css
    sed -i 's/0\.95/1/g' ~/下载/WhiteSur-gtk-theme/other/firefox/WhiteSur/colors/dark.css

    cd ~/下载/WhiteSur-wallpapers && ./install-wallpapers.sh && sudo ./install-gnome-backgrounds.sh
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Ventura/Ventura-timed.xml'
    
    cd ~/下载/WhiteSur-cursors && ./install.sh
    gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
    
    cd ~/下载/WhiteSur-icon-theme && ./install.sh
    gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
    
    # 在执行 ./tweaks.sh -f flat 安装 Firefox 主题时，Firefox 不能正在运行
    if pgrep firefox > /dev/null; then
        print_info "Firefox 正在运行，正在杀死进程..."
        pkill firefox
        sleep 3
    else
        print_info "Firefox 未在运行..."
        # 快速启动 Firefox 并在 3 秒后杀死它
        firefox & sleep 3 && pkill firefox
    fi
    
    # firefox not yet initialized error
    # https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1384
    # git clone https://cdn.gh-proxy.org/https://github.com/Sayanduary/WhiteSur-gtk-theme.git
    # 为 libadwaita 安装，默认是普通暗色主题
    cd ~/下载/WhiteSur-gtk-theme && ./install.sh -l -o solid && ./tweaks.sh -f flat -F -o solid
    # cd ~/下载/WhiteSur-gtk-theme && ./install.sh -l -o solid && ./tweaks.sh -f monterey -F -o solid
    # 使用自定义背景
    sudo ./tweaks.sh -g -b "$HOME/.local/share/backgrounds/Ventura-light.jpg"
    # 卸载因上面使用自定义背景而安装的 imagemagick
    sudo apt autoremove --purge -y imagemagick
    # 卸载主题
    # ./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r
    # 设置系统 GTK 主题
    gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
    gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
    
    # 如果文件都在当前目录
    cd ~/下载 && rm -rf WhiteSur-*
    # 最简洁的方式
    # cd ~/下载 && rm -rf WhiteSur-{cursors,icon-theme,gtk-theme}

    print_success "WhiteSur GTK 图标启用并配置完成！"
    print_success "主题和图标安装完成！"
}







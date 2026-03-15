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
# Gnome 官方网站：	https://www.gnome.org/zh-CN/
# Fedora ISO 下载：	https://fedoraproject.org/zh-Hans/
#			https://kojipkgs.fedoraproject.org/compose/
# Fedora 使用文档：	https://docs.fedoraproject.org/zh_CN/docs/
# Fedora 快速上手：	https://docs.fedoraproject.org/zh_Hans/quick-docs/
# Fedora 用户社区：	https://discussion.fedoraproject.org/
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

# 递归列出某个 Schema 的键值（例如 org.gnome.shell.extensions.dash-to-dock）
# gsettings list-recursively org.gnome.shell.extensions.dash-to-dock
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
# 更新 dnf 包列表、升级 dnf 包、 删除无用依赖
sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y
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

# Fedora 安装 Chromium 或 Google Chrome 浏览器
# https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-chromium-or-google-chrome-browsers/
# 安装第三方仓库
sudo dnf install fedora-workstation-repositories
# 启用 Google Chrome 仓库：
sudo dnf config-manager setopt google-chrome.enabled=1
# 最后，安装  Google Chrome 浏览器：
# sudo dnf install -y google-chrome-stable
# sudo dnf remove -y google-chrome-stable
# ------------------------------------------------------------------------------

# 删除无用的应用
sudo dnf remove -y mediawriter libreoffice-*

# https://docs.fedoraproject.org/zh_Hans/quick-docs/openh264/
# 从 fedora-cisco-openh264 存储库安装
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264 mozilla-ublock-origin
# 之后，您需要打开 Firefox，转到菜单 → 附加组件 → 插件 并启用 OpenH264 插件。
# 您可以在此页面 https://mozilla.github.io/webrtc-landing/pc_test.html 上对您的 H.264 是否在 RTC 中工作进行简单测试（检查需要 H.264 视频）
# 安装多媒体编解码器
echo "安装多媒体编解码器..."
# 作为 Fedora 用户和系统管理员，您可以使用这些步骤来安装额外的多媒体插件，使您能够播放各种视频和音频类型。 
# 对于 fedora 41 及更高版本，安装用于播放电影和音乐的插件
# https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-plugins-for-playing-movies-and-music/
sudo dnf group install -y multimedia


# 安装fedora的多媒体组，以下内容参考	https://rpmfusion.org/Howto/Multimedia
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
    git wget curl \
    unzip p7zip \
    fastfetch \
    flatpak \
    wl-clipboard \
    libadwaita-demo \
    gnome-tweaks gnome-system-monitor \
    gnome-browser-connector gnome-extensions-app
# evolution配置qq邮箱授权码： embwnsuwkdjrebge

# Tauri 在 Linux 上进行开发需要各种系统依赖项。这些可能会有所不同，具体取决于你的发行版，在 Fedora 系统中需安装以下依赖：
# https://tauri.app/zh-cn/start/prerequisites/#linux
sudo dnf check-update
sudo dnf install -y webkit2gtk4.1-devel \
  openssl-devel \
  curl \
  wget \
  file \
  libappindicator-gtk3-devel \
  librsvg2-devel \
  libxdo-devel
sudo dnf group install -y "c-development"
# dnf install -y @c-development
# Development Tools  是一个预定义的软件包组，包含一组常用的开发工具和库，用于支持软件开发工作。
# 它旨在为开发者提供一个基础的开发环境，而无需手动安装每个工具。
# sudo dnf group list		# 查看可用的软件包组
sudo dnf install -y @development-tools
# 配置 Git 访问的 SSH 密钥
git config --global user.name 'lcqh2635' 
git config --global user.email 'lcqh2635@gmail.com'
ssh-keygen -t rsa -b 4096 -C "lcqh2635@gmail.com"
# git config --global user.email '2320391937@qq.com'
# ssh-keygen -t rsa -b 4096 -C "2320391937@qq.com"
# 将上面生成的 SSH 密钥复制到剪切板，需要安装 wl-clipboard 工具
# cat ~/.ssh/id_rsa.pub | wl-copy
# 配置 Gitee 密钥	https://gitee.com/profile/sshkeys
# 配置 Github 密钥	https://github.com/settings/keys
# cd ~/文档 && git clone git@github.com:lcqh2635/linux-setup.git
# cd ~/下载 && git clone https://gitee.com/lcqh2635/init-fedora.git
# cd ~/下载 && git clone https://gh-proxy.org/https://github.com/lcqh2635/linux-setup.git

# nautilus ~/.local/share/backgrounds/
cd ~/下载
wget "https://gitee.com/lcqh2635/linux/raw/master/壁纸/wallpaper-light.jpg"
wget "https://gitee.com/lcqh2635/linux/raw/master/壁纸/wallpaper-dark.jpg"
wget "https://gitee.com/lcqh2635/linux/raw/master/壁纸/wallpaper-noon.jpg"
cp -v ~/下载/wallpaper-light.jpg ~/.local/share/backgrounds/
cp -v ~/下载/wallpaper-dark.jpg ~/.local/share/backgrounds/
cp -v ~/下载/wallpaper-noon.jpg ~/.local/share/backgrounds/
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-light.jpg"
# gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-dark.jpg"

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
# 轻松地将磁盘镜像写入你的硬盘。选择一张图片，插入你的硬盘，就可以开始了
sudo flatpak install -y flathub io.gitlab.adhami3310.Impression
# 用干净、无干扰的标记删除编辑器专注于你的写作
sudo flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe
# 浏览并安装GNOME Shell扩展以定制你的桌面
sudo flatpak install -y flathub com.mattjakeman.ExtensionManager
# Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
sudo flatpak install -y flathub com.google.Chrome
sudo flatpak install -y flathub com.qq.QQ
sudo flatpak install -y flathub com.tencent.WeChat

# VPN 相关软件和订阅来源
# https://gh-proxy.com/
# https://ghproxylist.com/
# https://www.freeclashnode.com/

install_vpn() {
    # 进入到下载目录
    cd ~/下载
    
    # https://v2rayn.co/
    # https://github.com/2dust/v2rayN/releases
    # 使用教程	https://v2rayn.co/v2rayn-tutorial/
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
    wget "https://gh-proxy.org/https://github.com/2dust/v2rayN/releases/download/7.18.0/v2rayN-linux-rhel-64.rpm"
    sudo dnf install -y ./v2rayN-linux-rhel-64.rpm
    wget "https://gh-proxy.org/https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.4.6/Clash.Verge-2.4.6-1.x86_64.rpm"
    sudo dnf install -y ./Clash.Verge-2.4.6-1.x86_64.rpm
}


# ------------------------------------------------------------------------------
# https://ubuntu.com/toolchains
sudo dnf install -y nodejs
# npm config get registry
# 执行后，npm 会自动帮你把配置写入 ~/.npmrc 文件，没必要手动编辑 ~/.npmrc 文件。
# 但需要注意的是，该配置的 npm 加速镜像只对当前用户有效，对于使用 sudo 的 npm 无效，例如  sudo npm install -g bun
# 配置 npm 国内阿里云 aliyun 加速镜像源，地址为	https://developer.aliyun.com/mirror/NPM
npm config set registry https://registry.npmmirror.com/
# 将目录所有权改为当前用户，否则如下命令将因为权限问题执行失败
sudo chown -R $(whoami):$(whoami) /usr/local
# 安装 Bun 运行时环境	https://www.bunjs.cn/docs/installation
# bun - 现代的 JavaScript 运行时和包管理器
# https://www.npmjs.com/package/bun
npm install -g bun
# bun create vite my-vue-app --template vue-ts
# Claude Code 是一款存在于终端中的代理编码工具，理解你的代码库，并通过自然语言命令帮助你执行例行任务、
# 解释复杂代码和处理 git 工作流程，从而更快地完成代码。在你的终端、IDE或Github上的标签@claude中使用。
# https://www.npmjs.com/package/@anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
# https://openclaw.cc/
npm install -g openclaw
echo "🐍 你刚安装的 bun 版本号为：$(bun --version)"
# bun 自行升级	bun upgrade
# bun run config --help
# bun --config
# 将 bunfig.toml 作为隐藏文件添加到用户主目录	https://www.bunjs.cn/docs/runtime/bunfig
cat << EOF | tee $HOME/.bunfig.toml
[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，地址为	https://developer.aliyun.com/mirror/NPM
registry = "https://registry.npmmirror.com/"
EOF
# which node
# whereis node
# whereis bun
# 将 IDEA 的 JS/TS 默认运行时环境从 nodejs 改为 bun 操作如下：
# 1、设置 -> 语言和框架 -> Bun -> /usr/local/bin/bun
# 2、设置 -> 语言和框架 -> Node.js -> Node解释器 -> /usr/local/bin/bun

# 推荐安装的全局工具包
# https://docs.deno.org.cn/
npm install -g deno
# deno init --npm vite my-vue-app --template vue-ts
# vite - 下一代前端构建工具（通常项目局部安装，但全局也有用）
npm install -g typescript vite eslint prettier
# npm 列出所有全局安装的包
# npm list -g --depth=0
# 执行更新命令，更新所有可更新的全局包
# npm update -g
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 通过 dnf 安装 (推荐)
# https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-java/
sudo dnf install -y java-25-openjdk maven
echo "🐍 你刚安装的 java 版本号为：$(java --version)"
echo "🐍 你刚安装的 maven 版本号为：$(mvn --version)"
# whereis maven
# nautilus admin:/usr/share/maven
# 配置 maven 阿里云 aliyun 加速镜像	https://maven.aliyun.com/mvn/guide
# -v (verbose)：详细模式。
# 作用：每创建一个目录，都会在终端打印一条提示信息。让用户知道命令到底执行了什么
# -p (parents)：父目录模式。
# 作用 ：如果指定的路径中父目录不存在，会自动递归创建。如果目录已经存在，不会报错，而是静默成功
mkdir -vp $HOME/.m2
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee -a $HOME/.m2/settings.xml
<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">

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
# 甚至可以使用大括号展开来创建有规律的目录
mkdir -vp $HOME/编程/{Java,Rust,Cpp,Python,TypeScript,Database}
# https://gitcn.org/
# https://gitcn.org/topics
# https://gitcn.org/top

# https://github.com/openjdk/jdk
# https://github.com/topics/java
# https://dev.java/

# https://github.com/rust-lang/rust
# https://gitcn.org/topics/rust
# https://gitcn.org/trending?lang=Rust
# https://rust-lang.org/zh-CN/

# https://github.com/topics/c
# https://github.com/topics/python
mkdir -vp $HOME/编程/Database/{SQLite,MySQL,MariaDB,Postgres,Distributed,Redis}
# https://github.com/sqlite/sqlite
# https://www.sqlite.net.cn/

# https://github.com/mysql/mysql-server
# https://www.mysql.com/cn/

# https://github.com/MariaDB/server
# https://mariadb.org.cn/

# https://github.com/postgres/postgres
# https://postgresql.ac.cn/

# https://github.com/pingcap/tidb
# https://docs.pingcap.com/zh/

# https://github.com/oceanbase/oceanbase
# https://www.oceanbase.com/product/opensource

# https://github.com/redis/redis
# https://www.redis.net.cn/

# IDEA 配置 “Maven 主路径” 为 /usr/share/maven 直接复制到输入框即可
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 第七步：安装 Rust
echo "🦀 安装 Rust..."
# Rust Web 常用的框架 Axum 目前排名性能总榜 7，需要使用 pg 数据库，数据来自性能测试网站	https://www.techempower.com/benchmarks
# 配置 crates.io 国内中科大 ustc 加速镜像源	 https://mirrors.ustc.edu.cn/help/crates.io-index.html
# 配置 crates.io 国内阿里云 aliyun 加速镜像源	https://developer.aliyun.com/mirror/rustup 

# 配置 rustup 使用阿里云的加速镜像源，从而 加速 Rust 工具链（如 rustc、cargo）的下载和更新
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee -a ~/.bash_profile
# 配置中科大 ustc 的 Rust Toolchain 反向代理 	https://mirrors.ustc.edu.cn/help/rust-static.html
# 指定 Rust 工具链和组件的下载地址（如 rustc,cargo,rust-std 等）
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
# 指定 rustup 自身更新元数据的地址（即 rustup 如何检查自身版本、下载新版本）
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

# 配置阿里云 aliyun 的 Rust Toolchain 反向代理 	https://developer.aliyun.com/mirror/rustup
# export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
# export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
EOF

source ~/.bash_profile
# cat ~/.bash_profile

# 用 shell 执行从标准输入来的脚本，并把 -y 作为参数传给那个脚本，告诉它：自动安装，不要问我！
# 自动确认所有提示，使用默认设置安装（相当于 yes）
# 使用官方安装脚本
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# 使用阿里云安装脚本
curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/repo/rust/rustup-init.sh | sh -s -- -y
# 激活 Rust 环境
. "$HOME/.cargo/env"

# rustup update
# 如果正在使用 cargo 1.68 及以上版本，在 $HOME/.cargo/config.toml 中添加如下内容即可：

# -v (verbose)：详细模式。
# 作用：每创建一个目录，都会在终端打印一条提示信息。让用户知道命令到底执行了什么
# -p (parents)：父目录模式。
# 作用 ：如果指定的路径中父目录不存在，会自动递归创建。如果目录已经存在，不会报错，而是静默成功。
#  ${MAVEN_HOME:-$HOME/.m2} 这是 Shell 参数扩展（Parameter Expansion） 语法，格式为 ${变量名:-默认值}
# 作用：检查环境变量 MAVEN_HOME 是否已设置且非空。如果是：使用 MAVEN_HOME 的值作为目录路径。如果否（未设置或为空）：使用默认值 $HOME/.m2
mkdir -vp ${CARGO_HOME:-$HOME/.cargo}
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee -a ${CARGO_HOME:-$HOME/.cargo}/config.toml
# 配置 Cargo 国内加速镜像源，可选：ustc、aliyun、tuna 此处默认选择 ustc
# 使用稀疏协议（sparse）减少元数据下载量，大幅加速
[source.crates-io]
replace-with = 'ustc'

# ustc 中科大 crates.io 镜像 	https://mirrors.ustc.edu.cn/help/crates.io-index.html
[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

# aliyun 阿里云 crates.io 镜像	https://developer.aliyun.com/mirror/rustup 
[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"
[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"
EOF
# cat $HOME/.cargo/config.toml

# https://crates.io/
# https://crates.io/crates/leptos
# https://crates.io/crates/tauri
# https://crates.io/crates/tokio
# https://crates.io/crates/hyper
# https://crates.io/crates/axum
# https://crates.io/crates/axum-valid
# https://crates.io/crates/axum-extra
# https://crates.io/crates/axum-test
# https://crates.io/crates/axum-login
# https://crates.io/crates/axum-anyhow
# https://crates.io/crates/tower
# https://crates.io/crates/tower-http
# https://crates.io/crates/tower-sessions
# https://crates.io/crates/tower_governor
# https://crates.io/crates/reqwest
# https://crates.io/crates/tonic
# https://crates.io/crates/sqlx
# https://crates.io/crates/sea-orm
# https://crates.io/crates/redis
# https://crates.io/crates/deadpool
# https://crates.io/crates/deadpool-redis
# https://crates.io/crates/deadpool-postgres
# https://crates.io/crates/fred
# https://crates.io/crates/serde
# https://crates.io/crates/serde_json
# https://crates.io/crates/validator
# https://crates.io/crates/jsonwebtoken
# https://crates.io/crates/uuid
# https://crates.io/crates/chrono
# https://crates.io/crates/dotenvy
# https://crates.io/crates/config
# https://crates.io/crates/tokio-cron-scheduler
# https://crates.io/crates/lettre
# https://crates.io/crates/captcha
# https://crates.io/crates/thiserror
# https://crates.io/crates/anyhow
# https://crates.io/crates/axum-anyhow
# https://crates.io/crates/rand
# https://crates.io/crates/image
# https://crates.io/crates/aws-sdk-s3
# https://crates.io/crates/object_store
# https://crates.io/crates/utoipa
# https://crates.io/crates/utoipa-gen
# https://crates.io/crates/base64
# https://crates.io/crates/bcrypt
# https://crates.io/crates/oauth2
# https://crates.io/crates/tracing
# https://crates.io/crates/tracing-subscriber
# https://crates.io/crates/console-subscriber
# https://crates.io/crates/opentelemetry
# https://crates.io/crates/opentelemetry-otlp
# https://crates.io/crates/tracing-opentelemetry
# https://crates.io/crates/axum-tracing-opentelemetry
# https://crates.io/crates/rnacos
# https://crates.io/crates/nacos-sdk
# https://crates.io/crates/metrics
# https://crates.io/crates/metrics-exporter-prometheus
# https://crates.io/crates/prometheus
# https://crates.io/crates/metrics-prometheus
# https://crates.io/crates/lapin
# https://crates.io/crates/rdkafka
# https://crates.io/crates/rocketmq-rust
# https://crates.io/crates/rocketmq-client-rust
# https://crates.io/crates/rust_decimal
# https://crates.io/crates/sysinfo
# https://crates.io/crates/clap
# https://crates.io/crates/regex
# ------------------------------------------------------------------------------

# https://course.ziglang.cc/
# https://github.com/ziglang/zig
# https://github.com/zigtools/zls
# https://zigtools.org/zls/install/
sudo dnf install -y zig
echo "🐍 你刚安装的 zig 版本号为：$(zig version)"

# ------------------------------------------------------------------------------
# 第六步：安装 Go 语言
echo "🐹 安装 Go 语言..."
# Go 国内加速镜像	https://learnku.com/go/wikis/38122
# golang 中文学习文档	https://golang.halfiisland.com/
# golang 官方网站	https://golang.google.cn/
# golang 公共软件包仓库	https://pkg.go.dev/
sudo dnf install -y golang
echo "🐍 你刚安装的 golang 版本号为：$(go version)"
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
mkdir -p $HOME/.go
go env -w GOPATH=$HOME/.go
# 查看当前环境
# go env GOPATH
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
sudo dnf install -y podman podman-compose
# 启用用户级 socket
systemctl --user enable --now podman.socket
# systemctl --user status podman
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
sudo cp /etc/containers/registries.conf{,.bak}
# 检查 .bak 文件是否存在
# ls -l /etc/containers
# 从同目录 .bak 文件恢复
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

# 创建网络
podman network create podman-net
podman pull redis:latest
# https://pgtune.leopard.in.ua/
podman pull postgres:latest
# Pods 是一个 podman 的前端。它的用户界面使用 libadwaita 并力求符合 GNOME 的设计原则
# 打开 Pods 软件，点击 “新建连接” 然后选择使用默认的 “Unix Socket” 点击 Connect
# IDEA 连接 Podman：按 Ctrl+Alt+S 打开设置，然后选择 构建、执行、部署 | Docker。点击 "添加"按钮 以添加 Docker 配置。选择 Unix 套接字 ，然后下拉选择 rootless 版地址
sudo flatpak install -y flathub com.github.marhkb.Pods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# JetBrains 的 API 返回的 JSON 中包含 多个架构的下载链接，你的 grep 命令会匹配 所有 包含 jetbrains-toolbox-*.tar.gz 的链接，
# 而 head -1 恰好取到了第一个（可能是 arm64）
# 关键：| grep -v 'arm64' 会过滤掉包含 "arm64" 的链接
wget -O jetbrains-toolbox.tar.gz "$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -o 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^\"]*\.tar\.gz' | grep -v 'arm64' | head -1)"
# 1. 创建一个专门放软件的目录 (例如在 home 目录下创建一个 apps 文件夹)
mkdir -p ~/.apps
# 2. 进入下载目录 (假设你的安装包在这里)
cd ~/下载
# 3. 解压到刚才创建的目录
# 注意：将 jetbrains-toolbox-*.tar.gz 替换为你实际下载的文件名，可以用 Tab 键自动补全
tar -xvf jetbrains-toolbox-*.tar.gz -C ~/.apps

# 1. 进入解压后的文件夹
cd ~/.apps/jetbrains-toolbox-*/bin
# 2. 赋予执行权限 (防止提示权限不足)
chmod +x jetbrains-toolbox
# 3. 启动程序
./jetbrains-toolbox


# https://3.jetbra.in/
# https://github.com/jonssonyan/3.jetbra.in
# https://account.jetbrains.com/licenses
cd ~/下载
wget https://3.jetbra.in/files/jetbra-5a50fc03d68a014f893b7fc3aa465380d59f9095.zip
unzip jetbra-*.zip && mv jetbra ~/.jetbra
# 自动配置  jetbrains 代码编辑器 vmoptions
~/.jetbra/scripts/install.sh
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 列出所有系统级扩展
# gnome-extensions list --system
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
# dnf list gnome-shell-extension*

sudo dnf remove -y \
gnome-shell-extension-apps-menu \
gnome-shell-extension-places-menu \
gnome-shell-extension-window-list \
gnome-shell-extension-launch-new-instance

sudo dnf install -y \
gnome-shell-extension-user-theme \
gnome-shell-extension-dash-to-dock \
gnome-shell-extension-blur-my-shell \
gnome-shell-extension-just-perfection \
gnome-shell-extension-drive-menu \
gnome-shell-extension-appindicator \
gnome-shell-extension-auto-move-windows \
gnome-shell-extension-workspace-indicator \
gnome-shell-extension-caffeine \
gnome-shell-extension-gsconnect \
gnome-shell-extension-forge \
gnome-shell-extension-no-overview \
gnome-shell-extension-light-style


# 列出所有用户级扩展
# gnome-extensions list --user
# 查看所有用户级扩展的文件目录
# nautilus ~/.local/share/gnome-shell/extensions
sudo dnf install -y gettext meson just
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
# 更新 dnf 包列表、升级 dnf 包、 删除无用依赖
sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y


# 安装 Ubuntu 的声音主题
sudo dnf install -y yaru-sound-theme
gsettings set org.gnome.desktop.sound theme-name 'Yaru'
# ------------------------------------------------------------------------------
# dnf list *fonts*
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
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-wallpapers.git --depth=1
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
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

gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-light.jpg"

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-dark.jpg"

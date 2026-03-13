#!/bin/bash
# ==============================================================================
# 脚本名称: 1-ubuntu-setup.sh
# 功能描述：自动安装并配置系统初始优化
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x 1-ubuntu-setup.sh && ./1-ubuntu-setup.sh
# ==============================================================================


# ------------------------------------------------------------------------------
# Ubuntu 操作系统 ISO 阿里云和中科大加速下载网址：
# https://mirrors.ustc.edu.cn/ubuntu-cdimage/releases/
# https://mirrors.aliyun.com/ubuntu-cdimage/releases/
# https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/releases/
# cd ~/下载 && git clone https://cdn.gh-proxy.org/https://github.com/lcqh2635/linux-setup.git
# cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push
# 打开 “软件和更新” 将中的软件源设置为 “阿里云 aliyun” 提供的加速镜像，不要直接选 “直接位于中国的服务器” 这可能会导致一些异常
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
# 禁用系统自带的 Ubuntu Dock 扩展，改用 Dash to Dock
gnome-extensions disable ubuntu-dock@ubuntu.com
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 安装必需的Chrome依赖，安装用于安全下载和GPG密钥管理所需的包：
sudo apt install -y curl apt-transport-https ca-certificates
# 配置 Ubuntu 国内加速镜像，在所有的国内加速镜像中 ustc 中科大是同步更新最及时，并且下载速度也飞快的一个加速镜像站点，优先使用它！
# https://mirrors.ustc.edu.cn/help/ubuntu.html
# https://developer.aliyun.com/mirror/ubuntu
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
# ls /etc/apt/sources.list.d && cat /etc/apt/sources.list.d/ubuntu.sources
# 备份到同目录（添加 .bak 后缀）
sudo cp /etc/apt/sources.list.d/ubuntu.sources{,.bak}
# 检查 .bak 文件是否存在
# ls -l /etc/apt/sources.list.d
# 从同目录 .bak 文件恢复
# sudo cp /etc/apt/sources.list.d/ubuntu.sources{.bak,}
# 常规官方软件源替换
sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources
# 安全更新源替换
sudo sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
# 使用 HTTPS 可以有效避免国内运营商的缓存劫持。可以运行以下命令替换：
sudo sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources
# ls /usr/share/keyrings
# cat /etc/apt/sources.list.d/ubuntu.sources
# ------------------------------------------------------------------------------


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
# https://cn.ubuntu.com/pro
sudo pro attach C1fNYhSKakFcaXf77wgse9XF725K6
sudo pro enable esm-apps esm-infra livepatch
# pro status --all
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







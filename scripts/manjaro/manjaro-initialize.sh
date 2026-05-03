#!/bin/bash

# 会自动寻找可与你连接的国内节点，选一个延迟最低的就可，当然你可以选两三个，多了拖慢速度。
sudo pacman-mirrors -i -c China -m rank

# 如果安装了 yay 就不要在安装和使用 flatpak 了，因为 yay 中基本都有，避免造成内存占用，所有软件读使用 pacman、yay 进行安装管理
sudo pacman -Syyu
sudo pacman -S yay
yay -Syyu

# 安装tuari相关的依赖，都是一些系统基础工具
sudo pacman -Syu
sudo pacman -S --needed \
  webkit2gtk \
  base-devel \
  curl \
  wget \
  file \
  openssl \
  appmenu-gtk-module \
  gtk3 \
  libappindicator-gtk3 \
  librsvg

yay -Rcns gnome-chess gnome-mines iagno quadrapassel thunderbird
yay -S popsicle extension-manager vim

# 开启分数缩放
gsettings get org.gnome.mutter experimental-features
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

git config --global user.name "龙茶清欢"
git config --global user.email "2320391937@qq.com"
ssh-keygen -t rsa -b 4096 -C "2320391937@qq.com"
cat ~/.ssh/id_rsa.pub

# 推荐直接使用系统自带的  ibus 输入法，如果感觉不行再切换到  fcitx5
# 参考：https://www.cnblogs.com/fatalord/p/13850072.html
sudo pacman -Rns ibus
sudo pacman -Rns $(pacman -Qsq fcitx)
# 安装 fcitx5 输入法, https://zhuanlan.zhihu.com/p/597197721
yay -S manjaro-asian-input-support-fcitx5 fcitx5-chinese-addons fcitx5-configtool

yay -S whitesur-gtk-theme whitesur-icon-theme whitesur-cursor-theme
 sudo pacman -Rcns whitesur-gtk-theme
# WhiteSur GTK 主题
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
# 主题在部分 GTK4 应用中无法生效问题解决，
# 参考  https://github.com/vinceliuice/WhiteSur-gtk-theme?tab=readme-ov-file#fix-for-libadwaita-not-perfect   但无法实现主题切换了
# 修复 libadwaita (不完美)
./install.sh
./install.sh -l -c light
# 安装的 flat Firefox 主题
./tweaks.sh -f flat
# 安装 GDM 主题，使用默认的背景
sudo ./tweaks.sh -g

sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0
./tweaks.sh -F

# 推荐直接使用 yay 不要额外安装下面的内容
echo "==========开始安装gnome相关软件=========="
# 下载系统基础工具，安装GNOME插件和扩展, gnome-shell-extensions
# yay 包管理器不要使用  sudo

# 安装 Flatpak 支持，由于 Flatpak 支持不是默认安装的，因此必须先从软件源安装一些软件包并进行配置。
# 来自 EndeavourOS 官方文档 https://discovery.endeavouros.com/applications/flatpak-enabling-and-application-management/2021/03/
# 国内源 https://mirror.sjtu.edu.cn/docs/flathub
yay -S flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
flatpak remotes --show-details
sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0
flatpak install flathub com.mattjakeman.ExtensionManager -y
flatpak install flathub com.github.tchx84.Flatseal -y



# 系统扩展目录
# nautilus admin:/usr/share/gnome-shell/extensions

# 网站国内可用 DNS 测试 ping 	https://ping.chinaz.com/www.youtube.com
# 配置Github访问加速
echo "
# GitHub Start
20.27.177.113    github.com
185.199.108.133    raw.githubusercontent.com
151.101.193.91    extensions.gnome.org
# GitHub End
" | sudo tee -a /etc/hosts

cat /etc/hosts
nautilus admin:/etc/hosts

# 自动自带的系统扩展移除办法
nautilus admin:/usr/share/gnome-shell/extensions
# 用户扩展目录
nautilus ~/.local/share/gnome-shell/extensions
cd ~/.local/share/gnome-shell/extensions

yay -S gnome-shell-extensions
extra/gnome-shell-extensions
extra/gnome-shell-extension-dash-to-dock
extra/gnome-shell-extension-caffeine
extra/gnome-shell-extension-vitals
extra/gnome-shell-extension-gtk4-desktop-icons-ng

aur/gnome-shell-extension-blur-my-shell
aur/gnome-shell-extension-blur-my-shell-git

aur/gnome-shell-extension-rounded-window-corners-reborn
aur/gnome-shell-extension-rounded-window-corners-reborn-git

aur/gnome-shell-extension-rounded-window-corners-git
aur/gnome-shell-extension-compiz-alike-magic-lamp-effect-git
aur/gnome-shell-extension-nightthemeswitcher-git

aur/gnome-shell-extension-just-perfection-desktop
aur/gnome-shell-extension-just-perfection-desktop-git

aur/gnome-shell-extension-bluetooth-quick-connect
aur/gnome-shell-extension-hidetopbar-git


# 将应用程序搜索从概述中移除。全局搜索框，类似：search-everything
aur/gnome-shell-extension-search-light-git

clipboard-indicator@tudmotu.com

compiz-windows-effect@hermes83.github.com
wifiqrcode@glerro.pm.me
# 根据自己的喜好配置通知横幅位置和动画。
notification-banner-reloaded@marcinjakubowski.github.com


SettingsCenter@lauinger-clan.de
quick-settings-avatar@d-go

extra/gnome-shell-extension-legacy-theme-auto-switcher
yay -Rcns gnome-shell-extension-legacy-theme-auto-switcher
aur/gnome-shell-extension-wifiqrcode-git
yay -Rcns gnome-shell-extension-wifiqrcode-git
logout

# 查询系统中已安装的以 gnome-shell-extension 为前缀的软件包或扩展
pacman -Q | grep '^gnome-shell-extension'
yay -Q | grep '^gnome-shell-extension'
# 查看所有启用的扩展
gnome-extensions list


# 全局统一GTK主题样式
cat /etc/profile
sudo vim /etc/profile

# 统一将 QT 应用为 GTK 主题。参考 https://wiki.archlinuxcn.org/wiki/统一_Qt_和_GTK_应用程序的外观 文章中的 3.2、3.4 章节
https://wiki.archlinuxcn.org/wiki/GTK
# 参考 github 仓库 QWhiteSurGtkDecorations 文档  https://github.com/FengZhongShaoNian/QWhiteSurGtkDecorations
# 安装Kvantum主题引擎参考 https://cn.linux-terminal.com/?p=7569

https://oo-infty.netlify.app/posts/unify-look-of-linux-gui-frameworks/

# QWhiteSurGtkDecorations是一个 Qt 装饰插件，可以在Gnome wayland上实现类似 GNOME WhiteSur-gtk 主题风格的客户端装饰，适用于Qt 6 和 QT 5 平台。 
# https://wiki.archlinuxcn.org/wiki/%E7%BB%9F%E4%B8%80_Qt_%E5%92%8C_GTK_%E5%BA%94%E7%94%A8%E7%A8%8B%E5%BA%8F%E7%9A%84%E5%A4%96%E8%A7%82#QWhiteSurGtkDecorations
yay -S qwhitesurgtkdecorations-qt5 qwhitesurgtkdecorations-qt6
# 将以下配置添加到用户的环境变量文件（如 ~/.bashrc 或 ~/.profile）：	
echo 'export QT_WAYLAND_DECORATION=whitesur-gtk' >> ~/.profile
source ~/.profile
cat ~/.profile

# /etc/profile 为系统环境变量
# sudo vim /etc/profile
# export QT_WAYLAND_DECORATION=whitesur-gtk
# echo 'export QT_WAYLAND_DECORATION=whitesur-gtk' >> /etc/profile


# Manjaro 官方文档，设置所有Qt应用程序使用GTK字体和主题。参考
# https://wiki.manjaro.org/index.php/Set_all_Qt_app%27s_to_use_GTK%2B_font_%26_theme_settings#Overview
pamac install qt5ct 
echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> ~/.profile
source ~/.profile
echo '[[ -f ~/.profile ]] && . ~/.profile' >> ~/.bash_profile
source ~/.bash_profile
reboot

sudo pacman -S xdg-desktop-portal


# 加入全局环境变量
echo "
export GTK_THEME=WhiteSur-Dark
export QT_WAYLAND_DECORATION=whitesur-gtk
" | sudo tee -a /etc/profile

yay -S libadwaita-demos
# 可视化编辑  GSettings editor for GNOME.类似 主题、图标都可以在该软件可视化配置
yay -S dconf-editor
yay -S gnome-console
yay -S libreoffice-still-zh-cn 
yay -S jetbrains-toolbox code apifox switchhosts google-chrome
yay -S microsoft-edge-stable-bin
yay -S firefox firefox-i18n-zh-cn
yay -S linuxqq wechat baidunetdisk-bin typora
yay -S yesplaymusic tabby
yay -S vagrant virtualbox postgresql
 yay -S neofetch evolution popsicle obsidian
 evolution配置qq邮箱授权码： embwnsuwkdjrebge
 
20.205.243.166	github.com
185.199.110.133	raw.githubusercontent.com
104.24.156.12	download.typora.io
 
# 安装的 rust 自带 cargo 包管理工具    
# curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
sudo pacman -S rust
source "$HOME/.cargo/env"

# 安装 sdkman 工具
curl -s "https://get.sdkman.io" | bash
# 启动SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.4-graal
sdk install java 17.0.11-graal
sdk use java 21.0.4-graal
sdk install maven
sdk install gradle
sdk current

# 安装 bun
# curl -fsSL https://bun.sh/install | bash
# yay -S nodejs npm

# 安装 nvm
sudo pacman -S nvm
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.bashrc
source ~/.bashrc
nvm --help
nvm --version
nvm ls-remote --lts
nvm install --lts
node --version
npm --version
#最新地址 淘宝 NPM 镜像站喊你切换新域名啦!
npm config set registry https://registry.npmmirror.com
npm config get registry

sudo npm install -g bun
source ~/.bashrc
echo 你刚安装的 bun 版本号为： $(bun --version)
### 将 bunfig.toml 作为隐藏文件添加到用户主目录
# 使用 bun 创建一个基于 vue-ts 模板的项目，bun即是一个包管理器也是JS运行时
bun create vite bun-vue3-ts --template vue-ts
bun install
bun run dev
# 是用 bun 创建一个 tauri 2.0 项目
bun create tauri-app
# Template created! To get started run:
cd tauri-app
bun install
# 需要提前安装并配置好 Android Studio  参考 https://tauri.app/zh-cn/start/prerequisites/#android
bun run tauri android init
# For Desktop development, run:
bun run tauri dev
# For Android development, run: 需要提前安装并配置好 Android Studio  参考 https://tauri.app/zh-cn/start/prerequisites/#android
bun run tauri android dev

# 安装 go 直接打开 manjaro自带的应用商城搜索 go 并安装即可
sudo pacman -S go
go version




# 列出所有已安装的 Schema
gsettings list-schemas
# 列出某个 Schema 下的所有键
gsettings list-keys org.gnome.desktop.interface
# 查看键的取值类型和描述
gsettings describe org.gnome.desktop.interface font-name
# 递归列出某个 Schema 的键值（例如 org.gnome.desktop.interface）
gsettings list-recursively org.gnome.desktop.interface

# 参考官方解决方案  https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1059
# Night Theme Switcher 扩展插件配置
# 白天执行命令
gsettings set org.gnome.desktop.interface color-scheme prefer-light
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-light"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Light"
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light'
ln -fs $HOME/.config/gtk-4.0/gtk-Light.css $HOME/.config/gtk-4.0/gtk.css

# 夜晚执行命令
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark"
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark'
ln -fs $HOME/.config/gtk-4.0/gtk-Dark.css $HOME/.config/gtk-4.0/gtk.css

# 字体设置
# 安装思源黑体（简体中文）
sudo pacman -S adobe-source-han-sans-cn-fonts
# 安装思源宋体（简体中文）
sudo pacman -S adobe-source-han-serif-cn-fonts
# 安装 JetBrains Mono 等款字体
sudo pacman -S ttf-jetbrains-mono
# 安装完字体后需要登出才能生效
logout
# 设置界面字体（Inter 或 Noto Sans，字号建议 11-12）（简体中文优先）
gsettings set org.gnome.desktop.interface font-name '思源黑体 CN Medium 12'
# 设置文档字体（Noto Serif，字号建议 12）
gsettings set org.gnome.desktop.interface document-font-name '思源宋体 CN Medium 12'
# 设置等宽字体（编程/终端）（JetBrains Mono，字号建议 13-14）专为开发者设计，连字特性优秀
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono Medium 13'
# 设置窗口标题字体（加粗 Inter，字号稍大）
gsettings set org.gnome.desktop.wm.preferences titlebar-font '思源黑体 CN Bold 12'
gsettings get org.gnome.desktop.wm.preferences titlebar-font

# 抗锯齿与渲染
# 启用抗锯齿（推荐 subpixel RGB 次像素渲染）
# 为 LCD 屏幕启用次像素渲染（RGB 顺序）
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
# 为 OLED 屏幕使用灰度抗锯齿
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
# 微调模式（slight 平衡清晰度与渲染速度）
gsettings set org.gnome.desktop.interface font-hinting 'slight'
# 禁用字体缩放（依赖全局缩放比例，见下文）
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

# 高分屏适配优化，全局缩放比例。对于 16 英寸 2.5K（2560x1600），推荐缩放比例：125% (1.25x) 平衡空间利用和可读性。
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
通过 GNOME 设置 → 显示器/缩放，直接选择 125%

# 显示电量百分比
gsettings set org.gnome.desktop.interface show-battery-percentage true
# 居中显示新建窗口
gsettings set org.gnome.mutter center-new-windows true
# 窗口按钮布局
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'


gsettings get org.gnome.desktop.wm.preferences button-layout
gsettings list-keys org.gnome.mutter
gsettings list-recursively org.gnome.mutter
gsettings list-recursively org.gnome.desktop.interface
gsettings list-recursively org.gnome.desktop.wm.preferences





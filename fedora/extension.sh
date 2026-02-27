#!/bin/bash

# 更新系统并升级所有已安装的包
echo "开始系统..."
sudo dnf update -y && sudo dnf upgrade -y

# https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/installation-guide.html
sudo dnf install -y gnome-browser-connector

# gnome-extensions list
# gnome-extensions install
# dnf search gnome-shell-extension*
# dnf list gnome-shell-extension*

# dnf copr enable huakim/kde-plasma
gnome-shell-extension-gtk4-ding
gnome-shell-extension-desktop-icons
gnome-shell-extension-hidetopbar



# 可以通过查看插件中的 metadata.json 文件内容中的 settings-schema 配置确定插件配置 schema
# nautilus ~/.local/share/gnome-shell/extensions
# 比装用户扩展插件
Add to Desktop
Alphabetical App Grid
Applications Overview Tooltip
App menu is back
Bluetooth Battery Meter
Clipboard Indicator
# Compiz alike magic lamp effect
Coverflow Alt-Tab
Color Picker
ddterm
# 修复 Hide Top Bar 闪跳 BUG
Disable unredirect
Fedora Linux Update Indicator
Gtk4 Desktop Icons NG (DING)
# 用户比装 Gnome 扩展
Hide Top Bar
# 右键点击 panel 上的输入法，点击“首选项”，将“候选词排列方向”改为竖直
IBus Tweaker
Impatience
# 安装 Lunar Calendar 农历 扩展插件需要如下内容
#https://gitlab.gnome.org/Nei/ChineseCalendar/-/archive/20250205/ChineseCalendar-20250205.tar.gz
# tar -xzvf ChineseCalendar-20250205.tar.gz
# cd ChineseCalendar-20250205
# ./install.sh
Lunar Calendar 农历
Logo Menu
Net Speed
Night Theme Switcher
Privacy Quick Settings
Quick Settings Tweaks
Rounded Corners
Rounded Window Corners Reborn
Search Light
# 开启模糊搜索
GNOME Fuzzy App Search
SettingsCenter
Show Desktop Button
# 数值设置为 5
Status Area Horizontal Spacing
Top Bar Organizer
User Avatar In Quick Settings
Weather Clock
Window Gestures

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

# 列出所有已安装的 Schema
# gsettings list-schemas
# gsettings list-recursively org.gnome.shell
# gsettings list-recursively org.gnome.mutter
# gsettings list-recursively org.gnome.desktop.interface
# gsettings list-recursively org.gnome.desktop.wm.preferences
# gsettings list-recursively org.gnome.Settings
# gsettings list-recursively org.gnome.tweaks

# Hide Top Bar
# 递归列出某个 Schema 的键值
# gsettings list-recursively org.gnome.shell.extensions.hidetopbar
# 设置鼠标触发灵敏度（true/false）
gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive true
gsettings set org.gnome.shell.extensions.hidetopbar animation-time-autohide 0.5
gsettings set org.gnome.shell.extensions.hidetopbar animation-time-overview 0.5
# 恢复默认设置
# gsettings reset-recursively org.gnome.shell.extensions.hidetopbar


# Clipboard Indicator
# gsettings list-recursively org.gnome.shell.extensions.clipboard-indicator
gsettings set org.gnome.shell.extensions.clipboard-indicator history-size 10
gsettings set org.gnome.shell.extensions.clipboard-indicator cache-images false
# gsettings reset-recursively org.gnome.shell.extensions.clipboard-indicator


# Gtk4 Desktop Icons NG
# gsettings list-recursively org.gnome.shell.extensions.gtk4-ding
gsettings set org.gnome.shell.extensions.gtk4-ding show-home false
gsettings set org.gnome.shell.extensions.gtk4-ding show-trash false
# gsettings reset-recursively org.gnome.shell.extensions.gtk4-ding

# Status Area Horizontal Spacing
gsettings set org.gnome.shell.extensions.status-area-horizontal-spacing hpadding 5

# Ibus Tweaker
# gsettings list-recursively org.gnome.shell.extensions.ibus-tweaker
gsettings set org.gnome.shell.extensions.ibus-tweaker enable-custom-font true
gsettings set org.gnome.shell.extensions.ibus-tweaker custom-font '思源黑体 CN Medium 12'
gsettings set org.gnome.shell.extensions.ibus-tweaker enable-preset-theme true
gsettings set org.gnome.shell.extensions.ibus-tweaker enable-clip-history true
# 恢复默认设置
# gsettings reset-recursively org.gnome.shell.extensions.ibus-tweaker

# Coverflow Alt-Tab
# 递归列出某个 Schema 的键值
# gsettings list-recursively org.gnome.shell.extensions.coverflowalttab
# gsettings set org.gnome.shell.extensions.coverflowalttab switcher-looping-method 'Flip Stack'
gsettings set org.gnome.shell.extensions.coverflowalttab switcher-looping-method 'Carousel'
# 设置背景黯淡因素，越大越暗
gsettings set org.gnome.shell.extensions.coverflowalttab dim-factor 0.0
gsettings set org.gnome.shell.extensions.coverflowalttab animation-time 0.5
# gsettings get org.gnome.shell.extensions.coverflowalttab easing-function
# gsettings set org.gnome.shell.extensions.coverflowalttab easing-function 'ease-out-quad'
# gsettings set org.gnome.shell.extensions.coverflowalttab easing-function 'ease-out-cubic'
# gsettings set org.gnome.shell.extensions.coverflowalttab easing-function 'ease-out-quart'
gsettings set org.gnome.shell.extensions.coverflowalttab easing-function 'ease-out-quint'
# gsettings set org.gnome.shell.extensions.coverflowalttab easing-function 'ease-out-sine'
# gsettings set org.gnome.shell.extensions.coverflowalttab preview-to-monitor-ratio 0.75
# gsettings get org.gnome.shell.extensions.coverflowalttab preview-to-monitor-ratio
# gsettings reset org.gnome.shell.extensions.coverflowalttab preview-to-monitor-ratio
# 恢复默认设置
# gsettings reset-recursively org.gnome.shell.extensions.coverflowalttab

# ddterm，默认的切换快捷键 F12
# gsettings list-recursively com.github.amezin.ddterm
gsettings set com.github.amezin.ddterm background-opacity 1.0
gsettings set com.github.amezin.ddterm hide-animation-duration 0.3
gsettings set com.github.amezin.ddterm show-animation-duration 0.2
# gsettings set com.github.amezin.ddterm window-size 0.6
gsettings set com.github.amezin.ddterm hide-when-focus-lost true
gsettings set com.github.amezin.ddterm hide-window-on-esc true
# gsettings reset-recursively com.github.amezin.ddterm

# Impatience，默认是 0.75
# gsettings list-recursively org.gnome.shell.extensions.net.gfxmonk.impatience
gsettings set org.gnome.shell.extensions.net.gfxmonk.impatience speed-factor 1.0
# gsettings reset-recursively org.gnome.shell.extensions.net.gfxmonk.impatience

# Lunar Calendar 农历
# gsettings list-recursively org.gnome.shell.extensions.lunar-calendar
gsettings set org.gnome.shell.extensions.lunar-calendar jrrilinei true
gsettings set org.gnome.shell.extensions.lunar-calendar show-time false
gsettings set org.gnome.shell.extensions.lunar-calendar yuyan 0
# gsettings reset-recursively org.gnome.shell.extensions.lunar-calendar


# Quick Settings Tweaks
# 控制 GNOME 顶部面板快捷设置菜单（Quick Settings）的弹出样式和动画效果
# gsettings list-recursively org.gnome.shell.extensions.quick-settings-tweaks
# 启用或禁用 覆盖式菜单样式（即快捷设置面板以独立浮层形式弹出，而非传统的下拉样式）。
gsettings set org.gnome.shell.extensions.quick-settings-tweaks overlay-menu-enabled true
# 控制菜单弹出/关闭的 动画时长（毫秒）推荐 200-500（值越大动画越慢）。
gsettings set org.gnome.shell.extensions.quick-settings-tweaks overlay-menu-animate-duration 500
gsettings set org.gnome.shell.extensions.quick-settings-tweaks menu-animation-enabled true
gsettings set org.gnome.shell.extensions.quick-settings-tweaks menu-animation-close-duration 500
gsettings set org.gnome.shell.extensions.quick-settings-tweaks menu-animation-open-duration 500
# gsettings reset-recursively org.gnome.shell.extensions.quick-settings-tweaks


# Search Light
# gsettings list-recursively org.gnome.shell.extensions.search-light
gsettings set org.gnome.shell.extensions.search-light shortcut-search "['<Super>q']"
# gsettings set org.gnome.shell.extensions.search-light show-panel-icon true
gsettings set org.gnome.shell.extensions.search-light border-radius 2
gsettings set org.gnome.shell.extensions.search-light animation-speed 200.0
gsettings set org.gnome.shell.extensions.search-light background-color (0.0, 0.0, 0.0, 0.25)
gsettings set org.gnome.shell.extensions.search-light blur-brightness 0.6
gsettings set org.gnome.shell.extensions.search-light blur-sigma 50.0
gsettings set org.gnome.shell.extensions.search-light blur-background true
# gsettings set org.gnome.shell.extensions.search-light background-color (1.0, 1.0, 1.0, 0.25)
# gsettings reset-recursively org.gnome.shell.extensions.search-light

# Logo Menu
# gsettings list-recursively org.gnome.shell.extensions.logo-menu
gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-image 1
gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-size 20
gsettings set org.gnome.shell.extensions.logo-menu show-activities-button false
# 在 Just Profect 中也同时将 activities 隐藏
gsettings set org.gnome.shell.extensions.just-perfection activities-button false
# gsettings reset-recursively org.gnome.shell.extensions.logo-menu

# Top Bar Organizer
# gsettings list-recursively org.gnome.shell.extensions.top-bar-organizer
gsettings set org.gnome.shell.extensions.top-bar-organizer left-box-order "['LogoMenu', 'appMenu']"
gsettings set org.gnome.shell.extensions.top-bar-organizer center-box-order "['dateMenu']"
gsettings set org.gnome.shell.extensions.top-bar-organizer right-box-order "['appindicator-kstatusnotifieritem-tray-icon tray app', 'netspeed@alynx.one', 'workspace-indicator', 'drive-menu', 'ddterm', 'FedoraUpdateIndicator', 'color-picker@tuberry', 'Show Desktop Button Indicator', 'clipboardIndicator', 'screenRecording', 'screenSharing', 'dwellClick', 'a11y', 'keyboard', 'quickSettings']"
# gsettings set org.gnome.shell.extensions.top-bar-organizer hide "[]"
# gsettings set org.gnome.shell.extensions.top-bar-organizer show "[]"
# gsettings reset-recursively org.gnome.shell.extensions.top-bar-organizer


# SettingsCenter
# gsettings list-recursively org.gnome.shell.extensions.SettingsCenter
gsettings set org.gnome.shell.extensions.SettingsCenter label-menu '快捷应用'
gsettings set org.gnome.shell.extensions.SettingsCenter show-systemindicator true
gsettings set org.gnome.shell.extensions.SettingsCenter items '优化;org.gnome.tweaks.desktop;1;org.gnome.tweaks|扩展;org.gnome.Extensions.desktop;1;org.gnome.Extensions|扩展管理器;com.mattjakeman.ExtensionManager.desktop;1;com.mattjakeman.ExtensionManager|密码和密钥;org.gnome.seahorse.Application.desktop;1;org.gnome.seahorse.Application'
# gsettings reset-recursively org.gnome.shell.extensions.SettingsCenter


# Rounded Window Corners Reborn
# gsettings list-recursively org.gnome.shell.extensions.rounded-window-corners-reborn
# 跳过Libadwaita/Libhandy应用（避免与GTK4应用冲突）
gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn skip-libadwaita-app true
gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn skip-libhandy-app true
gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn tweak-kitty-terminal true
gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn enable-preferences-entry true
# 全局圆角设置（核心参数）
# gsettings get org.gnome.shell.extensions.rounded-window-corners-reborn global-rounded-corner-settings
gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn global-rounded-corner-settings "{'padding': <{'left': uint32 1, 'right': 1, 'top': 1, 'bottom': 1}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}"
# 解决 jetbrains 软件的边框问题
gsettings set org.gnome.shell.extensions.rounded-window-corners-reborn custom-rounded-corner-settings "{'jetbrains-idea': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>, 'jetbrains-goland': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>, 'jetbrains-webstorm': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>, 'jetbrains-rustrover': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>, 'jetbrains-datagrip': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>, 'jetbrains-pycharm': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>, 'jetbrains-studio': <{'padding': <{'left': uint32 2, 'right': 2, 'top': 2, 'bottom': 2}>, 'keepRoundedCorners': <{'maximized': true, 'fullscreen': true}>, 'borderRadius': <uint32 12>, 'smoothing': <0.2>, 'borderColor': <(1.0, 1.0, 1.0, 0.0)>, 'enabled': <true>}>}"
# gsettings reset-recursively org.gnome.shell.extensions.rounded-window-corners-reborn



# Night Theme Switcher
# 递归列出某个 Schema 的键值
# gsettings list-recursively org.gnome.shell.extensions.nightthemeswitcher.commands
# gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunrise
# gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunset
gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands enabled true
# 透明版本
gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunrise "gsettings set org.gnome.desktop.interface color-scheme 'default'\ngsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1\ngsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2\ngsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(153,193,241)'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1"
gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunset "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'\ngsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 2\ngsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 3\ngsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(26,95,180)'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 2"

# 不透明版本
gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunrise "gsettings set org.gnome.desktop.interface color-scheme 'default'\ngsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1\ngsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2\ngsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(153,193,241)'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1"
gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunset "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'\ngsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 2\ngsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 3\ngsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(26,95,180)'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 2"


gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'
gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2
gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(153,193,241)'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 2
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 3
gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(26,95,180)'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 2



# 清理无用的包和缓存
echo "清理未使用的软件包和缓存..."
sudo dnf autoremove -y
sudo dnf clean all

echo "系统配置成功完成!"

# 优质推荐 Gnome 扩展
Add to Desktop
Bluetooth Quick Connect
Clipboard Indicator
# Compiz windows effect
Compiz alike magic lamp effect
ddterm
Desktop Cube
# Open Bar
# Dash2Dock Animated
# Extension List
Gtk4 Desktop Icons NG (DING)
# 安装 Lunar Calendar 农历 扩展插件需要如下内容
#https://gitlab.gnome.org/Nei/ChineseCalendar/-/archive/20250205/ChineseCalendar-20250205.tar.gz
# tar -xzvf ChineseCalendar-20250205.tar.gz
# cd ChineseCalendar-20250205
# ./install.sh
Lunar Calendar 农历
IBus Tweaker
Night Theme Switcher
Quick Settings Tweaks
Search Light
SettingsCenter
Top Bar Organizer
Fedora Linux Update Indicator
Window Gestures
Show Desktop Button
# Weather O'Clock
VirtualBox applet
# https://github.com/Sominemo/Fildem-Gnome-45
App menu is back
Custom Window Controls
# https://extensions.gnome.org/extension/6300/custom-window-controls/
# https://github.com/icedman/custom-window-controls
Custom Command Toggle
Color Picker
Desktop Widgets
Bluetooth Battery Meter
Astra Monitor
Applications Overview Tooltip
Hide Universal Access
Customize Clock on Lock Screen


nautilus ~/.local/share/gnome-shell/extensions
sudo dnf install -y just gettext
# gnome-extensions list
# 通过源码安装的Gnome扩展插件需要重新登陆才有效
# Hide Top Bar
git clone https://gitcode.com/gh_mirrors/hi/hidetopbar.git --depth=1
cd hidetopbar
make
gnome-extensions install ./hidetopbar.zip

# Rounded Window Corners Reborn
git clone https://gitcode.com/gh_mirrors/rou/rounded-window-corners.git --depth=1
cd rounded-window-corners
just install

git clone https://github.com/flexagoon/rounded-window-corners --depth=1
cd rounded-window-corners
just install

# Rounded Corners
git clone https://github.com/lennart-k/gnome-rounded-corners.git --depth=1
cd gnome-rounded-corners
make
gnome-extensions install ./hidetopbar.zip
gnome-extensions enable hidetopbar@mathieu.bidon.ca


gnome-extensions enable hidetopbar@mathieu.bidon.ca
gnome-extensions enable rounded-window-corners@fxgn


# 知名禁书
# git clone https://github.com/michaelfan0310/deep-library.git --depth=1

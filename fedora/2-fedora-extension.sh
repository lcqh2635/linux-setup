#!/bin/bash
# ==============================================================================
# 脚本名称: 2-ubuntu-extension.sh
# 功能描述：自动安装并配置常用 gnome shell 扩展
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x 2-ubuntu-extension.sh && ./2-ubuntu-extension.sh
# ==============================================================================

# Ubuntu 操作系统 ISO 阿里云和中科大加速下载网址：
# https://mirrors.aliyun.com/ubuntu-cdimage/releases/
# https://mirrors.ustc.edu.cn/ubuntu-cdimage/releases/
# cd ~/下载 && git clone https://cdn.gh-proxy.org/https://github.com/lcqh2635/linux-setup.git
# cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push

# ------------------------------------------------------------------------------
# 1. 安全与规范设置 (Best Practices)
# ------------------------------------------------------------------------------
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail

# apt list gnome-shell-extension*
# apt list gnome-shell-ubuntu-extensions*
sudo apt install -y \
gnome-shell-extension-user-theme \
gnome-shell-extension-alphabetical-grid \
gnome-shell-extension-auto-move-windows \
gnome-shell-extension-drive-menu \
gnome-shell-extension-light-style \
gnome-shell-extension-workspace-indicator \
gnome-shell-extension-desktop-icons-ng \
gnome-shell-extension-prefs

# gnome-extensions 直接使用可以查看扩展的所有命令的作用
# help      打印帮助
# version   打印版本
# enable    启用扩展
# disable   禁用扩展
# reset     重置扩展
# uninstall 卸载扩展
# list      列出扩展
# info      显示扩展信息
# show      显示扩展信息
# prefs     打开扩展首选项
# create    创建扩展
# pack      打包扩展
# install   安装扩展包
# gnome-extensions help
# gnome-extensions list	列出可安装的扩展插件

# 列出所有系统级扩展
# gnome-extensions list --system
# 查看所有系统级扩展的文件目录
# nautilus admin:/usr/share/gnome-shell/extensions
# 列出所有用户级扩展
# gnome-extensions list --user
# 查看所有用户级扩展的文件目录
# nautilus ~/.local/share/gnome-shell/extensions

# Add to Desktop
# Applications Overview Tooltip
# App menu is back
# ArcMenu
# Battery Health Charging
# Bing Wallpape
# Bluetooth Battery Meter
# Blur my Shell
# Burn My Windows
# Caffeine
# CHC-E (Custom Hot Corners - Extended)
# Clipboard Indicator
# Compiz alike magic lamp effect
# Compiz windows effect
# Coverflow Alt-Tab
# ddterm
# Dash to Dock
# Debian Linux Update Indicator
# Disable Unredirect
# Do Not Disturb While Screen Sharing Or Recording
# Extension List
# Fly-Pie
# GNOME Fuzzy App Search
# gTile
# Gtk4 Desktop Icons NG (DING)
# Hide Top Bar
# In Picture
# Lock Keys
# Lunar Calendar 农历
# Night Theme Switcher
# Privacy Quick Settings
# Quick Settings Tweaks
# Rounded Corners
# Rounded Window Corners Reborn
# Screencast extra Feature
# Screen word translate
# Search Light
# Show Desktop Button
# Status Area Horizontal Spacing
# Top Bar Organizer
# User Avatar In Quick Settings
# Weather O'Clock
# Wifi QR Code

# 应用默认配置
apply_default_settings() {
    print_info "正在应用默认配置..."

    # 系统外观主题和Gnome扩展插件优化
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
    
    print_success "默认配置应用完成！"
}

# 更新系统
update_system() {
    print_info "正在更新系统软件包..."
    sudo dnf upgrade -y
    if [ $? -eq 0 ]; then
        print_success "系统更新完成！"
    else
        print_error "系统更新失败！"
    fi
}

# 配置 GNOME 扩展
configure_gnome_extensions() {

    # gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
    # gsettings list-schemas
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
    # gsettings list-recursively org.gnome.desktop.interface
    # gsettings list-recursively org.gnome.desktop.wm.preferences
    # 列出所有系统级扩展
    # gnome-extensions list --system
    # 查看所有系统级扩展的文件目录
    # nautilus admin:/usr/share/gnome-shell/extensions
    # dnf list gnome-shell-extension*
    # ------------------------------------------------------------------------------
    print_info "正在启用并配置 GNOME 扩展..."
    # 启用系统 GNOME 扩展
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable blur-my-shell@aunetx
    gnome-extensions enable just-perfection-desktop@just-perfection
    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
    gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable caffeine@patapon.info
    gnome-extensions enable no-overview@fthx
    gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
    gnome-extensions enable light-style@gnome-shell-extensions.gcampax.github.com
    
    # 递归列出某个 Schema 的键值（例如 org.gnome.shell.extensions.dash-to-dock）
    # gsettings list-recursively org.gnome.shell.extensions.dash-to-dock
    print_info "正在配置Dash to Dock..."
    # 配置 Dash to Dock (自定义Dock栏)
    # 取消面板模式，改为类似 MacOS 系统的 Dock 栏模式
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    # 智能隐藏 Dock 栏
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.5
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
    gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
    gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
    # 收缩 Dash
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DASHES'
    gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true
    # gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 1.0
    # 恢复默认设置
    # gsettings reset-recursively org.gnome.shell.extensions.dash-to-dock
    # 默认主题色/强调色，蓝色
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(153,193,241)'
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(26,95,180)'
    # 绿色
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(143,240,164)'
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(38,162,105)'
    # 紫色
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(220,138,221)'
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(97,53,131)'
    # 将 panel 一同切换为紫色
    # gsettings set org.gnome.shell.extensions.blur-my-shell pipelines "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_96853877854398'>, 'params': <@a{sv} {}>}>]>}, 'pipeline_panel': {'name': <'blur panel'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_75271904090067'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'color'>, 'id': <'effect_36769853581304'>, 'params': <{'color': <(0.9, 0.4, 0.8, 0.3)>}>}>]>}, 'pipeline_dock': {'name': <'blur dock'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_05617311186362'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'corner'>, 'id': <'effect_78081442948590'>, 'params': <{'radius': <20>}>}>]>}}"
    # 白色
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(255,255,255)'
    # gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(154,153,150)'
    
    # 配置 Blur My Shell (透明模糊效果)
    # gsettings list-recursively org.gnome.shell.extensions.blur-my-shell
    # gsettings list-recursively org.gnome.shell.extensions.blur-my-shell.panel
    # gsettings list-recursively org.gnome.shell.extensions.blur-my-shell.applications
    # 设置自定义模糊效果
    # gsettings get org.gnome.shell.extensions.blur-my-shell pipelines
    # gsettings reset-recursively org.gnome.shell.extensions.blur-my-shell pipelines
    gsettings set org.gnome.shell.extensions.blur-my-shell pipelines "{'pipeline-overview': {'name': <'pipeline overview'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_24286504481826'>, 'params': <@a{sv} {}>}>]>}, 'pipeline-panel-light': {'name': <'pipeline panel light'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <1>, 'unscaled_radius': <100>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <24>, 'corners_bottom': <false>}>}>, <{'type': <'color'>, 'id': <'effect_11444492989407'>, 'params': <{'color': <(1.0, 1.0, 1.0, 0.2)>}>}>, <{'type': <'noise'>, 'id': <'effect_02421618172361'>, 'params': <{'noise': <0.20000000000000001>, 'lightness': <2>}>}>]>}, 'pipeline-panel-dark': {'name': <'pipeline panel dark'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_34582829524533'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'corner'>, 'id': <'effect_01633318478434'>, 'params': <{'corners_bottom': <false>, 'radius': <24>}>}>, <{'type': <'color'>, 'id': <'effect_61396509891604'>, 'params': <{'color': <(0.0, 0.0, 0.0, 0.2)>}>}>, <{'type': <'noise'>, 'id': <'effect_16736138416410'>, 'params': <{'lightness': <2>, 'noise': <0.20000000000000001>}>}>]>}, 'pipeline-dock-light': {'name': <'pipeline dock light'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_69102858487382'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'corner'>, 'id': <'effect_89248773469157'>, 'params': <{'radius': <24>, 'corners_bottom': <true>}>}>, <{'type': <'color'>, 'id': <'effect_34422355468895'>, 'params': <{'color': <(1.0, 1.0, 1.0, 0.2)>}>}>, <{'type': <'noise'>, 'id': <'effect_48521965919475'>, 'params': <{'noise': <0.20000000000000001>, 'lightness': <2>}>}>]>}, 'pipeline-dock-dark': {'name': <'pipeline dock dark'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_63269999366132'>, 'params': <{'brightness': <1>, 'unscaled_radius': <100>}>}>, <{'type': <'corner'>, 'id': <'effect_88027249213595'>, 'params': <{'radius': <24>}>}>, <{'type': <'color'>, 'id': <'effect_67188885938383'>, 'params': <{'color': <(0.0, 0.0, 0.0, 0.2)>}>}>, <{'type': <'noise'>, 'id': <'effect_75924425574829'>, 'params': <{'lightness': <2>, 'noise': <0.20000000000000001>}>}>]>}}"
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline-panel-light'
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel unblur-in-overview true
    gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility true
    gsettings set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline-overview'
    gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2
    gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline-dock-light'
    gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1
    # 模糊强度（50=中等模糊，过高会显脏）
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications sigma 50
    # 亮度微调（1.0=原始亮度，建议保持）
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications brightness 1.0
    # 基础透明度（220/255≈86%，平衡通透与朦胧感）
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications opacity 220
    # 启用应用程序窗口模糊
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur true
    # 使聚焦窗口不透明
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications dynamic-opacity false
    # 禁用在Overview（超级键视图）中模糊（避免卡顿）
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur-on-overview false
    # 不强制所有应用模糊（避免兼容性问题）
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications enable-all false
    # 应用毛玻璃效果的应用列表
    gsettings set org.gnome.shell.extensions.blur-my-shell.applications whitelist "['org.gnome.Settings', 'org.gnome.Software', 'org.gnome.TextEditor', 'org.gnome.Ptyxis', 'org.gnome.SystemMonitor', 'org.gnome.tweaks', 'org.gnome.Extensions', 'com.mattjakeman.ExtensionManager']"
    gsettings set org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab blur false
    # gsettings reset-recursively org.gnome.shell.extensions.blur-my-shell

    print_info "正在配置Just Perfection..."
    # Just Perfection（微调 GNOME Shell 的细节，隐藏冗余元素、调整动画速度等）
    # gsettings list-recursively org.gnome.shell.extensions.just-perfection
    gsettings set org.gnome.shell.extensions.just-perfection accessibility-menu false
    gsettings set org.gnome.shell.extensions.just-perfection activities-button false
    gsettings set org.gnome.shell.extensions.just-perfection world-clock false
    gsettings set org.gnome.shell.extensions.just-perfection events-button false
    gsettings set org.gnome.shell.extensions.just-perfection weather false
    # 概览中工作区切换区缩略图，此处设置为隐藏
    # gsettings set org.gnome.shell.extensions.just-perfection workspace false
    gsettings set org.gnome.shell.extensions.just-perfection window-demands-attention-focus true
    gsettings set org.gnome.shell.extensions.just-perfection startup-status 0
    gsettings set org.gnome.shell.extensions.just-perfection animation 7
    # gsettings reset-recursively org.gnome.shell.extensions.just-perfection
    
    # Auto Move Windows
    # gsettings list-recursively org.gnome.shell.extensions.auto-move-windows
    gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['jetbrains-toolbox.desktop:1', 'org.gnome.TextEditor.desktop:2', 'org.gnome.Papers.desktop:2', 'org.mozilla.firefox.desktop:3', 'com.google.Chrome.desktop:3']"
    # gsettings reset-recursively org.gnome.shell.extensions.auto-move-windows
    
    # Background Logo
    # gsettings list-recursively org.fedorahosted.background-logo-extension
    gsettings set org.fedorahosted.background-logo-extension logo-always-visible true
    # gsettings reset-recursively org.fedorahosted.background-logo-extension
    
    # gsettings list-recursively org.gnome.shell.extensions.forge
    # 默认不启用窗口平铺模式
    # gsettings set org.gnome.shell.extensions.forge tiling-mode-enabled false
    # gnome-extensions enable forge@jmmaranan.com
    # ------------------------------------------------------------------------------
    
    
    # 列出所有用户级扩展
    # gnome-extensions list --user
    # 查看所有用户级扩展的文件目录
    # nautilus ~/.local/share/gnome-shell/extensions
    # ------------------------------------------------------------------------------
    # 用户 GNOME 扩展
    gnome-extensions enable Rounded_Corners@lennart-k
    gnome-extensions enable rounded-window-corners@fxgn
    gnome-extensions enable hidetopbar@mathieu.bidon.ca
    gnome-extensions enable add-to-desktop@tommimon.github.com
    gnome-extensions enable gtk4-ding@smedius.gitlab.com
    gnome-extensions enable appmenu-is-back@fthx
    gnome-extensions enable Bluetooth-Battery-Meter@maniacx.github.com
    gnome-extensions enable clipboard-indicator@tudmotu.com
    gnome-extensions enable compiz-alike-magic-lamp-effect@hermes83.github.com
    gnome-extensions enable CoverflowAltTab@palatis.blogspot.com
    gnome-extensions enable ddterm@amezin.github.com
    gnome-extensions enable disable-unredirect@exeos
    gnome-extensions enable ibus-tweaker@tuberry.github.com
    gnome-extensions enable logomenu@aryan_k
    gnome-extensions enable nightthemeswitcher@romainvigier.fr
    gnome-extensions enable quick-settings-tweaks@qwreey
    gnome-extensions enable search-light@icedman.github.com
    gnome-extensions enable show-desktop-button@amivaleo
    gnome-extensions enable status-area-horizontal-spacing@mathematical.coffee.gmail.com
    gnome-extensions enable top-bar-organizer@julian.gse.jsts.xyz
    gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
    
    print_info "正在配置Hide Top Bar..."
    # 配置 Hide Top Bar
    # 递归列出某个 Schema 的键值
    # gsettings list-recursively org.gnome.shell.extensions.hidetopbar
    # 设置鼠标触发灵敏度（true/false）
    gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive true
    gsettings set org.gnome.shell.extensions.hidetopbar animation-time-autohide 0.5
    gsettings set org.gnome.shell.extensions.hidetopbar animation-time-overview 0.5
    # 窗口被激活时不要总是显示 panel
    gsettings set org.gnome.shell.extensions.hidetopbar enable-active-window false
    # 恢复默认设置
    # gsettings reset-recursively org.gnome.shell.extensions.hidetopbar
    
    print_info "正在配置Gtk4 Desktop Icons NG..."
    # Gtk4 Desktop Icons NG
    # gsettings list-recursively org.gnome.shell.extensions.gtk4-ding
    gsettings set org.gnome.shell.extensions.gtk4-ding show-home false
    gsettings set org.gnome.shell.extensions.gtk4-ding show-trash false
    gsettings set org.gnome.shell.extensions.gtk4-ding show-volumes false
    # gsettings reset-recursively org.gnome.shell.extensions.gtk4-ding
    
    print_info "正在配置Clipboard Indicator..."
    # Clipboard Indicator
    # gsettings list-recursively org.gnome.shell.extensions.clipboard-indicator
    gsettings set org.gnome.shell.extensions.clipboard-indicator history-size 10
    gsettings set org.gnome.shell.extensions.clipboard-indicator cache-images false
    # gsettings reset-recursively org.gnome.shell.extensions.clipboard-indicator

    print_info "正在配置Coverflow Alt-Tab..."
    # Coverflow Alt-Tab
    # 递归列出某个 Schema 的键值
    # gsettings list-recursively org.gnome.shell.extensions.coverflowalttab
    # gsettings set org.gnome.shell.extensions.coverflowalttab switcher-looping-method 'Flip Stack'
    gsettings set org.gnome.shell.extensions.coverflowalttab switcher-looping-method 'Carousel'
    gsettings set org.gnome.shell.extensions.coverflowalttab hide-panel false
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
    
    print_info "正在配置ddterm..."
    # ddterm，默认的切换快捷键 F12
    # gsettings list-recursively com.github.amezin.ddterm
    gsettings set com.github.amezin.ddterm background-opacity 1.0
    gsettings set com.github.amezin.ddterm hide-animation-duration 0.3
    gsettings set com.github.amezin.ddterm show-animation-duration 0.2
    # gsettings set com.github.amezin.ddterm window-size 0.6
    gsettings set com.github.amezin.ddterm hide-when-focus-lost true
    gsettings set com.github.amezin.ddterm hide-window-on-esc true
    # gsettings reset-recursively com.github.amezin.ddterm
    
    print_info "正在配置Ibus Tweaker..."
    # 配置 Ibus Tweaker
    # gsettings list-recursively org.gnome.shell.extensions.ibus-tweaker
    gsettings set org.gnome.shell.extensions.ibus-tweaker enable-custom-font true
    gsettings set org.gnome.shell.extensions.ibus-tweaker custom-font '思源黑体 CN Medium 12'
    gsettings set org.gnome.shell.extensions.ibus-tweaker enable-preset-theme true
    gsettings set org.gnome.shell.extensions.ibus-tweaker enable-clip-history true
    # 恢复默认设置
    # gsettings reset-recursively org.gnome.shell.extensions.ibus-tweaker
    
    # Logo Menu
    # gsettings list-recursively org.gnome.shell.extensions.logo-menu
    gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-image 1
    gsettings set org.gnome.shell.extensions.logo-menu menu-button-icon-size 20
    gsettings set org.gnome.shell.extensions.logo-menu show-activities-button false
    # 在 Just Profect 中也同时将 activities 隐藏
    gsettings set org.gnome.shell.extensions.just-perfection activities-button false
    # gsettings reset-recursively org.gnome.shell.extensions.logo-menu
    
    print_info "正在配置Night Theme Switcher..."
    # 递归列出某个 Schema 的键值
    # gsettings list-recursively org.gnome.shell.extensions.nightthemeswitcher.commands
    # gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunrise
    # gsettings get org.gnome.shell.extensions.nightthemeswitcher.commands sunset
    gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands enabled true
    # 使用 WhiteSur-*-solid 不透明 GTK 主题版本
    gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunrise "gsettings set org.gnome.desktop.interface color-scheme 'default'\ngsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1\ngsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2\ngsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(153,193,241)'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1"
    gsettings set org.gnome.shell.extensions.nightthemeswitcher.commands sunset "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'\ngsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'\ngsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'\ngsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'\ngsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 2\ngsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 3\ngsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(26,95,180)'\ngsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 2"

    # Quick Settings Tweaks
    # 控制 GNOME 顶部面板快捷设置菜单（Quick Settings）的弹出样式和动画效果
    # gsettings list-recursively org.gnome.shell.extensions.quick-settings-tweaks
    # 启用或禁用 覆盖式菜单样式（即快捷设置面板以独立浮层形式弹出，而非传统的下拉样式）。
    gsettings set org.gnome.shell.extensions.quick-settings-tweaks overlay-menu-enabled true
    # gsettings reset-recursively org.gnome.shell.extensions.quick-settings-tweaks

    print_info "正在配置Search Light..."
    # gsettings list-recursively org.gnome.shell.extensions.search-light
    gsettings set org.gnome.shell.extensions.search-light shortcut-search "['<Super>q']"
    # gsettings set org.gnome.shell.extensions.search-light show-panel-icon true
    # gsettings get org.gnome.shell.extensions.search-light border-radius
    gsettings set org.gnome.shell.extensions.search-light border-radius 6
    gsettings set org.gnome.shell.extensions.search-light animation-speed 200.0
    gsettings set org.gnome.shell.extensions.search-light background-color "(0.0, 0.0, 0.0, 0.9)"
    gsettings set org.gnome.shell.extensions.search-light blur-brightness 0.6
    gsettings set org.gnome.shell.extensions.search-light blur-sigma 50.0
    gsettings set org.gnome.shell.extensions.search-light blur-background true
    # gsettings set org.gnome.shell.extensions.search-light background-color (1.0, 1.0, 1.0, 0.25)
    # gsettings reset-recursively org.gnome.shell.extensions.search-light

    print_info "正在配置Show Desktop Button..."
    # gsettings list-recursively org.gnome.shell.extensions.show-desktop-button
    # 不隐藏当前激活的焦点窗口，他的全部隐藏
    gsettings set org.gnome.shell.extensions.show-desktop-button keep-focused true
    gsettings set org.gnome.shell.extensions.show-desktop-button shortcut "['<Super>h']"
    # gsettings reset-recursively org.gnome.shell.extensions.show-desktop-button

    print_info "正在配置Status Area Horizontal Spacing..."
    # Status Area Horizontal Spacing
    # gsettings list-recursively org.gnome.shell.extensions.status-area-horizontal-spacing
    gsettings set org.gnome.shell.extensions.status-area-horizontal-spacing hpadding 5
    # gsettings reset-recursively org.gnome.shell.extensions.status-area-horizontal-spacing
    
    print_info "正在配置Top Bar Organizer..."
    # Top Bar Organizer
    # gsettings list-recursively org.gnome.shell.extensions.top-bar-organizer
    gsettings set org.gnome.shell.extensions.top-bar-organizer left-box-order "['ArcMenu', 'apps-menu', 'places-menu', 'vitalsMenu', 'appmenu-indicator']"
    # gsettings set org.gnome.shell.extensions.top-bar-organizer center-box-order "['dateMenu']"
    gsettings set org.gnome.shell.extensions.top-bar-organizer right-box-order "['workspace-indicator', 'flag', 'FedoraUpdateIndicator', 'Show Desktop Button Indicator', 'ddterm', 'copyous@boerdereinar.dev', 'lockkeys', 'drive-menu', 'screenRecording', 'screenSharing', 'dwellClick', 'a11y', 'keyboard', 'quickSettings']"
    # gsettings set org.gnome.shell.extensions.top-bar-organizer hide "[]"
    # gsettings set org.gnome.shell.extensions.top-bar-organizer show "[]"
    # gsettings reset-recursively org.gnome.shell.extensions.top-bar-organizer
    
    print_success "GNOME 扩展启用并配置完成！"
    # ------------------------------------------------------------------------------
}

# gsettings get org.gnome.shell.extensions.blur-my-shell pipelines


    gsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline_panel_light'
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
    gsettings set org.gnome.shell.extensions.blur-my-shell.panel unblur-in-overview true
    gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility true
    gsettings set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline_overview'
    gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2
    gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline_dock_light'



gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-light.jpg"
gsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline_panel_light'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline_dock_light'
gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text false

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-dark.jpg"
gsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline_panel_dark'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline_dock_dark'
gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true

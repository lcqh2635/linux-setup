#!/bin/bash

# Fedora GNOME 42 主题美化脚本
# 功能：自动安装并配置常用主题、图标、光标和扩展
# 使用方法：chmod +x beautify.sh && ./beautify.sh

# gsettings list-schemas
# gsettings list-recursively org.gnome.shell
# gsettings list-recursively org.gnome.mutter
# gsettings list-recursively org.gnome.desktop.interface
# gsettings list-recursively org.gnome.desktop.wm.preferences
# gsettings list-recursively  org.gnome.Settings

# gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略。
# 设置新窗口居中显示
gsettings set org.gnome.mutter center-new-windows true
# 设置电量百分比
gsettings set org.gnome.desktop.interface show-battery-percentage true
# 显示星期几
gsettings set org.gnome.desktop.interface clock-show-weekday true
# 显示秒
# gsettings set org.gnome.desktop.interface clock-show-seconds true
# 设置窗口按钮位置 (右)
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
# 开启夜灯
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
# 设置夜灯温度（色温，范围 1000~10000，默认约 2700 色温严重偏黄，越小越黄）
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
# gsettings get org.gnome.settings-daemon.plugins.color night-light-temperature
# gsettings reset org.gnome.settings-daemon.plugins.color night-light-temperature

# gsettings set org.gnome.shell.weather locations "[<(uint32 2, <('Shenzhen', 'ZGSZ', true, [(0.39357174632472131, 1.9914206765255298)], @a(dd) [])>)>, <(uint32 2, <('Guangzhou', 'ZGGG', false, [(0.4043346158631172, 1.9780398131091426)], [(0.40346195123711998, 1.9765853778835782)])>)>]"


# 更新系统并升级所有已安装的包
echo "开始更新系统并升级所有已安装的包..."
sudo dnf update -y && sudo dnf upgrade -y

# 安装字体
echo "正在安装额外字体..."
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

# gsettings reset org.gnome.desktop.interface font-name
# gsettings reset org.gnome.desktop.interface document-font-name
# gsettings reset org.gnome.desktop.interface monospace-font-name
# gsettings reset org.gnome.desktop.wm.preferences titlebar-font

# 安装 ubuntu 的声音主题
# dnf list *-sound-theme
sudo dnf install -y yaru-sound-theme
gsettings set org.gnome.desktop.sound theme-name 'Yaru'
# 系统级目录（所有用户生效）	ls /usr/share/sounds/gnome/default/alerts
# /usr/share/sounds/gnome/default/alerts/
# 用户级目录（仅当前用户生效）	ls ~/.local/share/sounds/
# ~/.local/share/sounds/

# 安装必要依赖
echo "正在安装图形界面优化工具..."
# 图形界面工具: gnome-tweaks, gnome-extensions-app
sudo dnf install -y gnome-tweaks gnome-extensions-app
flatpak install -y flathub com.mattjakeman.ExtensionManager

# dnf list gnome-shell-extension*
# 卸载自带无用 Gnome 扩展插件
echo "卸载自带无用 Gnome 扩展插件..."
sudo dnf remove -y \
gnome-shell-extension-apps-menu \
gnome-shell-extension-places-menu \
gnome-shell-extension-window-list \
gnome-shell-extension-launch-new-instance

# 安装常用GNOME扩展
echo "正在安装常用GNOME扩展..."
sudo dnf install -y \
gnome-shell-extension-user-theme \
gnome-shell-extension-dash-to-dock \
gnome-shell-extension-blur-my-shell \
gnome-shell-extension-just-perfection \
gnome-shell-extension-drive-menu \
gnome-shell-extension-appindicator \
gnome-shell-extension-caffeine \
gnome-shell-extension-auto-move-windows \
gnome-shell-extension-no-overview \
gnome-shell-extension-gsconnect \
gnome-shell-extension-workspace-indicator \
gnome-shell-extension-forge

# sudo dnf install -y gnome-shell-extension-gsconnect
# sudo dnf install -y gnome-shell-extension-workspace-indicator
# sudo dnf install -y gnome-shell-extension-system-monitor

# dnf copr enable huakim/kde-plasma
sudo dnf install -y gradle
sudo dnf install -y \
gnome-shell-extension-gtk4-ding \
gnome-shell-extension-desktop-icons


# 启用已安装的扩展
# gnome-extensions list
echo "启用已安装的扩展..."
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable just-perfection-desktop@just-perfection
gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable caffeine@patapon.info
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable no-overview@fthx
gnome-extensions enable gsconnect@andyholmes.github.io
gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable forge@jmmaranan.com
# gnome-extensions enable forge@jmmaranan.com

# 列出所有已安装的 Schema
# gsettings list-schemas
# 递归列出某个 Schema 的键值（例如 org.gnome.shell.extensions.dash-to-dock）
# gsettings list-recursively org.gnome.shell.extensions.dash-to-dock
# 配置 Dash to Dock (自定义Dock栏)
echo "正在配置Dash to Dock..."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.5
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DASHES'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(153,193,241)'
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.3
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
# 白色
# gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(255,255,255)'
# gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(154,153,150)'


# 配置 Blur My Shell (透明模糊效果)
echo "正在配置Blur My Shell..."
# gsettings list-recursively org.gnome.shell.extensions.blur-my-shell.panel
# gsettings list-recursively org.gnome.shell.extensions.blur-my-shell.applications
# 恢复默认设置 gsettings reset-recursively org.gnome.shell.extensions.blur-my-shell
# 设置自定义模糊效果
# gsettings get org.gnome.shell.extensions.blur-my-shell pipelines
gsettings set org.gnome.shell.extensions.blur-my-shell pipelines "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_96853877854398'>, 'params': <@a{sv} {}>}>]>}, 'pipeline_panel': {'name': <'blur panel'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_75271904090067'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'color'>, 'id': <'effect_36769853581304'>, 'params': <{'color': <(0.4, 0.7, 0.9, 0.3)>}>}>]>}, 'pipeline_dock': {'name': <'blur dock'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_05617311186362'>, 'params': <{'unscaled_radius': <100>, 'brightness': <1>}>}>, <{'type': <'corner'>, 'id': <'effect_78081442948590'>, 'params': <{'radius': <20>}>}>]>}}"
gsettings set org.gnome.shell.extensions.blur-my-shell.panel pipeline 'pipeline_panel'
gsettings set org.gnome.shell.extensions.blur-my-shell.panel force-light-text true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel style-panel 1
gsettings set org.gnome.shell.extensions.blur-my-shell.hidetopbar compatibility true
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder style-dialogs 2
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline 'pipeline_dock'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 1
# 启用应用程序窗口模糊
gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur true
# 启用自定义设置（必须为true才能生效）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications customize true
# 颜色叠加（RGBA，此处为透明黑色，增强暗色模式对比度）
# gsettings reset org.gnome.shell.extensions.blur-my-shell.applications color
gsettings set org.gnome.shell.extensions.blur-my-shell.applications color "(0.05, 0.05, 0.05, 0.1)"
# 噪点强度（0.3=轻微颗粒感，模拟真实磨砂玻璃）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications noise-amount 0.3
# 噪点明度（0.1=低对比噪点，自然不刺眼）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications noise-lightness 0.1
# 模糊强度（50=中等模糊，过高会显脏）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications sigma 50
# 亮度微调（1.0=原始亮度，建议保持）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications brightness 1.0
# 基础透明度（220/255≈86%，平衡通透与朦胧感）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications opacity 220
# 禁用动态透明度（避免窗口切换时效果闪烁）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications dynamic-opacity false
# 禁用在Overview（超级键视图）中模糊（避免卡顿）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications blur-on-overview false
# 不强制所有应用模糊（避免兼容性问题）
gsettings set org.gnome.shell.extensions.blur-my-shell.applications enable-all false
# 应用毛玻璃效果的应用列表
gsettings set org.gnome.shell.extensions.blur-my-shell.applications whitelist "['org.gnome.Nautilus', 'org.gnome.Settings', 'org.gnome.Software', 'org.gnome.TextEditor', 'org.gnome.Ptyxis', 'org.gnome.SystemMonitor', 'org.gnome.tweaks', 'org.gnome.Extensions', 'com.mattjakeman.ExtensionManager', 'com.github.tchx84.Flatseal', 'io.github.flattool.Warehouse', 'com.gitee.gmg137.NeteaseCloudMusicGtk4', 'yesplaymusic', 'tabby', 'org.gnome.Builder', 'io.missioncenter.MissionCenter', 'com.github.neithern.g4music', 'com.github.amezin.ddterm', 'me.iepure.devtoolbox', 'org.gnome.Calendar', 're.sonny.Playhouse', 'de.haeckerfelix.Fragments', 'it.mijorus.gearlever', 'io.github.realmazharhussain.GdmSettings', 'Bitwarden', 'net.nokyan.Resources', 'Steam++', 'io.github.vikdevelop.SaveDesktop', 'io.gitlab.adhami3310.Impression']"
gsettings set org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab blur false

# Just Perfection（微调 GNOME Shell 的细节，隐藏冗余元素、调整动画速度等）
echo "正在配置Just Perfection..."
# gsettings list-recursively org.gnome.shell.extensions.just-perfection
gsettings set org.gnome.shell.extensions.just-perfection accessibility-menu false
gsettings set org.gnome.shell.extensions.just-perfection world-clock false
gsettings set org.gnome.shell.extensions.just-perfection events-button false
# gsettings set org.gnome.shell.extensions.just-perfection weather false
# 概览中工作区切换区缩略图，此处设置为隐藏
gsettings set org.gnome.shell.extensions.just-perfection workspace false
gsettings set org.gnome.shell.extensions.just-perfection window-demands-attention-focus true
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0
# gsettings reset-recursively org.gnome.shell.extensions.just-perfection

# gsettings list-recursively org.gnome.shell.weather
# gsettings list-recursively org.gnome.mutter
# gsettings list-recursively org.gnome.desktop.wm.preferences
# 禁用动态工作区
gsettings set org.gnome.mutter dynamic-workspaces false
# 设置工作区数量为3（奇数确保有中间位）
gsettings set org.gnome.desktop.wm.preferences num-workspaces 3
# 预设工作区名称
gsettings set org.gnome.desktop.wm.preferences workspace-names "['休闲区', '工作区', '开发区']"
# workspace-indicator
# gsettings list-recursively org.gnome.shell.extensions.workspace-indicator
gsettings set org.gnome.shell.extensions.workspace-indicator embed-previews false
# gsettings reset-recursively org.gnome.shell.extensions.workspace-indicator


# 设置 Background Logo 扩展插件
# gsettings list-recursively org.fedorahosted.background-logo-extension
# gsettings set org.fedorahosted.background-logo-extension logo-size 9.0
gsettings set org.fedorahosted.background-logo-extension logo-always-visible true
# 恢复默认设置
# gsettings reset-recursively org.fedorahosted.background-logo-extension


# auto-move-windows
echo "正在配置auto-move-windows..."
# gsettings list-recursively org.gnome.shell.extensions.auto-move-windows
# gsettings get org.gnome.shell.extensions.auto-move-windows application-list
gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['org.gnome.Settings.desktop:1', 'org.gnome.Software.desktop:1', 'org.gnome.TextEditor.desktop:1', 'org.gnome.SystemMonitor.desktop:1', 'org.gnome.tweaks.desktop:1', 'org.gnome.Shell.Extensions.desktop:1', 'com.mattjakeman.ExtensionManager.desktop:1', 'org.gnome.Loupe.desktop:1', 'yelp.desktop:1', 'org.gnome.DiskUtility.desktop:1', 'org.gnome.baobab.desktop:1', 'org.gnome.Tour.desktop:1', 'org.gnome.Maps.desktop:1', 'org.gnome.Firmware.desktop:1', 'org.gnome.Calculator.desktop:1', 'org.freedesktop.MalcontentControl.desktop:1', 'org.gnome.Contacts.desktop:1', 'org.gnome.Calendar.desktop:1', 'org.gnome.Totem.desktop:1', 'org.gnome.Weather.desktop:1', 'org.gnome.Evince.desktop:1', 'org.gnome.Snapshot.desktop:1', 'org.gnome.clocks.desktop:1', 'io.missioncenter.MissionCenter.desktop:1', 'org.gnome.Characters.desktop:1', 'org.gnome.font-viewer.desktop:1', 'com.github.tchx84.Flatseal.desktop:1', 'ca.desrt.dconf-editor.desktop:1', 'de.haeckerfelix.Fragments.desktop:1', 'io.github.realmazharhussain.GdmSettings.desktop:1', 'it.mijorus.gearlever.desktop:1', 'gnome-system-monitor-kde.desktop:1', 'io.gitlab.adhami3310.Impression.desktop:1', 'io.github.nokse22.inspector.desktop:1', 'com.obsproject.Studio.desktop:1', 'page.tesk.Refine.desktop:1', 'org.fedoraproject.MediaWriter.desktop:1', 'net.nokyan.Resources.desktop:1', 'org.gnome.Evolution.desktop:1', 'io.github.vikdevelop.SaveDesktop.desktop:1', 'org.gnome.World.PikaBackup.desktop:1', 'timeshift-gtk.desktop:1', 'com.qq.QQ.desktop:2', 'com.tencent.WeChat.desktop:2', 'org.mozilla.firefox.desktop:2', 'com.microsoft.Edge.desktop:2', 'com.google.Chrome.desktop:2', 'com.github.gmg137.netease-cloud-music-gtk.desktop:2', 'io.github.qier222.YesPlayMusic.desktop:2', 'com.github.neithern.g4music.desktop:2', 'cn.feishu.Feishu.desktop:2', 'libreoffice-startcenter.desktop:2', 'libreoffice-calc.desktop:2', 'libreoffice-impress.desktop:2', 'libreoffice-writer.desktop:2', 'io.typora.Typora.desktop:2', 'md.obsidian.Obsidian.desktop:2', 'jetbrains-toolbox.desktop:3', 'jetbrains-idea-1e43afa8-7b74-4314-97e3-6dc2fcd19338.desktop:3', 'jetbrains-datagrip-6221d402-4768-423c-8755-982ae877905f.desktop:3', 'me.iepure.devtoolbox.desktop:3', 'switchhosts.desktop:3', 'com.github.marhkb.Pods.desktop:3', 'io.podman_desktop.PodmanDesktop.desktop:3', 'tabby.desktop:3', 'com.visualstudio.code.desktop:3', 're.sonny.Playhouse.desktop:3', 'org.gnome.Builder.desktop:3']"


cd ~/文档
git clone https://gitee.com/llf2635/linux.git --depth=1
cp -v ~/文档/linux/模板/* ~/模板/
cp -v ~/文档/linux/壁纸/* ~/.local/share/backgrounds/
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-1.jpg"


# 进入到下载目录
cd ~/图片
# git clone https://gitee.com/llf2635/linux.git --depth=1
git clone https://gitee.com/llf2635/linux-wallpapers.git --depth=1
# flatpak install flathub me.dusansimic.DynamicWallpaper

# 免费壁纸网站 https://haowallpaper.com/homeView
# https://bz.zzzmh.cn/index
# ls ~/.local/share/backgrounds
# ls /usr/share/backgrounds
# nautilus admin:/usr/share/backgrounds

# 安装 capitaine 光标主题
echo "准备开始安装WhiteSur-cursors光标主题..."
sudo dnf install -y la-capitaine-cursor-theme

# 下载并安装 WhiteSur 图标主题
echo "准备开始安装WhiteSur-icon-theme图标主题..."
# 安装WhiteSur图标主题 (macOS风格)
if [ ! -d "WhiteSur-icon-theme" ]; then
    echo "正在安装WhiteSur图标主题..."
    # git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
    git clone https://gh-proxy.com/github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
    # git clone https://gitcode.com/gh_mirrors/wh/WhiteSur-icon-theme.git --depth=1
    cd WhiteSur-icon-theme
    ./install.sh
    cd ..
    rm -rf WhiteSur-icon-theme
fi

# 下载并安装主题 https://github.com/vinceliuice/WhiteSur-gtk-theme
echo "准备开始安装WhiteSur-gtk-theme应用主题..."
sudo dnf install -y adw-gtk3-theme
# https://github.com/FedoraQt
# https://packages.fedoraproject.org/pkgs/qadwaitadecorations/
# https://discussion.fedoraproject.org/t/qt-app-theme-in-gnome/102649
# https://pkgs.org/search/?q=QGnomePlatform
# https://pkgs.org/search/?q=Qadwaitadecorations
# dnf list qadwaitadecorations*
sudo dnf install -y \
qgnomeplatform-qt5 \
qgnomeplatform-qt6 \
qadwaitadecorations-qt5 \
qadwaitadecorations-qt6
# 安装WhiteSur主题 (macOS风格)
if [ ! -d "WhiteSur-gtk-theme" ]; then   # 检查目录是否存在
    echo "正在安装WhiteSur GTK主题..."
    # git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
    git clone https://gh-proxy.com/github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
    # git clone https://gitcode.com/gh_mirrors/wh/WhiteSur-gtk-theme.git --depth=1
    # 修改 Nautilus 侧边栏不透明度，参考 https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1127
    sed -i 's/\$opacity: 0\.96/\$opacity: 1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    grep '$opacity' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    cd WhiteSur-gtk-theme
    # 卸载 ./install.sh -r
    # 安装 GTK 主题，设置主题不透明度变体。默认为所有变体
    ./install.sh -o solid -l --round
    # 设置 panel 图标会导致 overview 增加一个 工作空间列表
    # ./install.sh -o solid -l --shell -i fedora --round
    # ./install.sh -o solid -l --shell -i apple --round
    # 修复 libadwaita（不完美）https://github.com/vinceliuice/WhiteSur-gtk-theme?tab=readme-ov-file#fix-for-libadwaita-not-perfect
    # ./install.sh -l
    # ./install.sh -l -c light
    # 设置 'WhiteSur' GDM/Flatpak 主题不透明度变体。默认值为 'normal'
    ./tweaks.sh -o solid
    # 安装 Firefox 主题
    # firefox & sleep 1 && pkill firefox	# 初始化 firefox 配置
    ./tweaks.sh -f flat
    # 安装 GDM 主题，可通过下面的软件自定义调节
    # flatpak install flathub io.github.realmazharhussain.GdmSettings
    # 不要模糊自定义背景
    sudo ./tweaks.sh -g -nb -b "$HOME/.local/share/backgrounds/wallpaper-1.jpg"
    # 设置 GDM 要模糊自定义背景
    # sudo ./tweaks.sh -g -b "$HOME/.local/share/backgrounds/wallpaper-1.jpg"
    # 将 WhiteSur 主题包连接到 Flatpak 仓库，可以解决部分应用无法使用 WhiteSur 主题问题，例如：Chrome、Edge
    sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0
    ./tweaks.sh -F -o solid
    # flatpak list --all
    # 不推荐、修复 Dash to Dock 主题的问题  ./tweaks.sh -d -r
    # ./tweaks.sh -d
    cd ..
    rm -rf WhiteSur-gtk-theme
fi

# 授予全局访问 GTK 配置和主题文件的权限
# 允许所有 Flatpak 应用访问宿主机的 ~/.config/gtk-3.0 目录。该目录包含 GTK 3 的配置文件（如主题、图标、字体设置等）。
# 系统主题（/usr/share/themes）需 sudo 配置，影响所有用户。
# 用户主题（~/.themes）需用 --user 参数，仅限当前用户。建议统一使用 sudo
# 允许Flatpak应用读取主题和配置,共享 GTK3/GTK4 设置
# 同步 GTK3 配置（主题/字体/缩放）
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro
# 同步 GTK4 配置（Libadwaita 应用）
sudo flatpak override --filesystem=xdg-config/gtk-4.0:ro
# 仅当前用户生效（推荐）
# xdg-data/themes 是 ~/.local/share/themes 的标准化路径别名（Flatpak 优先识别）
# :ro 表示只读权限，避免应用误修改主题文件。
sudo flatpak override --filesystem=xdg-data/themes:ro
sudo flatpak override --filesystem=xdg-data/icons:ro
sudo flatpak override --filesystem=$HOME/.themes:ro
sudo flatpak override --filesystem=$HOME/.icons:ro
# 共享系统GTK主题文件
sudo flatpak override --filesystem=/usr/share/themes:ro
# 共享系统图标主题文件
sudo flatpak override --filesystem=/usr/share/icons:ro
# sudo flatpak override --help
# sudo flatpak override --reset
# sudo flatpak override --show
# sudo flatpak override --system --show
# flatpak override --user --show
# flatpak override --user --reset

# 应用主题设置
echo "正在应用主题设置..."
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-light'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Light-solid'
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light-solid'

# 清理临时文件
echo "正在清理临时文件..."
sudo dnf clean all && sudo dnf autoremove

echo "主题美化完成！请注销或重启系统以查看全部更改效果。"
echo "您可以使用GNOME Tweaks工具进一步自定义外观。"




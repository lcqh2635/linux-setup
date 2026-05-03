#!/bin/bash

# Fedora GNOME 42 初始化优化配置脚本
# 功能：自动安装并配置加速镜像、工具、依赖包
# 使用方法：chmod +x software.sh && ./software.sh

# 更新系统并升级所有已安装的包
echo "开始更新系统并升级所有已安装的包..."
sudo dnf update -y && sudo dnf upgrade -y
echo "系统更新、升级完成..."

# dnf list google-chrome-stable
sudo dnf install -y google-chrome-stable

# 启用第三方优质库	https://copr.fedorainfracloud.org
# https://copr.fedorainfracloud.org/coprs/medzik/jetbrains/
# sudo dnf copr enable medzik/jetbrains
# dnf list goland
# sudo dnf install -y intellij-idea-ultimate
# sudo dnf install -y goland webstorm rustrover datagrip android-studio pycharm-professional
# sudo dnf install -y jetbrains-fleet
# 关于 tauri android 应用环境搭建 https://tauri.app/zh-cn/start/prerequisites/#android

# 下载并安装 Android Studio
sudo dnf install -y android-studio
# export JAVA_HOME=/opt/android-studio/jbr
# 使用 Android Studio 中的 Android SDK 安装以下内容：
    Android SDK Platform
    Android SDK Platform-Tools
    NDK (Side by side)
    Android SDK Build-Tools
    Android SDK Command-line Tools
# 查看环境变量配置，通过 sdkman 安装的所有候选都会自动配置环境变量，用户不需要自己再额外配置
echo $PATH    
# 配置 tauri 安卓 Android 所需的环境变量 https://tauri.app/zh-cn/start/prerequisites/#android   
echo '
export ANDROID_HOME="$HOME/Android/Sdk"
export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"
' >> ~/.bash_profile
source ~/.bash_profile
cat ~/.bash_profile
# 使用 rustup 添加 Android 编译目标：
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
# 创建 tauri 项目
bun create tauri-app
# 项目启动前操作
cd tauri-app && bun install
# 如果此处失败了，请在 android-studio 中点击  setting -> 搜索 Android SDK
bun run tauri android init
# 启动桌面应用程序
bun run tauri dev
# 启动 android 安卓应用程序，在运行该命令之前必须先在 android-studio 中运行内嵌手机，否则执行会卡住没反映
bun run tauri android dev
  


# https://copr.fedorainfracloud.org/coprs/julianve/open-any-terminal/
# sudo dnf copr enable julianve/open-any-terminal
# sudo dnf install open-any-terminal-nautilus
# https://copr.fedorainfracloud.org/coprs/changyp6/customize/
# dnf copr enable changyp6/customize


# sudo dnf copr enable thangckt/thang_foss
sudo dnf install -y zed rustdesk github-desktop


# 以下是 VPN 软件
# https://github.com/clash-verge-rev/clash-verge-rev/releases
# https://github.com/2dust/v2rayN/releases

# github 下载加速	https://gh-proxy.com/
# https://gh-proxy.com/https://github.com/clash-verge-rev/clash-verge-rev/releases/download/autobuild/Clash.Verge-2.4.0+autobuild.0805.44e8a03-1.x86_64.rpm
# https://gh-proxy.com/github.com/2dust/v2rayN/releases/download/7.13.2/v2rayN-linux-64.AppImage


# https://gh-proxy.com/https://github.com/rustdesk/rustdesk/releases/download/1.4.1/rustdesk-1.4.1-0.x86_64.rpm
# https://github.com/clash-verge-rev/clash-verge-rev/releases/download/autobuild/Clash.Verge-2.4.0+autobuild.0805.44e8a03-1.x86_64.rpm
# https://gh-proxy.com/https://github.com/2dust/v2rayN/releases/download/7.13.6/v2rayN-linux-64.AppImage



# 安装一些常用的Flatpak应用（如VSCode, LibreOffice）
echo "安装基础Flatpak应用程序..."
flatpak install -y flathub \
app.drey.Dialect \
com.bitwarden.desktop \
com.github.gmg137.netease-cloud-music-gtk \
com.github.marhkb.Pods \
io.podman_desktop.PodmanDesktop \
com.github.neithern.g4music \
com.github.tchx84.Flatseal \
com.mattjakeman.ExtensionManager \
de.haeckerfelix.Fragments \
io.github.alainm23.planify \
io.github.flattool.Warehouse \
io.github.realmazharhussain.GdmSettings \
io.github.seadve.Kooha \
com.obsproject.Studio \
io.github.vikdevelop.SaveDesktop \
io.gitlab.adhami3310.Impression \
io.typora.Typora \
it.mijorus.gearlever \
md.obsidian.Obsidian \
me.iepure.devtoolbox \
net.nokyan.Resources \
io.missioncenter.MissionCenter \
org.gnome.Builder \
org.gnome.Firmware \
org.gnome.Gtranslator \
org.gnome.World.PikaBackup \
org.gnome.gitlab.somas.Apostrophe \
re.sonny.Playhouse \
re.sonny.Workbench \
org.gnome.seahorse.Application \
io.github.nokse22.inspector \
com.usebottles.bottles \
page.tesk.Refine \
com.qq.QQ \
com.tencent.WeChat \
com.tencent.wemeet \
com.dingtalk.DingTalk \
cn.feishu.Feishu \
com.baidu.NetDisk \
com.microsoft.Edge \
com.google.Chrome \
com.protonvpn.www \
com.rustdesk.RustDesk \
org.dupot.easyflatpak \
me.dusansimic.DynamicWallpaper \
com.github.d4nj1.tlpui \
app.drey.Warp \
com.valvesoftware.Steam \
io.github.Foldex.AdwSteamGtk \
net.lutris.Lutris \
com.vysp3r.ProtonPlus \
com.heroicgameslauncher.hgl \
page.kramo.Cartridges \
net.eudic.dict \
io.github.debasish_patra_1987.linuxthemestore


flatpak install -y flathub \
com.apifox.Apifox \
com.jetbrains.IntelliJ-IDEA-Ultimate \
com.jetbrains.PyCharm-Professional \
com.jetbrains.WebStorm \
com.jetbrains.RustRover \
com.jetbrains.GoLand \
com.jetbrains.DataGrip


flatpak install flathub com.jetbrains.IntelliJ-IDEA-Ultimate
flatpak install flathub com.jetbrains.WebStorm
flatpak install flathub com.jetbrains.RustRover
flatpak install flathub com.jetbrains.GoLand
flatpak install flathub com.jetbrains.PyCharm-Professional
flatpak install flathub com.jetbrains.DataGrip
# 配置 Zed 参考官网 https://zed.rust-lang.net.cn/docs/configuring-zed
flatpak install flathub dev.zed.Zed
flatpak install flathub com.apifox.Apifox
flatpak install flathub cn.apipost.apipost
# 用于 UX/UI 的免费图形设计工具
flatpak install flathub com.icons8.Lunacy
# 简单的 UML 和 SysML 建模工具
flatpak install flathub org.gaphor.Gaphor
# 注意：要在另一个驱动器上添加游戏库，首先需要授予应用程序访问它的权限：
# flatpak override --user --filesystem=/path/to/your/Steam/Library com.valvesoftware.Steam

# 将您的文件上传到任何地方，可以使用厂商云存储、或者自建 nas 存储服务器
flatpak install flathub io.github.pieterdd.RcloneShuttle


# Clash Verge 翻墙工具，加速下载地址	https://ghproxylist.com/
# 使用教程	https://clashmetacn.com/257.html
https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.3.1/Clash.Verge-2.3.1-1.x86_64.rpm
# Clash免费节点	https://www.freeclashnode.com/
# https://node.freeclashnode.com/uploads/2025/07/2-20250702.yaml
# https://node.freeclashnode.com/uploads/2025/07/1-20250701.yaml
# https://node.clashvergerev.cc/uploads/2025/07/0-20250701.yaml
# Clash Meta for Android 使用教程	https://clashmetaforandroid.com/tutorial/
# Clash Meta for Android 下载地址	https://clashmetaforandroid.com/


flatpak install flathub app.drey.Damask
flatpak install flathub page.codeberg.libre_menu_editor.LibreMenuEditor
flatpak install flathub io.gitlab.gwendalj.package-transporter
# https://www.appimagehub.com
flatpak install flathub io.github.prateekmedia.appimagepool
flatpak install flathub org.dupot.easyflatpak
flatpak install flathub com.apifox.Apifox
flatpak install -y flathub cn.apipost.apipost
flatpak install flathub com.jeffser.Alpaca
# 任务中心
flatpak install flathub io.missioncenter.MissionCenter
# 火焰截图
flatpak install flathub org.flameshot.Flameshot
# 钉钉
flatpak install flathub com.dingtalk.DingTalk
# 飞书
flatpak install flathub cn.feishu.Feishu
# 适用于 Plausible Analytics 的混合原生 + Web 应用程序，这是一款轻量级的开源网站分析工具。Tally 将 Plausible Web 应用程序封装在本机 UI 中，从而更好地与桌面作系统集成。
flatpak install flathub com.cassidyjames.plausible
# 浏览、预览和安装桌面主题
flatpak install flathub io.github.debasish_patra_1987.linuxthemestore
# 适用于 Apache Kafka 的美观且功能齐全的桌面客户端
flatpak install flathub io.conduktor.Conduktor
# 用于管理 Distrobox 容器的图形界面
flatpak install flathub com.ranfdev.DistroShelf
# 视频壁纸
flatpak install flathub io.github.jeffshee.Hidamari
# 欧路词典
flatpak install flathub net.eudic.dict
# 快捷、安全的文件传输工具
flatpak install flathub app.drey.Warp
# 一个漂亮的 GTK 4 终端，Black Box 是 GNOME 的原生终端模拟器，提供了极好的主题选项。
flatpak install flathub com.raggesilver.BlackBox
flatpak install flathub me.dusansimic.DynamicWallpaper
flatpak install flathub com.github.maoschanz.DynamicWallpaperEditor
flatpak install flathub com.github.d4nj1.tlpui
flatpak install flathub ca.desrt.dconf-editor
flatpak install flathub org.wezfurlong.wezterm
# 漫画
flatpak install flathub info.febvre.Komikku
flatpak install flathub com.geekbench.Geekbench6
# Ping 网站
flatpak install flathub io.github.lo2dev.Echo
flatpak install flathub io.github.qier222.YesPlayMusic
flatpak install flathub com.visualstudio.code
flatpak install flathub org.libreoffice.LibreOffice

https://github.com/quick123official/quick_redis_blog/releases
https://www.appimagehub.com/p/2292484

# https://flathub.org/zh-Hans/apps/search?q=jetbrains
flatpak install flathub com.jetbrains.IntelliJ-IDEA-Ultimate
flatpak install flathub com.jetbrains.WebStorm
flatpak install flathub com.jetbrains.RustRover
flatpak install flathub com.jetbrains.GoLand
flatpak install flathub com.jetbrains.PyCharm-Professional
flatpak install flathub com.jetbrains.DataGrip

cn.apipost.apipost
ca.desrt.dconf-editor




flatpak list --app
flatpak list --user  # 查看用户级安装的应用
flatpak list --system  # 查看系统级安装的应用

flatpak search org.gtk.Gtk3theme
flatpak list org.gtk.Gtk3theme
sudo flatpak install -y flathub \
org.gtk.Gtk3theme.Adwaita-dark \
org.gtk.Gtk3theme.adw-gtk3 \
org.gtk.Gtk3theme.adw-gtk3-dark

# https://packagecloud.io/eugeny/tabby/install#bash-rpm
sudo dnf install -y tabby-terminal
# 游戏
flatpak install flathub com.valvesoftware.Steam -y
flatpak install flathub io.github.Foldex.AdwSteamGtk -y

# 定期运行 flatpak uninstall --unused 删除旧版本运行时。
flatpak uninstall --unused -y

# 进入到下载目录
cd ~/下载

# 下载 jetbrains-toolbox 应用
echo "准备开始安装jetbrains-toolbox应用..."
if [ ! -d "WhiteSur-wallpapers" ]; then
    echo "正在安装WhiteSur壁纸..."
    # git clone https://github.com/vinceliuice/WhiteSur-wallpapers.git --depth=1
    git clone https://gitee.com/llf2635/linux.git --depth=1
    cd linux
    sudo dnf install -y unzip
    unzip jetbra.zip
    mv jetbra ~/.jetbra
    wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.6.2.41321.tar.gz"
    tar -xzf jetbrains-toolbox-2.6.2.41321.tar.gz
    cd jetbrains-toolbox-2.6.2.41321
    ./jetbrains-toolbox
    cd ..
    rm -rf jetbrains-toolbox-2.6.2.41321 jetbrains-toolbox-2.6.2.41321.tar.gz
fi

# 下载 jetbrains-toolbox
https://www.jetbrains.com/zh-cn/toolbox-app/download/download-thanks.html?platform=linux


# 下载  jetbra.zip 以及获取 JetBrains 软件激活码
# https://3.jetbra.in/
# https://ipfs.io/ipfs/bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i/
# https://bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i.ipfs.dweb.link/

# IDEA 虚拟机配置文件存放位置
cat ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions
nautilus ~/.config/JetBrains

echo "
-Xms1g
-Xmx5g
-XX:ReservedCodeCacheSize=512m
-XX:+IgnoreUnrecognizedVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:+UseZGC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Drecreate.x11.input.method=true
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains
" | sudo tee -a ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions

https://github.com/Eugeny/tabby/releases/download/v1.0.223/tabby-1.0.223-linux-x64.rpm
# https://gitcode.com/gh_mirrors/ta/tabby
# 参考 https://packagecloud.io/eugeny/tabby/install#bash-rpm
curl -s https://packagecloud.io/install/repositories/eugeny/tabby/script.rpm.sh | sudo bash
https://github.com/oldj/SwitchHosts/releases/download/v4.2.0-beta/SwitchHosts_linux_x86_64_4.2.0.6105.AppImage
curl -sSL https://steampp.net/Install/Linux.sh | bash
/home/lcqh/.WattToolkit
curl -sSL https://steampp.net/Install/Linux.sh | INSTALL_DIR="$HOME/.watt-toolkit" bash

# 转换后的包可能因依赖问题无法运行（尤其是依赖 glibc 版本不同的软件）。
# 使用 alien 工具转换 .deb 为 .rpm（推荐）
sudo dnf install -y alien rpm-build
# 将 .deb 转换为 .rpm
sudo alien -r --scripts Apipost_linux_x64_8.1.14.deb  # 保留安装脚本（-r 生成 RPM，--scripts 保留脚本）
sudo alien -r --scripts ting_en.deb
sudo alien --to-rpm --scripts *.deb
sudo alien -r  -c -v Apipost_linux_x64_8.1.14.deb

# 安装生成的 .rpm 文件
sudo dnf install package-version.Apipost_linux_x64_8.1.14.rpm
sudo yum localinstall package.rpm

# libadwaita-demos
# https://ftp5.gwdg.de/pub/linux/archlinux/extra/os/x86_64/libadwaita-demos-1:1.7.4-1-x86_64.pkg.tar.zst

# 清理临时文件
echo "正在清理临时文件..."
dnf clean all

echo "主题美化完成！请注销或重启系统以查看全部更改效果。"
echo "您可以使用GNOME Tweaks工具进一步自定义外观。"



flatpak install flathub app.zen_browser.zen -y
flatpak install flathub org.videolan.VLC -y
# 办公软件
flatpak install flathub org.libreoffice.LibreOffice -y
# 快捷、安全的文件传输工具
flatpak install flathub app.drey.Warp -y
# 下载、使用且能自适应的 GTK 应用程序字体
flatpak install flathub org.gustavoperedo.FontDownloader -y
# 一个系统 systemd 服务管理器
flatpak install flathub io.github.plrigaux.sysd-manager -y
# VPN 软件
flatpak install flathub com.protonvpn.www -y
flatpak install flathub io.github.Fndroid.clash_for_windows -y
# Lutris 可帮您安装和运行大多数平台上几乎所有时代的电子游戏。通过对现有的模拟器、兼容层、第三方游戏引擎等进行整合利用，Lutris 可为您提供一个统一的界面来启动您的所有游戏。
flatpak install flathub net.lutris.Lutris -y
flatpak install flathub com.valvesoftware.Steam -y
# 给予 Steam 以 Adwaita 级待遇，让 Steam 看起来属于您的电脑。这款应用会为您安装并更新 Adwaita-for-Steam 皮肤。
flatpak install flathub io.github.Foldex.AdwSteamGtk -y
# 现代兼容性工具管理器
flatpak install flathub com.vysp3r.ProtonPlus -y
# Heroic 是一个开源游戏启动器。目前支持使用 Legendary 启动 Epic 游戏商城中的游戏， 使用我们自定义的 gogdl 实现启动 GOG 游戏，以及使用 Nile 启动 Amazon 游戏。
flatpak install flathub com.heroicgameslauncher.hgl -y
# Cartridges 是一个简单的游戏启动器，适用于您的所有游戏。它支持从Steam、Lutris、Heroic等游戏平台导入游戏且无需登录。您可以排序和隐藏游戏，也可以从SteamGridDB下载封面。
flatpak install flathub page.kramo.Cartridges -y
# 与AI模型聊天
flatpak install flathub com.jeffser.Alpaca -y
# 查看有关系统的信息
flatpak install flathub io.github.nokse22.inspector -y
# Bottles 允许您在 Linux 上运行 Windows 软件，例如应用程序和游戏。
flatpak install flathub com.usebottles.bottles -y
# 让 Firefox 保持时尚，可轻松安装 Firefox GNOME Theme* 并在后台自动更新。
flatpak install flathub dev.qwery.AddWater -y
# 为 GNOME 创建应用程序
flatpak install flathub org.gnome.Builder -y
# Workbench 用于使用 GNOME 技术进行学习和原型设计，无论是第一次修补还是构建和测试 GTK 用户界面。
flatpak install flathub re.sonny.Workbench -y
# https://flathub.org/zh-Hans/apps/com.jetbrains.IntelliJ-IDEA-Ultimate
flatpak install flathub com.jetbrains.IntelliJ-IDEA-Ultimate -y
# 及时跟进您的订阅
flatpak install flathub io.gitlab.news_flash.NewsFlash -y
# 忘记忘记事情
flatpak install flathub io.github.alainm23.planify -y
# 这款阅读器的界面简洁、美观、适应性强，可让您轻松搜索、排序和阅读系列文章。
flatpak install flathub info.febvre.Komikku -y
# 创建和编辑应用程序快捷方式
flatpak install flathub io.github.fabrialberio.pinapp -y
# 自定义应用程序图标
flatpak install flathub page.codeberg.libre_menu_editor.LibreMenuEditor -y
# 将网站作为桌面应用安装，使其显示在独立的窗口中，与安装的任何浏览器分开。
flatpak install flathub net.codelogistics.webapps
# 该项目是 Firefox 的一个独立分支，主要目标是隐私安全和用户自由。它是 LibreFox 的社区运营继承者。
flatpak install flathub io.gitlab.librewolf-community
# 屏幕录制，替代 OBS
flatpak install flathub io.github.seadve.Kooha -y
flatpak install -y flathub com.obsproject.Studio
# 彻底删除应用及数据：
flatpak uninstall --delete-data flathub com.obsproject.Studio -y
# 定期运行 flatpak uninstall --unused 删除旧版本运行时。
flatpak uninstall --unused -y
# 列出已配置的远程仓库
flatpak remote-list -d
sudo flatpak override --reset

# 以下软件为适配主题，依旧使用自带默认主题
flatpak install flathub com.qq.QQ -y
flatpak install flathub com.tencent.WeChat -y
flatpak install flathub com.tencent.wemeet -y
flatpak install flathub cn.apipost.apipost -y
flatpak install flathub com.rustdesk.RustDesk -y
# Fedora 自带启动盘 ISO 写入工具
flatpak install flathub org.fedoraproject.MediaWriter -y
# 创建图像或编辑照片
flatpak install flathub org.gimp.GIMP -y
flatpak install flathub com.wps.Office -y

# Conky 桌面小组件
# Conky 轻量级、高度可定制的桌面监视工具，可显示系统信息（CPU、内存、网络等）、天气、日历、笔记等。
# Conky 主题 https://www.gnome-look.org/u/closebox73x
sudo dnf install -y conky


# https://docs.fedoraproject.org/zh_CN/gaming/proton/


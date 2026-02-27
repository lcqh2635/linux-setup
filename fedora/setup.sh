#!/bin/bash

# Fedora GNOME 42 初始优化配置脚本
# 功能：自动安装并配置加速镜像、工具、依赖包、开发环境配置
# 使用方法：chmod +x setup.sh && ./setup.sh

# 检查是否为root用户
# if [ "$(id -u)" -ne 0 ]; then
#     echo "请使用root用户或通过sudo运行此脚本"
#     exit 1
# fi


# 从源代码安装软件 https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-from-source/
# tar -zxf archive.tar.gz $ cd archive/ $ ./configure $ make $ sudo make install
# 在 Fedora 添加或移除软件源 https://docs.fedoraproject.org/zh_Hans/quick-docs/adding-or-removing-software-repositories-in-fedora/
# 安装 PostgreSQL 数据库 https://docs.fedoraproject.org/zh_Hans/quick-docs/postgresql/


# gsettings list-schemas
# gsettings list-recursively org.gnome.shell
# gsettings list-recursively org.gnome.mutter
# gsettings list-recursively org.gnome.desktop.interface
# gsettings list-recursively org.gnome.desktop.wm.preferences

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

# gsettings list-recursively org.gnome.Settings
# gsettings list-recursively org.gnome.settings-daemon.plugins

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


## 1. 系统基础配置 ==============================================
# 中国科技大学 Fedora 加速镜像 https://mirrors.ustc.edu.cn/help/fedora.html
# 配置dnf以加快软件下载速度（启用最快的镜像）
sudo sed -e 's|^metalink=|#metalink=|g' \
         -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' \
         -i.bak \
         /etc/yum.repos.d/fedora.repo \
         /etc/yum.repos.d/fedora-updates.repo

# ls /etc/yum.repos.d
# cat /etc/yum.repos.d/fedora.repo
# cat /etc/yum.repos.d/fedora-updates.repo
# 修改还原
# sudo mv /etc/yum.repos.d/fedora.repo.bak /etc/yum.repos.d/fedora.repo
# sudo mv /etc/yum.repos.d/fedora-updates.repo.bak /etc/yum.repos.d/fedora-updates.repo


# 中国科技大学 RPMFusion 镜像源 https://mirrors.ustc.edu.cn/help/rpmfusion.html
# 使用下列命令（在 bash 或兼容 shell 中），可以同时启用其 free 和 nonfree 软件源
sudo dnf install -y https://mirrors.ustc.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.ustc.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# 在 Fedora 上，我们默认使用 openh264 库，因此您需要显式启用存储库。 
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
# 替换源地址
sudo sed -e 's|^metalink=|#metalink=|g' \
         -e 's|^#baseurl=http://download1.rpmfusion.org|baseurl=https://mirrors.ustc.edu.cn/rpmfusion|g' \
         -i.bak \
         /etc/yum.repos.d/rpmfusion*.repo

# ls /etc/yum.repos.d
# cat /etc/yum.repos.d/rpmfusion-free.repo
# cat /etc/yum.repos.d/rpmfusion-free-updates.repo
# 修改还原
# sudo mv /etc/yum.repos.d/rpmfusion-free.repo.bak /etc/yum.repos.d/rpmfusion-free.repo
# sudo mv /etc/yum.repos.d/rpmfusion-free-updates.repo.bak /etc/yum.repos.d/rpmfusion-free-updates.repo
# sudo mv /etc/yum.repos.d/rpmfusion-nonfree.repo.bak /etc/yum.repos.d/rpmfusion-nonfree.repo
# sudo mv /etc/yum.repos.d/rpmfusion-nonfree-updates.repo.bak /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
# sudo mv /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo.bak /etc/yum.repos.d/rpmfusion-nonfree-nvidia-driver.repo
# sudo mv /etc/yum.repos.d/rpmfusion-free-updates-testing.repo.bak /etc/yum.repos.d/rpmfusion-free-updates-testing.repo
# sudo mv /etc/yum.repos.d/rpmfusion-nonfree-steam.repo.bak /etc/yum.repos.d/rpmfusion-nonfree-steam.repo
# sudo mv /etc/yum.repos.d/rpmfusion-nonfree-updates-testing.repo.bak /etc/yum.repos.d/rpmfusion-nonfree-updates-testing.repo


# 中国科技大学 Flathub 镜像源 https://mirrors.ustc.edu.cn/help/flathub.html
# 在已有 flathub 远程源的基础上替换 Flatpak 默认的软件源
# Fedora默认安装了Flatpak，只要配置Flatpak加速镜像即可
echo "开始配置Flatpak加速镜像..."
# flatpak remotes --show-details
# 添加 Flathub 官方仓库
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# 修改 Flathub 仓库地址为国内镜像
# 2、中科大 Flatpak 镜像源（处于测试阶段） https://mirrors.ustc.edu.cn/help/flathub.html
sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
# 恢复默认值
# sudo flatpak remote-modify flathub --url=https://dl.flathub.org/repo
# flatpak remotes --show-details


# 修改完成后，清除并重建缓存
sudo dnf clean all && sudo dnf makecache


# 更新系统并升级所有已安装的包
echo "开始更新系统并升级所有已安装的包..."
sudo dnf update -y && sudo dnf upgrade -y
echo "系统更新、升级完成..."



# 安装必要的多媒体编解码器以支持高效的视频解码
# https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c#install-gstreamer-on-fedora
sudo dnf install -y gstreamer1-devel gstreamer1-plugins-base-tools gstreamer1-doc gstreamer1-plugins-base-devel gstreamer1-plugins-good gstreamer1-plugins-good-extras gstreamer1-plugins-ugly gstreamer1-plugins-bad-free gstreamer1-plugins-bad-free-devel gstreamer1-plugins-bad-free-extras

# dnf list gstreamer1-plugin*
sudo dnf install -y \
gstreamer1-plugins-{bad-\*,good-\*,base} \
gstreamer1-libav \
gstreamer1-plugins-bad-freeworld \
gstreamer1-plugins-fc


# 以下内容参考 https://docs.fedoraproject.org/zh_Hans/quick-docs/openh264/
# 从 fedora-cisco-openh264 存储库安装
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264 mozilla-ublock-origin
# 之后，您需要打开 Firefox，转到菜单 → 附加组件 → 插件 并启用 OpenH264 插件。
# 您可以在此页面 https://mozilla.github.io/webrtc-landing/pc_test.html 上对您的 H.264 是否在 RTC 中工作进行简单测试（检查需要 H.264 视频）。

# Firefox 配置更改 https://docs.fedoraproject.org/zh_Hans/quick-docs/openh264/
# 在 Firefox address/URL 字段中键入 about:config 并接受警告。
# 在搜索字段中，输入 264，将出现一些选项。通过双击 false，为以下 Preference Names 指定 true 值：
media.gmp-gmpopenh264.autoupdate
media.gmp-gmpopenh264.enabled
media.gmp-gmpopenh264.provider.enabled
media.peerconnection.video.h264_enabled
# 重启 Firefox 后，about:config 中的以下字符串将更改为从 Web 安装的当前版本：
# dnf list mozilla-openh264
media.gmp-gmpopenh264.version


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

# 安装Node.js
echo "安装Node.js..."
sudo dnf install -y nodejs
echo 你刚安装的 nodejs 版本号为：$(node -v)
echo 你刚安装的 npm 版本号为：$(npm -v)
# 最新地址 淘宝 NPM 镜像站喊你切换新域名啦!
npm config set registry https://registry.npmmirror.com
# 安装 Bun
sudo npm install -g bun
echo 你刚安装的 bun 版本号为：$(bun --version)
# 将 bunfig.toml 作为隐藏文件添加到用户主目录 https://www.bunjs.cn/docs/runtime/bunfig
echo '[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，地址为 https://developer.aliyun.com/mirror/
registry = "https://registry.npmmirror.com/"
' >> ~/.bunfig.toml
# which node
# whereis node
# whereis bun
# 将 IDEA 的 JS/TS 默认运行时环境从 nodejs 改为 bun 操作如下：
# 1、设置 -> 语言和框架 -> Bun -> /usr/local/bin/bun
# 2、设置 -> 语言和框架 -> Node.js -> Node解释器 -> /usr/local/bin/bun


# 配置 Rust Toolchain 反向代理 https://mirrors.ustc.edu.cn/help/rust-static.html
# 使用 rustup 前，先设置环境变量 RUSTUP_DIST_SERVER （用于更新 toolchain）：
echo 'export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static' >> ~/.bash_profile
# 以及 RUSTUP_UPDATE_ROOT （用于更新 rustup）：
echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup' >> ~/.bash_profile
source ~/.bash_profile
cat  ~/.bash_profile

echo "安装rust..."
# 安装 rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# 加载环境变量
source $HOME/.cargo/env
rustup update
# rustup self uninstall

#  配置 Cargo 国内加速镜像源
# 配置 Rust Crates Registry 源 https://mirrors.ustc.edu.cn/help/crates.io-index.html
# 如果正在使用 cargo 1.68 及以上版本，在 $HOME/.cargo/config.toml 中添加如下内容即可：
mkdir -p ~/.cargo && cat >> ~/.cargo/config.toml << 'EOF'
# 配置 Cargo 国内加速镜像源，可选：ustc、tuna、sjtu、aliyun、rsproxy
[source.crates-io]
replace-with = 'ustc'

# 中国科学技术大学镜像 https://mirrors.ustc.edu.cn/help/crates.io-index.html
[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

# 阿里云镜像
# 使用稀疏协议（sparse）减少元数据下载量，大幅加速
[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"
[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"
EOF


# 验证安装
echo 你刚安装的 rust 版本号为：$(rustc --version)
echo 你刚安装的 cargo 版本号为：$(cargo --version)

# 安装 SDKMAN  https://sdkman.java.net.cn/install/
# echo "安装SDKMAN..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
# echo 你刚安装的 sdkman 版本号为：$(sdk version)
sdk list java
# sdk uninstall java 24.0.2-graal
# 默认安装 Temurin(Eclipse) 的最新稳定版 Java，例如：21.0.8-tem
sdk install java
sdk install java 24.0.2-graal
sdk default java 21.0.8-tem
# 安装 maven/mvnd
sdk install maven
sdk install mvnd
# 安装 Kotlin，他 是一种静态类型编程语言，安卓开发必须搭配 gradle
sdk install kotlin
sdk install gradle
# 查看所有已安装的候选正在使用的版本
sdk current
# 刷新 SDKMAN 候选数据库，并检查已安装的候选有哪些可以升级
sdk update && sdk upgrade
# SDKMAN 自我更新，如果可用，则安装 SDKMAN！的新版本。
sdk selfupdate
# 查看环境变量配置，通过 sdkman 安装的所有候选都会自动配置环境变量，用户不需要自己再额外配置
echo $PATH    
# 下面的环境变量配置不需要配置，sdkman 已经配置了
echo '
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export PATH="$JAVA_HOME/bin:$PATH"
# 在 ~/.bashrc 或 ~/.zshrc 中确保 SDKMAN! 的 PATH 在最前面
export MAVEN_HOME="$HOME/.sdkman/candidates/maven/current"
export PATH="$MAVEN_HOME/bin:$PATH"
# 替换为你的 Gradle 安装路径
export GRADLE_HOME="$HOME/.sdkman/candidates/gradle/current"
export PATH="$GRADLE_HOME/bin:$PATH"
' >> ~/.bash_profile
source ~/.bash_profile
cat ~/.bash_profile

# 安装 JDK（示例：安装 Temurin JDK 17）https://docs.fedoraproject.org/en-US/quick-docs/installing-java/
# java-21-openjdk 包含完整的OpenJDK，包括图形化组件（如AWT、Swing、JavaFX等依赖的库）
# sudo dnf install -y java-latest-openjdk-headless
# 仅包含无图形界面的运行时环境（无AWT/Swing的图形依赖）fedora 默认安装这个
# sudo dnf install -y java-21-openjdk-headless
# which java
# whereis java
# ls -l /usr/lib/jvm/
# 一般为	/usr/lib/jvm/java-21-openjdk
# 查看 JAVA_HOME 配置    java -XshowSettings:properties -version 2>&1 | grep 'java.home'
# sudo dnf install -y java-21-openjdk
# dnf list java-*-openjdk
# 在 Java 版本之间切换
# sudo alternatives --config java
# nautilus admin:/usr/lib/jvm
# sudo dnf install -y maven gradle
echo 你刚安装的 java 版本号为：$(java --version)
echo 你刚安装的 kotlin 版本号为：$(kotlin --version)
echo 你刚安装的 maven 版本号为：$(mvn --version)
echo 你刚安装的 mvnd 版本号为：$(mvnd --version)
echo 你刚安装的 gradle 版本号为：$(gradle --version)


# 配置 Gradle 国内加速镜像
# 创建 Gradle 初始化脚本目录（不存在则新建）
mkdir -p ~/.gradle/init.d

# 创建镜像配置文件
cat > ~/.gradle/init.d/mirror.gradle << 'EOF'
allprojects {
    buildscript {
        repositories {
            // 优先使用阿里云镜像（Spring 官方仓库已包含在内）
            maven { url "https://maven.aliyun.com/repository/public" }
            maven { url "https://maven.aliyun.com/repository/spring" } // Spring 专属镜像
            maven { url "https://maven.aliyun.com/repository/spring-plugin" } // Spring 插件镜像
            
            // 备用腾讯云镜像（阿里云故障时自动切换）
            maven { url "https://mirrors.cloud.tencent.com/nexus/repository/maven-public/" }
            maven { url "https://mirrors.cloud.tencent.com/nexus/repository/spring/" }
            
            // 最后尝试官方仓库（国内通常无法直连）
            mavenCentral()
            gradlePluginPortal()
        }
    }
    
    repositories {
        // 同上，但移除插件仓库
        maven { url "https://maven.aliyun.com/repository/public" }
        maven { url "https://maven.aliyun.com/repository/spring" }
        maven { url "https://mirrors.cloud.tencent.com/nexus/repository/maven-public/" }
        mavenCentral()
    }
}
EOF

# 查看配置内容
cat ~/.gradle/init.d/mirror.gradle


# 安装 golang	https://learnku.com/go/wikis/38122
sudo dnf install -y golang
# 启用 Go Modules 功能
go env -w GO111MODULE=on
go env -w GOSUMDB=sum.golang.google.cn
# 阿里云
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
# 查看配置是否成功
go env | grep GOPROXY


# 安装 PostgreSQL
# 参考fedora官方文档 https://docs.fedoraproject.org/zh_CN/quick-docs/postgresql/
sudo dnf install -y postgresql-server postgresql-contrib
# 默认情况下，postgresql 服务器未运行且处于禁用状态。要将其设置为在启动时启动，请运行：
sudo systemctl enable postgresql
# 初始化数据库
# 安装后，需要使用初始数据填充数据库。可以使用以下命令完成数据库初始化。它创建配置文件 postgresql.conf 和 pg_hba.conf
# sudo postgresql-setup --initdb
sudo postgresql-setup --initdb --unit postgresql
# 要手动启动 postgresql 服务器，请运行
sudo systemctl start postgresql
# systemctl status postgresql
# psql --version
# PostgreSQL 在端口 5432（或您在 postgresql.conf 中设置的任何其他内容）上运行。在 firewalld 中，您可以像这样打开它：
# firewall-cmd --zone=public --list-ports
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
# 默认 postgres 管理员密码为空，此处设置为 postgres
# 在使用 postgres 用户时为 postgres 用户添加密码可能是个好主意：
# postgres=# \password postgres
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# PostgreSQL 配置文件
# sudo cat /var/lib/pgsql/data/postgresql.conf
# 使用 sed 修改 postgresql.conf
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
sudo sh -c "echo 'host    all             all             0.0.0.0/0               md5' >> /var/lib/pgsql/data/pg_hba.conf"
# 设置数据库后，您需要配置对数据库服务器的访问
sudo sed -i 's/^host    all             all             127\.0\.0\.1\/32            ident$/host    all             all             127.0.0.1\/32            md5/' /var/lib/pgsql/data/pg_hba.conf
# nautilus admin:/var/lib/pgsql/data/pg_hba.conf
# 重启 PostgreSQL 生效
sudo systemctl restart postgresql
# 使用默认的 postgres 用户，登录 PostgreSQL 控制台
sudo -u postgres psql
# 用户创建和数据库创建
CREATE USER lcqh WITH PASSWORD '479368';
CREATE DATABASE test_db OWNER lcqh;
GRANT ALL PRIVILEGES ON DATABASE test_db TO lcqh;
# 示例（连接刚创建的 testdb）：
psql -U lcqh -d test_db -W


# Fedora 内置 podman，无需安装    https://podman.org.cn/docs/installation#fedora
echo "安装podman..."
# Podman 默认为无守护进程的 rootless 模式（普通用户直接操作）：
echo Fedora 内置 podman 版本号为：$(podman --version)
sudo dnf install -y podman-compose
echo 安装的 podman-compose 版本号为：$(podman-compose --version)
# 主要用于 登录到容器镜像仓库（Registry），以便拉取（pull）私有镜像或推送（push）镜像到仓库。
# lcqh2635@gmail.com
podman login
# 配置国内加速镜像仓库
cat /etc/containers/registries.conf
# 备份到同目录（添加 .bak 后缀）
sudo cp /etc/containers/registries.conf{,.bak}
# 检查 .bak 文件是否存在
ls -l /etc/containers
# 从同目录 .bak 文件恢复
sudo cp /etc/containers/registries.conf{.bak,}

sudo bash -c 'cat <<EOF >> /etc/containers/registries.conf

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
EOF'

# 重启 podman 相关服务（如果使用了 API 服务）
sudo systemctl restart podman  # 仅当启用了 podman 服务时需执行
systemctl status podman
# Podman 本身是一个守护进程，但默认不自动启动。可以手动启用
sudo systemctl enable --now podman.service
# podman info
flatpak install -y flathub \
com.github.marhkb.Pods \
io.podman_desktop.PodmanDesktop \


# podman pull redis
# 后台运行 Nginx
# podman run -d --name redis_db -p 6379:6379 redis:latest
# 查看运行中的容器
# podman ps
# 查看所有容器（包括已停止的）
# podman ps -a
# podman stop redis_db
# 删除已经运行过，但现在是 stop 停止状态的容器实例，也就是删除 podman run 产生的容器实例。最原始下载的镜像依旧存在
# podman rm redis_db
# 删除最原始下载的镜像，也就是删除 podman pull redis 拉取的内容
# podman rmi redis
# 查看 Podman 系统服务（适用于 rootful 模式）
# systemctl status podman
# systemctl start podman
# Rootless 用户级 socket
# systemctl --user enable --now podman.socket
# podman run -d --name my_container --restart=always nginx
podman pull debian:trixie-slim
podman pull debian:stable-slim
# -it：分配一个交互式终端（-i 交互式，-t 伪终端）
# /bin/bash：启动容器后执行的命令（这里是启动 Bash Shell）
podman run -it --name debian debian:trixie-slim /bin/bash

## 6. 用户个性化设置 ===========================================
# 安装 TLP 优化续航
echo "设置TLP 优化续航..."
sudo dnf install -y tlp tlp-rdw
sudo systemctl enable --now tlp

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

## 7. 清理和完成 ==============================================

# 清理缓存
echo "清理缓存..."
sudo dnf autoremove && sudo dnf clean all

# 完成提示
echo "==================================================="
echo "Fedora GNOME 42 优化配置完成！"
echo "建议操作："
echo "1. 重启系统使所有更改生效"
echo "2. 使用GNOME Tweaks进一步自定义桌面"
echo "3. 检查系统设置中的区域和语言选项"
echo "==================================================="

# sudo dnf install -y zsh zsh-syntax-highlighting zsh-autosuggestions


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

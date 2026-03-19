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
configure_basics_gsettings() {
# 设置强调色为蓝色
gsettings set org.gnome.desktop.interface accent-color 'blue'
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
# 设置窗口按钮位置 (右)
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
# 禁用动态工作区
gsettings set org.gnome.mutter dynamic-workspaces false
# 设置工作区数量为3（奇数确保有中间位）
gsettings set org.gnome.desktop.wm.preferences num-workspaces 3
# 预设工作区名称
gsettings set org.gnome.desktop.wm.preferences workspace-names "['工作/代码', '浏览/文档', '娱乐/交流']"

# 自定义快捷键优化，Alt 管理工作区、Super 管理窗口
# gsettings list-recursively org.gnome.desktop.wm.keybindings
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last "['<Alt>End']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Alt>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Alt>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Alt>3']"
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>c']"

# nautilus ~/.local/share/backgrounds/
cd ~/下载
wget "https://gitee.com/lcqh2635/linux/raw/master/壁纸/wallpaper-light.jpg"
wget "https://gitee.com/lcqh2635/linux/raw/master/壁纸/wallpaper-dark.jpg"
wget "https://gitee.com/lcqh2635/linux/raw/master/壁纸/wallpaper-noon.jpg"
cp -v ~/下载/wallpaper-light.jpg ~/.local/share/backgrounds/
cp -v ~/下载/wallpaper-dark.jpg ~/.local/share/backgrounds/
cp -v ~/下载/wallpaper-noon.jpg ~/.local/share/backgrounds/
# gsettings list-recursively org.gnome.desktop.background
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/wallpaper-light.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/wallpaper-dark.jpg"
}
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# https://docs.fedoraproject.org/zh_Hans/quick-docs/adding-or-removing-software-repositories-in-fedora/
# dnf config-manager --help
# 查看所有仓库
# dnf repolist --all
# 禁用仓库
sudo dnf config-manager setopt copr:copr.fedorainfracloud.org:phracek:PyCharm.enabled=0
# 在 DNF 5 中，彻底移除第三方仓库的最标准方法依然是手动删除对应的 .repo 文件，下列会打印与每个 Yum 仓库关联的仓库 ID 列表
# grep -E "^\[.*]" /etc/yum.repos.d/*
# 删除仓库文件
sudo rm /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
# 删除文件后，必须清理 DNF 缓存以生效
sudo dnf clean all
# 重建 DNF 缓存
sudo dnf makecache

# 配置固定加速镜像源
configure_fixed_mirror() {
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

# RPM Fusion 默认使用 metalink 来根据用户发出请求的 IP 选择合适的镜像，通常情况下并不需要手动换源
# 中国科技大学 RPMFusion 镜像源	https://mirrors.ustc.edu.cn/help/rpmfusion.html
# 使用下列命令（在 bash 或兼容 shell 中），可以同时启用其 free 和 nonfree 软件源
sudo dnf install -y https://mirrors.ustc.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://mirrors.ustc.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
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
}

# 还原上述固定加速镜像源配置
reset_fixed_mirror() {
# 还原上述 fedora 修改
# 遍历 /etc/yum.repos.d/ 目录下所有以 fedora 开头且以 .bak 结尾的文件，并去除末尾的 .bak 后缀
for i in /etc/yum.repos.d/fedora*.bak; do sudo mv "$i" "${i%.bak}"; done
# 还原上述 RPM Fusion 修改
# 遍历 /etc/yum.repos.d/ 目录下所有以 rpmfusion 开头且以 .bak 结尾的文件，并去除末尾的 .bak 后缀
for i in /etc/yum.repos.d/rpmfusion*.bak; do sudo mv "$i" "${i%.bak}"; done
}


# 如何在Fedora Linux上提高DNF速度
configure_dnf_acceleration() {
# https://linuxcapable.com/increase-dnf-speed-on-fedora-linux/
# 当Fedora上DNF感觉很慢时，等待通常来自两个原因：保守的下载行为和镜像选择与你的网络路径不匹配。
# 要提高 Fedora 的 DNF 速度，可以启用并行下载并测试 fastestmirror，这样大规模更新和多包安装时可以减少一次只等待一个包的时间。
# 当前的Fedora版本使用DNF5，最简洁的更改方式是使用 dnf config-manager setopt，而不是先在编辑器中打开/etc/dnf/dnf.conf。
# 这样可以保持更改的可重复性，清晰显示当前运行时的值，并且方便之后降低max_parallel_downloads或关闭fastestmirror=true。
# https://mirrormanager.fedoraproject.org/
# https://dnf-plugins-core.readthedocs.io/en/latest/
# https://github.com/rpm-software-management/dnf5
sudo dnf install -y dnf5 dnf-plugins-core
# 先从安全刷新开始，这样你可以用当前的元数据对比后续运行。--assumeno 标志会预览交易并在 DNF 安装任何东西前退出
sudo dnf upgrade --refresh --assumeno
# 在Fedora上，DNF默认为max_parallel_downloads=3，fastestmirror=False。这安全且可预测，但当连接稳定且镜像路径良好时，下载速度可能会明显受影响。
# Fedora已经给出了DNF工作镜像列表，所以fastestmirror=True值得测试，但不值得当作绝对标准。如果启用后刷新速度变慢，就关闭该选项，保持并行下载。
# 这会把数值写入你的主配置文件，地址是 /etc/dnf/dnf.conf。如果你之后检查文件，应该会在[main]下方看到这些行：
sudo dnf config-manager setopt max_parallel_downloads=10 fastestmirror=True
# 现在验证当前运行时的值，而不仅仅是检查文件内容：
dnf --dump-main-config | grep -E '^(fastestmirror|max_parallel_downloads) = '
# 执行一次 DNF 操作（如检查更新），观察输出信息。如果配置成功，你会看到类似以下的提示，表明它正在检测镜像速度：
sudo dnf check-update
# ls /etc/dnf && cat /etc/dnf/dnf.conf
}

# 更新 dnf 包列表、升级 dnf 包、 删除无用依赖
sudo dnf update -y && sudo dnf upgrade --refresh -y && sudo dnf autoremove -y
# 删除无用的应用
sudo dnf remove -y mediawriter libreoffice-*
# ShellCheck 是一个专门用于分析 Shell 脚本的工具，它能发现语法错误、逻辑隐患、未引用的变量、过时的写法等，而无需运行脚本
sudo dnf install -y ShellCheck
# shellcheck fedora-setup.sh

# https://docs.fedoraproject.org/zh_Hans/quick-docs/autoupdates/
sudo dnf install -y dnf-automatic
# ls /etc/dnf && cat /etc/dnf/automatic.conf
# 默认情况下，dnf-automatic 会从 /etc/dnf/automatic.conf 文件中的配置中运行。这些配置只会下载，但不会应用任何包。
# 要更改或添加任何配置，请以 root 用户身份（或使用sudo）从终端窗口打开 .conf 文件。
# 修改 automatic.conf 以下载所有更新、应用并重启，可以是：
cat << EOF | sudo tee /etc/dnf/automatic.conf
[commands]
apply_updates=True
reboot=when-needed
EOF
# 配置完成后，执行以下命令以启用并启动系统D计时器
systemctl enable --now dnf-automatic.timer
# 检查DNF-自动状态：
# systemctl status dnf-automatic.timer


# Fedora 安装 Chromium 或 Google Chrome 浏览器
# https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-chromium-or-google-chrome-browsers/
# 安装第三方仓库
sudo dnf install -y fedora-workstation-repositories
# 禁用 Google Chrome 仓库，由于从该仓库中安装的 Google Chrome 只有一个暗色主题，无法根据系统切换主题，所以禁用
sudo dnf config-manager setopt google-chrome.enabled=0
# 启用 Google Chrome 仓库：
# sudo dnf config-manager setopt google-chrome.enabled=1
# 最后，安装  Google Chrome 浏览器：
# sudo dnf install -y google-chrome-stable
# sudo dnf remove -y google-chrome-stable
# 创建一个 Google Chrome 扩展，复刻 Dev Toolbox 的功能

# 删除官方 Fedora Flatpaks 源
sudo flatpak remote-delete fedora
# Flathub 官方在 Fedora 配置文件 https://flathub.org/zh-Hans/setup/Fedora
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
# 上海交通大学 Flatpak 软件源镜像
# sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
sudo flatpak update --appstream
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


# development-tools 是一个预定义的软件包组，包含一组常用的开发工具和库，用于支持软件开发工作。例如：git
# c-development 是简化C开发环境配置的包组，安装后即可获得编译、调试和构建C程序所需的核心工具。如果你需要开发C程序，安装它或对应的包组是第一步。例如：gcc、gcc-c++
# rpm-development-tools	是专门用于 RPM 包开发 的工具集，适合软件打包、维护或发布 RPM 格式的软件。例如：rpm-build、rpmdevtools
# dnf group install 			# 旨在为开发者提供一个基础的开发环境，而无需手动安装每个工具。
# dnf group list			# 查看可用的软件包组
# dnf group info development-tools	# 查看软件包组的信息
# dnf group info c-development		# 查看软件包组的信息
sudo dnf group install -y development-tools c-development rpm-development-tools
# 安装虚拟化基础
sudo dnf group install -y --with-optional virtualization
# 安装多媒体编解码器 https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-plugins-for-playing-movies-and-music/
# multimedia 包组提供了一套完整的音视频处理工具链，适合普通用户或开发者处理多媒体任务。例如：gstreamer1-plugin-* 以包含 gstreamer1-plugin-openh264 等
# 作为 Fedora 用户和系统管理员，您可以使用这些步骤来安装额外的多媒体插件，使您能够播放各种视频和音频类型。 
# 对于 fedora 41 及更高版本，安装用于播放电影和音乐的插件
sudo dnf group install -y multimedia
# https://docs.fedoraproject.org/zh_Hans/quick-docs/openh264/
# 从 fedora-cisco-openh264 存储库安	dnf list gstreamer1-plugin-*
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264 mozilla-ublock-origin
# 之后，您需要打开 Firefox，转到菜单 → 附加组件 → 插件 并启用 OpenH264 插件。
# 您可以在此页面 https://mozilla.github.io/webrtc-landing/pc_test.html 上对您的 H.264 是否在 RTC 中工作进行简单测试（检查需要 H.264 视频）


# 安装fedora的多媒体组，以下内容参考 https://rpmfusion.org/Howto/Multimedia
# 切换到完整的 ffmpeg，使用 swap 命令为替换操作
# FFmpeg-Free 是 Fedora 默认提供的一个受限版本，仅包含开源且无专利限制的编解码器。
# FFmpeg 是一个功能强大的多媒体处理工具集，支持视频、音频的编码、解码、转码、流媒体传输等功能。
# 它支持广泛的编解码器（如 H.264、HEVC、AAC 等），包括一些专利保护的编解码器。 
# Fedora ffmpeg-free 在大多数时候都能正常工作，但有时会遇到版本不匹配的情况。切换到 rpmfusion 提供的 ffmpeg 构建，它得到了更好的支持。您仍然需要按照下一节了解与您可能已安装的软件包相关的其他编解码器或插件。
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
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
# evolution配置qq邮箱授权码： embwnsuwkdjrebge
echo "安装常用应用程序..."
sudo dnf install -y \
git wget curl unzip p7zip \
fastfetch wl-clipboard \
gnome-tweaks gnome-browser-connector \
libadwaita-demo
# Tauri 在 Linux 上进行开发需要各种系统依赖项。这些可能会有所不同，具体取决于你的发行版，在 Fedora 系统中需安装以下依赖：
# https://tauri.app/zh-cn/start/prerequisites/#linux
sudo dnf check-update
sudo dnf install -y \
webkit2gtk4.1-devel \
openssl-devel curl wget file \
libappindicator-gtk3-devel \
librsvg2-devel libxdo-devel
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


# 安装编程语言开发环境
install_development_environment() {
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
    # Claude Code 是一款存在于终端中的代理编码工具，理解你的代码库，并通过自然语言命令帮助你执行例行任务、
    # 解释复杂代码和处理 git 工作流程，从而更快地完成代码。在你的终端、IDE或Github上的标签@claude中使用。
    # https://www.npmjs.com/package/@anthropic-ai/claude-code
    npm install -g @anthropic-ai/claude-code
    # https://openclaw.cc/
    npm install -g openclaw
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
    
    # 安装 Bun 运行时环境	https://www.bunjs.cn/docs/installation
    # bun - 现代的 JavaScript 运行时和包管理器
    # https://www.npmjs.com/package/bun
    npm install -g bun
    # bun create vite my-vue-app --template vue-ts
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
    # ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 通过 dnf 安装 (推荐)
# https://docs.fedoraproject.org/zh_Hans/quick-docs/installing-java/
sudo dnf install -y java-25-openjdk maven4 maven4-openjdk25
# sudo dnf remove -y maven
echo "🐍 你刚安装的 java 版本号为：$(java --version)"
echo "🐍 你刚安装的 maven 版本号为：$(mvn --version)"
echo "🐍 你刚安装的 maven 版本号为：$(mvn4 --version)"
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
cat << EOF | tee ${CARGO_HOME:-$HOME/.cargo}/config.toml
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
flatpak install -y flathub com.github.marhkb.Pods
# 在 Fedora 上使用 Kubernetes 官方文档 https://docs.fedoraproject.org/zh_Hans/quick-docs/using-kubernetes/
# Fedora 40（及更新版本）安装 Kubernetes 建议 https://docs.fedoraproject.org/zh_Hans/quick-docs/using-kubernetes-non-versioned/#sect-fedora-40-recommendations
# Kubelet 是节点上的 Kubernetes 运行时。对应 kubernetes 包
# Kubeadm 初始化集群并将新节点加入集群。这个rpm是可选的，但由Kubernetes团队推荐。如果使用，请在每个节点上安装。
# kubectl 命令行客户端。建议在任何配置为控制平面的节点上使用，因为它允许集群管理员从控制平面的SSH会话中对集群进行控制。在可以通过网络连接到集群的机器上安装。
# kubernetes-systemd 用于 Kubernetes 控制平面和/或节点的 Systemd 服务。对于大多数安装，不需要这些服务，因为 kubeadm 会将这些组件作为静态 Pod 安装。如果使用，则需要在所有节点上安装。
# 使用 systemctl 在所有节点上启用 kube-proxy。在控制平面节点上启用 kube-apiserver、kube-controller-manager 和 kube-scheduler。
sudo dnf install -y kubernetes kubernetes-kubeadm kubernetes-client
sudo systemctl enable --now kubelet
# 查看 kubelet 服务状态
# systemctl status kubelet
# kubelet 每个节点都在运行的服务，管理本节点上的所有 Pod 和容器
echo "🐍 你安装的 kubernetes 版本号为：$(kubelet --version)"
# Kubeadm 初始化集群并将新节点加入集群
echo "🐍 你安装的 kubernetes-kubeadm 版本号为：$(kubeadm version)"
# kubectl 是 Kubernetes 命令行客户端，由 kubernetes-client 包提供
echo "🐍 你安装的 k8s 命令行工具 kubectl 版本号为：$(kubectl version --client)"
# IDEA 添加 Kubernetes 集群，参考 jetbrains 官方文档 https://www.jetbrains.com/zh-cn/help/idea/kubernetes.html
# 在 设置 对话框（Ctrl + Alt + S ）中，选择 构建、执行、部署 | Kubernetes。测试好 kubectl（K8s 的命令行工具 CLI） 和 Helm（K8s 的“包管理器”） 
# 有关群集的信息存储在 kubeconfig 文件中。 IntelliJ IDEA 会检测默认的 kubeconfig 文件，这个文件通常位于 $HOME/.kube/config （此位置可以通过 KUBECONFIG 环境变量更改）。
# https://docs.fedoraproject.org/zh_Hans/quick-docs/using-kubernetes-kubeadm/
# 使用 kubeadm 初始化 Kubernetes 集群
flatpak install -y flathub dev.skynomads.Seabird
# ------------------------------------------------------------------------------
}


# 安装基础应用软件
install_basic_application_software() {
    # 不推荐在 flatpak install 命令前加 sudo 这样不需要 root 权限，不会影响系统其他用户，卸载或管理时也不需要密码，更安全。
    # 对于个人日常使用，请去掉 sudo。这样不需要每次输入密码、更方便、更安全，也符合 Flatpak 的设计初衷

    # 浏览并安装GNOME Shell扩展以定制你的桌面
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    # 为 Linux 上的 Flathub 提供支持的 Flatpak 应用商店
    flatpak install -y flathub io.github.kolunmi.Bazaar
    # Flatseal 是一种图形工具，用于审查和修改 Flatpak 应用程序中的权限
    flatpak install -y flathub com.github.tchx84.Flatseal
    # Warehouse 提供了一个简单的用户界面来控制复杂的 Flatpak 选项，而且完全无需借助命令行
    flatpak install -y flathub io.github.flattool.Warehouse
    # 卸载Flatpak时，可能会在电脑上留下一些文件。Flatsweep 帮助您轻松清除未安装 Flatpak 残留在系统上的残留物
    flatpak install -y flathub io.github.giantpinkrobots.flatsweep
    # Evolution 是一款个人信息管理应用，提供集成的邮件、日历和地址簿功能
    flatpak install -y flathub org.gnome.Evolution
    # 一款高级用户工具，允许在支持fwupd的设备上更新、重装和降级固件
    flatpak install -y flathub org.gnome.Firmware
    # 更改 GDM 设置； 应用主题和背景、更改光标主题、图标主题和夜灯设置等
    flatpak install -y flathub io.github.realmazharhussain.GdmSettings
    # 轻松地将磁盘镜像写入你的硬盘。选择一张图片，插入你的硬盘，就可以开始了
    flatpak install -y flathub io.gitlab.adhami3310.Impression
    # 用干净、无干扰的标记删除编辑器专注于你的写作
    flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe
    # 忘记忘记事情
    flatpak install -y flathub io.github.alainm23.planify
    # 你可以从拥有简洁友好的用户界面的在线来源获取字体。Sitra为安装、卸载和预览字体提供了无缝体验
    flatpak install -y flathub io.github.sitraorg.sitra
    # Refine 帮助发现 GNOME 中的高级和实验性功能
    flatpak install -y flathub page.tesk.Refine
    # 一款用 GTK4 编写的轻量级音乐播放器，专注于大型音乐收藏
    flatpak install -y flathub com.github.neithern.g4music
    # 开启桌面歌词功能需要的依赖 https://github.com/osdlyrics/osdlyrics
    # netease-cloud-music-gtk 是使用 Rust + GTK 开发的网易云音乐客户端，专为 Linux 系统打造
    flatpak install -y flathub com.github.gmg137.netease-cloud-music-gtk
    # 一个轻松管理 AppImages 的工具！齿轮杆可以帮你整理和管理 AppImage 文件，生成桌面条目和应用元数据，原地更新应用，或将多个版本并排保存
    flatpak install -y flathub it.mijorus.gearlever
    # Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
    flatpak install -y flathub com.google.Chrome
    # Playhouse 让原型制作、教学、设计、学习和构建网页内容变得简单
    flatpak install -y flathub re.sonny.Playhouse
    # Workbench 是用来学习和用 GNOME 技术做原型设计的，无论是第一次动手还是构建和测试 GTK 用户界面
    flatpak install -y flathub re.sonny.Workbench
    # 这是一组功能强大但易于使用的工具，用于解决最常见的日常开发问题
    flatpak install -y flathub me.iepure.devtoolbox
    # Diffuse 是一个用于比较和合并文本文件的图形工具。它可以从 Bazaar、CVS、Darcs、Git、Mercurial、Monotone、RCS 和 Subversion 仓库中获取要比较的文件
    flatpak install -y flathub io.github.mightycreak.Diffuse
    # Bottles 允许你在 Linux 上运行 Windows 软件，比如应用程序和游戏
    flatpak install -y flathub com.usebottles.bottles
    # Builder 是一个为 GNOME 积极开发的集成开发环境。它将对关键 GNOME 技术（如 GTK、GLib 和 GNOME API）的集成支持与任何开发者都会欣赏的功能相结合
    flatpak install -y flathub org.gnome.Builder
    # 一个易用的BitTorrent客户端。片段可以通过BitTorrent点对点文件共享协议传输文件，例如视频、音乐或Linux发行版的安装映像
    flatpak install -y flathub de.haeckerfelix.Fragments
    # GNOME的网页浏览器，与桌面紧密集成，界面简单直观，让你能够专注于网页。如果你在寻找一个简单、干净、美丽的网页视图，这款浏览器就是你的首选
    flatpak install -y flathub org.gnome.Epiphany
    flatpak install -y flathub com.qq.QQ
    flatpak install -y flathub com.tencent.WeChat
    # OSTREE_DEBUG_HTTP=1 flatpak install -y flathub me.iepure.devtoolbox

    # ------------------------------------------------------------------------------
    # 1. 进入下载目录 (假设你的安装包在这里)
    cd ~/下载
    # JetBrains 的 API 返回的 JSON 中包含 多个架构的下载链接，你的 grep 命令会匹配 所有 包含 jetbrains-toolbox-*.tar.gz 的链接，
    # 而 head -1 恰好取到了第一个（可能是 arm64）
    # 关键：| grep -v 'arm64' 会过滤掉包含 "arm64" 的链接
    wget -O jetbrains-toolbox.tar.gz "$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -o 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^\"]*\.tar\.gz' | grep -v 'arm64' | head -1)"
    # 2. 创建一个专门放软件的目录 (例如在 home 目录下创建一个 apps 文件夹)
    mkdir -p ~/.apps
    # 3. 解压到刚才创建的目录
    # 注意：将 jetbrains-toolbox*.tar.gz 替换为你实际下载的文件名，可以用 Tab 键自动补全
    tar -xvf jetbrains-toolbox*.tar.gz -C ~/.apps
    # nautilus ~/.apps
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
    # nautilus ~/.jetbra
    # 自动配置  jetbrains 代码编辑器 vmoptions
    ~/.jetbra/scripts/install.sh
    # ------------------------------------------------------------------------------
}

# VPN 相关软件和订阅来源
# https://gh-proxy.com/
# https://github.akams.cn/
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
    # https://github.com/hiddify/hiddify-app/blob/main/README_cn.md
    # 一款基于 Sing-box 通用代理工具的跨平台代理客户端。Hiddify 提供了较全面的代理功能，例如自动选择节点、TUN 模式、使用远程配置文件等。Hiddify 无广告，并且代码开源。
    # 它为大家自由访问互联网提供了一个支持多种协议的、安全且私密的工具。多种订阅链接和配置文件格式支持： Sing-box、V2ray、Clash、Clash meta
    # Hiddify 使用教程 https://hiddify.la/tutorial/
    # 免费通用机场节点仓库  https://github.com/mksshare/mksshare.github.io
    	# https://pPiPDy.mcsslk.xyz/fa998be69a450c433133472d2ddd7a68
    	# https://woDF6n.tosslk.xyz/2c58cc7fb6edb08f1b88e0ce07f03f78
    # 对于 AppImage 格式应用的安装，先打开 AppImage 安装管理器 Gear Lever 这个软件 flatpak run it.mijorus.gearlever 配置 AppImage 安装目录为 ~/.apps 然后点击 + 添加下面的 AppImage 应用
    wget "https://gh-proxy.org/https://github.com/hiddify/hiddify-app/releases/download/v4.1.1/Hiddify-Linux-x64-AppImage.AppImage"
}


# 安装 gnome shell 扩展插件
install_gnome_extensions() {
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
    gnome-shell-extension-appindicator \
    gnome-shell-extension-auto-move-windows \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-forge \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-just-perfection \
    gnome-shell-extension-light-style \
    gnome-shell-extension-no-overview \
    gnome-shell-extension-drive-menu \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-workspace-indicator
    
    # 列出所有用户级扩展
    # gnome-extensions list --user
    # 查看所有用户级扩展的文件目录
    # nautilus ~/.local/share/gnome-shell/extensions
    sudo dnf install -y gettext meson just
    mkdir -p ~/下载/extensions && cd ~/下载/extensions
    git clone https://gh-proxy.com/https://github.com/fthx/appmenu-is-back.git
    git clone https://gh-proxy.com/https://github.com/Tommimon/add-to-desktop.git
    git clone https://gitlab.com/smedius/desktop-icons-ng.git
    git clone https://gh-proxy.com/https://github.com/Exeos/disable-unredirect.git
    git clone https://gh-proxy.com/https://github.com/tuxor1337/hidetopbar.git
    git clone https://gh-proxy.com/https://github.com/lennart-k/gnome-rounded-corners.git
    git clone https://gh-proxy.com/https://github.com/flexagoon/rounded-window-corners.git
    git clone https://gh-proxy.com/https://github.com/maniacx/Bluetooth-Battery-Meter.git
    git clone https://gh-proxy.com/https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git
    git clone https://gh-proxy.com/https://github.com/hermes83/compiz-alike-magic-lamp-effect.git
    git clone https://gitlab.com/rmnvgr/nightthemeswitcher-gnome-shell-extension.git
    git clone https://gh-proxy.com/https://github.com/icedman/search-light.git
    git clone https://gh-proxy.com/https://github.com/amivaleo/Show-Desktop-Button.git
    git clone https://gitlab.com/p91paul/status-area-horizontal-spacing-gnome-shell-extension.git
    git clone https://gh-proxy.com/https://github.com/StorageB/custom-command-menu.git
    git clone https://gh-proxy.com/https://github.com/tuberry/desktop-lyric.git
    git clone https://gh-proxy.com/https://github.com/subz69/pigeon.git
    git clone https://gitlab.com/paddatrapper/shortcuts-gnome-extension.git
    git clone https://gh-proxy.com/https://github.com/ChrisLauinger77/gnome-shell-extension-SmartAutoMoveNG.git
    cd ~/下载/extensions && zip -FSr appmenu-is-back.zip appmenu-is-back/* && gnome-extensions install -f appmenu-is-back.zip
    cd ~/下载/extensions/add-to-desktop && ./build.sh && gnome-extensions install -f output/add-to-desktop@tommimon.github.com.v15.shell-extension.zip
    cd ~/下载/extensions/desktop-icons-ng && ./scripts/local_install.sh
    cd ~/下载/extensions/disable-unredirect && make install
    cd ~/下载/extensions/hidetopbar && make && gnome-extensions install -f hidetopbar.zip
    cd ~/下载/extensions/gnome-rounded-corners && make && gnome-extensions install -f Rounded_Corners@lennart-k.zip
    cd ~/下载/extensions/rounded-window-corners && just install
    cd ~/下载/extensions/Bluetooth-Battery-Meter && ./install.sh
    cd ~/下载/extensions/gnome-shell-extension-clipboard-indicator && make bundle && gnome-extensions install -f bundle.zip
    cd ~/下载/extensions/compiz-alike-magic-lamp-effect && ./zip.sh && gnome-extensions install -f compiz-alike-magic-lamp-effect@hermes83.github.com.zip
    cd ~/下载/extensions/nightthemeswitcher-gnome-shell-extension && meson setup builddir --prefix=~/.local && meson install -C builddir
    cd ~/下载/extensions/search-light && make
    cd ~/下载/extensions && mv Show-Desktop-Button show-desktop-button@amivaleo && zip -r show-desktop-button@amivaleo.zip show-desktop-button@amivaleo && gnome-extensions install -f show-desktop-button@amivaleo.zip
    cd ~/下载/extensions/status-area-horizontal-spacing-gnome-shell-extension && ./buildforupload.sh && gnome-extensions install -f status-area-horizontal-spacing@mathematical.coffee.gmail.com.zip
    cd ~/下载/extensions/custom-command-menu && ./buildforupload.sh && gnome-extensions install -f status-area-horizontal-spacing@mathematical.coffee.gmail.com.zip
    cd ~/下载/extensions/desktop-lyric && meson setup build && meson install -C build
    cd ~/下载/extensions/pigeon && make install
    cd ~/下载/extensions/shortcuts-gnome-extension && ./shortcuts.sh install
    cd ~/下载/extensions/gnome-shell-extension-SmartAutoMoveNG && zip -r SmartAutoMoveNG@lauinger-clan.de.zip SmartAutoMoveNG@lauinger-clan.de && gnome-extensions install -f SmartAutoMoveNG@lauinger-clan.de.zip
    # 系统级别构建安装，默认 --prefix=/usr/local
    # meson setup build -Dtarget=system && meson install -C build

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
}


# 更新 dnf 包列表、升级 dnf 包、 删除无用依赖
sudo dnf update -y && sudo dnf upgrade -y && sudo dnf autoremove -y


# 安装 gnome shell 扩展插件
install_and_configure_theme() {
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

    mkdir -vp ~/下载/WhiteSur-themes && cd ~/下载/WhiteSur-themes
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-wallpapers.git --depth=1
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
    git clone https://gh-proxy.com/https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
    # 修改 Nautilus 侧边栏不透明度，参考 https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1127
    # grep '$opacity: ' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    # sed -i 's/\$opacity: 0\.96/\$opacity: 1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    sed -i 's/0\.96/1/g' ~/下载/WhiteSur-themes/WhiteSur-gtk-theme/src/sass/_colors.scss
    sed -i 's/0\.95/1/g' ~/下载/WhiteSur-themes/WhiteSur-gtk-theme/other/firefox/WhiteSur/colors/light.css
    sed -i 's/0\.95/1/g' ~/下载/WhiteSur-themes/WhiteSur-gtk-theme/other/firefox/WhiteSur/colors/dark.css
    cd ~/下载/WhiteSur-themes/WhiteSur-wallpapers && ./install-wallpapers.sh && sudo ./install-gnome-backgrounds.sh
    # gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Ventura/Ventura-timed.xml'
    cd ~/下载/WhiteSur-themes/WhiteSur-cursors && ./install.sh
    cd ~/下载/WhiteSur-themes/WhiteSur-icon-theme && ./install.sh
    # 在执行 ./tweaks.sh -f flat 安装 Firefox 主题时，Firefox 不能正在运行
    if pgrep firefox > /dev/null; then
        print_info "Firefox 正在运行，正在杀死进程..."
        pkill firefox && sleep 3
    else
        print_info "Firefox 未在运行..."
        # 快速启动 Firefox 并在 3 秒后杀死它
        firefox & sleep 3 && pkill firefox
    fi
    # firefox not yet initialized error
    # https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1384
    # git clone https://cdn.gh-proxy.org/https://github.com/Sayanduary/WhiteSur-gtk-theme.git
    # 为 libadwaita 安装，默认是普通暗色主题
    cd ~/下载/WhiteSur-themes/WhiteSur-gtk-theme && ./install.sh -l -o solid && ./tweaks.sh -f flat -F -o solid
    # cd ~/下载/WhiteSur-gtk-theme && ./install.sh -l -o solid && ./tweaks.sh -f monterey -F -o solid
    # 使用自定义背景
    # sudo ./tweaks.sh -g -b "$HOME/.local/share/backgrounds/Ventura-light.jpg"
    sudo ~/下载/WhiteSur-themes/WhiteSur-gtk-theme/tweaks.sh -g -b "$HOME/.local/share/backgrounds/wallpaper-noon.jpg"
    # 如果文件都在当前目录
    cd ~/下载 && rm -rf WhiteSur-*
    # cd ~/下载/WhiteSur-themes && rm -rf WhiteSur-{cursors,icon-theme,gtk-theme}

    # 安装 Ubuntu 的声音主题
    sudo dnf install -y yaru-sound-theme
    gsettings set org.gnome.desktop.sound theme-name 'Yaru'
}

# 卸载主题
uninstall_theme() {
    cd ~/下载/WhiteSur-themes/WhiteSur-wallpapers && ./install-wallpapers.sh -u && sudo ./install-gnome-backgrounds.sh -u
    cd ~/下载/WhiteSur-themes/WhiteSur-cursors && ./install.sh
    cd ~/下载/WhiteSur-themes/WhiteSur-icon-theme && ./install.sh
    cd ~/下载/WhiteSur-themes/WhiteSur-gtk-theme && ./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r
}

# 重置系统字体配置
reset_font() {
    gsettings reset org.gnome.desktop.interface font-name
    gsettings reset org.gnome.desktop.interface document-font-name
    gsettings reset org.gnome.desktop.interface monospace-font-name
    gsettings reset org.gnome.desktop.wm.preferences titlebar-font
    gsettings reset org.gnome.desktop.interface font-antialiasing
    gsettings reset org.gnome.desktop.interface font-hinting
}

# 重置系统主题配置
reset_theme() {
    gsettings reset org.gnome.desktop.interface cursor-theme
    gsettings reset org.gnome.desktop.interface icon-theme
    gsettings reset org.gnome.shell.extensions.user-theme name
    gsettings reset org.gnome.desktop.interface gtk-theme
    gsettings reset org.gnome.desktop.wm.preferences theme
    gsettings reset org.gnome.desktop.sound theme-name
}

set_theme_example() {
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
}

# ------------------------------------------------------------------------------
# 主执行流程
# ------------------------------------------------------------------------------
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Fedora 初始化配置脚本 v2.0${NC}"
    echo -e "${BLUE}  作者：龙茶清欢 (优化版)${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    wait_for_network

    if ! confirm_action "即将开始系统配置，过程中可能需要输入 sudo 密码。是否继续？"; then
        exit 0
    fi

    # 1. 基础 GNOME 设置
    configure_basics_gsettings

    # 2. 软件源与 DNF
    configure_repos_and_dnf

    # 3. 系统更新
    system_update_and_cleanup

    # 4. 开发工具
    install_dev_tools
    configure_languages
    configure_git

    # 5. Flatpak 应用
    configure_flatpak

    # 6. 主题美化 (可选)
    if confirm_action "是否安装 WhiteSur 主题并进行美化？"; then
        install_theme_whitesur
        apply_theme_settings
    else
        log_warn "跳过主题安装。"
    fi

    # 7. JetBrains Toolbox
    if confirm_action "是否安装 JetBrains Toolbox？"; then
        install_jetbrains_toolbox
    else
        log_warn "跳过 JetBrains Toolbox 安装。"
    fi

    # 8. 最终清理
    log_info "执行最终清理..."
    sudo dnf autoremove -y
    sudo dnf clean all

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  配置全部完成！${NC}"
    echo -e "${GREEN}  建议重启系统以应用所有更改。${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    read -p "是否立即重启？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl reboot
    fi
}

# 执行主函数
main "$@"

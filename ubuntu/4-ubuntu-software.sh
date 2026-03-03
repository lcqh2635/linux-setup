#!/bin/bash
# ==============================================================================
# 脚本名称: 4-ubuntu-software.sh
# 功能描述：自动安装常用软件
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x 4-ubuntu-software.sh && ./4-ubuntu-software.sh
# ==============================================================================

# Ubuntu 操作系统 ISO 阿里云和中科大加速下载网址：
# https://mirrors.aliyun.com/ubuntu-cdimage/releases/
# https://mirrors.ustc.edu.cn/ubuntu-cdimage/releases/
# cd ~/下载 && git clone https://cdn.gh-proxy.org/https://github.com/lcqh2635/linux-setup.git
# cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push

# 如果一个 GUI 应用软件包同时在 APT (.deb) 和 Flatpak 两个仓库都存在，推荐我该怎么选择？
# 📌 关键结论：APT 是系统级包管理，Flatpak 是应用级沙箱分发，二者解决的问题域不同
# 🎯 核心原则：「系统服务/后端组件 → APT」，「桌面 GUI 应用 → 优先考虑 Flatpak」保持系统的干净

# ------------------------------------------------------------------------------
# 1. 安全与规范设置 (Best Practices)
# ------------------------------------------------------------------------------
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail

# 脚本元数据
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"
readonly AUTHOR="DevOps Team"

# 退出状态码
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2

# ------------------------------------------------------------------------------
# 2. 颜色定义与智能检测 (核心新增部分)
# ------------------------------------------------------------------------------
# 定义 ANSI 颜色代码
# \033 是 ESC 字符的八进制表示，[0m 表示重置所有属性
readonly COLOR_RESET="\033[0m"
readonly COLOR_RED="\033[31m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_YELLOW="\033[33m"
readonly COLOR_BLUE="\033[34m"
readonly COLOR_CYAN="\033[36m"
readonly COLOR_BOLD="\033[1m"

# 初始化颜色变量（默认启用）
COLOR_ENABLED=true


snap install --help
# 列出所有已安装的 Snap
snap list
snap find intellij-idea
snap list intellij-idea
# 更新所有 Snap 包
sudo snap refresh
# 查看哪些 Snap 有更新
sudo snap refresh --list


sudo apt update -y
sudo apt autoremove --purge -y firefox && sudo snap remove firefox
# 在 Ubuntu 上搭建 Firefox APT 仓库
# https://support.mozilla.org/zh-CN/kb/install-firefox-linux?redirectslug=linux-firefox&redirectlocale=zh-CN
# 创建一个保存 APT 库密钥的目录：
sudo install -d -m 0755 /etc/apt/keyrings
# 导入 Mozilla APT 密钥环：
# ls /etc/apt/keyrings && cat /etc/apt/keyrings/packages.mozilla.org.asc
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
# cat /etc/apt/sources.list.d/mozilla.sources
# 接下来，将 Mozilla APT 库添加到 sources.list 中，对于 Debian Trixie 及更新版本
cat << EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
# nautilus admin:/etc/apt/preferences.d
# sudo rm /etc/apt/preferences.d/mozilla
# cat /etc/apt/preferences.d/mozilla
# 配置 APT 优先使用 Mozilla 库中的包
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
# 更新软件列表并安装 firefox（或 firefox-esr、-beta、-nightly、-devedition 之一）
sudo apt-get update && sudo apt-get install --fix-missing -y firefox-l10n-zh-cn
# sudo apt-get update && sudo apt-get install --fix-missing -y firefox-esr-l10n-zh-cn
# apt list -a firefox-l10n-zh-cn
# apt list -a firefox-esr-l10n-zh-cn

# ls /etc/apt/preferences.d
# sudo rm /etc/apt/keyrings/packages.mozilla.org.asc && sudo rm /etc/apt/sources.list.d/mozilla.sources && sudo rm /etc/apt/preferences.d/mozilla


# 在 Ubuntu 上搭建 Google Chrome APT 仓库
# https://linuxcapable.com/install-google-chrome-on-ubuntu-linux/
# 更新 Ubuntu 包列表，刷新系统包索引，确保安装了所有前置条件的最新版本：
sudo apt update -y
# 安装必需的Chrome依赖，安装用于安全下载和GPG密钥管理所需的包：
sudo apt install -y ca-certificates curl
# ls /usr/share/keyrings
# 导入 Google Chrome 的 GPG 签名密钥
# APT 需要 GPG 密钥来验证从外部仓库下载的包的真实性。下载谷歌的公用签名密钥，转换为二进制格式，并存储在系统密钥环目录中：
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /usr/share/keyrings/google-chrome.gpg
# cat /etc/apt/sources.list.d/google-chrome.sources
# 添加 Google Chrome APT 仓库
# 使用现代 DEB822 格式创建仓库配置文件，该格式比传统单行格式更清晰且易于维护：
cat << EOF | sudo tee /etc/apt/sources.list.d/google-chrome.sources
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/google-chrome.gpg
EOF
# 验证 Chrome 仓库配置，刷新你的包列表以包含新的仓库：
sudo apt update
# 通过检查包源来确认仓库正常工作：
apt-cache policy google-chrome-stable
# 在 Ubuntu 上安装 Google Chrome，仓库配置好后，用APT安装你喜欢的 Chrome 频道
# 安装 Google Chrome Stable 稳定版经过谷歌质量保证团队的全面测试，是日常浏览的最安全选择：
sudo apt install -y google-chrome-stable
# sudo apt autoremove --purge -y google-chrome-stable

# ls /etc/apt/keyrings
# ls /etc/apt/sources.list.d
# sudo rm /usr/share/keyrings/google-chrome.gpg && sudo rm /etc/apt/sources.list.d/google-chrome.sources


# VPN 相关软件和订阅来源
# https://gh-proxy.com/
# https://ghproxylist.com/
# https://www.freeclashnode.com/

install_vpn() {
    # 进入到下载目录
    cd ~/下载
    # 安装 WhiteSur 壁纸
    echo "准备开始安装WhiteSur系列主题..."
    wget "https://gh-proxy.org/https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.4.6/Clash.Verge_2.4.6_amd64.deb"
    wget "https://gh-proxy.org/https://github.com/hiddify/hiddify-app/releases/download/v4.0.4/Hiddify-Debian-x64.deb"
    wget "https://gh-proxy.org/https://github.com/chen08209/FlClash/releases/download/v0.8.92/FlClash-0.8.92-linux-amd64.deb"
    wget "https://gh-proxy.org/https://github.com/2dust/v2rayN/releases/download/7.18.0/v2rayN-linux-64.deb"
    
    sudo apt install -y ./Clash.Verge_2.4.6_amd64.deb
    sudo apt install -y ./Hiddify-Debian-x64.deb
    sudo apt install -y ./FlClash-0.8.92-linux-amd64.deb
    sudo apt install -y ./v2rayN-linux-64.deb
    
    # 动作：卸载主包 + 删除配置文件 + 自动清理不再需要的依赖包
    # sudo apt autoremove --purge -y flclash
    
    
    if [ ! -d "WhiteSur-*" ]; then
        install_themes_and_icons
    else
        echo "仓库 $target_dir 已存在，跳过克隆"
        # 如果文件都在当前目录
        cd ~/下载 && rm -rf WhiteSur-*
        install_themes_and_icons
    fi
}


flatpak -h
flatpak install -h
flatpak uninstall -h
# 更新已安装的应用程序或运行时
flatpak update
# 列出已安装的应用
flatpak list --app
# 卸载未使用的依赖
flatpak uninstall --unused -y
# flatpak search *theme*
# 为 Linux 上的 Flathub 提供支持的 Flatpak 应用商店
sudo flatpak install -y flathub io.github.kolunmi.Bazaar
# Flatseal 是一种图形工具，用于审查和修改 Flatpak 应用程序中的权限
sudo flatpak install -y flathub com.github.tchx84.Flatseal
# Warehouse 提供了一个简单的用户界面来控制复杂的 Flatpak 选项，而且完全无需借助命令行
sudo flatpak install -y flathub io.github.flattool.Warehouse
# 卸载Flatpak时，可能会在电脑上留下一些文件。Flatsweep 帮助您轻松清除未安装 Flatpak 残留在系统上的残留物
sudo flatpak install -y flathub io.github.giantpinkrobots.flatsweep
# 快速、私密且安全的网页浏览器
sudo flatpak install -y flathub org.mozilla.firefox
# Brave 致力于通过为用户提供更安全、更快速、更好的浏览体验来修复网络，同时通过一个基于注意力的奖励生态系统，扩大对内容创作者的支持
sudo flatpak install -y flathub com.brave.Browser
# Google Chrome 是一款结合极简设计与先进技术的浏览器，旨在让网页更快、更安全、更便捷
sudo flatpak install -y flathub com.google.Chrome
# 更改 GDM 设置； 应用主题和背景、更改光标主题、图标主题和夜灯设置等
sudo flatpak install -y flathub io.github.realmazharhussain.GdmSettings
# 轻松地将磁盘镜像写入你的硬盘。选择一张图片，插入你的硬盘，就可以开始了！Impression 是热衷于发行的用户和普通电脑用户都非常有用的工具
sudo flatpak install -y flathub io.gitlab.adhami3310.Impression
# 一个易用的BitTorrent客户端。片段可以通过BitTorrent点对点文件共享协议传输文件，例如视频、音乐或Linux发行版的安装映像
sudo flatpak install -y flathub de.haeckerfelix.Fragments


# GNOME的网页浏览器，与桌面紧密集成，界面简单直观，让你能够专注于网页。如果你在寻找一个简单、干净、美丽的网页视图，这款浏览器就是你的首选
sudo flatpak install -y flathub org.gnome.Epiphany
# 视频是GNOME桌面环境的官方电影播放器。它包含可搜索的本地视频列表、DVD，以及本地网络视频分享（使用UPnP/DLNA）和来自多个网站的视频集锦
sudo flatpak install -y flathub org.gnome.Totem
# D-Spy 是一个用于探索 D-Bus 连接的简单工具
sudo flatpak install -y flathub org.gnome.dspy
# File Roller 是一款用于打开、创建和修改归档和压缩归档文件的 GNOME 应用程序
sudo flatpak install -y flathub org.gnome.FileRoller
# 选择一个作系统，让Box在虚拟机中下载并安装
sudo flatpak install -y flathub org.gnome.Boxes
# Builder 是一个为 GNOME 积极开发的集成开发环境。它将对关键 GNOME 技术（如 GTK、GLib 和 GNOME API）的集成支持与任何开发者都会欣赏的功能相结合
sudo flatpak install -y flathub org.gnome.Builder
# Evolution 是一款个人信息管理应用，提供集成的邮件、日历和地址簿功能
sudo flatpak install -y flathub org.gnome.Evolution
# 一款高级用户工具，允许在支持fwupd的设备上更新、重装和降级固件
sudo flatpak install -y flathub org.gnome.Firmware
# Gtranslator 是一款针对 GNOME 桌面环境的增强版 gettext po 文件编辑器。它支持各种形式的 gettext PO 文件，并包含非常有用的功能
sudo flatpak install -y flathub org.gnome.Gtranslator
# 字符是一个简单的工具应用，用于查找和插入不寻常字符。它让你通过搜索关键词快速找到你想要的字符
sudo flatpak install -y flathub org.gnome.Characters
# GNOME 扩展负责更新扩展、配置扩展偏好以及移除或禁用不需要的扩展
sudo flatpak install -y flathub org.gnome.Extensions
# 浏览并安装GNOME Shell扩展以定制你的桌面
sudo flatpak install -y flathub com.mattjakeman.ExtensionManager
# Refine 帮助发现 GNOME 中的高级和实验性功能
sudo flatpak install -y flathub page.tesk.Refine
# 你可以从拥有简洁友好的用户界面的在线来源获取字体。Sitra为安装、卸载和预览字体提供了无缝体验
sudo flatpak install -y flathub io.github.sitraorg.sitra
# 一款用户友好的应用程序，专为管理你系统上的极客字体而设计。凭借由 libadwaita 增强的简洁 GTK4 用户界面
sudo flatpak install -y flathub io.github.getnf.embellish
# Rewaita通过用流行的配色方案为您的Adwaita应用增添新意
sudo flatpak install -y flathub io.github.swordpuffin.rewaita
# 浏览、预览并安装桌面主题，原生安装桌面主题
sudo flatpak install -y flathub io.github.debasish_patra_1987.linuxthemestore
# Wardrobe 是一个用于下载社区制作的 Gnome Shell、Gtk3/4、图标和光标主题以及壁纸的工具
sudo flatpak install -y flathub io.github.swordpuffin.wardrobe


# Shortwave 是一个互联网广播播放器，提供访问超过5万个电台的电台数据库
sudo flatpak install -y flathub de.haeckerfelix.Shortwave
# Dconf 编辑器是一个允许直接编辑 dconf 配置数据库的工具。这在开发使用这些设置的应用程序时非常有用
sudo flatpak install -y flathub ca.desrt.dconf-editor

# Launcher Studio 是一款现代的原生 GTK4 应用程序，旨在简化 Linux 上 .desktop 文件的创建和管理
sudo flatpak install -y flathub fr.arnaudmichel.launcherstudio
# Geekbench 6 是一个跨平台基准测试，只需按下按钮即可测量系统性能
sudo flatpak install -y flathub com.geekbench.Geekbench6


# 管理好你的任务，为喜欢简单设计的人准备的Todo应用
sudo flatpak install -y flathub io.github.mrvladus.List
# 忘记忘记事情
sudo flatpak install -y flathub io.github.alainm23.planify
# 用干净、无干扰的标记删除编辑器专注于你的写作
sudo flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe
# Obsidian 是一个强大的知识库，运行在本地纯文本 Markdown 文件文件夹之上
sudo flatpak install -y flathub md.obsidian.Obsidian
# 一款极简的Markdown阅读与写作应用
sudo flatpak install -y flathub io.typora.Typora
# Sublime Text 是一款文本和源代码编辑器，具备极简界面、语法高亮和代码折叠功能，原生支持多种编程和标记语言，集成终端/控制台窗口以及可自定义主题
sudo flatpak install -y flathub com.sublimehq.SublimeText


# 一款用 GTK4 编写的轻量级音乐播放器，专注于大型音乐收藏
sudo flatpak install -y flathub com.github.neithern.g4music
# 以最高质量播放曲目，使用发现混音或探索标签探索新曲目，或者只是享受你已知喜爱的收藏中的歌曲
sudo flatpak install -y flathub dev.dergs.Tonearm
# 高颜值的第三方网易云音乐播放器，支持各种各样的方便的特性
sudo flatpak install -y flathub io.github.qier222.YesPlayMusic
# netease-cloud-music-gtk 是使用 Rust + GTK 开发的网易云音乐客户端，专为 Linux 系统打造
sudo flatpak install -y flathub com.github.gmg137.netease-cloud-music-gtk
# GTK/Adwaita 应用程序，允许在 Linux作系统上使用 Yandex Music 服务
sudo flatpak install -y flathub space.rirusha.Cassette
# 动态播放列表、集成光谱可视化、背景模糊、同步歌词等功能
sudo flatpak install -y flathub io.github.htkhiem.Euphonica
# Delfin 是 Jellyfin 媒体服务器的本地客户端。它拥有快速且简洁的界面，可在嵌入式基于MPV的视频播放器中流媒体播放
sudo flatpak install -y flathub cafe.avery.Delfin


# 备份用最简单的方法。插上你的U盘，让Pika帮你完成剩下的
sudo flatpak install -y flathub org.gnome.World.PikaBackup
# Save Desktop可帮助您轻松备份、还原和同步整个桌面环境。它保存和导入您的主题，图标，字体，壁纸，扩展，桌面文件夹，Flatpak应用程序及其数据，以及其他桌面设置-所有在一个存档。选择要包含的内容，并通过自动定期保存和同步来保持设备之间的设置一致
sudo flatpak install -y flathub io.github.vikdevelop.SaveDesktop
# Pods 是一个 podman 的前端。它的用户界面使用 libadwaita 并力求符合 GNOME 的设计原则
sudo flatpak install -y flathub com.github.marhkb.Pods
# Bottles 允许你在 Linux 上运行 Windows 软件，比如应用程序和游戏
sudo flatpak install -y flathub com.usebottles.bottles
# WineCharm 是一款图形用户界面（GUI）应用程序，旨在简化使用 Wine 在 Linux 上运行和管理 Windows 应用程序
sudo flatpak install -y flathub io.github.fastrizwaan.WineCharm
# DistroShelf 是一个用于管理 Linux 上 Distrobox 容器的图形界面。它提供了一种简单的方式
# 需要提前安装运行环境 sudo apt install -y distrobox
sudo flatpak install -y flathub com.ranfdev.DistroShelf
# BoxBuddy 是 Distrobox 的一个图形用户界面。Distrobox 允许用户创建多个不同 Linux 发行版的容器镜像，这些镜像与你的主机系统集成良好，但仍然完全独立
sudo flatpak install -y flathub io.github.dvlv.boxbuddyrs
# 资源功能允许您检查系统资源的利用情况，并控制正在运行的进程和应用。它设计得用户友好，使用GNOME的libadwaita，在现代桌面上感觉非常亲切
sudo flatpak install -y flathub net.nokyan.Resources
# 监控您的处理器、内存、硬盘、网络和显卡使用情况，同时附上每个应用和进程对这些信息的分解统计
sudo flatpak install -y flathub io.missioncenter.MissionCenter
# 这个应用允许你通过本地局域网发送文件和消息。与大多数替代方案不同，这里不需要外部服务器。所有事情都在本地的WiFi网络中发生
sudo flatpak install -y flathub org.localsend.localsend_app
# 一个轻松管理 AppImages 的工具！齿轮杆可以帮你整理和管理 AppImage 文件，生成桌面条目和应用元数据，原地更新应用，或将多个版本并排保存
sudo flatpak install -y flathub it.mijorus.gearlever
# Kooha 是一个界面极简的录屏软件。无需一系列的配置，只需轻点一下即可开始录制
sudo flatpak install -y flathub io.github.seadve.Kooha

# 分析任何展示。输入一些简单细节，计算出某个显示器的宽高比、DPI和其他细节。非常适合决定买哪款笔记本或外接显示器，以及是否算作HiDPI
sudo flatpak install -y flathub com.github.cassidyjames.dippi
# Spider 是一个旨在简化安装和使用网页应用的程序，同时能与 GNOME 桌面集成
sudo flatpak install -y flathub io.github.zaedus.spider
# Projectpad 允许管理你作为软件开发者或系统管理员需要处理的秘密凭证和服务器信息
sudo flatpak install -y flathub com.github.emmanueltouzery.projectpad
# Actioneer 让你无需离开桌面即可浏览 GitHub 仓库、检查工作流程运行、查看作业日志和刷新状态
sudo flatpak install -y flathub me.spaceinbox.actioneer
# Linux视频壁纸。用Python写的
sudo flatpak install -y flathub io.github.jeffshee.Hidamari
# 凭借其简洁、优雅且适应性强的界面，这款阅读器让你可以轻松搜索、分类和阅读你的系列
sudo flatpak install -y flathub info.febvre.Komikku
# GNOME 的翻译应用程序
sudo flatpak install -y flathub app.drey.Dialect
# 测量你的网络连接速度
sudo flatpak install -y flathub xyz.ketok.Speedtest
# 显示系统电池的信息
sudo flatpak install -y flathub com.her01n.BatteryInfo
# 升频器可增强和放大图像，最大可放大至原始尺寸的四倍，并具备动画、动漫和照片的特殊模式
sudo flatpak install -y flathub io.gitlab.theevilskeleton.Upscaler
# 简单的应用程序，可以从wallhaven下载和设置壁纸
sudo flatpak install -y flathub io.github.davidoc26.wallpaper_selector

# Wordbook 是一款离线英英词典应用，由 WordNet 和 eSpeak 提供支持
sudo flatpak install -y flathub dev.mufeed.Wordbook
# 可生成双因素验证码的简单应用程序
sudo flatpak install -y flathub com.belmoussaoui.Authenticator
# 借助 YubiKey 保护共享密钥，生成基于时间的 OATH TOTP 和基于事件的 HOTP 一次性密码代码
sudo flatpak install -y flathub com.yubico.yubioath
# 一个用于管理 systemd 单元，用户友好的应用程序
sudo flatpak install -y flathub io.github.plrigaux.sysd-manager
# 轻松获取你的IP：无论是本地IP、公共IP还是虚拟接口IP，都易于理解，一键即可查看
sudo flatpak install -y flathub org.gabmus.whatip
# HydraPaper 是一款壁纸管理器，专门设计用于解决许多桌面环境在多显示器设置中无法为每个显示器设置不同壁纸的功能缺失问题
sudo flatpak install -y flathub org.gabmus.hydrapaper
# 当前天气状况和预报
sudo flatpak install -y flathub io.github.amit9838.mousam
# Pinta是一个图像编辑，绘图和绘画应用程序，具有简单而强大的界面。Pinta拥有广泛的绘图工具，包括：手绘，矩形，圆形和线条
sudo flatpak install -y flathub com.github.PintaProject.Pinta
# 一个使用 Rust、GTK 和 Adwaita 设计语言构建的现代 Web 应用管理器。Web App Hub 可实现对网页应用的无缝管理，每个应用都有自己的图标和独立的浏览器配置文件
sudo flatpak install -y flathub org.pvermeer.WebAppHub
# 训练 Newelle 使用自定义扩展和新的 AI 模块来实现更多功能，为你的聊天机器人提供无限可能
sudo flatpak install -y flathub io.github.qwersyk.Newelle
# Concessio 帮助你理解和转换 Unix 权限表示方式
sudo flatpak install -y flathub io.github.ronniedroid.concessio
# Bitwarden 是存储所有登录信息和密码最简单、最安全的方式，同时可以方便地在所有设备间同步这些信息
sudo flatpak install -y flathub com.bitwarden.desktop
# Cambalache 是一款 RAD 工具，能够创建 Gtk 4/3 应用的用户界面
sudo flatpak install -y flathub ar.xjuan.Cambalache
# Stremio 提供安全、现代且流畅的娱乐体验。凭借其易于使用的界面和丰富的内容库，包括对 4K HDR 的支持，用户可以在所有设备上享受他们喜爱的电影和电视节目
sudo flatpak install -y flathub com.stremio.Stremio
# Tangram 是一种新型浏览器。它旨在组织和运行你的网络应用。每个标签页都是持久且独立的。你可以为同一应用设置多个不同账户的标签页
sudo flatpak install -y flathub re.sonny.Tangram
# Gradia 帮助你准备好截图分享，无论是快速与朋友或同事分享，还是专业地与全世界分享
sudo flatpak install -y flathub be.alexandervanhee.gradia
# 书法将短文转化为由ASCII字符组成的大型、令人印象深刻的横幅，随时可复制或导出为图像。为你的网络对话增添更多活力吧！
sudo flatpak install -y flathub dev.geopjr.Calligraphy
# Aurynk 是一款现代 Linux 应用程序，用于管理 Android 设备、通过 ADB 配对以及使用 scrcpy 镜像屏幕
sudo flatpak install -y flathub io.github.IshuSinghSE.aurynk
# Haguichi 让加入、创建和管理 Hamachi 网络变得轻松自如
sudo flatpak install -y flathub com.github.ztefn.haguichi
# Trayscale 是 Tailscale 守护进程的一个非官方 GUI 接口，专为 Linux 平台提供，因为没有官方的 Linux GUI 客户端。
# 它提供了一个基础的系统托盘图标和相当全面的界面，支持Tailscale的许多功能。
sudo flatpak install -y flathub dev.deedles.Trayscale
# Cine将简洁的界面与高性能引擎相结合，带来无缝的观看体验
sudo flatpak install -y flathub io.github.diegopvlk.Cine



# eOVPN 是一款用于连接、管理和更新（从远程.zip）OpenVPN 配置的应用程序
sudo flatpak install -y flathub com.github.jkotra.eovpn
# 一个快速、安全且易于使用的VPN。由Firefox的开发者打造
# 虚拟专用网络保护你与互联网的连接，使你的位置和在线活动在各设备间更加私密
sudo flatpak install -y flathub org.mozilla.vpn
# 保护您的互联网安全，保护您的网络隐私
sudo flatpak install -y flathub com.protonvpn.www
# 去中心化、混合网和零知识 VPN
sudo flatpak install -y flathub net.nymtech.NymVPN


# 在 Roblox 上玩游戏、聊天和探索
sudo flatpak install -y flathub org.vinegarhq.Sober
# Heroic 是一个开源游戏启动器。目前支持使用 Legendary 启动 Epic 游戏商城中的游戏， 使用我们自定义的 gogdl 实现启动 GOG 游戏
sudo flatpak install -y flathub com.heroicgameslauncher.hgl
# 现代兼容性工具管理器，管理各支持启动器的兼容性工具，更改 Steam 游戏的兼容性工具和启动选项
sudo flatpak install -y flathub com.vysp3r.ProtonPlus
# Steam 软件分发服务启动器
sudo flatpak install -y flathub com.valvesoftware.Steam
# 让 Steam 拥有 Adwaita 风格
sudo flatpak install -y flathub io.github.Foldex.AdwSteamGtk
# 动漫游戏启动器是一个非官方的原神启动器，用于在 Linux 上设置 Wine 并安装游戏
sudo flatpak install -y flathub moe.launcher.an-anime-game-launcher
# MangoJuice 是一款可以轻松编辑 MangoHUD 设置的应用程序，而 MangoHUD 又是一个用于跟踪游戏和其他软件加载和其他参数的叠加解决方案
sudo flatpak install -y flathub io.github.radiolamp.mangojuice

sudo flatpak install -y flathub com.qq.QQ
sudo flatpak install -y flathub com.tencent.WeChat
# Discord 是一个免费的一体化消息、语音和视频客户端，可以在你的电脑和手机上使用
sudo flatpak install -y flathub com.discordapp.Discord
# Dissent（前称gtkcord4）是一款第三方Discord客户端，旨在提供Linux桌面上的流畅原生体验
sudo flatpak install -y flathub so.libdb.dissent
# 纯即时通讯——简单、快速、安全，并在所有设备间同步。全球下载量前十的应用之一，拥有超过5亿活跃用户
sudo flatpak install -y flathub org.telegram.desktop

# ONLYOFFICE 桌面编辑器是一款免费的开源办公套件，包含用于文本文件的编辑器
sudo flatpak install -y flathub org.onlyoffice.desktopeditors
# RustDesk 是一个功能齐全的开源远程控制替代方案，适合自建托管和安全使用，并且配置最小化
sudo flatpak install -y flathub com.rustdesk.RustDesk
# 功能强大且易于使用的截图软件，内置具有高级功能的编辑器
sudo flatpak install -y flathub org.flameshot.Flameshot

# Bobby允许你打开SQLite数据库文件（.db、.sqlite）并浏览其中的表格。对应用开发或检查下载数据库非常方便
sudo flatpak install -y flathub studio.planetpeanut.Bobby
# Ping网站，定位网站的实用性
sudo flatpak install -y flathub io.github.lo2dev.Echo
# Brief 是一款用于浏览命令行速查表的应用。它允许你在多个平台和语言中搜索成千上万个命令行工具，提供简化的帮助页面
sudo flatpak install -y flathub io.github.shonebinu.Brief
# 面向开发者、SQL 程序员、数据库管理员和分析师的免费多平台数据库工具。支持所有流行的数据库：MySQL、PostgreSQL、MariaDB、SQLite、Oracle 等
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity
# 这是一组功能强大但易于使用的工具，用于解决最常见的日常开发问题
sudo flatpak install -y flathub me.iepure.devtoolbox
# Diffuse 是一个用于比较和合并文本文件的图形工具。它可以从 Bazaar、CVS、Darcs、Git、Mercurial、Monotone、RCS 和 Subversion 仓库中获取要比较的文件
sudo flatpak install -y flathub io.github.mightycreak.Diffuse
# Seabird 是一个为 GNOME 桌面设计的 Kubernetes IDE。用简单直观的界面探索和管理你的集群
sudo flatpak install -y flathub dev.skynomads.Seabird
# SSH Studio 是一款原生桌面应用程序，用于管理 SSH 配置文件。它提供了一个用户友好的界面，无需使用终端编辑器即可创建、编辑和验证 SSH 主机
sudo flatpak install -y flathub io.github.BuddySirJava.SSH-Studio
# Playhouse 让原型制作、教学、设计、学习和构建网页内容变得简单
sudo flatpak install -y flathub re.sonny.Playhouse
# Workbench 是用来学习和用 GNOME 技术做原型设计的，无论是第一次动手还是构建和测试 GTK 用户界面
sudo flatpak install -y flathub re.sonny.Workbench
# Roster 是一个现代的 HTTP 客户端，用于测试和调试 REST API。它提供了一个干净的 GNOME 原生接口，用于发送 HTTP 请求和检查响应
sudo flatpak install -y flathub cz.bugsy.roster
# Cartero 是一个图形化的 HTTP 客户端，可用作开发工具来测试 Web API 并对 Web 服务器执行各种 HTTP 请求
sudo flatpak install -y flathub es.danirod.Cartero
# Postman 是 API 开发者的完整工具链，全球有 500 万开发者和超过 10 万家公司每月访问 1.3 亿个 API
sudo flatpak install -y flathub com.getpostman.Postman
# Apifox = Postman + Swagger + Mock + JMeter
sudo flatpak install -y flathub com.apifox.Apifox

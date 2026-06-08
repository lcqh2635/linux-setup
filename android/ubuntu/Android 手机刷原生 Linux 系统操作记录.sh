sudo dnf install -y unzip p7zip p7zip-plugins
# scrcpy 是一款完全免费、开源的安卓设备投屏和控制工具
# sudo dnf copr enable -y zeno/scrcpy && sudo dnf install -y scrcpy
# scrcpy 的工作依赖于安卓系统内置的 ADB (Android Debug Bridge) 调试服务。你的 K20 Pro 现在运行的是完整的 Debian 系统，
# 这个环境里没有 ADB 服务，所以之前的那些方法自然就不管用了


# https://github.com/GengWei1997/linux-xiaomi-raphael-uboot

1、设备已完成 Bootloader 解锁
# 2、打开 USB 调试功能：在手机的 “开发者选项” 中，打开 “USB 调试” 功能
# 路径：设置 → 关于手机 → 连续点击 “版本号” 直到提示 “开发者选项已启用” → 返回上级菜单进入 “开发者选项” → 打开 “USB调试”
3、在电脑上安装 adb、fastboot 刷机工具，在终端执行如下 dnf 安装命令
sudo dnf install -y android-tools
# 2、验证：检查 adb 和 fastboot 是否安装成功，并能正确响应
adb --version
fastboot --version
# 4、连接测试：用USB数据线连接手机和电脑，并在终端输入命令确认
adb devices


在电脑上下载并解压 rootfs-ubuntu-gnome-7.0-resolute.zip，解压获取 rootfs.img 和 xiaomi-k20pro-boot.img 内核驱动镜像。
mkdir -vp ~/下载/刷机 && cd ~/下载/刷机
wget "https://gh-proxy.org/https://github.com/GengWei1997/linux-xiaomi-raphael-uboot/releases/download/v1.0.0/u-boot-sm8150-xiaomi-raphael.img.zip"
wget "https://gh-proxy.org/https://github.com/GengWei1997/linux-xiaomi-raphael-uboot/releases/download/latest/rootfs-ubuntu-server-7.0-resolute.7z"
# wget "https://gh-proxy.org/https://github.com/GengWei1997/linux-xiaomi-raphael-uboot/releases/download/latest/rootfs-debian-gnome-7.0-trixie.7z"
# 1. 解压（会保留原目录结构）
unzip u-boot-sm8150-xiaomi-raphael.img.zip
7z x rootfs-ubuntu-server-7.0-resolute.7z


# 1. 进入 Fastboot 模式
adb reboot bootloader
# 2. 擦除分区
fastboot erase dtbo
fastboot erase boot
fastboot erase cache
fastboot erase userdata
# 3. 刷入 boot 镜像
fastboot flash cache xiaomi-k20pro-boot.img
fastboot flash boot u-boot.img
# 4. 刷入系统镜像（需要先解压 rootfs.7z）
fastboot flash userdata rootfs.img
# 5. 重启设备
fastboot reboot


# 执行完以上命令后，系统将安装成功，使用默认的如下账号登录：
普通用户：user / 1234
超级用户：root / 1234
# 设备默认 IP：172.16.42.1，SSH 连接命令：
ssh user@172.16.42.1
# 更改指定用户（比如用户名为 "user"）的密码
# sudo passwd user
# 更改超级管理员 root 的密码
# sudo passwd root

# 提前记住本机的 IP 地址
hostname -I


# 如果你刷入的是完整的 Linux 系统（如 Ubuntu Touch、PostmarketOS），系统通常会使用 NetworkManager 来管理网络，而不是 netplan。
# 你可以尝试在 SSH 终端中使用 nmcli 命令来连接 Wi-Fi：
# 1. 检查 NetworkManager 是否正在运行：
nmcli general status
# 2. 扫描附近的 Wi-Fi 网络：
nmcli device wifi list
# 3. 连接 Wi-Fi：
# 将下面的 你的WiFi名称 和 你的WiFi密码 替换为实际内容（如果名称或密码包含空格或特殊字符，请保留双引号）：
nmcli device wifi connect "你的WiFi名称" password "你的WiFi密码"
sudo nmcli device wifi connect "A3-6-707-5G" password "VT4009030242"
sudo nmcli device wifi connect "A3-6-707" password "VT4009030242"
# 执行连接命令后，系统通常会提示 Device 'wld0' successfully activated with...。为了确保万无一失，请依次运行以下两条命令进行验证：
ip a show wld0


# 查看默认的软件源配置
# cat /etc/apt/sources.list
# cat /etc/apt/sources.list.d/ubuntu.sources
# 备份原有配置并将其置空，改用下面的 DEB822 格式配置
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo tee /etc/apt/sources.list < /dev/null
# 配置 USTC 中科大加速镜像源
# https://mirrors.ustc.edu.cn/help/ubuntu.html
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
cat << EOF | sudo tee /etc/apt/sources.list.d/debian.sources
Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: resolute resolute-updates resolute-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.ustc.edu.cn/ubuntu
Suites: resolute-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF


# https://www.debian.club/applications/development
# 更新软件包列表并升级已安装的包
sudo apt update && sudo apt upgrade -y
# 2. 尝试自动修复所有损坏的依赖关系
sudo apt --fix-broken install
# 3. 清理不再需要的软件包和过时的缓存libreoffice
sudo apt autoremove
sudo apt autoclean
sudo apt install -y apt-transport-https ca-certificates
sudo apt install -y fastfetch
fastfetch


# 安装基础工具
sudo apt install -y build-essential curl wget git unzip
# 安装 OpenJDK 21 (包含 JDK 和 JRE)
sudo apt install -y default-jdk
java -version
# 管理多个 Java 版本
sudo update-alternatives --auto java
# 安装 Maven
sudo apt install -y maven gradle
mvn -v
# 查看可用的 LTS (长期支持) 版本
sudo apt install -y nodejs npm
node -v
npm -v
npm config set registry https://registry.npmmirror.com/
if [ -d "/usr/local" ]; then
    sudo chown -R $(whoami):$(whoami) /usr/local
fi
# 安装 Bun
npm install -g bun
bun --version
cat << EOF | tee $HOME/.bunfig.toml
# Bun 加速仓库配置参考官网 https://bun.zhcndoc.com/runtime/bunfig#install-registry
[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，地址为 https://developer.aliyun.com/mirror/
registry = "https://registry.npmmirror.com/"

# 在 Bun 中使用 TypeScript。https://bun.zhcndoc.com/typescript
EOF


echo '
# 设置 Rustup 镜像，参考：https://developer.aliyun.com/mirror/rustup
export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
' >> ~/.bash_profile
source ~/.bash_profile
# 使用阿里云安装脚本
curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/repo/rust/rustup-init.sh | sh -s -- -y
. "$HOME/.cargo/env"
rustup update
rustup toolchain install stable
# 配置 Cargo 镜像
# 如果正在使用 cargo 1.68 及以上版本，在 $HOME/.cargo/config.toml 中添加如下内容即可：
mkdir -vp "$HOME/.cargo"
# cat $HOME/.cargo/config.toml
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee $HOME/.cargo/config.toml
# 配置 Cargo 国内加速镜像源，可选：aliyun、ustc、tuna 此处默认选择 aliyun
# 使用稀疏协议（sparse）减少元数据下载量，大幅加速
[source.crates-io]
replace-with = 'aliyun'

# aliyun 阿里云 crates.io 镜像 https://developer.aliyun.com/mirror/rustup
[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"
[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"

# ustc 中科大 crates.io 镜像 https://mirrors.ustc.edu.cn/help/crates.io-index.html
[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF


# Go 国内加速镜像	https://learnku.com/go/wikis/38122
# golang 中文学习文档	https://golang.halfiisland.com/
# golang 官方网站	https://golang.google.cn/
# golang 公共软件包仓库	https://pkg.go.dev/
sudo apt install -y golang-go
echo "你刚安装的 golang 版本号为：$(go version)"
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
mkdir -vp $HOME/.go
go env -w GOPATH=$HOME/.go
# 查看当前环境
# go env GOPATH


# 1. 更新apt包索引并安装依赖，以允许apt通过HTTPS使用仓库
sudo apt-get update
sudo apt-get install -y ca-certificates curl
# 2. 添加Docker的官方GPG密钥（使用阿里云镜像加速）
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 3. 设置Docker的APT软件源（同样使用阿里云镜像）
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. 更新apt包索引，建立缓存
sudo apt-get update
# 执行命令，安装Docker CE（社区版）相关组件
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# 启用用户级 socket
sudo systemctl enable --now docker
sudo systemctl status docker --no-pager


# 重启系统
sudo reboot

# 在安装 bt 宝塔面板之前，及的提前记录好系统的本地 IP 地质
hostname -I

# 安装宝塔面板
su
if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec
#========================面板账户登录信息==========================
#
# 【云服务器】请在安全组放行 16262 端口
# 外网ipv4面板地址: https://27.44.140.143:16262/b6878eb2
# 内网面板地址:     https://172.16.42.1:16262/b6878eb2
# username: 2knolzcf
# password: c9568a3b
#
# 浏览器访问以下链接，添加宝塔客服
# https://www.bt.cn/new/wechat_customer
#==================================================================


# 1. 查看防火墙状态和规则
sudo ufw status
# 2. 如果状态是 active，确保 22 端口（或你自定义的 SSH 端口）是 ALLOW
# 如果没有，手动放行 22 端口：
sudo ufw allow 22/tcp
sudo ufw allow 8888/tcp
sudo ufw allow 888/tcp
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 443/tcp
# 3. 重新加载防火墙
sudo ufw reload

# 宝塔面板破解
# https://docs.btkaixin.com/
# https://bt11.bthappy.com/
su
if [ -f /usr/bin/curl ];then curl -sSO https://bt11.bthappy.com/install/install_panel.sh;else wget -O install_panel.sh https://bt11.bthappy.com/install/install_panel.sh;fi;bash install_panel.sh bt11.bthappy.com

sudo bt

hostname -I
# 使用上面的本机 IP 地址进行远程 SSH 连接
ssh user@172.16.42.1
ssh user@192.168.1.2


# 内网穿透
# https://www.bilibili.com/video/BV1H4421X7Wg?spm_id_from=333.788.player.player_end_recommend_autoplay&vd_source=75333bb53891f589527eedfb7b2d5911&trackid=web_related_0.router-related-2589621-dpmnd.1780842559398.275

# https://www.cloudflare-cn.com/personal/
# https://zhuanlan.zhihu.com/p/638004070
# https://test-ipv6.com/
# https://ipv6.ddnspod.com/

# 连接蓝牙键盘，按住 FN + 1 3至4秒进入配对模式


mkdir -vp ~/Projects/{Java,Rust,Cpp,Python,TypeScript,Database,Gnome,AndroidStudio}
mkdir -vp ~/Projects/Database/{SQLite,MySQL,MariaDB,Postgres,Distributed,Redis}

bun create tauri-app --help
bun create tauri-app tauri-app \
--template vue-ts \
--manager bun \
--yes

1、模板已创建！要开始，请运行：
cd tauri-app
bun install
bun run tauri android init
2、对于桌面开发，运行：
bun run tauri dev
3、对于 Android 开发，运行：
bun run tauri android dev

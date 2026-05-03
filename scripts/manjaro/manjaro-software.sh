#!/bin/bash

echo "==========开始安装工作和娱乐常用软件工具=========="
# ISO 镜像写入
flatpak install flathub com.system76.Popsicle -y
# Flatseal 是一个图形实用程序，用于查看和修改 Flatpak 应用程序的权限。
flatpak install flathub com.github.tchx84.Flatseal -y
# 扩展管理器
# flatpak install flathub com.mattjakeman.ExtensionManager -y
# 存在闪屏BUG，使用snap版本
# flatpak install flathub org.mozilla.firefox -y
# 可让您一键保存当前配置（主题、图标、壁纸、所有桌面环境设置、扩展等）
flatpak install flathub io.github.vikdevelop.SaveDesktop -y
# 聊天、通讯
flatpak install flathub com.qq.QQ -y
flatpak install flathub com.tencent.WeChat -y
# YesPlayMusic音乐
# flatpak install flathub io.github.qier222.YesPlayMusic -y
# flatpak install flathub com.github.gmg137.netease-cloud-music-gtk -y
# 百度网盘
flatpak install flathub com.baidu.NetDisk -y
# 以上软件是基本必装的常用软件
# Obsidian 文本编辑器
flatpak install flathub md.obsidian.Obsidian -y
# 插件  https://flhzd5t6fl.feishu.cn/wiki/PVxTwenFdiR7JZkmtXVciAH3nwb?table=tbl8RLiBsIDt4d0i&view=vew1ZbjWVQ
# 办公软件
flatpak install flathub org.libreoffice.LibreOffice -y




sudo pacman -Syyu
sudo pacman -S yay
yay -S gnome-tweaks gnome-software aur/extension-manager
yay -S aur/whitesur-gtk-theme aur/whitesur-icon-theme aur/whitesur-cursor-theme

# extra 意为 arch 官方仓库，aur 为用户仓库
yay -S extra/neofetch extra/evolution extra/popsicle extra/obsidian extra/gnome-boxes
evolution配置qq邮箱授权码： embwnsuwkdjrebge
 
# linux系统下的分区助手
yay -S extra/gparted
# 在调整分区大小之前，通常需要先卸载（unmount）该分区。这是因为文件系统在挂载状态下正在使用，任何对其底层数据结构的修改都可能导致数据损坏或系统不稳定。


yay -S extra/libreoffice-fresh-zh-cn
yay -S extra/vagrant extra/virtualbox extra/postgresql extra/alacritty extra/lapce extra/helix extra/nushell
# 以下软件都是 rust 应用
yay -S extra/alacritty	Alacritty 使用 Rust 编写，是一款极简主义风格的跨平台终端模拟器，目前可以说是全网最快。不要安装
yay -S extra/lapce	类似 vscode 的代码编辑器
yay -S extra/helix	目标：取代 Vim 和 NeoVim
yay -S extra/nushell	目标：取代 PowerShell 和 ZSh

yay -S jetbrains-toolbox apifox switchhosts-bin visual-studio-code-bin google-chrome
# VSCode 主题随系统自动切换，打开设置、搜索并开启 autoDetectColorScheme 
yay -S yesplaymusic tabby-bin
yay -S aur/linuxqq aur/wechat aur/baidunetdisk-bin aur/typora aur/navicat17-premium-cs
# Navicat 调整界面和字体大小： 
1. 选择工具 > 选项。
2. 选择常规、编辑器或记录。在常规处选择 高DPI 进行缩放配置
3. 为界面、编辑器或数据网格选择你想要的样式或大小。
在變更界面字体后，请重新启动 Navicat 才能使更改生效。

yay -S aur/clash-verge aur/rustdesk


yay -S extra/neovim extra/zed
# https://zed.rust-lang.net.cn/docs/getting-started
NeoVim支持插件管理和高级配置。一个常见的方法是使用一个插件管理器如vim-plug或者packer.nvim来管理你的插件。这里以packer.nvim为例：
git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
创建一个名为init.lua的文件到 ~/.config/nvim/ 目录下，并设置你的NeoVim配置。例如：
nvim ~/.config/nvim/init.lua


# 当 manjaro 因为网络无法安装 deb 包时，可以使用 debtap 安装 如下
# 安装 debtap
yay -S debtap
# 升级debtap,这一步是必须的，否则在第一次执行下面的语句时会出现错误提示。
sudo debtap -u
# 变更deb包
sudo debtap xxxx.deb
sudo debtap expressvpn_3.74.0.6-1_amd64.deb
# 安装
sudo pacman -U XXXX.tar.xz



echo "==========开始jetbra破解工具包=========="
wget -O jetbra.zip https://hardbin.com/ipfs/bafybeiawsvnhqx5o2aqa37pvq7brlk7vqj2cpty3b5xac655bxbpqbpkq4/files/jetbra-ded4f9dc4fcb60294b21669dafa90330f2713ce4.zip
# 解压 ZIP 压缩文件，使用 unzip 解压直接得到里面内容，也可以后面指定目录
unzip jetbra.zip
# 重命名文件夹
mv jetbra .jetbra
# 移动文件夹到用户主目录
mv .jetbra $HOME

-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains


echo "==========完成安装工作和娱乐常用软件工具=========="

# https://wiki.archlinux.org/title/MariaDB
# MariaDB 是一个可靠，高性能且功能齐全的数据库服务器，是Arch Linux默认的MySQL实现
yay -S mariadb
mysql --version
/usr/bin/mariadb --version

# 如果数据库（在 /var/lib/mysql 中）驻留在 Btrfs 文件系统上，则应考虑在创建任何数据库之前禁用该目录的 Copy-on-Write。
sudo chmod -R 777 /var/lib/mysql
# mariadb-secure-installation 命令将以交互方式指导您完成一些建议的安全措施，例如删除匿名帐户和删除测试数据库：
sudo mariadb-secure-installation
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
systemctl status mariadb.service
# 以 sudo 管理员运行则不需要密码，无需密码
sudo mariadb
sudo mariadb -u root -p
show databases;
use mysql;
select host, user, plugin, authentication_string from user;
ALTER USER 'root'@'localhost' IDENTIFIED BY '479368';

# 需要密码
mariadb -u root -p


# - initialize: 默认会为 root 账户生成一个随机密码，且这个密码会过期。过期后需要重新生成一个。
# - initialize-insecure : 不会为 root 账户生成密码。
sudo systemctl start mysqld.service
sudo systemctl start mariadb.service


mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY '479368';
# 设置开机启动
sudo systemctl enable mysqld.service
cat /var/log/mysqld.log
chmod -R 777 /var/lib/mysql
nautilus admin:/var/lib




yay -S redis
redis-server --version
sudo chmod +rw /etc/redis
cat /etc/redis/redis.conf
sudo vim /etc/redis/redis.conf
requirepass 479368


sudo systemctl restart redis
sudo systemctl enable redis
redis-server --requirepass 479368

#!/bin/bash

# 设置在遇到错误时自动退出
set -e
echo "==========开始桌面美化配置=========="

# 读取用户密码
read -p "请输入你的登陆密码：" password

# 更新系统
# 在普通用户下执行管理员命令
echo $password | su -c "apt update && apt upgrade -y" -s /bin/bash root

# 安装并配置 flatpak
echo $password | su -c "apt install flatpak gnome-software-plugin-flatpak -y" -s /bin/bash root
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# 配置 flatpak 上海交大下载加速镜像仓库
echo $password | su -c "flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub" -s /bin/bash root

# 下载系统基础工具
# 安装GNOME插件和扩展
echo $password | su -c "apt install git chrome-gnome-shell gnome-shell-extension-manager -y" -s /bin/bash root

# 先创建一个主题存放目录，然后下载 WhiteSur 系统主题
cd $HOME/下载
directory="WhiteSur"
# 如果目录存在
if [ -d "$directory" ]; then
    rm -rf "$directory"	
fi
mkdir $directory
echo "创建临时目录 WhiteSur 成功"
cd $directory

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
# 安装 WhiteSur GTK 主题包
./install.sh
# 将 WhiteSur 主题连接到 Flatpak（不支持 Snap）
./tweaks.sh -F
# 修复 Flatpak gtk-4.0 应用程序
echo $password | su -c "flatpak override --filesystem=xdg-config/gtk-4.0" -s /bin/bash root
# 修改 Firefox 主题
./tweaks.sh -f
# 安装 GDM 主题，登陆界面、要求 root 权限
echo $password | su -c "./tweaks.sh -g" -s /bin/bash root

# 快速安装 ICON 主题
cd ../
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
cd WhiteSur-icon-theme
# 安装 WhiteSur ICON 主题包
./install.sh -d $HOME/.icons

# 快速安装 cursors 主题
cd ../
git clone https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1
cd WhiteSur-cursors
# 安装 WhiteSur cursors 主题包
echo $password | su -c "./install.sh" -s /bin/bash root

# 下载和安装壁纸
cd ../
wget -O wallpaper.jpg "https://gitee.com/llf2635/linux/raw/master/debian/wallpaper/b3eb9d03e5704f619f3fe55d809568ce.jpg"
picture_dir="$HOME/.local/share/backgrounds"
# 如果目录不存在
if [ ! -d "$picture_dir" ]; then
    mkdir -p "$picture_dir"	
fi
# 移动壁纸图片
mv -f wallpaper.jpg $picture_dir

# 启用 User Theme 扩展插件，必须先启用该插件，GTK 主图才能解除禁用，需要在普通用户下执行
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

# 在用户环境下执行的指令
echo "==========开始配置gnome-tweaks关键选项=========="
gsettings --help
# 展示所有 gsettings 可配置对象，列出安装了的架构
gsettings list-schemas
# 查看具体某个可配置对象内部的所有可配置项的键
gsettings list-keys org.gnome.mutter
gsettings list-keys org.gnome.desktop.wm.preferences
gsettings list-keys org.gnome.desktop.interface
# gsettings 配置项属性查询模板
gsettings get 架构[:路径] 键
gsettings get org.gnome.desktop.interface gtk-theme
gsettings get org.gnome.desktop.wm.preferences theme



# 执行 gsettings 命令，设置背景图片
gsettings set org.gnome.desktop.background picture-uri "file://$picture_dir/wallpaper.jpg"
# 界⾯文本
gsettings set org.gnome.desktop.interface font-name 'Cantarell Regular 12'
# ⽂档文本
gsettings set org.gnome.desktop.interface document-font-name 'Cantarell Regular 12'
# 等宽文本
gsettings set org.gnome.desktop.interface monospace-font-name "Monospace Regular 12"
# 更改光标主题
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
# 更改图标主题
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-light"
# 更改Shell主题
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Light"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark"
# 修改gtk主题，gtk-theme 为过时应用程序主题，不是 Shell 配置项
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
# 修改窗口主题，更改窗口管理器主题，wm.preferences 意为：窗口偏好
gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-Dark"
# 设置标题栏按钮，并设置在右侧
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# 居中显示新窗口
gsettings set org.gnome.mutter center-new-windows true

echo "==========完成配置gnome-tweaks关键选项=========="

# 清理下载的中间文件
cd ../
rm -rf $directory
echo "==========桌面美化配置完成=========="

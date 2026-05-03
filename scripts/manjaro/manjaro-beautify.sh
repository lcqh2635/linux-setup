#!/bin/bash

echo "==========开始桌面美化配置=========="
sudo pacman -Syyu
sudo pacman -S yay
yay -S gnome-tweaks gnome-software aur/extension-manager chrome-gnome-shell
yay -S aur/whitesur-gtk-theme aur/whitesur-icon-theme aur/whitesur-cursor-theme
yay -S whitesur-gtk-theme whitesur-icon-theme whitesur-cursor-theme

echo "==========开始下载并配置gtk主题=========="
# 先创建一个主题存放目录，然后下载 WhiteSur 系统主题
cd $HOME/下载

# WhiteSur GTK 主题
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme

# 安装默认 WhiteSur GTK 主题包
./install.sh    
# 主题在部分 GTK4 应用中无法生效问题解决，参考  https://github.com/vinceliuice/WhiteSur-gtk-theme?tab=readme-ov-file#fix-for-libadwaita-not-perfect   但无法实现主题切换了
./install/sh -l
# 卸载 GTK 主题
./install.sh -r
# 修复 libadwaita (不完美)
./install.sh -l -c Light 

# 优化头部 gnome-shell 
./install.sh --shell -i 'arch'

# 修复 libadwaita (不完美)
./install.sh --round --right

# 安装的 flat Firefox 主题
./tweaks.sh -f flat
# 卸载 Firefox 火狐主题
./tweaks.sh -f -r

# 修复了 Dash to Dock 主题问题。
./tweaks.sh -d

# 安装 GDM 主题，使用默认的背景
sudo ./tweaks.sh -g -b default         
# 安装 GDM 主题，使用自定义背景
sudo ./tweaks.sh -g -b "my picture.jpg" 
# 卸载 GDM 主题
sudo ./tweaks.sh -g -r

# WhiteSur Icon 主题
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
# 安装 Icon 主题
./install.sh
# 卸载 Icon 主题
./install.sh -r

# WhiteSur cursors 主题
git clone https://github.com/vinceliuice/WhiteSur-cursors.git -depth=1
sudo ./install.sh
yay -S WhiteSur-cursors

# WhiteSur 壁纸
git clone https://github.com/vinceliuice/WhiteSur-wallpapers.git --depth=1
# 安装 Gnome 背景（壁纸将随时间变化）
sudo ./install-gnome-backgrounds.sh
# 安装普通壁纸
./install-wallpapers.sh


# grub2 主题
git clone https://github.com/vinceliuice/grub2-themes.git
sudo ./install.sh -t tela -s 2k
sudo ./install.sh -t whitesur -s 2k
sudo ./install.sh -r -t tela
sudo ./install.sh -r -t whitesur

cat /etc/default/grub
grep "GRUB_THEME" /etc/default/grub


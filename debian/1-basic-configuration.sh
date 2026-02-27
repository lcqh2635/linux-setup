#!/bin/bash

# 设置在遇到错误时自动退出
set -e

# 在Wayland上开启分数缩放，开启显示缩放实验性功能
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
# 设置缩放比例，此处设置为 1.5 即显示器缩放 150%
gsettings set org.gnome.desktop.interface scaling-factor 1.5

# 读取用户密码
read -p "请输入你的登陆密码：" password

# 检查当前用户是否在sudo组中，如果不在就添加到 sudo 权限组
if ! groups | grep -q '\bsudo\b'; then
  echo "当前用户无法使用sudo，正在为用户配置sudo权限..."
  # 将当前用户添加到sudo组
  echo $password | su -c "usermod -aG sudo $USER" -s /bin/bash root
  # 重新登录以使更改生效
  echo "配置完成，请重新登录以使sudo权限生效。"
fi

# 安装指纹识别
echo "==========开始安装指纹模组=========="
echo $password | su -c "apt install fprintd libpam-fprintd" -s /bin/bash root

echo "==========开始安装 fcitx5 中文输入法=========="
# 首先卸载旧版输入法，卸载与 fcitx5 冲突的所有依赖
echo $password | su -c "apt remove --purge fcitx ibus" -s /bin/bash root
# 安装fcitx5中文拼音输入法
echo $password | su -c "apt install fcitx5 fcitx5-chinese-addons" -s /bin/bash root

echo "==========开始卸载自带游戏和不常用软件=========="
# 卸载Gnome自带游戏和不常用/无用软件
# 使用 --purge 参数可以确保在卸载软件时,连同配置文件一起删除
echo $password | su -c "apt remove --purge aisleriot gnome-sudoku gnome-nibbles ace-of-penguins gbrainy gnome-sushi gnome-taquin gnome-tetravex  gnome-robots gnome-chess lightsoff swell-foop quadrapassel tali gnome-mahjongg gnome-2048 iagno gnome-klotski five-or-more gnome-mines four-in-a-row hitori -y" -s /bin/bash root
# 清理残留的配置文件，删除之前卸载软件时留下的残余配置文件和依赖关系
echo $password | su -c "apt autoremove --purge && apt clean && apt autoclean -y" -s /bin/bash root

echo "==========Debian基础配置完成，需要重启才能生效！！！=========="
# 询问用户是否立刻重启
read -p "是否立即重启系统？(y/n): " answer
if [[ $answer == "y" || $answer == "Y" ]]; then
    echo $password | su -c "/usr/sbin/reboot" -s /bin/bash root
else
    echo "已取消立即重启，但系统将在5分钟后自动重启，请保存您的工作！！！"
    # 这将在当前时间的1分钟后重启系统，并在重启前显示一条提示消息。替换 `+5` 为您想要的倒计时时间，单位为分钟。
    # sudo shutdown -r +1 "系统将在1分钟后重启，请保存您的工作。你也可以手动立即重启！！！"
    echo $password | su -c "/usr/sbin/shutdown -r +5" -s /bin/bash root
fi


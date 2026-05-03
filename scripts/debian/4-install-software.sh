#!/bin/bash

echo "==========开始安装工作和娱乐常用软件工具=========="
# 设置在遇到错误时自动退出
set -e

# 读取用户密码
read -p "请输入你的登陆密码：" password

# 可让您一键保存当前配置（主题、图标、壁纸、所有桌面环境设置、扩展等）
flatpak install flathub io.github.vikdevelop.SaveDesktop -y
# 聊天、通讯
flatpak install flathub com.qq.QQ -y
flatpak install flathub com.tencent.WeChat -y
# YesPlayMusic音乐
flatpak install flathub io.github.qier222.YesPlayMusic -y
# 百度网盘
flatpak install flathub com.baidu.NetDisk -y
# Flatseal 是一个图形实用程序，用于查看和修改 Flatpak 应用程序的权限。
flatpak install flathub com.github.tchx84.Flatseal -y
# 以上软件是基本必装的常用软件
# Obsidian 文本编辑器
flatpak install flathub md.obsidian.Obsidian -y

# 下载安装非软件商城编程软件
cd $HOME/下载
echo "==========开始安装 jetbrains-toolbox 代码编辑器管理工具=========="
# -O 选项指示curl将下载的文件保存为与远程文件相同的文件名，为大写字母
# 使用`-OJ`选项参数后，`curl`会从URL中提取文件名，并将其用作保存文件的名称。
# toolbox
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.1.31116.tar.gz
# 解压缩 .tar.gz 文件
tar -xvf jetbrains-toolbox-2.3.1.31116.tar.gz
# 重命名
mv jetbrains-toolbox-2.3.1.31116 ToolBox
# 给AppImage文件授予可执行权限
chmod +x ToolBox/jetbrains-toolbox
# 将软件目录移动到 /opt 目录，需要管理员权限
echo $password | su -c "mv ToolBox /opt" -s /bin/bash root
# 执行 AppImage 文件来启动应用程序，第一次需要运行一下才能被系统识别出图标
echo $password | su -c "/opt/ToolBox/jetbrains-toolbox" -s /bin/bash root
echo "==========开始jetbra破解工具包=========="
wget -O jetbra.zip https://hardbin.com/ipfs/bafybeiawsvnhqx5o2aqa37pvq7brlk7vqj2cpty3b5xac655bxbpqbpkq4/files/jetbra-ded4f9dc4fcb60294b21669dafa90330f2713ce4.zip
# 解压 ZIP 压缩文件，使用 unzip 解压直接得到里面内容，也可以后面指定目录
unzip jetbra.zip
# 重命名文件夹
mv jetbra .jetbra
# 移动文件夹到用户主目录
mv .jetbra $HOME

echo "==========开始安装 Apifox 接口测试工具=========="
# Apifox
wget https://file-assets.apifox.com/download/Apifox-linux-deb-latest.zip
# 解压 ZIP 压缩文件，使用 unzip 解压直接得到里面内容，也可以后面指定目录
unzip Apifox-linux-deb-latest.zip -d Apifox-linux-deb-latest
cd Apifox-linux-deb-latest
package_name=$(ls | grep deb)
echo $password | su -c "apt install ./$package_name -y" -s /bin/bash root

echo "==========开始安装 virtual+vagrant 虚拟机环境=========="
# 从官网下载 virtualbox
package_name=virtualbox-7.0_7.0.18-162988~Debian~bookworm_amd64.deb
wget https://download.virtualbox.org/virtualbox/7.0.18/virtualbox-7.0_7.0.18-162988~Debian~bookworm_amd64.deb
echo $password | su -c "apt install vagrant ./$package_name -y" -s /bin/bash root

echo "==========开始安装 WindTerm_远程连接SSH软件工具=========="
wget https://github.com/kingToolbox/WindTerm/releases/download/2.6.0/WindTerm_2.6.1_Linux_Portable_x86_64.tar.gz
# 解压缩 .tar.gz 文件
tar -xvf WindTerm_2.6.1_Linux_Portable_x86_64.tar.gz
# 重命名文件夹
mv WindTerm_2.6.1 WindTerm
# 移动文件夹到 /opt
echo $password | su -c "mv WindTerm /opt" -s /bin/bash root
# 进入到 /opt/WindTerm 文件夹
cd /opt/WindTerm
# 执行权限
echo $password | su -c "chmod +x WindTerm" -s /bin/bash root
# 给快捷方式文件添加公共读取权限，让其能够被系统读取识别
echo $password | su -c "chmod +r windterm.desktop" -s /bin/bash root
# 请注意，路径中的斜杠 / 需要使用反斜杠 \ 进行转义，否则会被解释为分隔符。
echo $password | su -c "sed -i 's/Icon=windterm/Icon=\/opt\/WindTerm\/windterm.png/g' windterm.desktop" -s /bin/bash root
echo $password | su -c "sed -i 's/Exec=\/usr\/bin\/windterm/Exec=\/opt\/WindTerm\/WindTerm/g' windterm.desktop" -s /bin/bash root
# 移动desktop文件到 /usr/share/applications
echo $password | su -c "cp windterm.desktop /usr/share/applications" -s /bin/bash root
# 修改 windterm 主题字体大小
cd global/themes
echo $password | su -c "sed -i 's/font-size: 9pt/font-size: 12pt/g' dige-black/gui.theme" -s /bin/bash root
echo $password | su -c "sed -i 's/font-size: 9pt/font-size: 12pt/g' dige-white/gui.theme" -s /bin/bash root
echo $password | su -c "sed -i 's/font-size: 9pt/font-size: 12pt/g' dige-black-and-white/gui.theme" -s /bin/bash root

echo "==========完成安装工作和娱乐常用软件工具=========="




#!/bin/bash

# gnome-extensions 直接使用可以查看扩展的所有命令的作用
# gnome-extensions官网：https://gjs.guide/extensions/
# help      打印帮助
# version   打印版本
# enable    启用扩展
# disable   禁用扩展
# reset     重置扩展
# uninstall 卸载扩展
# list      列出扩展
# info      显示扩展信息
# show      显示扩展信息
# prefs     打开扩展首选项
# create    创建扩展
gnome-extensions create --help
gnome-extensions: UUID、名称和描述都是必需的
用法：
  gnome-extensions create [选项…]
创建新扩展
应用程序选项：
  --uuid=UUID                   新扩展的唯一标识符
  --name=名称                		新扩展的用户可见名称
  --description=描述         		扩展功能的简短描述
  --gettext-domain=域        	扩展使用的 gettext 域
  --settings-schema=架构     	扩展使用的 GSettings 方案
  --template=模板            		新扩展使用的模板
  --prefs                    	包括 prefs.js 模版
  -i, --interactive          	以交互方式输入扩展信息
  -q, --quiet                	不要打印错误信息
要使用完整的`gnome-extensions create`命令创建一个GNOME扩展插件，你需要在终端中执行以下命令：
gnome-extensions create --name="window-rounded-corners" --description="My first GNOME extension" --uuid="2320391937@qq.com"

# 以交互方式创建扩展并输入扩展信息
gnome-extensions create --interactive
window-rounded-corners
Style all gnome windows with rounded corners
window-rounded-corners@llf.yyds.com


这条命令将会创建一个名称为"MyFirstExtension"，描述为"My first GNOME extension"，UUID为"myfirstextension@yourdomain.com"
# 以上创建的自定义gnome扩展默认存放在 ~/.local/share/gnome-shell/extensions 目录
nautilus ~/.local/share/gnome-shell/extensions

圆角窗口参考项目：https://github.com/yilozt/rounded-window-corners




# pack      打包扩展
# install   安装扩展包
# gnome-extensions help
# gnome-extensions list	列出可安装的扩展插件
# gnome-extensions install rounded-window-corners@yilozt.shell-extension.zip
# gnome-extensions uninstall forge@jmmaranan.com
# 将 扩展、优化、扩展管理器这三个打开快捷指令添加到 SettingsCenter@lauinger-clan.de 扩展配置中，以此来减少dock栏的应用


# 以下是必装和推荐安装的扩展插件
# gtk4-ding@smedius.gitlab.com
Rounded_Corners@lennart-k
rounded-window-corners@fxgn
SettingsCenter@lauinger-clan.de
blur-my-shell@aunetx
caffeine@patapon.info
clipboard-indicator@tudmotu.com
hidetopbar@mathieu.bidon.ca
just-perfection-desktop@just-perfection
bluetooth-quick-connect@bjarosze.gmail.com
compiz-alike-magic-lamp-effect@hermes83.github.com
compiz-windows-effect@hermes83.github.com
wifiqrcode@glerro.pm.me
kimpanel@kde.org
quick-settings-avatar@d-go
ProxySwitcher@flannaghan.com
PrivacyMenu@stuarthayhurst
user-theme@gnome-shell-extensions.gcampax.github.com
arcmenu@arcmenu.com
custom-accent-colors@demiskp
dash-to-dock@micxgx.gmail.com
gsconnect@andyholmes.github.io
ding@rastersoft.com
pamac-updates@manjaro.org
space-bar@luchrioh
apps-menu@gnome-shell-extensions.gcampax.github.com
auto-move-windows@gnome-shell-extensions.gcampax.github.com
drive-menu@gnome-shell-extensions.gcampax.github.com
places-menu@gnome-shell-extensions.gcampax.github.com
nightthemeswitcher@romainvigier.fr
add-to-desktop@tommimon.github.com
Bluetooth-Battery-Meter@maniacx.github.com
lockkeys@vaina.lt
windowgestures@extension.amarullz.com
order-extensions@wa4557.github.com
display-scale-switcher@knokelmaat.gitlab.com
randomwallpaper@iflow.space
color-picker@tuberry
gnomebedtime@ionutbortis.gmail.com
ShutdownTimer@deminder
gnome-ui-tune@itstime.tech
# 根据自己的喜好配置通知横幅位置和动画。
notification-banner-reloaded@marcinjakubowski.github.com
# 将应用图标托盘带回顶部面板，并具有附加功能。
trayIconsReloaded@selfmade.pl
# 在网格上平铺窗口
gTile@vibou
# 使用键盘快捷键平铺窗口。
awesome-tiles@velitasali.com
# 将应用程序搜索从概述中移除。全局搜索框，类似：search-everything
search-light@icedman.github.com
# 农历
lunarcal@ailin.nemui


# dash2dock-lite@icedman.github.com
# rounded-window-corners@yilozt
# ddterm@amezin.github.com
# Vitals@CoreCoding.coms
# vbox-applet@gs.eros2.info
# lan-ip-address@mrhuber.com
# workspace-indicator@gnome-shell-extensions.gcampax.github.com


# 自动自带的系统扩展移除办法
nautilus admin:/usr/share/gnome-shell/extensions
# 用户扩展目录
nautilus ~/.local/share/gnome-shell/extensions
cd ~/.local/share/gnome-shell/extensions

# 开启分数缩放
gsettings get org.gnome.mutter experimental-features
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# .po文件编辑器
yay -S extra/poedit
# 将.mo文件转换为可编辑的.po文件。然后，您可以使用任何文本编辑器打开并修改.po文件。po文件为汉化模板文件
msgunfmt hidetopbar.mo -o hidetopbar.po
msgunfmt SettingsCenter.mo -o SettingsCenter.po
msgunfmt PrivacyMenu@stuarthayhurst.mo -o PrivacyMenu@stuarthayhurst.po

# 只需要将汉化文件添加到对应插件的 locale 国际化目录下即可。具体步骤如下：
1、首先随便在插件中选择一门国际化目录，然后将国际化文件转成可编辑的po模板文件，再使用上面安装的 poedit 打开，
2、然后点击 toolbar 中的 翻译/属性将其中的语言改成	中文（简体）
3、然后对汉化模板 po 文件的每一项进行翻译，保存
4、然后将 zh_CN 目录复制到对应插件的 locale 国际化目录


# 建议直接等插件对应版本更新
# GNOME有没有类似于macOS中应用程序菜单（如文件、编辑、视图等）集成到顶部Panel或全局菜单栏的功能，让 Manjaro 拥有Mac的全局菜单
参看网站： https://blog.csdn.net/YV_LING/article/details/128270852
Github工具网址： https://github.com/gonzaarcr/Fildem
用户改造版本： https://github.com/Sominemo/Fildem-Gnome-45
gnome扩展名称但目前还没有版本适配： fildem-global-menu

下载安装
https://github.com/gonzaarcr/Fildem/releases
sudo pacman -U ./python3-fildem*.zst




# FIldem-Menu-Gnome-46 使用配置参考
https://github.com/AndreaScerra/FIldem-Menu-Gnome-46
# 创建或编辑如下文件，并添加该配置项	gtk-modules="appmenu-gtk-module"
~/.gtkrc-2.0

# 创建或编辑如下文件
~/.config/gtk-3.0/settings.ini
# 添加如下内容
[Settings]
gtk-modules="appmenu-gtk-module"







yay -S extra/gnome-shell-extensions

# Night Theme Switcher 扩展插件配置
# 白天执行命令

gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-light"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Light"
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Light'

# 夜晚执行命令
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark"
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur-Dark'

# 列出所有可用的模式
gsettings list-schemas
# 查看某个特定模式下的所有键
gsettings list-keys org.gnome.desktop.interface
gsettings list-keys org.gnome.shell.extensions.user-theme
# 需要安装了 user-themes 扩展插件才有这个配置选项
gsettings get org.gnome.shell.extensions.user-theme name
gsettings list-keys org.gnome.desktop.wm.preferences
gsettings reset org.gnome.desktop.wm.preferences theme
gsettings set org.gnome.desktop.wm.preferences theme 'WhiteSur'



#!/bin/bash
# ==============================================================================
# 脚本名称: 3-ubuntu-beautify.sh
# 功能描述：自动安装并配置常用字体、主题、图标、光标
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x 3-ubuntu-beautify.sh && ./3-ubuntu-beautify.sh
# ==============================================================================

# Ubuntu 操作系统 ISO 阿里云和中科大加速下载网址：
# https://mirrors.aliyun.com/ubuntu-cdimage/releases/
# https://mirrors.ustc.edu.cn/ubuntu-cdimage/releases/
# cd ~/下载 && git clone https://cdn.gh-proxy.org/https://github.com/lcqh2635/linux-setup.git
# cd ~/文档/linux-setup && git add . && git commit -m 'backup' && git push

# ------------------------------------------------------------------------------
# 1. 安全与规范设置 (Best Practices)
# ------------------------------------------------------------------------------
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail


usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -t, --theme VARIANT     Specify theme color variant(s) [default|purple|pink|red|orange|yellow|green|grey|nord|all] (Default: blue)
    -a, --alternative       Install alternative icons for software center and file-manager
    -b, --bold              Install bolder panel icons version (1.5px size)
    -p, --kde-plasma        Replaces Apple logo with KDE Plasma logo.

    -r, --remove,
    -u, --uninstall         Uninstall (remove) icon themes

    -h, --help              Show help
EOF
}


# gsettings list-schemas
# gsettings list-recursively org.gnome.desktop.interface
# gsettings list-recursively org.gnome.desktop.wm.preferences
# gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略

# 设置新窗口居中显示
gsettings set org.gnome.mutter center-new-windows true
# 显示星期几
gsettings set org.gnome.desktop.interface clock-show-weekday true
# 设置电量百分比
gsettings set org.gnome.desktop.interface show-battery-percentage true
# 开启夜灯
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
# 设置夜灯温度（色温，范围 1000~10000，默认约 2700 色温严重偏黄，越小越黄）
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000


set_font() {
# apt list *fonts*
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
# 安装：sudo apt install -y fonts-noto-cjk fonts-jetbrains-mono

sudo apt install -y fonts-noto-cjk fonts-jetbrains-mono
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
}


reset_font() {
gsettings reset org.gnome.desktop.interface font-name
gsettings reset org.gnome.desktop.interface document-font-name
gsettings reset org.gnome.desktop.interface monospace-font-name
gsettings reset org.gnome.desktop.wm.preferences titlebar-font
gsettings reset org.gnome.desktop.interface font-antialiasing
gsettings reset org.gnome.desktop.interface font-hinting
}

uninstall_gtk_theme() {
./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r
}


# https://www.gnome-look.org/u/vinceliuice
# https://www.gnome-look.org/u/eliverlara
# 安装字体、图标、主题
install_themes_and_icons() {
    print_info "正在安装并配置系统字体..."
    echo "正在安装WhiteSur主题..."
    git clone --depth=1 https://cdn.gh-proxy.org/https://github.com/vinceliuice/WhiteSur-cursors.git

    git clone --depth=1 https://gitcode.com/gh_mirrors/wh/WhiteSur-wallpapers.git
    git clone --depth=1 https://gitcode.com/gh_mirrors/wh/WhiteSur-icon-theme.git
    git clone --depth=1 https://gitcode.com/gh_mirrors/wh/WhiteSur-gtk-theme.git

    git clone --depth=1 https://gitcode.com/gh_mirrors/ma/MacTahoe-icon-theme.git
    git clone --depth=1 https://gitcode.com/gh_mirrors/ma/MacTahoe-gtk-theme.git
    # 修改 Nautilus 侧边栏不透明度，参考 https://github.com/vinceliuice/WhiteSur-gtk-theme/issues/1127
    # grep '$opacity: ' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    # sed -i 's/\$opacity: 0\.96/\$opacity: 1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    sed -i 's/0\.96/1/g' ~/下载/WhiteSur-gtk-theme/src/sass/_colors.scss
    sed -i 's/0\.95/1/g' ~/下载/WhiteSur-gtk-theme/other/firefox/WhiteSur/colors/light.css
    sed -i 's/0\.95/1/g' ~/下载/WhiteSur-gtk-theme/other/firefox/WhiteSur/colors/dark.css

    cd ~/下载/WhiteSur-wallpapers && sudo ./install-gnome-backgrounds.sh
    cd ~/下载/WhiteSur-cursors && ./install.sh
    cd ~/下载/WhiteSur-icon-theme && ./install.sh
    
    # 在执行 ./tweaks.sh -f flat 安装 Firefox 主题时，Firefox 不能正在运行
    if pgrep firefox > /dev/null; then
        print_info "Firefox 正在运行，正在杀死进程..."
        pkill firefox
        sleep 3
    else
        print_info "Firefox 未在运行..."
        # 快速启动 Firefox 并在 3 秒后杀死它
        firefox & sleep 3 && pkill firefox
    fi
    # 为 libadwaita 安装，默认是普通暗色主题
    cd ~/下载/WhiteSur-gtk-theme && ./install.sh -l -o solid && ./tweaks.sh -f flat -F -o solid
    # 如果文件都在当前目录
    cd ~/下载 && rm -rf WhiteSur-*
    # 最简洁的方式
    # cd ~/下载 && rm -rf WhiteSur-{cursors,icon-theme,gtk-theme}
    
    # 卸载主题
    # ./install.sh -r && ./tweaks.sh -f -r && ./tweaks.sh -F -r

    print_success "WhiteSur GTK 图标启用并配置完成！"
    print_success "主题和图标安装完成！"
}


# 主函数
main() {
    print_info "开始 Fedora Workstation 42 自动化配置..."
    
    # 检查权限
    check_root
    
    print_success "=========================================="
    print_success "Fedora 配置完成！"
    print_success "建议重启系统以应用所有更改。"
    print_success "=========================================="
    
    # 提示用户重启
    read -p "是否现在重启系统？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo reboot
    fi
}

# 执行主函数
main "$@"

# 清理临时文件
echo "正在清理临时文件..."
dnf clean all

echo "主题美化完成！请注销或重启系统以查看全部更改效果。"
echo "您可以使用GNOME Tweaks工具进一步自定义外观。"


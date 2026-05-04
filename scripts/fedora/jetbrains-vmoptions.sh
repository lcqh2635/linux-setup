#!/bin/bash

# Fedora GNOME 42 初始化优化配置脚本
# 功能：自动安装并配置加速镜像、工具、依赖包
# 使用方法：chmod +x jetbrains-vmoptions.sh && ./jetbrains-vmoptions.sh

# 更新系统并升级所有已安装的包
echo "开始更新系统并升级所有已安装的包..."
sudo dnf update -y && sudo dnf upgrade -y
echo "系统更新、升级完成..."


# 启用第三方优质库	https://copr.fedorainfracloud.org
# https://copr.fedorainfracloud.org/coprs/medzik/jetbrains/
# sudo dnf copr enable medzik/jetbrains
# dnf list goland
# sudo dnf install -y intellij-idea-ultimate
# sudo dnf install -y goland webstorm rustrover datagrip android-studio pycharm-professional

# sudo dnf copr enable huakim/kde-plasma
sudo dnf install -y \
gradle \
gnome-shell-extension-gtk4-ding \
gnome-shell-extension-desktop-icons \
gnome-shell-extension-valent \
gnome-shell-extension-unite


# 下载  jetbra.zip 以及获取 JetBrains 软件激活码
# https://3.jetbra.in/
# https://ipfs.io/ipfs/bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i/
# https://bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i.ipfs.dweb.link/


# 下载 jetbrains-toolbox 应用
echo "准备开始安装jetbrains-toolbox应用..."
if [ ! -d "WhiteSur-wallpapers" ]; then
    echo "正在安装WhiteSur壁纸..."
    # git clone https://github.com/vinceliuice/WhiteSur-wallpapers.git --depth=1
    git clone https://gitee.com/llf2635/linux.git --depth=1
    cd linux
    sudo dnf install -y unzip
    wget "https://ipfs.io/ipfs/bafybeih65no5dklpqfe346wyeiak6wzemv5d7z2ya7nssdgwdz4xrmdu6i/files/jetbra-8f6785eac5e6e7e8b20e6174dd28bb19d8da7550.zip"
    unzip jetbra.zip
    mv jetbra ~/.jetbra
    wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.6.2.41321.tar.gz"
    tar -xzf jetbrains-toolbox-2.6.2.41321.tar.gz
    cd jetbrains-toolbox-2.6.2.41321
    ./jetbrains-toolbox
    cd ..
    rm -rf jetbrains-toolbox-2.6.2.41321 jetbrains-toolbox-2.6.2.41321.tar.gz
fi


# ===================================================================
#  JetBrains IDE 优化配置文件 (idea64.vmoptions)
#  适用环境：
#    - 操作系统：Fedora Linux
#    - JVM：JDK 21（推荐使用 Oracle JDK 或 OpenJDK 21+）
#    - IDE：IntelliJ IDEA、WebStorm、PyCharm、GoLand 等
#    - 物理内存建议：16GB ~ 32GB 系统，堆内存 2G~4G
#  优化目标：
#    - 稳定优先（适合日常开发）
#    - 内存利用合理（6GB）
#    - 避免 GC 卡顿，加快启动和索引性能
#    - 兼顾 Linux / Wayland 显示效果
#  使用方式：
#    1. 在 IDE 启动界面点击齿轮图标 → "Custom VM Options"
#    2. 或手动编辑：
#       ~/.config/JetBrains/<Product><Version>/idea64.vmoptions
# JVM 配置参数官网：https://www.jetbrains.com/zh-cn/help/idea/tuning-the-ide.html
# ===================================================================

# ===================================================================
# 1、🧠 内存设置（核心参数）
# ===================================================================
# JVM 初始堆内存：2GB
# 👉 启动时直接分配，避免频繁扩容带来的性能抖动
-Xms2g
# JVM 最大堆内存：6GB
# 👉 你的 32GB 内存，给 IDEA 6GB 是比较合理的平衡点
-Xmx6g
# ===================================================================
# 2、⚙️ JIT + 代码缓存
# ===================================================================
# JIT 编译后的代码缓存大小：1GB
# 👉 防止 "CodeCache is full" 导致性能下降
# 👉 大型项目（Spring / 多模块）很有用
-XX:ReservedCodeCacheSize=1g
# JIT 编译线程数
# 👉 使用 4 个线程进行即时编译
# 👉 避免线程过多抢占 CPU（你是 16 线程，4 是较优解）
-XX:CICompilerCount=4
# ===================================================================
# 3、🗑️ 垃圾回收（GC）
# ===================================================================
# 使用 G1 垃圾回收器（默认推荐）
# 👉 平衡吞吐量与延迟，适合 IDEA 这种桌面应用
-XX:+UseG1GC
# 目标 GC 停顿时间：200ms
# 👉 JVM 会尽量调整策略来控制停顿时间
-XX:MaxGCPauseMillis=200
# 软引用回收策略
# 👉 内存紧张时更快回收缓存对象（如图片、索引缓存）
# 👉 IDEA 这种大量缓存场景很有用
-XX:SoftRefLRUPolicyMSPerMB=50
# 禁止手动调用 System.gc()
# 👉 防止某些插件或代码触发 Full GC 导致卡顿
-XX:+DisableExplicitGC
# ===================================================================
# 4、🚀 性能优化
# ===================================================================
# 字符串去重（G1GC 特性）
# 👉 减少重复字符串占用内存（对 Java 项目特别有效）
-XX:+UseStringDeduplication
# 压缩对象指针
# 👉 减少内存占用，提高缓存命中率（默认其实已开启）
-XX:+UseCompressedOops
# 解锁实验性 JVM 参数
# 👉 为某些高级参数提供支持（本配置中影响不大，但可保留）
-XX:+UnlockExperimentalVMOptions
# ===================================================================
# 5、🧯 稳定性 & 调试
# ===================================================================
# OOM 时生成堆转储（heap dump）
# 👉 用于分析内存泄漏问题
-XX:+HeapDumpOnOutOfMemoryError
# 禁用 FastThrow 优化
# 👉 保证异常始终有完整堆栈（方便调试）
-XX:-OmitStackTraceInFastThrow
# ===================================================================
# 6、🌐 网络 & IO
# ===================================================================
# 优先使用 IPv4
# 👉 避免某些环境 IPv6 带来的连接问题
-Djava.net.preferIPv4Stack=true
# 禁用文件路径缓存
# 👉 避免文件变动后缓存未更新的问题（开发环境更安全）
-Dsun.io.useCanonCaches=false
# ===================================================================
# 7、🌍 编码
# ===================================================================
# 默认字符编码 UTF-8
# 👉 避免中文乱码问题（强烈建议保留）
-Dfile.encoding=UTF-8
# ===================================================================
# 8、🖥️ UI 渲染（Linux / Wayland 优化）
# ===================================================================
# 使用系统字体抗锯齿设置
# 👉 提升字体显示效果
-Dawt.useSystemAAFontSettings=lcd
# Swing 开启抗锯齿
# 👉 让 IDEA 字体更平滑
-Dswing.aatext=true
# ===================================================================
# 9、🔥 自定义的破解工具
# ===================================================================
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains



# IDEA 虚拟机配置文件存放位置
# nautilus ~/.config/JetBrains
# cat ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions

# 为 IntelliJIdea 配置虚拟机参数
tee -a ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions > /dev/null << EOF

EOF

# 为 RustRover 配置虚拟机参数
tee -a ~/.config/JetBrains/RustRover*/rustrover64.vmoptions > /dev/null << EOF

EOF

# 为 GoLand 配置虚拟机参数
tee -a ~/.config/JetBrains/GoLand*/goland64.vmoptions > /dev/null << EOF

EOF

# 为 DataGrip 配置虚拟机参数
tee -a ~/.config/JetBrains/DataGrip*/datagrip64.vmoptions > /dev/null << EOF

EOF

# 为 PyCharm 配置虚拟机参数
tee -a ~/.config/JetBrains/PyCharm*/pycharm64.vmoptions > /dev/null << EOF

EOF

echo "主题美化完成！请注销或重启系统以查看全部更改效果。"
echo "您可以使用GNOME Tweaks工具进一步自定义外观。"






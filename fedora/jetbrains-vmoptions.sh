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


# IDEA 虚拟机配置文件存放位置
# nautilus ~/.config/JetBrains
# cat ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions




-Xms512m
-Xmx4g
-XX:ReservedCodeCacheSize=512m
-XX:MetaspaceSize=256m
-XX:MaxMetaspaceSize=512m
-XX:+UseZGC
-XX:SoftMaxHeapSize=3g
-XX:+UnlockExperimentalVMOptions
-XX:+TieredCompilation
-XX:TieredStopAtLevel=1
-XX:+ParallelRefProcEnabled
-Dsun.java2d.uiScale.enabled=true
-Dsun.java2d.dpiaware=true
-Dswing.bufferPerWindow=true
-Dide.no.platform.update=true
-Dide.plugins.snapshot.on.start=false
-Dfile.encoding=UTF-8
-Duser.language=zh
# -Duser.region=CN
# -Duser.country=CN


# 为 IntelliJIdea 配置虚拟机参数
echo "
-Xms2g
-Xmx4g
-XX:ReservedCodeCacheSize=512m
-XX:+IgnoreUnrecognizedVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:+UseZGC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow

-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Drecreate.x11.input.method=true
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains
" | sudo tee -a ~/.config/JetBrains/IntelliJIdea*/idea64.vmoptions



#=============================================================
#  JetBrains IDE 优化配置 (JDK 21 + Fedora 42)
#  适用于 IntelliJ IDEA / WebStorm / GoLand 等
#  内存建议：16GB+ 系统，堆内存 2G~4G
#=============================================================
# 基础堆内存（根据项目规模调整）
-Xms2g
-Xmx4g
# 垃圾回收器（JDK21推荐ZGC）减少 GC 停顿（ZGC 下效果显著）
-XX:+UseZGC
-XX:+UnlockExperimentalVMOptions
-XX:ZCollectionInterval=30
-XX:ZAllocationSpikeTolerance=2.0
-XX:ZCollectionInterval=5000
# 元空间（默认值可能不足）
-XX:MetaspaceSize=256m
-XX:MaxMetaspaceSize=512m
-XX:ZFragmentationLimit=10
-XX:+UseStringDeduplication
-XX:ReservedCodeCacheSize=512m
-XX:+IgnoreUnrecognizedVMOptions
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
# 启用并行类加载（提升启动速度）
-XX:+ParallelRefProcEnabled
# 启用 JVM 分层编译，提升启动和运行性能
-XX:+TieredCompilation
-XX:TieredStopAtLevel=1
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Dfile.encoding=UTF-8
-Duser.language=zh
# -Duser.region=CN

--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains


# 为 GoLand 配置虚拟机参数
echo "
-Xms1g
-Xmx5g
-XX:ReservedCodeCacheSize=512m
-XX:+IgnoreUnrecognizedVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:+UseZGC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Drecreate.x11.input.method=true
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains
" | sudo tee -a ~/.config/JetBrains/GoLand*/goland64.vmoptions

# 为 DataGrip 配置虚拟机参数
echo "
-Xms1g
-Xmx5g
-XX:ReservedCodeCacheSize=512m
-XX:+IgnoreUnrecognizedVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:+UseZGC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Drecreate.x11.input.method=true
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains
" | sudo tee -a ~/.config/JetBrains/DataGrip*/datagrip64.vmoptions

# 为 PyCharm 配置虚拟机参数
echo "
-Xms1g
-Xmx5g
-XX:ReservedCodeCacheSize=512m
-XX:+IgnoreUnrecognizedVMOptions
-XX:+UnlockExperimentalVMOptions
-XX:+UseZGC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off
-Drecreate.x11.input.method=true
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains
" | sudo tee -a ~/.config/JetBrains/PyCharm*/pycharm64.vmoptions


# 清理临时文件
echo "正在清理临时文件..."
dnf clean all

echo "主题美化完成！请注销或重启系统以查看全部更改效果。"
echo "您可以使用GNOME Tweaks工具进一步自定义外观。"



# ===================================================================
#  JetBrains IDE 优化配置文件 (idea64.vmoptions)
#  适用环境：
#    - 操作系统：Fedora 42（Linux）
#    - JVM：JDK 21（推荐使用 Oracle JDK 或 OpenJDK 21+）
#    - IDE：IntelliJ IDEA、WebStorm、PyCharm、GoLand 等
#    - 物理内存建议：16GB ~ 32GB 系统，堆内存 2G~4G
#  优化目标：
#    - 降低内存占用
#    - 提升 UI 响应速度
#    - 减少 GC 卡顿
#    - 加快启动和索引性能
#  使用方式：
#    1. 在 IDE 启动界面点击齿轮图标 → "Custom VM Options"
#    2. 或手动编辑：
#       ~/.config/JetBrains/<Product><Version>/idea64.vmoptions
# ===================================================================

# 堆内存设置：平衡性能与内存占用
# 初始堆大小设为 512MB，避免启动时占用过多内存
-Xms1g
# 最大堆内存设为 4GB。足够应对大多数 Java/TS/Rust 项目。
# 若内存紧张可降为 -Xmx3g 或 -Xmx2g；大型项目可升至 -Xmx6g
-Xmx4g

# 代码缓存与元空间优化
# JIT 编译后的字节码缓存空间。增大可减少重复编译，提升响应速度
-XX:ReservedCodeCacheSize=512m
# 类元数据区初始大小。避免频繁动态扩展
# -XX:MetaspaceSize=256m
# 限制元空间最大值，防止因类加载过多导致内存溢出
# -XX:MaxMetaspaceSize=512m

# 使用 ZGC（低延迟垃圾回收器，JDK 21 推荐）
# JDK 21 默认支持 ZGC，延迟极低（通常 < 10ms），显著减少卡顿
# 替代 G1GC，特别适合交互式开发环境
-XX:+UseZGC
# ZGC 特有参数：建议 JVM 尽量保持堆在 3GB 以内，仅在必要时扩展到 -Xmx
# 有助于控制系统内存占用
-XX:SoftMaxHeapSize=3g
# 启用 ZGC 所需（在某些 OpenJDK 构建中需要）
-XX:+UnlockExperimentalVMOptions

# JVM 性能与编译优化
# 启用分层编译（解释执行 → C1 → C2），提升运行时性能
-XX:+TieredCompilation
# 限制 JIT 编译层级到 C1（简单优化），减少编译开销和内存使用
# 适合开发环境（非生产），加快响应
-XX:TieredStopAtLevel=1
# 并行处理软/弱/虚引用，减少 GC 停顿时间
-XX:+ParallelRefProcEnabled
-XX:+IgnoreUnrecognizedVMOptions
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
-ea
-Dsun.io.useCanonCaches=false
-Djdk.http.auth.tunneling.disabledSchemes=""
-Djdk.attach.allowAttachSelf=true
-Djdk.module.illegalAccess.silent=true
-Dkotlinx.coroutines.debug=off

# UI 与图形渲染优化（Fedora 推荐）
# 启用高 DPI 缩放支持（HiDPI 屏幕友好）
-Dsun.java2d.uiScale.enabled=true
# 让 Java 应用感知系统 DPI 设置，避免模糊
-Dsun.java2d.dpiaware=true
# 启用窗口级双缓冲，减少重绘闪烁，提升 UI 流畅性
-Dswing.bufferPerWindow=true

# IDE 功能与行为优化
# 禁用 IDE 平台更新检查（可手动检查），减少后台任务
-Dide.no.platform.update=true
# 禁用启动时插件状态快照，加快启动速度
-Dide.plugins.snapshot.on.start=false
# 强制文件编码为 UTF-8
-Dfile.encoding=UTF-8
# 设置中文（简体）
-Duser.language=zh
# 设置区域格式，影响日期、数字、货币的显示形式（如 ¥ vs ￥）CN, US
# -Duser.region=CN
# 设置国家/地区代码，影响语言包加载（如界面语言）CN, US
# -Duser.country=CN

--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
-javaagent:/home/lcqh/.jetbra/ja-netfilter.jar=jetbrains

# 其他建议（不在 vmoptions 中，但相关）
# 1. 在 IDE 设置中：
#    - Settings → Plugins → 禁用不用的插件（如 Docker、Database、AI 工具）
#    - Settings → Directories → 将 node_modules、target、build 标记为 "Excluded"
#    - 启用 "Power Save Mode" 进行专注编码
# 2. 使用 JetBrains Toolbox 管理多个 IDE 版本
# 3. 避免使用 Flatpak 版本（沙盒限制多，性能较差）
# 4. 若使用 Rust 插件，确保启用 LSP 模式以减少资源占用

#!/bin/bash

# 设置在遇到错误时自动退出
set -e
echo "==========开始安装配置开发环境=========="

# 读取用户密码
read -p "请输入你的登陆密码：" password

# 更新系统
# 在普通用户下执行管理员命令
echo $password | su -c "apt update && apt upgrade -y" -s /bin/bash root
echo $password | su -c "apt install build-essential git vim nodejs zip curl -y" -s /bin/bash root

# 安装的 rust 自带 cargo 包管理工具
echo "==========开始安装 Rust=========="
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
echo 你刚安装的 Rust 版本号为： $(rustc --version)

echo "==========开始安装 sdkman=========="
sdkman_dir="$HOME/.sdkman"
# 如果目录存在
if [ -d "$sdkman_dir" ]; then
    cd $HOME
    rm -rf .sdkman		
fi
# 安装 sdkman 工具
curl -s "https://get.sdkman.io" | bash
# 启动SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"
# 验证SDKMAN是否成功安装
echo 你刚安装的 sdkman 版本号为： $(sdk version)
# 这将安装指定版本的Java。
echo "==========开始安装 Java=========="
sdk install java 21.0.3-graal
# 这将安装指定版本的Maven
echo "==========开始安装 Maven=========="
sdk install maven 3.9.6
sdk current

echo "==========开始安装 Bun=========="
# 安装 bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
echo 你刚安装的 bun 版本号为： $(bun --version)

echo "==========开发环境安装配置完成，需要重启才能生效！！！=========="
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

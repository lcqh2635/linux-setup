#!/bin/bash

echo "==========开始安装配置开发环境=========="

# 更新系统
sudo pacman -Syu
# 安装tuari相关的依赖，都是一些系统基础工具
sudo pacman -S --needed \
    webkit2gtk \
    base-devel \
    curl \
    wget \
    openssl \
    appmenu-gtk-module \
    gtk3 \
    libappindicator-gtk3 \
    librsvg \
    libvips

yay -S vim zip
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
    rm -rf $HOME/.sdkman		
fi
# 安装 sdkman 工具
curl -s "https://get.sdkman.io" | bash
# 启动SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"
# 验证SDKMAN是否成功安装
echo 你刚安装的 sdkman 版本号为： $(sdk version)
# 这将安装指定版本的Java。
echo "==========开始安装 Java=========="
sdk install java 21.0.4-graal
sdk install java 17.0.11-graal
sdk use java 21.0.3-graal
sdk install kotlin

# 这将安装指定版本的Maven
echo "==========开始安装 Maven=========="
sdk install maven
sdk install gradle
sdk current

echo "==========开始安装 Bun=========="
# 安装 bun
curl -fsSL https://bun.sh/install | bash
yay -S nodejs npm
sudo npm install -g bun
source ~/.bashrc
echo 你刚安装的 bun 版本号为： $(bun --version)



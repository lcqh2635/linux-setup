#!/bin/bash
# ==============================================================================
# 脚本名称: 5-ubuntu-development.sh
# 功能描述：自动安装并配置常用字体、主题、图标、光标
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x 5-ubuntu-development.sh && ./5-ubuntu-development.sh
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


# 🏆 最佳实践，完美组合
# 更新 APT 包列表、升级 APT 包、 删除无用依赖、清理无效缓存
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y && sudo apt autoclean -y


# ------------------------------------------------------------------------------
# 通过 apt 安装 (推荐)
# https://ubuntu.com/toolchains
sudo apt install -y default-jdk maven
echo "🐍 你刚安装的 java 版本号为：$(java --version)"
echo "🐍 你刚安装的 maven 版本号为：$(mvn --version)"
# whereis maven
# nautilus admin:/usr/share/maven
# 配置 maven 阿里云 aliyun 加速镜像	https://maven.aliyun.com/mvn/guide
# -v (verbose)：详细模式。
# 作用：每创建一个目录，都会在终端打印一条提示信息。让用户知道命令到底执行了什么
# -p (parents)：父目录模式。
# 作用 ：如果指定的路径中父目录不存在，会自动递归创建。如果目录已经存在，不会报错，而是静默成功
mkdir -vp $HOME/.m2
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee -a $HOME/.m2/settings.xml
<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">

  <mirrors>
    <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>*</mirrorOf>
      <name>阿里云公共仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>

</settings>
EOF
# 甚至可以使用大括号展开来创建有规律的目录
mkdir -vp $HOME/编程/{Java,Rust,Cpp,Python,TypeScript,Database}
# https://gitcn.org/
# https://gitcn.org/topics
# https://gitcn.org/top

# https://github.com/openjdk/jdk
# https://github.com/topics/java
# https://dev.java/

# https://github.com/rust-lang/rust
# https://gitcn.org/topics/rust
# https://gitcn.org/trending?lang=Rust
# https://rust-lang.org/zh-CN/

# https://github.com/topics/c
# https://github.com/topics/python
mkdir -vp $HOME/编程/Database/{SQLite,MySQL,MariaDB,Postgres,Distributed,Redis}
# https://github.com/sqlite/sqlite
# https://www.sqlite.net.cn/

# https://github.com/mysql/mysql-server
# https://www.mysql.com/cn/

# https://github.com/MariaDB/server
# https://mariadb.org.cn/

# https://github.com/postgres/postgres
# https://postgresql.ac.cn/

# https://github.com/pingcap/tidb
# https://docs.pingcap.com/zh/

# https://github.com/oceanbase/oceanbase
# https://www.oceanbase.com/product/opensource

# https://github.com/redis/redis
# https://www.redis.net.cn/

# IDEA 配置 “Maven 主路径” 为 /usr/share/maven 直接复制到输入框即可
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 第七步：安装 Rust
echo "🦀 安装 Rust..."
# Rust Web 常用的框架 Axum 目前排名性能总榜 7，需要使用 pg 数据库，数据来自性能测试网站	https://www.techempower.com/benchmarks
# 配置 crates.io 国内中科大 ustc 加速镜像源	 https://mirrors.ustc.edu.cn/help/crates.io-index.html
# 配置 crates.io 国内阿里云 aliyun 加速镜像源	https://developer.aliyun.com/mirror/rustup 

# 配置 rustup 使用阿里云的加速镜像源，从而 加速 Rust 工具链（如 rustc、cargo）的下载和更新
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee -a ~/.bash_profile
# 配置中科大 ustc 的 Rust Toolchain 反向代理 	https://mirrors.ustc.edu.cn/help/rust-static.html
# 指定 Rust 工具链和组件的下载地址（如 rustc,cargo,rust-std 等）
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
# 指定 rustup 自身更新元数据的地址（即 rustup 如何检查自身版本、下载新版本）
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

# 配置阿里云 aliyun 的 Rust Toolchain 反向代理 	https://developer.aliyun.com/mirror/rustup
# export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
# export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
EOF

source ~/.bash_profile
# cat ~/.bash_profile

# 用 shell 执行从标准输入来的脚本，并把 -y 作为参数传给那个脚本，告诉它：自动安装，不要问我！
# 自动确认所有提示，使用默认设置安装（相当于 yes）
# 使用官方安装脚本
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# 使用阿里云安装脚本
curl --proto '=https' --tlsv1.2 -sSf https://mirrors.aliyun.com/repo/rust/rustup-init.sh | sh -s -- -y
# 激活 Rust 环境
. "$HOME/.cargo/env"

# rustup update
# 如果正在使用 cargo 1.68 及以上版本，在 $HOME/.cargo/config.toml 中添加如下内容即可：

# -v (verbose)：详细模式。
# 作用：每创建一个目录，都会在终端打印一条提示信息。让用户知道命令到底执行了什么
# -p (parents)：父目录模式。
# 作用 ：如果指定的路径中父目录不存在，会自动递归创建。如果目录已经存在，不会报错，而是静默成功。
#  ${MAVEN_HOME:-$HOME/.m2} 这是 Shell 参数扩展（Parameter Expansion） 语法，格式为 ${变量名:-默认值}
# 作用：检查环境变量 MAVEN_HOME 是否已设置且非空。如果是：使用 MAVEN_HOME 的值作为目录路径。如果否（未设置或为空）：使用默认值 $HOME/.m2
mkdir -vp ${CARGO_HOME:-$HOME/.cargo}
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | tee -a ${CARGO_HOME:-$HOME/.cargo}/config.toml
# 配置 Cargo 国内加速镜像源，可选：ustc、aliyun、tuna 此处默认选择 ustc
# 使用稀疏协议（sparse）减少元数据下载量，大幅加速
[source.crates-io]
replace-with = 'ustc'

# ustc 中科大 crates.io 镜像 	https://mirrors.ustc.edu.cn/help/crates.io-index.html
[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

# aliyun 阿里云 crates.io 镜像	https://developer.aliyun.com/mirror/rustup 
[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"
[registries.aliyun]
index = "sparse+https://mirrors.aliyun.com/crates.io-index/"
EOF
# cat $HOME/.cargo/config.toml

# https://crates.io/
# https://crates.io/crates/tauri
# https://crates.io/crates/tokio
# https://crates.io/crates/hyper
# https://crates.io/crates/axum
# https://crates.io/crates/axum-valid
# https://crates.io/crates/axum-extra
# https://crates.io/crates/axum-test
# https://crates.io/crates/axum-login
# https://crates.io/crates/axum-anyhow
# https://crates.io/crates/tower
# https://crates.io/crates/tower-http
# https://crates.io/crates/tower-sessions
# https://crates.io/crates/tower_governor
# https://crates.io/crates/leptos
# https://crates.io/crates/reqwest
# https://crates.io/crates/tonic
# https://crates.io/crates/sqlx
# https://crates.io/crates/sea-orm
# https://crates.io/crates/redis
# https://crates.io/crates/deadpool
# https://crates.io/crates/deadpool-redis
# https://crates.io/crates/deadpool-postgres
# https://crates.io/crates/fred
# https://crates.io/crates/serde
# https://crates.io/crates/serde_json
# https://crates.io/crates/validator
# https://crates.io/crates/jsonwebtoken
# https://crates.io/crates/uuid
# https://crates.io/crates/chrono
# https://crates.io/crates/dotenvy
# https://crates.io/crates/config
# https://crates.io/crates/tokio-cron-scheduler
# https://crates.io/crates/lettre
# https://crates.io/crates/captcha
# https://crates.io/crates/thiserror
# https://crates.io/crates/anyhow
# https://crates.io/crates/axum-anyhow
# https://crates.io/crates/rand
# https://crates.io/crates/image
# https://crates.io/crates/aws-sdk-s3
# https://crates.io/crates/object_store
# https://crates.io/crates/utoipa
# https://crates.io/crates/utoipa-gen
# https://crates.io/crates/base64
# https://crates.io/crates/bcrypt
# https://crates.io/crates/oauth2
# https://crates.io/crates/tracing
# https://crates.io/crates/tracing-subscriber
# https://crates.io/crates/console-subscriber
# https://crates.io/crates/opentelemetry
# https://crates.io/crates/opentelemetry-otlp
# https://crates.io/crates/tracing-opentelemetry
# https://crates.io/crates/axum-tracing-opentelemetry
# https://crates.io/crates/rnacos
# https://crates.io/crates/nacos-sdk
# https://crates.io/crates/metrics
# https://crates.io/crates/metrics-exporter-prometheus
# https://crates.io/crates/prometheus
# https://crates.io/crates/metrics-prometheus
# https://crates.io/crates/lapin
# https://crates.io/crates/rdkafka
# https://crates.io/crates/rocketmq-rust
# https://crates.io/crates/rocketmq-client-rust
# https://crates.io/crates/rust_decimal
# https://crates.io/crates/sysinfo
# https://crates.io/crates/clap
# https://crates.io/crates/regex
# ------------------------------------------------------------------------------

sudo apt install -y zig
echo "🐍 你刚安装的 zig 版本号为：$(zig version)"

# ------------------------------------------------------------------------------
# 第六步：安装 Go 语言
echo "🐹 安装 Go 语言..."
# Go 国内加速镜像	https://learnku.com/go/wikis/38122
# golang 中文学习文档	https://golang.halfiisland.com/
# golang 官方网站	https://golang.google.cn/
# golang 公共软件包仓库	https://pkg.go.dev/
sudo apt install -y golang-go
echo "🐍 你刚安装的 golang 版本号为：$(go version)"
# Go 1.13+：默认启用，无需额外配置。但使用  go env GO111MODULE 显示为空
# 并不代表 Go Modules 未开启，而是表示你没有显式配置该变量，Go 将使用内部默认值
# 设置为 auto（推荐，Go 1.13+ 默认逻辑）
# go env -w GO111MODULE=auto
# 或者强制开启 Go Modules 功能
go env -w GO111MODULE=on
# 1. 设置模块代理（加速下载）
# 阿里云Go Module代理仓库服务	https://developer.aliyun.com/mirror/goproxy
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
# 2. 设置校验和数据库（避免超时）
go env -w GOSUMDB=sum.golang.google.cn
# 查看配置是否成功
# go env GO111MODULE
# go env GOPROXY
# go env GOSUMDB

# 设置 GOPATH 为 ~/go
mkdir -p $HOME/.go
go env -w GOPATH=$HOME/.go
# 查看当前环境
# go env GOPATH
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 通过 apt 安装 (推荐)
# https://ubuntu.com/toolchains
sudo apt install -y nodejs npm
# npm config get registry
# 执行后，npm 会自动帮你把配置写入 ~/.npmrc 文件，没必要手动编辑 ~/.npmrc 文件。
# 但需要注意的是，该配置的 npm 加速镜像只对当前用户有效，对于使用 sudo 的 npm 无效，例如  sudo npm install -g bun
# 配置 npm 国内阿里云 aliyun 加速镜像源，地址为	https://developer.aliyun.com/mirror/NPM
npm config set registry https://registry.npmmirror.com/
# 将目录所有权改为当前用户，否则如下命令将因为权限问题执行失败
sudo chown -R $(whoami):$(whoami) /usr/local
# 安装 Bun 运行时环境	https://www.bunjs.cn/docs/installation
# bun - 现代的 JavaScript 运行时和包管理器
# https://www.npmjs.com/package/bun
npm install -g bun
# bun create vite my-vue-app --template vue-ts
# Claude Code 是一款存在于终端中的代理编码工具，理解你的代码库，并通过自然语言命令帮助你执行例行任务、
# 解释复杂代码和处理 git 工作流程，从而更快地完成代码。在你的终端、IDE或Github上的标签@claude中使用。
# https://www.npmjs.com/package/@anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
echo "🐍 你刚安装的 bun 版本号为：$(bun --version)"
# bun 自行升级	bun upgrade
# bun run config --help
# bun --config
# 将 bunfig.toml 作为隐藏文件添加到用户主目录	https://www.bunjs.cn/docs/runtime/bunfig
cat << EOF | tee $HOME/.bunfig.toml
[install]
# 使用阿里云加速仓库，仓库地址可从阿里云官方获取，地址为	https://developer.aliyun.com/mirror/NPM
registry = "https://registry.npmmirror.com/"
EOF
# which node
# whereis node
# whereis bun
# 将 IDEA 的 JS/TS 默认运行时环境从 nodejs 改为 bun 操作如下：
# 1、设置 -> 语言和框架 -> Bun -> /usr/local/bin/bun
# 2、设置 -> 语言和框架 -> Node.js -> Node解释器 -> /usr/local/bin/bun

# 推荐安装的全局工具包
# https://docs.deno.org.cn/
npm install -g deno
# deno init --npm vite my-vue-app --template vue-ts
# vite - 下一代前端构建工具（通常项目局部安装，但全局也有用）
npm install -g typescript vite eslint prettier
# npm 列出所有全局安装的包
# npm list -g --depth=0
# 执行更新命令，更新所有可更新的全局包
# npm update -g
# ------------------------------------------------------------------------------

# https://3.jetbra.in/
# https://account.jetbrains.com/licenses
# JetBrains 的 API 返回的 JSON 中包含 多个架构的下载链接，你的 grep 命令会匹配 所有 包含 jetbrains-toolbox-*.tar.gz 的链接，
# 而 head -1 恰好取到了第一个（可能是 arm64）
# 关键：| grep -v 'arm64' 会过滤掉包含 "arm64" 的链接
wget -O jetbrains-toolbox.tar.gz "$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -o 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-[^\"]*\.tar\.gz' | grep -v 'arm64' | head -1)"
# 1. 创建一个专门放软件的目录 (例如在 home 目录下创建一个 apps 文件夹)
mkdir -p ~/.apps
# 2. 进入下载目录 (假设你的安装包在这里)
cd ~/下载
# 3. 解压到刚才创建的目录
# 注意：将 jetbrains-toolbox-*.tar.gz 替换为你实际下载的文件名，可以用 Tab 键自动补全
tar -xvf jetbrains-toolbox-*.tar.gz -C ~/.apps

# 1. 进入解压后的文件夹
cd ~/.apps/jetbrains-toolbox-*/bin
# 2. 赋予执行权限 (防止提示权限不足)
chmod +x jetbrains-toolbox
# 3. 启动程序
./jetbrains-toolbox




# ------------------------------------------------------------------------------
sudo apt install -y podman podman-compose
# 启用用户级 socket
systemctl --user enable --now podman.socket
# systemctl --user status podman
# https://github.com/containers/podman/blob/cea9340242f3f6cf41f20fb0b6239aa3db5decd6/docs/tutorials/socket_activation.md
# cat /usr/lib/systemd/user/podman.socket
# ls $XDG_RUNTIME_DIR/podman/podman.sock
# unix:///run/user/1000/podman/podman.sock
# podman info

# 配置国内加速镜像仓库
# 主要用于 登录到容器镜像仓库（Registry），以便拉取（pull）私有镜像或推送（push）镜像到仓库
# lcqh2635@gmail.com
# podman login
# cat /etc/containers/registries.conf
# 备份到同目录（添加 .bak 后缀）
sudo cp /etc/containers/registries.conf{,.bak}
# 检查 .bak 文件是否存在
# ls -l /etc/containers
# 从同目录 .bak 文件恢复
# sudo cp /etc/containers/registries.conf{.bak,}
# tee -a 中的 -a 参数的作用是 追加（append）内容到文件末尾，而不是覆盖文件原有内容
cat << EOF | sudo tee -a /etc/containers/registries.conf
# 定义未指定镜像仓库前缀时，默认搜索的镜像仓库列表
# 例如执行 "podman pull nginx" 会自动从 "docker.io" 查找 "library/nginx"
unqualified-search-registries = ["docker.io"]

# Podman 优先尝试从 registry.mirror 拉取镜像，如果加速器不可用/镜像不存在，则自动回退到 location 指定的官方地址
# 官方仓库地址（最终回退地址）
[[registry]]
# 匹配的镜像仓库前缀（支持通配符 *）
# 例如 "docker.io" 会匹配所有 "docker.io/xxx" 的镜像
prefix = "docker.io"
# 实际访问的仓库服务器地址
# Docker Hub 的官方注册表地址
location = "registry-1.docker.io"

# 镜像加速器地址（优先使用的镜像源）
# 添加该仓库的镜像加速器（Mirror）以阿里云镜像加速为示例
[[registry.mirror]]
# 镜像加速器地址（替换为你的阿里云镜像加速URL）
location = "docker.1ms.run"
# 是否允许不安全的 HTTP 连接（生产环境建议 false）
insecure = false
EOF

# 创建网络
podman network create podman-net
podman pull redis:latest
# https://pgtune.leopard.in.ua/
podman pull postgres:latest
# Pods 是一个 podman 的前端。它的用户界面使用 libadwaita 并力求符合 GNOME 的设计原则
# 打开 Pods 软件，点击 “新建连接” 然后选择使用默认的 “Unix Socket” 点击 Connect
# IDEA 连接 Podman：按 Ctrl+Alt+S 打开设置，然后选择 构建、执行、部署 | Docker。点击 "添加"按钮 以添加 Docker 配置。选择 Unix 套接字 ，然后下拉选择 rootless 版地址
sudo flatpak install -y flathub com.github.marhkb.Pods
# ------------------------------------------------------------------------------


echo "==========开发环境安装配置完成，需要重启才能生效！！！=========="
# 询问用户是否立刻重启
read -p "是否立即重启系统？(y/n): " answer
if [[ $answer == "y" || $answer == "Y" ]]; then
    sudo reboot
else
    echo "已取消立即重启，但系统将在5分钟后自动重启，请保存您的工作！！！"
fi

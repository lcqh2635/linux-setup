你好！既然你使用的是 **Ubuntu** 系统，且考虑到你之前从事的是 **金融级后端开发**（对脚本的健壮性、规范性和可维护性要求较高），我为你编写了一个符合企业级规范的 Shell 脚本示例。

这个示例模拟了一个名为 `deploy-tool.sh` 的运维辅助脚本，它实现了类似 `apt --help` 的结构化帮助信息，并展示了如何专业地解析 `-h`、`--help`、`-v`、`--version` 以及业务参数。

### 📜 标准 Shell 脚本帮助功能示例 (`deploy-tool.sh`)

```bash
#!/usr/bin/env bash
# ==============================================================================
# 脚本名称：deploy-tool.sh
# 功能描述：模拟企业级部署工具，展示标准的帮助信息设计与参数解析最佳实践
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：Assistant (基于用户背景定制)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 安全与规范设置 (Best Practices)
# ------------------------------------------------------------------------------
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail

# 定义脚本元数据，方便维护版本信息
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"
readonly AUTHOR="DevOps Team"

# 定义退出状态码 (符合 Linux 标准规范)
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2

# ------------------------------------------------------------------------------
# 2. 帮助信息函数 (核心需求)
# ------------------------------------------------------------------------------
# 设计思路：参考 apt --help 的结构，分为用法、描述、选项、示例、备注
# 使用 cat << EOF 保持格式整齐，避免大量 echo 语句
show_help() {
    cat << EOF
用法：${SCRIPT_NAME} [选项] <命令> [参数...]

描述：
  企业级应用部署与维护辅助工具。
  用于自动化执行环境检查、服务重启及日志清理等操作。

选项：
  -h, --help             显示此帮助信息并退出
  -v, --version          显示版本号并退出
  -c, --config <FILE>    指定配置文件路径 (默认：/etc/deploy/config.yaml)
  -e, --env <ENV>        指定运行环境 (可选：dev, test, prod)
  -d, --debug            开启调试模式，输出详细日志
  -q, --quiet            静默模式，仅输出错误信息

命令：
  check                  检查系统依赖与环境状态
  restart                重启目标服务
  clean                  清理旧版本构建产物

示例：
  ${SCRIPT_NAME} --help
  ${SCRIPT_NAME} -e prod restart
  ${SCRIPT_NAME} -c ./custom.yaml check
  ${SCRIPT_NAME} --debug clean

备注：
  1. 本脚本需要 root 权限执行部分命令。
  2. 配置文件需符合 YAML 格式规范。
  3. 遇到问题请联系：${AUTHOR}

EOF
}

# ------------------------------------------------------------------------------
# 3. 版本信息函数
# ------------------------------------------------------------------------------
show_version() {
    echo "${SCRIPT_NAME} version ${VERSION}"
}

# ------------------------------------------------------------------------------
# 4. 错误处理函数
# ------------------------------------------------------------------------------
# 参数：$1 错误消息
log_error() {
    # 将错误信息输出到 stderr (标准错误流)，符合 Linux 规范
    echo "[ERROR] ${SCRIPT_NAME}: $1" >&2
}

# 参数：$1 错误消息，$2 退出码
die() {
    log_error "$1"
    exit "${2:-$EXIT_FAILURE}"
}

# ------------------------------------------------------------------------------
# 5. 主逻辑入口
# ------------------------------------------------------------------------------
main() {
    # 初始化默认变量
    local config_file="/etc/deploy/config.yaml"
    local environment="dev"
    local debug_mode=false
    local quiet_mode=false
    local command=""

    # ------------------------------------------------------------------------------
    # 参数解析循环 (核心逻辑)
    # ------------------------------------------------------------------------------
    # 使用 while 循环配合 shift 手动解析，比 getopts 更灵活，支持长选项 (--help)
    while [[ $# -gt 0 ]]; do
        case "$1" in
            # 短选项 -h 和 长选项 --help
            -h|--help)
                show_help
                exit $EXIT_SUCCESS
                ;;
            # 短选项 -v 和 长选项 --version
            -v|--version)
                show_version
                exit $EXIT_SUCCESS
                ;;
            # 带参数的选项 -c/--config
            -c|--config)
                # 检查是否提供了参数值
                if [[ -n "${2:-}" ]]; then
                    config_file="$2"
                    shift 2 # 消耗掉选项名和参数值
                else
                    die "选项 '$1' 需要指定配置文件路径" $EXIT_INVALID_ARGS
                fi
                ;;
            # 带参数的选项 -e/--env
            -e|--env)
                if [[ -n "${2:-}" ]]; then
                    environment="$2"
                    shift 2
                else
                    die "选项 '$1' 需要指定环境名称 (dev/test/prod)" $EXIT_INVALID_ARGS
                fi
                ;;
            # 开关型选项 -d/--debug
            -d|--debug)
                debug_mode=true
                shift
                ;;
            # 开关型选项 -q/--quiet
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            # 捕获未知选项
            -*)
                die "未知选项：'$1'。请使用 '--help' 查看用法" $EXIT_INVALID_ARGS
                ;;
            # 非选项参数 (通常作为子命令，如 check, restart)
            *)
                if [[ -z "$command" ]]; then
                    command="$1"
                else
                    # 如果已经有一个命令了，又出现了非选项参数，视为多余参数
                    die "未知参数：'$1'。每个脚本只接受一个主命令" $EXIT_INVALID_ARGS
                fi
                shift
                ;;
        esac
    done

    # ------------------------------------------------------------------------------
    # 业务逻辑验证
    # ------------------------------------------------------------------------------
    # 如果没有提供命令，则显示帮助（类似 git 或 apt 的行为）
    if [[ -z "$command" ]]; then
        log_error "未指定命令。"
        echo "请使用 '${SCRIPT_NAME} --help' 查看可用命令。" >&2
        exit $EXIT_INVALID_ARGS
    fi

    # 模拟执行逻辑 (实际场景中这里会调用具体函数)
    if [[ "$debug_mode" == true ]]; then
        echo "[DEBUG] 配置文件的：${config_file}"
        echo "[DEBUG] 当前环境：${environment}"
        echo "[DEBUG] 执行命令：${command}"
    fi

    # 模拟命令执行反馈
    case "$command" in
        check|restart|clean)
            if [[ "$quiet_mode" == false ]]; then
                echo "正在执行 '${command}' 操作 (环境：${environment})..."
            fi
            # 这里添加实际业务逻辑
            exit $EXIT_SUCCESS
            ;;
        *)
            die "未知命令：'$command'。可用命令：check, restart, clean" $EXIT_INVALID_ARGS
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 6. 脚本执行入口
# ------------------------------------------------------------------------------
# 确保脚本被直接执行而不是被 source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 💡 关键设计点解析 (结合你的开发背景)

1.  **参数解析策略 (`while` + `case`)**：
    *   虽然 `getopts` 是 Shell 内置的，但它**不支持长选项**（如 `--help`）。
    *   为了达到 `apt` 那种现代 CLI 工具的体验，我们使用 `while [[ $# -gt 0 ]]` 循环配合 `case` 语句手动解析。
    *   **`shift` 的用法**：这是关键。处理完一个参数后，必须用 `shift` 将其从参数列表中移除，否则会导致死循环。带值的选项（如 `-c`）需要 `shift 2`。

2.  **帮助信息的设计 (`show_help`)**：
    *   **结构化**：分为用法、描述、选项、命令、示例。这符合 POSIX 标准及 GNU 规范。
    *   **动态变量**：使用 `${SCRIPT_NAME}` 而不是写死脚本名，这样即使你重命名脚本，帮助信息依然准确。
    *   **退出码**：显示帮助后使用 `exit 0`，表示成功退出；错误时使用非零值，方便其他脚本调用判断。

3.  **健壮性设置 (`set -euo pipefail`)**：
    *   你在 Java 开发中关注**单元测试**和**稳定性**，Shell 脚本亦然。
    *   这三行代码能防止脚本在遇到错误时“静默失败”或继续执行危险操作，非常适合生产环境（如你的核保系统部署脚本）。

4.  **错误输出流 (`>&2`)**：
    *   注意 `log_error` 函数中使用了 `>&2`。这是将错误信息发送到**标准错误流**，而不是标准输出。
    *   这样做的好处是：当你把脚本输出重定向到文件时（`./script.sh > log.txt`），错误信息依然会显示在屏幕上，不会被掩盖。

5.  **入口检查 (`BASH_SOURCE`)**：
    *   最后一行判断确保脚本既可以被直接执行，也可以被 `source` 到其他脚本中作为函数库使用，增加了复用性。

### 🚀 如何测试这个脚本

1.  **保存文件**：将上述代码保存为 `deploy-tool.sh`。
2.  **赋予权限**：
    ```bash
    chmod +x deploy-tool.sh
    ```
3.  **测试帮助功能**：
    ```bash
    ./deploy-tool.sh --help
    # 或者
    ./deploy-tool.sh -h
    ```
4.  **测试错误处理**：
    ```bash
    ./deploy-tool.sh --unknown-option
    # 应该看到友好的错误提示并退出
    ```
5.  **测试业务逻辑**：
    ```bash
    ./deploy-tool.sh -e prod --debug restart
    ```

这个模板可以直接应用到你日常编写的 **数据库迁移脚本**、**日志清理脚本** 或 **服务健康检查脚本** 中。如果你需要针对特定业务场景（比如结合 PostgreSQL 备份或 Docker 容器管理）进行修改，随时告诉我！
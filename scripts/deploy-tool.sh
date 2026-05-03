#!/usr/bin/env bash
# ==============================================================================
# 脚本名称：deploy-tool.sh
# 功能描述：模拟企业级部署工具，展示标准的帮助信息设计与参数解析最佳实践
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x deploy-tool.sh && ./deploy-tool.sh --help
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

项目主页: https://example.com
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

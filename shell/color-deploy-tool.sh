#!/usr/bin/env bash
# ==============================================================================
# 脚本名称：color-deploy-tool.sh
# 功能描述：集成智能颜色输出的企业级部署工具示例
# 适用系统：Ubuntu / Debian 系列 (bash)
# 作者：龙茶清欢 (基于用户背景定制)
# 使用方法：chmod +x color-deploy-tool.sh && ./color-deploy-tool.sh --help
# 注意事项：自动检测终端环境，重定向日志时自动禁用颜色
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 安全与规范设置 (Best Practices)
# ------------------------------------------------------------------------------
# set -e: 遇到错误立即退出，防止错误级联
# set -u: 使用未定义变量时报错，避免隐式空值
# set -o pipefail: 管道中任一命令失败则整个管道失败
set -euo pipefail

# 脚本元数据
readonly SCRIPT_NAME=$(basename "$0")
readonly VERSION="1.0.0"
readonly AUTHOR="DevOps Team"

# 退出状态码
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2

# ------------------------------------------------------------------------------
# 2. 颜色定义与智能检测 (核心新增部分)
# ------------------------------------------------------------------------------
# 定义 ANSI 颜色代码
# \033 是 ESC 字符的八进制表示，[0m 表示重置所有属性
readonly COLOR_RESET="\033[0m"
readonly COLOR_RED="\033[31m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_YELLOW="\033[33m"
readonly COLOR_BLUE="\033[34m"
readonly COLOR_CYAN="\033[36m"
readonly COLOR_BOLD="\033[1m"

# 初始化颜色变量（默认启用）
COLOR_ENABLED=true

# 函数：检测是否支持颜色输出
# 原理：检查标准输出 (stdout) 是否连接到终端 (tty)
# 如果脚本被重定向到文件 (如 ./script.sh > log.txt)，则禁用颜色，防止日志文件出现乱码
check_color_support() {
    if [[ ! -t 1 ]]; then
        COLOR_ENABLED=false
    fi
    # 额外检查：如果环境变量 NO_COLOR 被设置，也禁用颜色 (符合 freedesktop.org 标准)
    if [[ -n "${NO_COLOR:-}" ]]; then
        COLOR_ENABLED=false
    fi
}

# 函数：获取颜色代码
# 参数：$1 颜色名称 (RED, GREEN, etc.)
# 返回：如果启用颜色则返回代码，否则返回空字符串
get_color() {
    if [[ "$COLOR_ENABLED" == true ]]; then
        case "$1" in
            RED)     echo -e "$COLOR_RED" ;;
            GREEN)   echo -e "$COLOR_GREEN" ;;
            YELLOW)  echo -e "$COLOR_YELLOW" ;;
            BLUE)    echo -e "$COLOR_BLUE" ;;
            CYAN)    echo -e "$COLOR_CYAN" ;;
            BOLD)    echo -e "$COLOR_BOLD" ;;
            RESET)   echo -e "$COLOR_RESET" ;;
            *)       echo -e "$COLOR_RESET" ;;
        esac
    else
        echo ""
    fi
}

# ------------------------------------------------------------------------------
# 3. 标准化日志函数 (封装颜色逻辑)
# ------------------------------------------------------------------------------
# 所有日志统一通过这些函数输出，便于后续修改格式或级别控制

# 普通信息 (白色/默认)
log_info() {
    local msg="$*"
    local c_bold=$(get_color "BOLD")
    local c_reset=$(get_color "RESET")
    # 使用 printf 避免 echo 对特殊字符的潜在解释问题
    printf "%s[INFO]%s %s\n" "$c_bold" "$c_reset" "$msg"
}

# 成功信息 (绿色)
log_success() {
    local msg="$*"
    local c_green=$(get_color "GREEN")
    local c_bold=$(get_color "BOLD")
    local c_reset=$(get_color "RESET")
    printf "%s[SUCCESS]%s %s\n" "${c_bold}${c_green}" "$c_reset" "$msg"
}

# 警告信息 (黄色)
log_warn() {
    local msg="$*"
    local c_yellow=$(get_color "YELLOW")
    local c_bold=$(get_color "BOLD")
    local c_reset=$(get_color "RESET")
    # 警告信息输出到 stderr
    printf "%s[WARN]%s %s\n" "${c_bold}${c_yellow}" "$c_reset" "$msg" >&2
}

# 错误信息 (红色)
log_error() {
    local msg="$*"
    local c_red=$(get_color "RED")
    local c_bold=$(get_color "BOLD")
    local c_reset=$(get_color "RESET")
    # 错误信息必须输出到 stderr
    printf "%s[ERROR]%s %s\n" "${c_bold}${c_red}" "$c_reset" "$msg" >&2
}

# 调试信息 (青色)
log_debug() {
    # 只有在全局 debug 模式开启时才输出
    if [[ "${DEBUG_MODE:-false}" == true ]]; then
        local msg="$*"
        local c_cyan=$(get_color "CYAN")
        local c_bold=$(get_color "BOLD")
        local c_reset=$(get_color "RESET")
        printf "%s[DEBUG]%s %s\n" "${c_bold}${c_cyan}" "$c_reset" "$msg"
    fi
}

# ------------------------------------------------------------------------------
# 4. 帮助与版本信息
# ------------------------------------------------------------------------------
show_help() {
    # 帮助信息中适度使用颜色，突出关键选项
    local c_bold=$(get_color "BOLD")
    local c_cyan=$(get_color "CYAN")
    local c_yellow=$(get_color "YELLOW")
    local c_reset=$(get_color "RESET")

    cat << EOF
用法：${c_bold}${SCRIPT_NAME}${c_reset} [选项] <命令> [参数...]

描述：
  企业级应用部署与维护辅助工具。
  用于自动化执行环境检查、服务重启及日志清理等操作。

选项：
  ${c_yellow}-h, --help${c_reset}             显示此帮助信息并退出
  ${c_yellow}-v, --version${c_reset}          显示版本号并退出
  ${c_yellow}-c, --config${c_reset} <FILE>    指定配置文件路径 (默认：/etc/deploy/config.yaml)
  ${c_yellow}-e, --env${c_reset} <ENV>        指定运行环境 (可选：dev, test, prod)
  ${c_yellow}-d, --debug${c_reset}            开启调试模式，输出详细日志
  ${c_yellow}-q, --quiet${c_reset}            静默模式，仅输出错误信息

命令：
  ${c_cyan}check${c_reset}                  检查系统依赖与环境状态
  ${c_cyan}restart${c_reset}                重启目标服务
  ${c_cyan}clean${c_reset}                  清理旧版本构建产物

示例：
  ${SCRIPT_NAME} --help
  ${SCRIPT_NAME} -e prod restart
  ${SCRIPT_NAME} --debug clean

EOF
}

show_version() {
    local c_bold=$(get_color "BOLD")
    local c_green=$(get_color "GREEN")
    local c_reset=$(get_color "RESET")
    echo -e "${c_bold}${SCRIPT_NAME}${c_reset} version ${c_green}${VERSION}${c_reset}"
}

# ------------------------------------------------------------------------------
# 5. 主逻辑入口
# ------------------------------------------------------------------------------
main() {
    # 初始化颜色支持检测
    check_color_support

    # 初始化默认变量
    local config_file="/etc/deploy/config.yaml"
    local environment="dev"
    local quiet_mode=false
    local command=""
    
    # 导出 DEBUG_MODE 供 log_debug 使用
    export DEBUG_MODE=false

    # 参数解析循环
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit $EXIT_SUCCESS
                ;;
            -v|--version)
                show_version
                exit $EXIT_SUCCESS
                ;;
            -c|--config)
                if [[ -n "${2:-}" ]]; then
                    config_file="$2"
                    shift 2
                else
                    log_error "选项 '$1' 需要指定配置文件路径"
                    exit $EXIT_INVALID_ARGS
                fi
                ;;
            -e|--env)
                if [[ -n "${2:-}" ]]; then
                    environment="$2"
                    shift 2
                else
                    log_error "选项 '$1' 需要指定环境名称 (dev/test/prod)"
                    exit $EXIT_INVALID_ARGS
                fi
                ;;
            -d|--debug)
                DEBUG_MODE=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            -*)
                log_error "未知选项：'$1'。请使用 '--help' 查看用法"
                exit $EXIT_INVALID_ARGS
                ;;
            *)
                if [[ -z "$command" ]]; then
                    command="$1"
                else
                    log_error "未知参数：'$1'。每个脚本只接受一个主命令"
                    exit $EXIT_INVALID_ARGS
                fi
                shift
                ;;
        esac
    done

    # 业务逻辑验证
    if [[ -z "$command" ]]; then
        log_error "未指定命令。"
        echo "请使用 '${SCRIPT_NAME} --help' 查看可用命令。" >&2
        exit $EXIT_INVALID_ARGS
    fi

    # 调试信息演示
    log_debug "配置文件：${config_file}"
    log_debug "当前环境：${environment}"
    log_debug "执行命令：${command}"

    # 模拟命令执行反馈
    case "$command" in
        check|restart|clean)
            if [[ "$quiet_mode" == false ]]; then
                log_info "正在执行 '${command}' 操作 (环境：${environment})..."
                # 模拟耗时操作
                sleep 0.5 
                log_success "命令 '${command}' 执行成功。"
            fi
            exit $EXIT_SUCCESS
            ;;
        *)
            log_error "未知命令：'$command'。可用命令：check, restart, clean"
            exit $EXIT_INVALID_ARGS
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 6. 脚本执行入口
# ------------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

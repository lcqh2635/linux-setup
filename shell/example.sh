#!/bin/bash

# 脚本名称: example.sh
# 功能：自动安装并配置常用主题、图标、光标和扩展
# 使用方法：chmod +x example.sh && ./example.sh --help

VERSION="1.0"

show_help() {
    cat << EOF
${0##*/} - 一个示例脚本，展示帮助功能

用法: ${0##*/} [选项]... [文件]...

选项:
  -h, --help        显示此帮助信息
  -v, --version     显示版本信息
  -f, --file FILE   指定输入文件（可重复）
  -o, --output DIR  指定输出目录（默认: ./output）

示例:
  ${0##*/} -f data.txt -o /tmp
  ${0##*/} --help

项目主页: https://example.com
EOF
}

show_version() {
    echo "${0##*/} 版本 $VERSION"
}

# 解析选项
OPTIONS=hvf:o:
LONGOPTS=help,version,file:,output:
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    exit 2
fi
eval set -- "$PARSED"

# 默认值
output_dir="./output"
files=()

while true; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -f|--file)
            files+=("$2")
            shift 2
            ;;
        -o|--output)
            output_dir="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "内部错误" >&2
            exit 3
            ;;
    esac
done

# 处理剩余的位置参数（也可作为文件）
for arg in "$@"; do
    files+=("$arg")
done

# 脚本主要逻辑
echo "输出目录: $output_dir"
echo "文件列表: ${files[@]}"

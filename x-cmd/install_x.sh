#!/bin/sh
# 安装单个包的函数
install_package() {
    echo "📦 正在安装: $1"
    if x env use "$1" 2>/dev/null; then
        echo "✅ 成功安装: $1"
    else
        echo "❌ 安装失败: $1"
        return 1
    fi
}

# 从文件读取并安装包的函数
install_from_file() {
    while read -r package || [ -n "$package" ]; do
        # 跳过空行和注释
        case "$package" in
            ""|\#*) continue ;;
            *) install_package "$package" || : ;;  # : 是 shell 的空操作符
        esac
    done < "$1"
}




SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 安装通用应用
# Download the x-cmd installer to a temp file first instead of `eval "$(curl ...)"`.
# Reasoning:
#   - `-fsSL` makes curl FAIL on HTTP errors (4xx/5xx). With the old `curl URL`
#     pattern, an HTML error page would get eval'd as shell — best case nothing
#     happens, worst case Bad Things.
#   - `--max-time 60` prevents hanging forever if the host is unreachable
#     (common behind restrictive corp/cluster proxies).
#   - Downloading to a file before running lets us check curl's exit code
#     explicitly (it's lost when piped into eval).
echo "安装x-cmd ..."
__x_tmp="$(mktemp -t x-cmd-install.XXXXXX)"
trap 'rm -f "$__x_tmp"' EXIT
if ! curl -fsSL --max-time 60 https://get.x-cmd.com -o "$__x_tmp"; then
    echo "⚠️  Failed to download x-cmd installer (network / proxy / rate limit?). Skipping x-cmd setup." >&2
    exit 0
fi
if ! sh "$__x_tmp"; then
    echo "⚠️  x-cmd installer reported failure. Skipping packages install." >&2
    exit 0
fi
echo "🎉 x-cmd安装完成"

# x-cmd's installer typically appends shell hooks to your rc files; in THIS
# shell we still need to source it to get the `x` command available for
# install_from_file below.
if [ -f "$HOME/.x-cmd.root/X" ]; then
    . "$HOME/.x-cmd.root/X"
fi

echo "🐧 是用x-cmd安装packages ..."
install_from_file "$SCRIPT_DIR/apps.txt"

echo "🎉 安装完成！"
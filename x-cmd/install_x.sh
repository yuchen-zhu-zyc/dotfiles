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
echo "安装x-cmd ..."
eval "$(curl https://get.x-cmd.com)"
echo "🎉 x-cmd安装完成"

echo "🐧 是用x-cmd安装packages ..."
install_from_file "$SCRIPT_DIR/apps.txt"

echo "🎉 安装完成！"
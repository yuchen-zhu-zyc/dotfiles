#!/bin/sh

# 检查是否为 ARM Linux
if uname -a | grep -q "Linux" && uname -m | grep -q "aarch64"; then
    echo "⚠️ ARM Linux 暂不支持 Homebrew，退出安装..."
    exit 0
fi

# ---- Privilege detection (Linux only; macOS uses brew which doesn't need root) ----
# On Linux we need to write to /etc/apt/{keyrings,sources.list.d}/ and run
# `apt install`. Both require root. If we have neither root nor passwordless
# sudo, exit early instead of producing a wall of "Permission denied" while
# pretending to succeed (the previous behavior silently did nothing on every
# step but printed "✅").
SUDO=""
if [ "$(uname)" = "Linux" ]; then
    if [ "$(id -u)" = "0" ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        SUDO="sudo"
    else
        cat <<'EOF' >&2
⏭️  Skipping brew/install_app.sh:
    This script needs root (or passwordless sudo) to write to /etc/apt/* and
    run `apt install`. Not available on this host — re-run on a machine where
    you have admin access if you want the eza / rust-tools apt repos and the
    packages from brew-linux.txt installed.
EOF
        exit 0
    fi
fi

# Update apt source
if [ "$(uname)" = "Linux" ]; then
    $SUDO apt install -y gpg wget
    $SUDO mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list
    $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    curl -fsSL https://apt.cli.rs/pubkey.asc | $SUDO tee -a /usr/share/keyrings/rust-tools.asc
    curl -fsSL https://apt.cli.rs/rust-tools.list | $SUDO tee /etc/apt/sources.list.d/rust-tools.list
    $SUDO apt update
fi



# 安装单个包的函数
install_package() {
    echo "📦 正在安装: $1"
    if [ "$(uname)" = "Linux" ]; then
        if $SUDO apt install -y "$1" 2>/dev/null; then
            echo "✅ 成功安装: $1"
        else
            echo "❌ 安装失败: $1"
            return 1
        fi
    else
        if brew install -y "$1" 2>/dev/null; then
            echo "✅ 成功安装: $1"
        else
            echo "❌ 安装失败: $1"
            return 1
        fi
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

# 根据系统添加 Homebrew 路径
if uname -a | grep -q "Darwin"; then
    # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "🍏 brew 安装 mac apps..."
    install_from_file "$SCRIPT_DIR/brew-mac.txt"
else
    # Linux (x86_64)
    # eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "🐧 apt 安装 linux apps..."
    install_from_file "$SCRIPT_DIR/brew-linux.txt"
fi

# 安装通用应用
# echo "🍺 brew 安装通用 apps..."
# install_from_file "$SCRIPT_DIR/brew-both.txt"

echo "🎉 安装完成！"
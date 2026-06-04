#!/bin/sh

echo "🔄 安装 zsh 插件..."

mkdir -p ~/.zsh/plugins/

clone_if_missing() {
    dest="$1"
    shift
    if [ -e "$dest" ]; then
        echo "⏭️  $dest already exists, skipping."
    else
        git clone "$@" "$dest"
    fi
}

clone_if_missing ~/.zsh/plugins/oh-my-zsh                       --depth=1 https://github.com/ohmyzsh/ohmyzsh.git
clone_if_missing ~/.zsh/plugins/powerlevel10k                   --depth=1 https://github.com/romkatv/powerlevel10k.git
clone_if_missing ~/.zsh/plugins/zsh-completions                 --depth=1 https://github.com/zsh-users/zsh-completions.git
clone_if_missing ~/.zsh/plugins/zsh-autosuggestions             --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git
# clone_if_missing ~/.zsh/plugins/zsh-autocomplete             --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git
clone_if_missing ~/.zsh/plugins/zsh-syntax-highlighting         --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git
# clone_if_missing ~/.zsh/plugins/fzf-git.sh                   --depth=1 https://github.com/junegunn/fzf-git.sh.git
clone_if_missing ~/.zsh/plugins/zsh-history-substring-search    --depth=1 https://github.com/zsh-users/zsh-history-substring-search.git

echo "✅ zsh 插件安装完成"

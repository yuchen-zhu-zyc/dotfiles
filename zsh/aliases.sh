alias echopath='echo $PATH | tr ":" "\n"'
alias grep='grep --color'



# zsh
alias re='exec zsh'
alias szsh='source ~/.zshrc'
alias e=exit

# ---- Eza (better ls) -----
alias ls="eza"
alias ll='eza \
  --header \
  --long \
  --all \
  --binary \
  --group \
  --icons=always \
  --git'

alias lls='eza \
  --header \
  --long \
  --all \
  --binary \
  --group \
  --icons=always \
  --total-size \
  --git'

# 利用 eza 定义一个 tree 命令
# 不带任何数字, `tree` 默认展开 2 层
# 可以自己加数字表示展开层级, `tree 1/3/...`
tree() {
  depth=2
  if [ $# -gt 0 ]; then
    case "$1" in
    *[!0-9]*)
      echo "Invalid argument: '$1'. Please provide a numeric depth value." >&2
      return 1
      ;;
    *)
      depth="$1"
      ;;
    esac
  fi
  lls -T -L="$depth"
}

# ---- Zxoide (better cd) -----
alias cd="z"
alias cdi="zi"
# ---- yazi ----
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down
[[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
[[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ZSH_THEME="powerlevel10k/powerlevel10k"
source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme

# ---- zsh-autosuggestions ----
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---- zsh-completions ----
fpath=(~/.zsh/plugins/zsh-completions/src $fpath)

# ---- zsh-syntax-highlighting ----
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# ---- zsh-autocomplete ----
# 必须将 autocomplete 放在 syntax-highlighting 下才能让新建 zsh 不再出现样式警告
# 参考: https://github.com/zsh-users/zsh-syntax-highlighting/issues/951#issuecomment-2089829937
# 按下 下方向键 展示所有可选
# cd 的自动补全效果一般，按下 tab 就把第一个补上了... 因此更推荐使用 z 直接跳转 或 yazi
# https://www.notion.so/zsh-53922bbbd4f74a8f961a3010f541845a?pvs=4#8723929e12c1463998b9dded920ab0b1
# source ~/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# ---- oh-my-zsh ----
ZSH_DISABLE_COMPFIX=true
source ~/.zsh/plugins/oh-my-zsh/oh-my-zsh.sh

# Override oh-my-zsh's `env_default 'LESS' '-R'` (lib/misc.zsh): without -F,
# git's pager (less) does NOT auto-quit on short output, so even `git branch`
# with two lines drops you into an interactive less prompt that shows `(END)`
# and requires `q` to exit. -FRX is exactly what git sets when LESS is unset;
# we recreate it here since oh-my-zsh has stolen that slot.
#   F = quit if output fits on one screen
#   R = pass ANSI color escapes through raw
#   X = don't send terminal init/deinit (keep output visible after exit)
export LESS='-FRX'

# ---- Inherit non-exportable init from ~/.bashrc ----
# When ~/.bashrc auto-launches us via `exec zsh`, every `export`-ed variable
# is already inherited (cluster vars, GITLAB_TOKEN, NVM_DIR, etc.). But two
# kinds of state do NOT survive the exec:
#   1. aliases  — replay every `alias ...` line from ~/.bashrc
#   2. shell functions like `nvm` — re-source nvm.sh if NVM_DIR is set
# Done before sourcing ~/.zsh/aliases.sh so dotfiles aliases (eza, zoxide,
# ...) take precedence over the bash defaults.
if [ -f "$HOME/.bashrc" ]; then
    eval "$(grep -E '^[[:space:]]*alias[[:space:]]+' "$HOME/.bashrc" 2>/dev/null)" 2>/dev/null
fi
if [ -n "${NVM_DIR:-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

# ---- User activation ----
source ~/.zsh/aliases.sh


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git cp)



# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh


#alias bathelp='bat --plain --language=help'
#help() {
#    "$@" --help 2>&1 | bathelp
#}
#alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
#alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# ---- fzf ----
# source ~/.dotfiles/zsh/fzf.zshrc


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# 自动探测常见的 conda 安装位置（anaconda / miniconda / miniforge），没装就跳过。
# 若你把 conda 装在了别处，把下面这一行的路径列表改成你的安装目录即可。
__conda_root=""
for __d in "$HOME/anaconda3" "$HOME/miniconda3" "$HOME/miniforge3" "/opt/homebrew/anaconda3" "/opt/homebrew/Caskroom/miniconda/base"; do
    [ -x "$__d/bin/conda" ] && { __conda_root="$__d"; break; }
done
if [ -n "$__conda_root" ]; then
    __conda_setup="$("$__conda_root/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "$__conda_root/etc/profile.d/conda.sh" ]; then
        . "$__conda_root/etc/profile.d/conda.sh"
    else
        export PATH="$__conda_root/bin:$PATH"
    fi
    unset __conda_setup
fi
unset __conda_root __d
# <<< conda initialize <<<


# Source machine-local overrides if present (not tracked in this dotfiles repo).
# Use this for per-host env vars / aliases / NVM init / etc.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"


# ---- zoxide ----
# zoxide registers chpwd / precmd hooks and warns at runtime if anything
# else in zshrc rewires those hook arrays after it. Keep this dead last so
# nothing (conda, ~/.zshrc.local, future additions) sneaks in afterwards.
eval "$(zoxide init zsh)"

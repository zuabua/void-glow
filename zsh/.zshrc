if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# CachyOS tuning (optional)
# source /usr/share/cachyos-zsh-config/cachyos-config.zsh


# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Tint
ZSH_AUTOSUGGEST_HIGHLIGT_STYULE="fg=#64748b"

# Powerlevel10k
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


# Void glow palette

# DIR
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#818cf8'
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#64748b'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGORUND='#5eead4'
typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND='#f87171'
typeset -g POWERLEVEL9K_DIR_NON_EXISTENT_FOREGROUND='#f87171'

# VCS
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#5eead4'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#5eead4'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#818cf8'

# Status
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='#5eead4'
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND='#5eead4'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#f87171'
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#f87171'
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND='#f87171'
p10k reload 2>/dev/null

# Syntax Highlighting

typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#e2e8f0'                 # VOID_TEXT
ZSH_HIGHLIGHT_STYLES[command]='fg=#5eead4'                 # VOID_ACCENT_TEAL — valid cmd
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#5eead4'                 # VOID_ACCENT_TEAL
ZSH_HIGHLIGHT_STYLES[function]='fg=#5eead4'                # VOID_ACCENT_TEAL
ZSH_HIGHLIGHT_STYLES[alias]='fg=#5eead4'                   # VOID_ACCENT_TEAL
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f87171'           # VOID_RED — invalid
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#818cf8'           # VOID_ACCENT_INDIGO — if/for/while
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#818cf8'  # VOID_ACCENT_INDIGO — strings
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#818cf8'  # VOID_ACCENT_INDIGO — strings
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#5eead4'    # VOID_ACCENT_TEAL
ZSH_HIGHLIGHT_STYLES[path]='fg=#e2e8f0,underline'          # VOID_TEXT, underlined
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#64748b'    # VOID_SUBTEXT — flags recede
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#64748b'    # VOID_SUBTEXT
ZSH_HIGHLIGHT_STYLES[comment]='fg=#64748b'                 # VOID_SUBTEXT — muted

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

#Set Zinit and plugin directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
#Download zinit if needed
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

#Source the zinit file
source "${ZINIT_HOME}/zinit.zsh"

#Plugins
source $ZDOTDIR/conf.d/plugins

#Load Completions
autoload -U compinit && compinit
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#Keybindings
source $ZDOTDIR/conf.d/keybinds

#History
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt inc_append_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#Completion Styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#Aliases
source $ZDOTDIR/conf.d/aliases

#Environment Variables
source $ZDOTDIR/conf.d/variables

#Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/simon/.dart-cli-completion/zsh-config.zsh ]] && . /home/simon/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

#Starship promt
eval "$(starship init zsh)"

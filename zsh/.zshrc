# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Anything that prints to the terminal must go below this block.
if [[ -r ~/.p10k.zsh ]]; then
  source ~/.p10k.zsh
fi

#######################################################
#######################################################
#aliases:
alias windows="sudo efibootmgr -n 0000 && sudo reboot"
alias shutdown="shutdown now"
alias sleep="systemctl sleep"
alias vim="nvim"
alias la="ls -a"
alias lock='hyprctl dispatch exit'
alias bios='sudo -v && sudo systemctl reboot --firmware-setup'
alias cd="z"
alias l="ls -l"
unalias please 2>/dev/null

please() {
  sudo -- sh -c "$(fc -ln -1)"
}
# Load zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Powerlevel10k theme
zinit light romkatv/powerlevel10k

# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions
zinit light zsh-users/zsh-autosuggestions

# Optional: enable autosuggestions immediately (makes suggestions appear faster)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:~/go/bin
export PATH=$HOME/.npm-global/bin:$PATH

source /usr/share/nvm/init-nvm.sh

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/.local/opt/go/bin

eval "$(zoxide init zsh)"

# Vim line editing
bindkey -v
export KEYTIMEOUT=1

function zle-keymap-select zle-line-init {
  case $KEYMAP in
    vicmd)      printf '\e[2 q' ;;
    main|viins) printf '\e[6 q' ;;
  esac
}
zle -N zle-keymap-select
zle -N zle-line-init

# Browser / clipboard helpers (zen, clip)
source "$HOME/dotfiles/zsh/tools.zsh"

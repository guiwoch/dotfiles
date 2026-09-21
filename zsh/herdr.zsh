# Pane navigation at the zsh prompt: C-h/j/k/l, the same keys nvim uses for its
# splits (see nvim/lua/plugins/herdr.lua).
#
# Herdr's own key map is unconditional - a chord bound in [keys] never reaches
# the pane - so ctrl+h/j/k/l is deliberately NOT bound there, and the innermost
# program that understands the key does the moving instead: nvim walks its
# splits and calls Herdr at its edge (smart-splits' herdr backend), and here zsh
# calls the same CLI. This is the `is_vim` test the old tmux.conf did, moved
# into the shell because Herdr has no equivalent. A TUI that knows neither -
# lazygit, yazi, claude - is left with prefix+h/j/k/l: Herdr also binds
# ctrl+alt+h/j/k/l, but Hyprland takes that chord first for swapwindow, so it
# never arrives (see herdr/.config/herdr/config.toml).
#
# Fallout: C-l no longer clears the screen, and C-j is no longer an accept-line
# alias (Return still is). C-o is free in zsh's vi keymaps and, unlike C-S-l,
# survives ZLE's raw-byte reading, so it takes over the clear. Backspace is
# unaffected: ghostty sends ^? for it, and only the literal C-h byte is rebound.
[[ -n "$HERDR_ENV" ]] || return 0

_herdr_focus() {
  ${HERDR_BIN_PATH:-herdr} pane focus --direction "$1" --current >/dev/null 2>&1
}

herdr-focus-left()  { _herdr_focus left  }
herdr-focus-down()  { _herdr_focus down  }
herdr-focus-up()    { _herdr_focus up    }
herdr-focus-right() { _herdr_focus right }

zle -N herdr-focus-left
zle -N herdr-focus-down
zle -N herdr-focus-up
zle -N herdr-focus-right

for keymap in viins vicmd; do
  bindkey -M $keymap '^H' herdr-focus-left
  bindkey -M $keymap '^J' herdr-focus-down
  bindkey -M $keymap '^K' herdr-focus-up
  bindkey -M $keymap '^L' herdr-focus-right
  bindkey -M $keymap '^O' clear-screen
done
unset keymap

# herdr-automatic-rename: renames tabs the moment a command starts.
for _f in ${HOME}/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source $_f; break
done

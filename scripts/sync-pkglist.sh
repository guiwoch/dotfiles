#!/usr/bin/env bash
set -euo pipefail

pacman -Qqe | sort > ~/dotfiles/pkglist-repo.txt
yay -Qqm | sort > ~/dotfiles/pkglist-aur.txt


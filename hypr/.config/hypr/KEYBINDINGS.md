# Keybindings & workflows

Source of truth: `~/.config/hypr/hyprland.conf`. Mod key is **ALT** (`$mainMod`).
Scripts live in `~/.config/hypr/scripts/`.

## Apps

| Keys | Action |
|---|---|
| ALT+Q | Terminal (ghostty + tmux) |
| ALT+E | File manager (nautilus, new window) |
| ALT+R | App launcher (fuzzel) |
| ALT+V | Clipboard history (clipse, floating) |
| ALT+SHIFT+V | Clipboard history, cliphist + fzf picker (trial) |
| ALT+S | Scratch pad: new draft (`scratch`), or show/hide the running pad |
| ALT+SHIFT+S | Scratch pad: note picker (`note`), or show/hide the running pad |
| ALT+G | Screenshot region → clipboard + `~/Pictures/Screenshots/` |
| ALT+SHIFT+G | Flameshot full editor (annotate before saving) |

## Windows

| Keys | Action |
|---|---|
| ALT+H/J/K/L | Focus left/down/up/right |
| ALT+SHIFT+H/J/K/L | **Move** window: joins a group in that direction, leaves the current group in that direction, otherwise moves the window |
| ALT+CTRL+H/J/K/L | **Swap** with the neighbour (never touches groups) |
| ALT+SHIFT+; | Toggle split: side-by-side ↔ stacked (focused window + its sibling) |
| ALT+C | Close window |

## Groups (tabbed windows)

| Keys | Action |
|---|---|
| ALT+U | Make the focused window a group / dissolve its group |
| ALT+SHIFT+H/J/K/L | Join the neighbouring group, or leave the current one (see above) |
| ALT+SHIFT+U | Pull the focused tab out of its group |
| ALT+M / ALT+, | Previous / next tab |
| ALT+CTRL+1…5 | Jump to tab 1–5 |
| ALT+I | Lock/unlock the group (nothing can join or leave) |
| ALT+SHIFT+I | Groupbar: thin strip ↔ full tabs with titles (reloads Hyprland; the choice survives reloads) |

## Workspaces

| Keys | Action |
|---|---|
| ALT+1…0 | Go to workspace 1–10 |
| ALT+SHIFT+1…0 | Send window to workspace 1–10 (you stay put) |
| ALT+scroll | Previous / next workspace |

## System

| Keys | Action |
|---|---|
| ALT+Space | Keyboard layout: US ↔ US International (PT) |
| ALT+; | Cycle audio output (moves playing streams too) |
| ALT+N | Night light on/off (hyprsunset, 4000K) |
| ALT+T | Resolution: 2560x1080 ↔ 1920x1080 (rewrites the config + reloads) |
| ALT+Esc | Passthrough on/off: every host bind is disabled so keys reach the focused window (e.g. the Omarchy VM). Press again to come back |

## Media & hardware keys

| Keys | Action |
|---|---|
| Volume up/down/mute | wpctl, 5% steps (max 100%) |
| Mic mute | Toggle default mic |
| Brightness up/down | Monitor backlight over DDC/CI (5% steps) |
| SHIFT+Brightness up/down | Night light cooler/warmer (250K steps, 2500–6500K); "warmer" while off turns it on. Sent from the Corne's layer 1 |
| Play/Pause, Next, Prev | playerctl |

---

## Workflows

### Tab two windows together
1. Focus window A, **ALT+U** → A is now a one-tab group.
2. Focus window B (next to it), **ALT+SHIFT+direction toward A** → B becomes a tab.
3. Flip with **ALT+M / ALT+,**. The 4px strip above the group has one segment
   per tab; **ALT+SHIFT+I** shows titles when you need to find one.

### Get a tab back out
- Focused on the tab: **ALT+SHIFT+direction** → it leaves the group on that side.
- Or **ALT+SHIFT+U** to pop it out wherever Hyprland puts it.
- **ALT+U** dissolves the whole group back into tiles.

### Move a window past a group
`group | win` → ALT+SHIFT+H on win joins the group → ALT+SHIFT+H again leaves out
the left side → `win | group`. If you don't want it joining, **ALT+I** lock the
group first, or use **ALT+CTRL+H** (swap).

### Rearranging tiles
- Wrong orientation (stacked vs side-by-side)? **ALT+SHIFT+;**.
- Two windows in the wrong order? **ALT+CTRL+direction** (swap).
- Want a window in a different spot of the tree? **ALT+SHIFT+direction** (move).

### Scratch pad
ALT+S pops a floating nvim pad over whatever you're doing; ALT+S again hides it
(it keeps running). `:q` closes it for good; the next ALT+S starts fresh.

### Working inside the Omarchy VM
1. Launch "Omarchy VM" from fuzzel (or `~/vms/omarchy/omarchy-vm --installed`).
2. **ALT+Esc** → passthrough; now ALT keys go to the VM, which mirrors this layout on ALT.
3. **ALT+Esc** again to get the host binds back.
4. Shell into it: `ssh -p 2222 guiwoch@localhost`.

### Not bound (yet)
- No mouse drag/resize binds on the host (`bindm`); floating windows move only via rules.

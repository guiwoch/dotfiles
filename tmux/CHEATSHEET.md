# tmux cheat sheet

Prefix is **`C-b`** — on the Corne, *layer 1 + A*. Written `<p>` below.

Almost everything here is stock tmux, on purpose: `<p> ?` lists every binding,
and `man tmux` describes this exact setup. The few local changes are marked ✱.

## Windows (your tabs)

| key | does |
|---|---|
| `<p> c` | new window ✱ *opens in the current pane's directory* |
| `<p> 1`…`9` | go to window N |
| `<p> n` / `<p> p` | next / previous window |
| `<p> l` | **last window** — the one you were just in |
| `<p> ,` | rename window |
| `<p> &` | kill window (asks first) |
| `<p> w` | pick a window from a list |

## Panes (splits)

| key | does |
|---|---|
| `<p> %` | split left/right ✱ *inherits cwd* |
| `<p> "` | split top/bottom ✱ *inherits cwd* |
| `C-h/j/k/l` | **move between panes — no prefix.** Crosses into nvim's splits too ✱ |
| `<p> z` | zoom pane to full window (again to undo) — the one to remember |
| `<p> o` | cycle to next pane |
| `<p> x` | kill pane (asks first) |
| `<p> Space` | cycle layouts |
| `<p> M-←↑↓→` | resize pane |
| `<p> !` | break pane out into its own window |

## Sessions

| key | does |
|---|---|
| `<p> s` | session/window tree — the main way to move around |
| `<p> d` | detach (everything keeps running) |
| `<p> $` | rename session |
| `<p> L` | last session |

From a plain shell: `tmux ls`, `tmux a` (attach last), `tmux a -t name`,
`tmux new -s name`.

## Copy / scrollback

vi keys are on.

| key | does |
|---|---|
| `<p> [` | enter copy mode (this is how you scroll back) |
| `k` `j` `C-u` `C-d` `g` `G` | move around, as in vim |
| `/` `?` then `n` `N` | search back / forward |
| `v` | start selection |
| `y` | yank to the Wayland clipboard ✱ *`wl-copy`, pastes anywhere* |
| `q` | leave copy mode |

Mouse is on too: scroll to enter copy mode, drag to select and copy.

## Misc

| key | does |
|---|---|
| `<p> ?` | **list every binding** — the real cheat sheet |
| `<p> :` | command prompt |
| `<p> r` | reload this config ✱ *replaces stock refresh-client* |
| `<p> t` | clock |

## If you only remember five

`<p> c` new window · `<p> l` last window · `<p> z` zoom · `<p> d` detach · `<p> [` scroll back

## Deliberately absent

No `|`/`-` splits, no `Alt+1..9`, no `<p> h/j/k/l`, no `<p> v`. Each duplicated
something stock — `<p> -` is `delete-buffer`, `<p> l` is `last-window` — and one
way to do a thing beats two.

#!/usr/bin/env bash
# Battery level of the bluetooth device currently playing audio.
#
# Prints nothing (waybar hides the module) unless the default sink is a
# bluetooth one, so the reading vanishes as soon as audio moves to HDMI or a
# wired output. Runs continuously: reacts to sink changes at once, and re-reads
# the level on a tick.
#
# Lifetime: waybar kills this on reload, but a script that only writes on
# change can sit for hours without touching its pipe and so never notices.
# The tick therefore always writes (SIGPIPE ends us) and also checks that the
# parent is still alive; the trap takes the helpers down with us.

PARENT=$PPID
TICK=10

emit() {
    local sink mac dev info pct model icon cls
    sink=$(pactl get-default-sink 2>/dev/null)

    if [[ $sink != bluez_output.* ]]; then
        echo '{}'
        return
    fi

    mac=${sink#bluez_output.}          # bluez_output.40_35_..._0F.1 -> 40_35_..._0F
    mac=${mac%%.*}

    dev=$(upower -e 2>/dev/null | grep -m1 "$mac")
    [[ -n $dev ]] || { echo '{}'; return; }

    info=$(upower -i "$dev" 2>/dev/null)
    pct=$(awk '/percentage:/ {gsub(/%/,"",$2); print $2; exit}' <<<"$info")
    [[ -n $pct ]] || { echo '{}'; return; }

    model=$(awk -F': *' '/model:/ {print $2; exit}' <<<"$info")

    local icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
    icon=${icons[$((pct / 10))]}

    cls=normal
    (( pct <= 15 )) && cls=critical
    (( pct > 15 && pct <= 30 )) && cls=warning

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s battery: %s%%"}\n' \
        "$icon" "$pct" "$cls" "${model:-Bluetooth audio}" "$pct"
}

cleanup() {
    [[ -n ${SUB_PID:-} ]] && kill "$SUB_PID" 2>/dev/null
}
trap cleanup EXIT INT TERM HUP

# pactl events on fd 3, read-only: if we die, pactl's writes hit a pipe with no
# reader and it takes itself out. (A read-write fifo would leave it orphaned,
# because the writer would be holding a read end open itself.)
exec 3< <(pactl subscribe 2>/dev/null)
SUB_PID=$!

emit
last=

# read -t doubles as the tick, so there is no timer subshell to leak.
while true; do
    if read -r -t "$TICK" ev <&3; then
        case $ev in
            *"on server"*|*"on sink #"*)      # not sink-input: per-app volume
                out=$(emit)
                [[ $out == "$last" ]] && continue
                last=$out
                printf '%s\n' "$out" 2>/dev/null || exit 0
                ;;
        esac
    else
        (( $? > 128 )) || exit 0              # read failed, not a timeout: pipe gone
        kill -0 "$PARENT" 2>/dev/null || exit 0
        last=$(emit)
        printf '%s\n' "$last" 2>/dev/null || exit 0
    fi
done

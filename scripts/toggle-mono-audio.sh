#!/bin/bash

# Toggles a mono downmix on the current audio output.
# Enabling stacks a remapped sink (both channels = L+R summed) on top of the
# real sink and moves every stream onto it; disabling puts everything back.

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/mono_audio_state"
SINK_NAME="mono_downmix"

# Move all active streams to the given sink
move_streams() {
    local target="$1"
    pactl list sink-inputs short | while read -r id _; do
        [[ -n "$id" ]] && pactl move-sink-input "$id" "$target" 2>/dev/null
    done
}

disable_mono() {
    local module_id master
    module_id=$(sed -n '1p' "$STATE_FILE" 2>/dev/null)
    master=$(sed -n '2p' "$STATE_FILE" 2>/dev/null)

    # Fall back to any real sink if the remembered one is gone
    if [[ -z "$master" ]] || ! pactl list sinks short | grep -q "[[:space:]]$master[[:space:]]"; then
        master=$(pactl list sinks short | grep -v "[[:space:]]$SINK_NAME[[:space:]]" | head -1 | cut -f2)
    fi

    if [[ -n "$master" ]]; then
        pactl set-default-sink "$master"
        move_streams "$master"
    fi

    [[ -n "$module_id" ]] && pactl unload-module "$module_id" 2>/dev/null
    rm -f "$STATE_FILE"
    echo "Mono downmix off (stereo)"
    notify-send "Audio" "Mono downmix off (stereo)" -t 2000
}

enable_mono() {
    local master module_id
    master=$(pactl get-default-sink)

    if [[ "$master" == "$SINK_NAME" ]]; then
        # Already on the mono sink but no valid state file - nothing to stack on
        echo "Mono downmix already active"
        notify-send "Audio" "Mono downmix already active" -t 2000
        exit 0
    fi

    module_id=$(pactl load-module module-remap-sink \
        sink_name="$SINK_NAME" \
        master="$master" \
        channels=1 \
        channel_map=mono \
        sink_properties="device.description='Mono Downmix'" 2>/dev/null)

    if [[ -z "$module_id" || "$module_id" == "0" ]]; then
        echo "Failed to enable mono downmix" >&2
        notify-send "Audio" "Failed to enable mono downmix" -t 2000
        exit 1
    fi

    pactl set-default-sink "$SINK_NAME"
    move_streams "$SINK_NAME"

    printf '%s\n%s\n' "$module_id" "$master" > "$STATE_FILE"
    echo "Mono downmix on"
    notify-send "Audio" "Mono downmix on" -t 2000
}

# A state file whose module is still loaded means mono is currently active
if [[ -f "$STATE_FILE" ]] && pactl list modules short | grep -q "^$(sed -n '1p' "$STATE_FILE")[[:space:]]"; then
    disable_mono
else
    rm -f "$STATE_FILE"
    enable_mono
fi

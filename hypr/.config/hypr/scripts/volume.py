#!/usr/bin/env python3


import subprocess
import sys

def get_sinks():
    """Get all available audio sinks"""
    try:
        output = subprocess.check_output("pactl list sinks short", shell=True, encoding="utf-8")
        sinks = []
        for line in output.strip().split('\n'):
            if line.strip():
                sink_id = line.split()[0]
                sink_name = line.split()[1]
                sinks.append({"id": sink_id, "name": sink_name})
        return sinks
    except subprocess.CalledProcessError:
        print("Error: Could not get audio sinks")
        sys.exit(1)

def get_default_sink():
    """Get the current default sink"""
    try:
        output = subprocess.check_output("pactl get-default-sink", shell=True, encoding="utf-8")
        return output.strip()
    except subprocess.CalledProcessError:
        print("Error: Could not get default sink")
        sys.exit(1)

def get_sink_inputs():
    """Get all active audio streams"""
    try:
        output = subprocess.check_output("pactl list sink-inputs short", shell=True, encoding="utf-8")
        inputs = []
        for line in output.strip().split('\n'):
            if line.strip():
                input_id = line.split()[0]
                inputs.append(input_id)
        return inputs
    except subprocess.CalledProcessError:
        # No active streams is not an error
        return []

def set_default_sink(sink_name):
    """Set the default sink"""
    try:
        subprocess.run(f"pactl set-default-sink {sink_name}", shell=True, check=True)
        print(f"Set default sink to: {sink_name}")
    except subprocess.CalledProcessError:
        print(f"Error: Could not set sink to {sink_name}")
        sys.exit(1)

def move_sink_inputs(sink_name):
    """Move all active audio streams to the new sink"""
    inputs = get_sink_inputs()
    for input_id in inputs:
        try:
            subprocess.run(f"pactl move-sink-input {input_id} {sink_name}", shell=True, check=True)
            print(f"Moved stream {input_id} to {sink_name}")
        except subprocess.CalledProcessError:
            print(f"Warning: Could not move stream {input_id}")

def main():
    sinks = get_sinks()
    
    if len(sinks) < 2:
        print("Error: Less than 2 audio sinks available")
        sys.exit(1)
    
    current_default = get_default_sink()
    
    # Find the current sink and switch to the other one
    for i, sink in enumerate(sinks):
        if sink["name"] == current_default:
            # Switch to the next sink (or first if we're at the end)
            next_sink = sinks[(i + 1) % len(sinks)]
            set_default_sink(next_sink["name"])
            move_sink_inputs(next_sink["name"])
            return
    
    # If current default not found, just switch to first sink
    set_default_sink(sinks[0]["name"])
    move_sink_inputs(sinks[0]["name"])

if __name__ == "__main__":
    main()

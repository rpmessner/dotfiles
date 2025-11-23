#!/bin/bash
# Smart tmux pane selection that prefers topmost/leftmost panes
# Usage: tmux-smart-select-pane.sh <direction>
# Where direction is one of: L, R, U, D

set -e

direction="${1:-R}"

# Get current pane info
current_pane=$(tmux display-message -p '#{pane_id}')
current_left=$(tmux display-message -p '#{pane_left}')
current_right=$(tmux display-message -p '#{pane_right}')
current_top=$(tmux display-message -p '#{pane_top}')
current_bottom=$(tmux display-message -p '#{pane_bottom}')

find_pane_in_direction() {
  local dir=$1
  local target_pane=""

  case $dir in
    R) # Right: find topmost pane to the right
      target_pane=$(tmux list-panes -F '#{pane_id} #{pane_left} #{pane_top}' \
        | awk -v right="$current_right" -v current="$current_pane" \
          '$2 >= right && $1 != current {print $3, $1}' \
        | sort -n \
        | head -1 \
        | awk '{print $2}')
      ;;
    L) # Left: find topmost pane to the left
      target_pane=$(tmux list-panes -F '#{pane_id} #{pane_right} #{pane_top}' \
        | awk -v left="$current_left" -v current="$current_pane" \
          '$2 <= left && $1 != current {print $3, $1}' \
        | sort -n \
        | head -1 \
        | awk '{print $2}')
      ;;
    U|D) # Up/Down: use tmux's default behavior (no smart logic)
      # Return empty to fall through to default
      ;;
  esac

  echo "$target_pane"
}

target_pane=$(find_pane_in_direction "$direction")

if [ -n "$target_pane" ]; then
  # Found a pane in the desired direction (only L/R with smart logic)
  tmux select-pane -t "$target_pane"
else
  # Use tmux's default directional selection (L/R fallback, or all U/D)
  tmux select-pane -"$direction"
fi

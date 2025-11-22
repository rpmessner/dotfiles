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
    D) # Down: find leftmost pane below
      target_pane=$(tmux list-panes -F '#{pane_id} #{pane_top} #{pane_left}' \
        | awk -v bottom="$current_bottom" -v current="$current_pane" \
          '$2 >= bottom && $1 != current {print $3, $1}' \
        | sort -n \
        | head -1 \
        | awk '{print $2}')
      ;;
    U) # Up: find leftmost pane above
      target_pane=$(tmux list-panes -F '#{pane_id} #{pane_bottom} #{pane_left}' \
        | awk -v top="$current_top" -v current="$current_pane" \
          '$2 <= top && $1 != current {print $3, $1}' \
        | sort -n \
        | head -1 \
        | awk '{print $2}')
      ;;
  esac

  echo "$target_pane"
}

target_pane=$(find_pane_in_direction "$direction")

if [ -n "$target_pane" ]; then
  # Found a pane in the desired direction
  tmux select-pane -t "$target_pane"
else
  # No pane found, use tmux's default directional selection
  tmux select-pane -"$direction"
fi

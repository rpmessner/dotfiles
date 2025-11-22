#!/usr/bin/env zsh
# Profile zsh completion performance
# Usage: source this file, then type a command and press TAB
# It will show how long completion took

# Enable profiling
zmodload zsh/zprof

# Original completion widget
_profile_comp_original=${widgets[complete-word]}

_profile_complete_word() {
  local start=$EPOCHREALTIME
  zle $_profile_comp_original
  local end=$EPOCHREALTIME
  local elapsed=$(( (end - start) * 1000 ))

  if (( elapsed > 100 )); then
    echo "\n⚠️  Completion took ${elapsed}ms (slow!)" >&2
  elif (( elapsed > 50 )); then
    echo "\n⏱️  Completion took ${elapsed}ms" >&2
  fi
}

zle -N _profile_complete_word
bindkey '^I' _profile_complete_word

echo "✅ Completion profiling enabled. Press TAB to complete and see timing."
echo "   Completions >50ms will show a warning."

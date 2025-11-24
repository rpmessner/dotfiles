# zsh-histdb configuration
# SQLite-based command history tracking

# Database location (XDG-compliant)
export HISTDB_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-histdb/zsh-history.db"

# Create database directory if it doesn't exist
[[ -d "$(dirname "$HISTDB_FILE")" ]] || mkdir -p "$(dirname "$HISTDB_FILE")"

# Enable histdb-specific features
autoload -Uz add-zsh-hook

# Integration with existing history
# Keep standard history alongside histdb for compatibility
setopt EXTENDED_HISTORY          # Write timestamp to history file
setopt HIST_FIND_NO_DUPS         # Don't show duplicates when searching
setopt INC_APPEND_HISTORY        # Append immediately, not on shell exit
setopt SHARE_HISTORY             # Share history between sessions

# Histdb helper functions for querying

# Show most used commands
histdb-top() {
  local limit="${1:-10}"
  sqlite3 "$HISTDB_FILE" \
    "SELECT cmd, COUNT(*) as count FROM commands
     INNER JOIN history ON history.command_id = commands.id
     GROUP BY cmd
     ORDER BY count DESC
     LIMIT $limit"
}

# Show commands from last N hours
histdb-recent() {
  local hours="${1:-24}"
  sqlite3 "$HISTDB_FILE" \
    "SELECT datetime(start_time, 'unixepoch', 'localtime') as time,
            commands.cmd
     FROM history
     INNER JOIN commands ON history.command_id = commands.id
     WHERE start_time > strftime('%s', 'now', '-$hours hours')
     ORDER BY start_time DESC"
}

# Show commands run in current directory
histdb-here() {
  sqlite3 "$HISTDB_FILE" \
    "SELECT datetime(start_time, 'unixepoch', 'localtime') as time,
            commands.cmd
     FROM history
     INNER JOIN commands ON history.command_id = commands.id
     INNER JOIN places ON history.place_id = places.id
     WHERE places.dir = '$PWD'
     ORDER BY start_time DESC
     LIMIT 20"
}

# Export database stats
histdb-stats() {
  echo "=== ZSH History Database Stats ==="
  echo "Database location: $HISTDB_FILE"
  echo "Database size: $(du -h "$HISTDB_FILE" 2>/dev/null | cut -f1 || echo 'N/A')"
  echo ""
  sqlite3 "$HISTDB_FILE" \
    "SELECT
       (SELECT COUNT(*) FROM commands) as total_commands,
       (SELECT COUNT(*) FROM history) as total_executions,
       (SELECT COUNT(*) FROM places) as unique_directories,
       (SELECT COUNT(DISTINCT session) FROM history) as total_sessions"
}

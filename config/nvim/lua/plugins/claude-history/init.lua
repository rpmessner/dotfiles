-- Claude Code History Tracker
-- Captures MCP tool invocations and terminal commands from Claude Code sessions

local M = {}

-- Session storage
M.sessions = {}
M.current_session_id = nil

---@class HistoryEntry
---@field type "tool"|"bash"|"diff"|"save"
---@field timestamp number
---@field tool_name string?
---@field params table?
---@field command string?
---@field file_path string?
---@field result table?

---Start a new session
function M.start_session()
  M.current_session_id = tostring(os.time())
  M.sessions[M.current_session_id] = {
    id = M.current_session_id,
    started_at = os.time(),
    entries = {},
  }
  return M.current_session_id
end

---Get current session or create one
function M.get_or_create_session()
  if not M.current_session_id or not M.sessions[M.current_session_id] then
    return M.start_session()
  end
  return M.current_session_id
end

---Add a history entry to the current session
---@param entry HistoryEntry
function M.add_entry(entry)
  local session_id = M.get_or_create_session()
  local session = M.sessions[session_id]

  entry.timestamp = entry.timestamp or os.time()
  table.insert(session.entries, entry)
end

---Get all entries from current session
---@return HistoryEntry[]
function M.get_current_entries()
  local session_id = M.current_session_id
  if not session_id or not M.sessions[session_id] then
    return {}
  end
  return M.sessions[session_id].entries
end

---Get all entries from all sessions
---@return HistoryEntry[]
function M.get_all_entries()
  local all_entries = {}
  for _, session in pairs(M.sessions) do
    for _, entry in ipairs(session.entries) do
      table.insert(all_entries, entry)
    end
  end
  -- Sort by timestamp descending (newest first)
  table.sort(all_entries, function(a, b)
    return (a.timestamp or 0) > (b.timestamp or 0)
  end)
  return all_entries
end

---Clear current session
function M.clear_current_session()
  if M.current_session_id and M.sessions[M.current_session_id] then
    M.sessions[M.current_session_id] = nil
  end
  M.current_session_id = nil
end

---Clear all sessions
function M.clear_all_sessions()
  M.sessions = {}
  M.current_session_id = nil
end

return M

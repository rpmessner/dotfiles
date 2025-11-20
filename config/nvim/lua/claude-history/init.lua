-- Claude Code History Tracker
-- Captures MCP tool invocations and terminal commands from Claude Code sessions

local M = {}

-- Session storage
M.sessions = {}
M.current_session_id = nil
M.current_cwd = nil -- Track the working directory for this history

-- Storage path
local data_path = vim.fn.stdpath("data") .. "/claude-history"

---Sanitize directory path for use as filename
---@param path string
---@return string
local function sanitize_path(path)
  -- Replace path separators and special chars with underscores
  return path:gsub("[/\\:*?\"<>|]", "_")
end

---Get storage file path for a directory
---@param cwd string
---@return string
local function get_storage_path(cwd)
  vim.fn.mkdir(data_path, "p") -- Ensure directory exists
  local filename = sanitize_path(cwd) .. ".json"
  return data_path .. "/" .. filename
end

---Save sessions to disk
local function save_to_disk()
  if not M.current_cwd then
    return -- No CWD set, can't save
  end

  local filepath = get_storage_path(M.current_cwd)
  local data = {
    cwd = M.current_cwd,
    current_session_id = M.current_session_id,
    sessions = M.sessions,
  }

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    vim.notify("Failed to encode claude-history data: " .. encoded, vim.log.levels.ERROR)
    return
  end

  local file = io.open(filepath, "w")
  if not file then
    vim.notify("Failed to open claude-history file for writing: " .. filepath, vim.log.levels.ERROR)
    return
  end

  file:write(encoded)
  file:close()
end

---Load sessions from disk
---@param cwd string
local function load_from_disk(cwd)
  local filepath = get_storage_path(cwd)

  -- Check if file exists
  if vim.fn.filereadable(filepath) == 0 then
    return -- No existing history for this directory
  end

  local file = io.open(filepath, "r")
  if not file then
    return
  end

  local content = file:read("*a")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data then
    vim.notify("Failed to decode claude-history data from: " .. filepath, vim.log.levels.WARN)
    return
  end

  -- Restore sessions
  M.current_cwd = data.cwd or cwd
  M.current_session_id = data.current_session_id
  M.sessions = data.sessions or {}
end

---@class HistoryEntry
---@field type "tool"|"bash"|"diff"|"save"
---@field timestamp number
---@field tool_name string?
---@field params table?
---@field command string?
---@field file_path string?
---@field old_file_path string?
---@field new_file_path string?
---@field old_file_contents string?
---@field new_file_contents string?
---@field tab_name string?
---@field result table?

---Initialize history for a specific directory
---@param cwd string
function M.init(cwd)
  M.current_cwd = cwd
  load_from_disk(cwd)
end

---Start a new session
function M.start_session()
  M.current_session_id = tostring(os.time())
  M.sessions[M.current_session_id] = {
    id = M.current_session_id,
    started_at = os.time(),
    entries = {},
  }
  save_to_disk()
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

  -- Auto-save after each entry
  save_to_disk()
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
  save_to_disk()
end

---Clear all sessions
function M.clear_all_sessions()
  M.sessions = {}
  M.current_session_id = nil
  save_to_disk()
end

---Get all sessions (for UI display)
---@return table[]
function M.get_sessions()
  local sessions_list = {}
  for _, session in pairs(M.sessions) do
    table.insert(sessions_list, {
      id = session.id,
      start_time = session.started_at,
      entries = session.entries,
    })
  end
  -- Sort by start time descending (newest first)
  table.sort(sessions_list, function(a, b)
    return (a.start_time or 0) > (b.start_time or 0)
  end)
  return sessions_list
end

return M

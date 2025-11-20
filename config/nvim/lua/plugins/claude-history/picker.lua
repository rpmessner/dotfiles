-- Snacks picker source for Claude Code history
local M = {}

local history = require("plugins.claude-history")

---Format timestamp as HH:MM:SS
---@param timestamp number
---@return string
local function format_time(timestamp)
  return os.date("%H:%M:%S", timestamp)
end

---Get icon for entry type
---@param entry_type string
---@return string
local function get_icon(entry_type)
  local icons = {
    tool = "🔧",
    bash = "🐚",
    diff = "📝",
    save = "💾",
  }
  return icons[entry_type] or "📋"
end

---Format history entry for display
---@param entry HistoryEntry
---@return string
local function format_entry(entry)
  local time = format_time(entry.timestamp or os.time())
  local icon = get_icon(entry.type)

  if entry.type == "bash" then
    return string.format("[%s] %s %s", time, icon, entry.command or "unknown")
  elseif entry.type == "tool" then
    local detail = entry.tool_name or "unknown"
    if entry.file_path then
      detail = detail .. " → " .. vim.fn.fnamemodify(entry.file_path, ":~:.")
    end
    return string.format("[%s] %s Tool: %s", time, icon, detail)
  elseif entry.type == "diff" then
    local file = entry.file_path and vim.fn.fnamemodify(entry.file_path, ":~:.") or "unknown"
    return string.format("[%s] %s Diff: %s", time, icon, file)
  elseif entry.type == "save" then
    local file = entry.file_path and vim.fn.fnamemodify(entry.file_path, ":~:.") or "unknown"
    return string.format("[%s] %s Save: %s", time, icon, file)
  end

  return string.format("[%s] %s %s", time, icon, entry.type or "unknown")
end

---Create picker source for history
---@param opts table?
---@return table
function M.create_source(opts)
  opts = opts or {}
  local show_all = opts.all or false

  return {
    name = show_all and "claude_history_all" or "claude_history",
    get = function(ctx, cb)
      local entries = show_all and history.get_all_entries() or history.get_current_entries()

      local items = {}
      for i, entry in ipairs(entries) do
        table.insert(items, {
          idx = i,
          text = format_entry(entry),
          entry = entry,
          file = entry.file_path,
        })
      end

      cb(items)
    end,
    preview = function(item, opts_preview)
      -- If entry has a file, preview it
      if item.entry.file_path then
        local file_path = vim.fn.expand(item.entry.file_path)
        if vim.fn.filereadable(file_path) == 1 then
          return {
            file = file_path,
            filetype = vim.filetype.match({ filename = file_path }),
          }
        end
      end

      -- Otherwise, show entry details as JSON
      local details = vim.json.encode(item.entry, { indent = 2 })
      return {
        text = details,
        filetype = "json",
      }
    end,
    actions = {
      default = function(item)
        -- Default action: open file if available
        if item.entry.file_path then
          local file_path = vim.fn.expand(item.entry.file_path)
          if vim.fn.filereadable(file_path) == 1 then
            vim.cmd("edit " .. vim.fn.fnameescape(file_path))
            return
          end
        end

        -- Otherwise, show details
        vim.notify(vim.inspect(item.entry), vim.log.levels.INFO, { title = "Claude History Entry" })
      end,
      rerun = function(item)
        -- For bash commands, insert into command line
        if item.entry.type == "bash" and item.entry.command then
          vim.fn.feedkeys(":" .. item.entry.command)
        else
          vim.notify("Can only rerun bash commands", vim.log.levels.WARN)
        end
      end,
    },
  }
end

---Open history picker
---@param opts table?
function M.open(opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("Snacks.nvim not available", vim.log.levels.ERROR)
    return
  end

  local entries = opts.all and history.get_all_entries() or history.get_current_entries()
  if #entries == 0 then
    vim.notify("No Claude Code history available", vim.log.levels.INFO)
    return
  end

  snacks.picker.pick({
    source = M.create_source(opts),
    prompt = opts.all and "Claude History (All Sessions)" or "Claude History (Current Session)",
  })
end

return M

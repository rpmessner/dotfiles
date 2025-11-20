-- Tracking hooks for claudecode.nvim
local M = {}

local history = require("claude-history")

---Setup tracking by wrapping claudecode tools
function M.setup()
  -- Wait for claudecode to be loaded
  vim.defer_fn(function()
    local ok, claudecode_tools = pcall(require, "claudecode.tools")
    if not ok then
      return -- claudecode not loaded yet or not installed
    end

    M.wrap_tools(claudecode_tools)
    M.setup_terminal_tracking()
  end, 1000)
end

---Wrap claudecode tools to capture invocations
function M.wrap_tools(tools_module)
  if not tools_module then
    vim.notify("claude-history: tools_module is nil", vim.log.levels.WARN)
    return
  end

  if not tools_module.handle_invoke then
    vim.notify("claude-history: handle_invoke not found on tools_module", vim.log.levels.WARN)
    return
  end

  -- Store original handle_invoke
  local original_handle_invoke = tools_module.handle_invoke

  -- Wrap handle_invoke to capture all tool calls
  tools_module.handle_invoke = function(client, params)
    -- Record the tool invocation
    local entry = {
      type = "tool",
      tool_name = params.name,
      params = params.arguments,
    }

    -- Extract file paths and content for common tools
    if params.name == "open_file" and params.arguments and params.arguments.filePath then
      entry.file_path = params.arguments.filePath
    elseif params.name == "openDiff" and params.arguments then
      -- Capture diff information
      entry.type = "diff"
      entry.file_path = params.arguments.old_file_path or params.arguments.new_file_path
      entry.old_file_path = params.arguments.old_file_path
      entry.new_file_path = params.arguments.new_file_path
      entry.new_file_contents = params.arguments.new_file_contents
      entry.tab_name = params.arguments.tab_name

      -- Read old content from disk if file exists
      if entry.old_file_path and vim.fn.filereadable(entry.old_file_path) == 1 then
        entry.old_file_contents = table.concat(vim.fn.readfile(entry.old_file_path), "\n")
      end
    elseif params.name == "save_document" and params.arguments and params.arguments.filePath then
      entry.file_path = params.arguments.filePath
      entry.type = "save"
    end

    history.add_entry(entry)

    -- Call original handler
    local result = original_handle_invoke(client, params)

    -- Store result if successful
    if result and not result.error then
      entry.result = result
    end

    return result
  end

  vim.notify("claude-history: Successfully wrapped claudecode.tools.handle_invoke", vim.log.levels.INFO)
end

---Setup terminal command tracking
function M.setup_terminal_tracking()
  -- Create autocmd to track new sessions
  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function(args)
      local bufname = vim.api.nvim_buf_get_name(args.buf)

      -- Check if this is a Claude Code terminal
      if bufname:match("claude") or bufname:match("Claude") then
        -- Get the working directory for this terminal
        -- First try buffer-local CWD, then fall back to global CWD
        local cwd = vim.fn.getcwd(-1, args.buf)
        if not cwd or cwd == "" then
          cwd = vim.fn.getcwd()
        end

        -- Initialize history for this directory (loads existing sessions)
        history.init(cwd)

        -- Start a new session if there isn't one
        if not history.current_session_id then
          history.start_session()
        end

        -- Set up buffer-local tracking
        M.track_terminal_buffer(args.buf)

        vim.notify(
          string.format("Claude history tracking started for: %s", vim.fn.fnamemodify(cwd, ":~")),
          vim.log.levels.INFO
        )
      end
    end,
  })
end

---Track commands in a terminal buffer
---@param bufnr number
function M.track_terminal_buffer(bufnr)
  -- Store last line count to detect new output
  local last_line_count = 0

  local timer = vim.loop.new_timer()
  if not timer then
    return
  end

  timer:start(
    500, -- Start after 500ms
    1000, -- Check every second
    vim.schedule_wrap(function()
      -- Check if buffer still exists
      if not vim.api.nvim_buf_is_valid(bufnr) then
        timer:stop()
        timer:close()
        return
      end

      local current_line_count = vim.api.nvim_buf_line_count(bufnr)

      -- If new lines were added, scan for commands
      if current_line_count > last_line_count then
        local new_lines = vim.api.nvim_buf_get_lines(bufnr, last_line_count, current_line_count, false)

        for _, line in ipairs(new_lines) do
          -- Try to extract bash commands (looking for common command patterns)
          -- This is a heuristic - looks for lines that start with common command patterns
          local command = M.extract_command(line)
          if command then
            history.add_entry({
              type = "bash",
              command = command,
            })
          end
        end

        last_line_count = current_line_count
      end
    end)
  )

  -- Clean up timer when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = bufnr,
    callback = function()
      if timer then
        timer:stop()
        timer:close()
      end
    end,
  })
end

---Extract command from terminal line
---@param line string
---@return string?
function M.extract_command(line)
  -- Remove ANSI escape codes
  local cleaned = line:gsub("\27%[%d*;?%d*m", "")

  -- Common command patterns to look for
  local patterns = {
    -- Bash prompt patterns: user@host:dir$ command
    "[$#>]%s+(.+)$",
    -- Simple command line (after prompt indicators)
    "^%s*❯%s+(.+)$", -- starship/oh-my-zsh prompt
    "^%s*➜%s+(.+)$", -- another common prompt
  }

  for _, pattern in ipairs(patterns) do
    local cmd = cleaned:match(pattern)
    if cmd and #cmd > 0 then
      -- Filter out non-commands (empty, just whitespace, or navigation)
      cmd = vim.trim(cmd)
      if #cmd > 0 and not cmd:match("^%s*$") then
        return cmd
      end
    end
  end

  return nil
end

return M

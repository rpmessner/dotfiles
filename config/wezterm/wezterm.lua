-- WezTerm Configuration
-- Modern, performant terminal emulator with Lua configuration

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================================================
-- Appearance
-- ============================================================================

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Font configuration
config.font = wezterm.font_with_fallback {
  'FiraCode Nerd Font',
  'JetBrains Mono',
}
config.font_size = 16.0
config.line_height = 1.2

-- Enable font ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Window appearance
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false

-- Window background opacity
config.window_background_opacity = 0.98
config.macos_window_background_blur = 20

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ============================================================================
-- Performance
-- ============================================================================

config.max_fps = 120
config.animation_fps = 60
config.front_end = 'WebGpu'

-- Scrollback
config.scrollback_lines = 10000

-- ============================================================================
-- macOS Integration
-- ============================================================================

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Native full screen
config.native_macos_fullscreen_mode = false

-- ============================================================================
-- Neovim & tmux Integration
-- ============================================================================

-- True color support
config.term = 'wezterm'

-- Copy mode (vim-like)
config.keys = {
  -- Copy mode
  {
    key = '[',
    mods = 'CMD',
    action = wezterm.action.ActivateCopyMode,
  },

  -- Pane navigation (when not using tmux)
  {
    key = 'h',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },

  -- Pane splitting
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Close pane
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- New tab
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Tab navigation
  {
    key = '[',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = ']',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateTabRelative(1),
  },

  -- Font size
  {
    key = '+',
    mods = 'CMD',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CMD',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CMD',
    action = wezterm.action.ResetFontSize,
  },

  -- Quick select (URL/path picker)
  {
    key = 'Space',
    mods = 'CMD|SHIFT',
    action = wezterm.action.QuickSelect,
  },
}

-- Copy mode key table (vim-like navigation)
config.key_tables = {
  copy_mode = {
    { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
    { key = 'q', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
    { key = 'h', mods = 'NONE', action = wezterm.action.CopyMode 'MoveLeft' },
    { key = 'j', mods = 'NONE', action = wezterm.action.CopyMode 'MoveDown' },
    { key = 'k', mods = 'NONE', action = wezterm.action.CopyMode 'MoveUp' },
    { key = 'l', mods = 'NONE', action = wezterm.action.CopyMode 'MoveRight' },
    { key = 'w', mods = 'NONE', action = wezterm.action.CopyMode 'MoveForwardWord' },
    { key = 'b', mods = 'NONE', action = wezterm.action.CopyMode 'MoveBackwardWord' },
    { key = '0', mods = 'NONE', action = wezterm.action.CopyMode 'MoveToStartOfLine' },
    { key = '$', mods = 'NONE', action = wezterm.action.CopyMode 'MoveToEndOfLineContent' },
    { key = 'g', mods = 'NONE', action = wezterm.action.CopyMode 'MoveToScrollbackTop' },
    { key = 'G', mods = 'NONE', action = wezterm.action.CopyMode 'MoveToScrollbackBottom' },
    { key = 'v', mods = 'NONE', action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' } },
    { key = 'V', mods = 'NONE', action = wezterm.action.CopyMode { SetSelectionMode = 'Line' } },
    {
      key = 'y',
      mods = 'NONE',
      action = wezterm.action.Multiple {
        { CopyTo = 'ClipboardAndPrimarySelection' },
        { CopyMode = 'Close' },
      },
    },
  },
}

-- Mouse bindings
config.mouse_bindings = {
  -- Click to open URLs
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ============================================================================
-- Shell Integration
-- ============================================================================

-- Default shell
config.default_prog = { '/bin/zsh', '-l' }

-- Detect and integrate with shell
config.detect_password_input = true

-- ============================================================================
-- Hyperlinks & Quick Select
-- ============================================================================

-- URL matching
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add custom patterns for quick select
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = 'https://github.com/$1/$3',
})

-- Quick select patterns
config.quick_select_patterns = {
  -- File paths
  [[/\w\S+]],
  -- Git commit hashes
  [[\b[0-9a-f]{7,40}\b]],
  -- IPv4 addresses
  [[\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b]],
  -- Hex colors
  [[\b#[0-9a-fA-F]{6}\b]],
}

-- ============================================================================
-- Bell & Notifications
-- ============================================================================

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}

-- ============================================================================
-- Status & Tab Bar Customization
-- ============================================================================

wezterm.on('update-right-status', function(window, pane)
  local date = wezterm.strftime '%Y-%m-%d %H:%M'
  local bat = ''

  for _, b in ipairs(wezterm.battery_info()) do
    bat = string.format('%.0f%%', b.state_of_charge * 100)
  end

  window:set_right_status(wezterm.format {
    { Text = bat .. ' | ' .. date .. ' ' },
  })
end)

-- Format tab titles
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local cwd = pane.current_working_dir

  local title = tab.tab_index + 1
  if cwd then
    local path = cwd.file_path or ''
    local home = os.getenv 'HOME'
    if home and path:sub(1, #home) == home then
      path = '~' .. path:sub(#home + 1)
    end
    local segments = {}
    for segment in string.gmatch(path, '[^/]+') do
      table.insert(segments, segment)
    end
    if #segments > 0 then
      title = title .. ' ' .. segments[#segments]
    end
  end

  return {
    { Text = ' ' .. title .. ' ' },
  }
end)

return config

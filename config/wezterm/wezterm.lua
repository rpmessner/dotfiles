-- WezTerm Configuration
-- Modern, performant terminal emulator with Lua configuration
-- Cross-platform: macOS, Linux, Windows (WSL)

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================================================
-- Platform Detection
-- ============================================================================

local is_windows = wezterm.target_triple:find 'windows' ~= nil
local is_macos = wezterm.target_triple:find 'darwin' ~= nil
local is_linux = wezterm.target_triple:find 'linux' ~= nil

-- ============================================================================
-- Appearance
-- ============================================================================

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Font configuration
-- FiraCode Nerd Font works great across all platforms with OpenGL backend
config.font = wezterm.font_with_fallback {
  'FiraCode Nerd Font',
  'JetBrains Mono',
  'Cascadia Code',
  'Consolas',
}
config.font_size = 11.0

-- Fix font clipping on Windows by adjusting cell metrics
config.line_height = 1.0
config.cell_width = 1.0
-- Allow fonts to render with proper vertical space
config.allow_square_glyphs_to_overflow_width = 'WhenFollowedBySpace'

-- Enable font ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Windows-specific rendering fixes for bold text clipping
if is_windows then
  config.freetype_load_target = 'Normal'
  config.freetype_render_target = 'Normal'
  -- Try to prevent clipping by adjusting font rasterizer
  config.freetype_load_flags = 'DEFAULT'
end

-- Window appearance
-- Options:
--   'NONE' - No decorations, no controls
--   'TITLE' - Title bar with controls
--   'RESIZE' - Just resize borders (current)
--   'TITLE | RESIZE' - Full decorations
--   'INTEGRATED_BUTTONS|RESIZE' - Buttons in tab bar (recommended for seamless look)
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 4,
}

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false -- Show tab bar to display integrated buttons
config.tab_bar_at_bottom = false -- Top is better for integrated buttons
config.show_tab_index_in_tab_bar = false

-- Window frame colors (for seamless integration with terminal background)
config.window_frame = {
  -- Font for tab bar - using Regular weight to prevent clipping
  font = wezterm.font { family = 'FiraCode Nerd Font', weight = 'Regular' },
  font_size = 10.0,

  -- The overall background color of the tab bar when
  -- the window is focused
  active_titlebar_bg = '#1a1b26', -- Tokyo Night background

  -- The overall background color of the tab bar when
  -- the window is not focused
  inactive_titlebar_bg = '#16161e',
}

-- Fix font clipping in tab bar with proper padding
config.tab_max_width = 32

-- Tab bar colors to match Tokyo Night
config.colors = {
  -- Darken the background for better contrast with antialiased fonts
  -- Tokyo Night default is #1a1b26, using darker variant
  background = '#14151c',
  -- Brighten foreground text slightly for better readability
  -- Tokyo Night default is #c0caf5, brightening to #d0daf5
  foreground = '#d0daf5',

  -- Dramatically brighten ANSI colors for better syntax highlighting contrast
  ansi = {
    '#2a2f44', -- black (much lighter)
    '#ff9db4', -- red (much brighter)
    '#c3f991', -- green (much brighter)
    '#ffd580', -- yellow (much brighter)
    '#97c2ff', -- blue (much brighter)
    '#d7bdff', -- magenta (much brighter)
    '#a3e5ff', -- cyan (much brighter)
    '#f5f5f5', -- white (much brighter)
  },
  brights = {
    '#545c7e', -- bright black (much lighter)
    '#ffb3c9', -- bright red (very bright)
    '#dcffb0', -- bright green (very bright)
    '#ffe9a3', -- bright yellow (very bright)
    '#b8d7ff', -- bright blue (very bright)
    '#ebd5ff', -- bright magenta (very bright)
    '#c9f3ff', -- bright cyan (very bright)
    '#ffffff', -- bright white (pure white)
  },

  tab_bar = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = '#1a1b26',

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = '#1a1b26',
      -- The color of the text for the tab
      fg_color = '#c0caf5',

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = 'Normal',

      -- Specify whether you want "None", "Single" or "Double" underline for
      -- label shown for this tab.
      -- The default is "None"
      underline = 'None',

      -- Specify whether you want the text to be italic (true) or not (false)
      -- for this tab. The default is false.
      italic = false,

      -- Specify whether you want the text to be rendered with strikethrough (true)
      -- or not for this tab. The default is false.
      strikethrough = false,
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = '#16161e',
      fg_color = '#545c7e',
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#7aa2f7',
      italic = false,
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = '#1a1b26',
      fg_color = '#7aa2f7',
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#c0caf5',
      italic = false,
    },
  },
}

-- Window background opacity (1.0 = fully opaque, no transparency)
config.window_background_opacity = 1.0

-- macOS-specific blur
if is_macos then
  config.macos_window_background_blur = 20
end

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
-- Use OpenGL on Windows for better font rendering, WebGpu on other platforms
config.front_end = is_windows and 'OpenGL' or 'WebGpu'

-- Scrollback
config.scrollback_lines = 10000

-- ============================================================================
-- Shell Configuration (Platform-Specific)
-- ============================================================================

if is_windows then
  -- On Windows, launch WSL by default
  config.default_prog = { 'wsl.exe', '~' }

  -- Auto-detect all available WSL distributions and set home directory
  config.wsl_domains = wezterm.default_wsl_domains()

  -- Ensure all WSL domains start in Linux home directory, not Windows path
  for _, domain in ipairs(config.wsl_domains) do
    domain.default_cwd = '~'
  end

  -- Use the default WSL distribution (whatever 'wsl.exe' launches)
  for _, domain in ipairs(config.wsl_domains) do
    if domain.default then
      config.default_domain = domain.name
      break
    end
  end
else
  -- On macOS/Linux, use zsh directly
  config.default_prog = { '/bin/zsh', '-l' }
end

-- Detect and integrate with shell
config.detect_password_input = true

-- ============================================================================
-- Platform-Aware Keybindings
-- ============================================================================

-- Determine modifier key based on platform
local mod = is_macos and 'CMD' or 'CTRL'
local mod_shift = is_macos and 'CMD|SHIFT' or 'CTRL|SHIFT'

-- Leader key configuration (like tmux)
-- Using Ctrl+Space for ergonomics (especially with Caps Lock → Ctrl)
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Copy mode
  {
    key = '[',
    mods = mod,
    action = wezterm.action.ActivateCopyMode,
  },

  -- Pane navigation (tmux-style with leader key)
  {
    key = 'h',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },

  -- Pane splitting (matching your tmux config)
  {
    key = '"',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '%',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },

  -- Pane zoom (matching your tmux config)
  {
    key = 'UpArrow',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = 'DownArrow',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },

  -- Close pane (tmux uses 'x', but keeping 'w' for familiarity)
  {
    key = 'x',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- New tab (tmux-style with 'c' for create)
  {
    key = 'c',
    mods = 'LEADER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Last tab (tmux-style: leader+Tab or double-tap leader)
  {
    key = 'Tab',
    mods = 'LEADER',
    action = wezterm.action.ActivateLastTab,
  },

  -- Tab navigation (next/previous)
  {
    key = 'n',
    mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(-1),
  },

  -- Direct tab access (tmux-style: leader + number)
  {
    key = '1',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(0),
  },
  {
    key = '2',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(1),
  },
  {
    key = '3',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(2),
  },
  {
    key = '4',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(3),
  },
  {
    key = '5',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(4),
  },
  {
    key = '6',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(5),
  },
  {
    key = '7',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(6),
  },
  {
    key = '8',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(7),
  },
  {
    key = '9',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(8),
  },

  -- Font size with increased line_height to prevent clipping
  -- Using built-in actions but with higher line_height (1.3) for stability
  {
    key = '=',
    mods = mod,
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = mod,
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = mod,
    action = wezterm.action.ResetFontSize,
  },

  -- Reload configuration (tmux-style with leader)
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action.ReloadConfiguration,
  },

  -- Disable Ctrl+Z to prevent accidental suspends
  {
    key = 'z',
    mods = 'CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },

  -- Suspend process (safer alternative via leader key)
  {
    key = 'z',
    mods = 'LEADER',
    action = wezterm.action.SendKey { key = 'z', mods = 'CTRL' },
  },

  -- Quick select (URL/path picker)
  {
    key = 'Space',
    mods = mod_shift,
    action = wezterm.action.QuickSelect,
  },

  -- Toggle full screen
  {
    key = 'Enter',
    mods = 'ALT',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- macOS-specific key handling
if is_macos then
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = true
  config.native_macos_fullscreen_mode = false
end

-- ============================================================================
-- Copy Mode (Vim-like navigation)
-- ============================================================================

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

-- ============================================================================
-- Mouse Bindings
-- ============================================================================

config.mouse_bindings = {
  -- Click to open URLs (platform-aware)
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = mod,
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

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
  -- File paths (both Unix and Windows)
  [[/\w\S+]],
  [[[A-Za-z]:\\[\w\\\-\.]+]],
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

  local status = date
  if bat ~= '' then
    status = bat .. ' | ' .. status
  end

  -- Add extra padding to prevent clipping
  window:set_right_status(wezterm.format {
    { Attribute = { Intensity = 'Normal' } },
    { Text = '  ' .. status .. '  ' },
  })
end)

-- Format tab titles with extra vertical padding to prevent clipping
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local cwd = pane.current_working_dir

  local title = tab.tab_index + 1
  if cwd then
    local path = cwd.file_path or ''
    local home = os.getenv 'HOME' or os.getenv 'USERPROFILE'
    if home and path:sub(1, #home) == home then
      path = '~' .. path:sub(#home + 1)
    end

    -- Split path by both / and \ for cross-platform support
    local segments = {}
    for segment in string.gmatch(path, '[^/\\]+') do
      table.insert(segments, segment)
    end

    if #segments > 0 then
      title = title .. ' ' .. segments[#segments]
    end
  end

  -- Extra padding with ZWSP (zero-width space) hack for vertical space
  return {
    { Text = '  ' .. title .. '  ' },
  }
end)

-- ============================================================================
-- Terminal Type
-- ============================================================================

-- Use xterm-256color for maximum compatibility
-- WezTerm supports true color regardless of this setting
config.term = 'xterm-256color'

return config

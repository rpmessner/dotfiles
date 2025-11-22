# Consolidated Action Items & Dotfiles Improvement Roadmap

**Date**: November 21, 2025
**Session**: WezTerm Configuration + Comprehensive Dotfiles Audit
**Status**: Active Development

---

## Executive Summary

This document consolidates all outstanding work from the WezTerm configuration session and comprehensive dotfiles audit. It represents a complete roadmap for improving the development environment.

**Current Status:**
- ✅ WezTerm core configuration complete and working
- ✅ Font rendering issues resolved
- ✅ Cross-platform support implemented
- ⚠️ Several high-value features installed but unconfigured
- ⚠️ Snippet system completely missing despite infrastructure being ready

---

## Session History Reference

- **Initial Session**: `2025-11-21-wezterm-wsl-cross-platform-fixes.md` - WSL integration, font fixes, platform detection
- **Current Session**: WezTerm keybindings, color adjustments, and comprehensive audit
- **Related**: `2025-11-20-wsl2-ubuntu-installation.md` - WSL setup

---

## Completed Work (Today's Session)

### WezTerm Configuration ✅

1. **Keybinding Improvements**
   - ✅ Implemented tmux-style leader key (`Ctrl+Space`)
   - ✅ Fixed keybinding conflicts with Vim (Ctrl+D page down)
   - ✅ Matched tmux split keybindings (`Leader + "` and `Leader + %`)
   - ✅ Added pane zoom/navigation with leader key
   - ✅ Added tab navigation (`Leader + n/p`, `Leader + 1-9`)
   - ✅ Added `Leader + Tab` for last tab switching

2. **Font Rendering Solutions**
   - ✅ Switched to OpenGL backend on Windows (fixed clipping)
   - ✅ Platform-agnostic FiraCode Nerd Font configuration
   - ✅ Optimal `line_height = 1.05` for bold character rendering
   - ✅ Font size reduced to 10pt per user preference

3. **Visual Improvements**
   - ✅ Removed window transparency (opacity = 1.0)
   - ✅ Darkened background to `#14151c` for better contrast
   - ✅ Brightened foreground text to `#d0daf5`
   - ✅ Dramatically brightened ANSI colors for syntax highlighting
   - ✅ Improved readability with antialiased fonts

4. **WSL Integration**
   - ✅ Auto-detection of WSL distributions (no hardcoded distro names)
   - ✅ Automatic default distribution selection

### Files Modified Today
- `config/wezterm/wezterm.lua` - Comprehensive updates

---

## Outstanding WezTerm Items

### Low Priority (Nice to Have)

#### 1. macOS Testing
**Status**: ⬜ Not tested
**Effort**: 15 minutes (requires Mac access)
**Tasks**:
- [ ] Verify `CMD` modifier works correctly
- [ ] Test window blur effect (`macos_window_background_blur = 20`)
- [ ] Verify native fullscreen mode setting
- [ ] Confirm FiraCode Nerd Font renders properly

#### 2. Dynamic Color Scheme Integration
**Status**: ⬜ Not implemented
**Effort**: 30 minutes
**Current**: Colors are hardcoded Tokyo Night values
**Improvement**: Extract colors programmatically from WezTerm's color scheme
```lua
-- Potential implementation
local scheme = wezterm.get_builtin_color_schemes()[config.color_scheme]
config.colors.background = adjust_brightness(scheme.background, -0.1)
```

#### 3. Tab Bar Font Size Optimization
**Status**: ⬜ Minor improvement possible
**Effort**: 10 minutes
**Current**: Tab bar font is 10pt Regular weight
**Test**: Try 11pt to see if clipping returns or if it's acceptable now with OpenGL

#### 4. Documentation Updates
**Status**: ⬜ Pending
**Effort**: 20 minutes
**Tasks**:
- [ ] Update `2025-11-21-wezterm-wsl-cross-platform-fixes.md` with final status
- [ ] Document the OpenGL rendering solution
- [ ] Note the line_height sweet spot (1.05)
- [ ] Add keybinding reference guide

---

## High-Impact Opportunities (From Comprehensive Audit)

### Category 1: Snippets & Code Generation 🔥 HIGHEST PRIORITY

#### Problem
**NO snippet engine is configured** despite blink-cmp being configured to use snippets. The "snippets" source is enabled but there's no snippet engine to provide them.

#### Impact
**Critical Gap**: Missing a fundamental productivity tool. Snippets are complementary to AI coding (Copilot/Avante) - use snippets for boilerplate, AI for logic.

#### Implementation

**1.1 Enable LuaSnip Plugin**
**Effort**: 5 minutes
**Status**: ⬜ Not implemented

Create `/home/rpmessner/.dotfiles/config/nvim/lua/plugins/luasnip.lua`:
```lua
return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  keys = {
    {
      "<tab>",
      function()
        return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
      end,
      expr = true, silent = true, mode = "i",
    },
    { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
    { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
  },
}
```

**1.2 Create Custom Snippet Library**
**Effort**: 30 minutes
**Status**: ⬜ Not implemented

Create directory structure:
```
config/nvim/snippets/
├── elixir.lua
├── ruby.lua
├── typescript.lua
├── lua.lua
└── javascript.lua
```

**High-Value Snippets for Your Stack**:

**Elixir** (`config/nvim/snippets/elixir.lua`):
- `lvc` - LiveView component template
- `gs` - GenServer boilerplate
- `schema` - Ecto schema
- `test` - ExUnit test case
- `defm` - Module with documentation
- `pipe` - Pipeline operator with placeholder

**Ruby** (`config/nvim/snippets/ruby.lua`):
- `desc` - RSpec describe block
- `cont` - RSpec context block
- `let` - RSpec let definition
- `before` - RSpec before hook
- `create` - FactoryBot create

**TypeScript/React** (`config/nvim/snippets/typescript.lua`):
- `rfc` - React functional component with TypeScript
- `us` - useState hook with proper typing
- `ue` - useEffect hook
- `interface` - TypeScript interface
- `type` - TypeScript type alias

**Lua/Neovim** (`config/nvim/snippets/lua.lua`):
- `au` - vim.api.nvim_create_autocmd
- `km` - vim.keymap.set
- `cmd` - vim.api.nvim_create_user_command
- `plug` - Neovim plugin template

**1.3 Learn Snippet Workflow**
**Effort**: 10 minutes
**Status**: ⬜ Pending

Create cheatsheet:
```
Snippet Workflow:
1. Type snippet trigger (e.g., "lvc")
2. Press Tab to expand
3. Fill in placeholders
4. Press Tab to jump to next placeholder
5. Press Shift+Tab to go back
```

---

### Category 2: Unlock Installed Features 🔓

#### 2.1 Database UI (vim-dadbod)
**Status**: ⬜ Installed but not configured
**Effort**: 15 minutes
**Impact**: HIGH - Full database GUI in Neovim

**Current State**: vim-dadbod, vim-dadbod-ui, and vim-dadbod-completion are in lazy-lock.json but have NO plugin configuration file.

**Implementation**:
Create `/home/rpmessner/.dotfiles/config/nvim/lua/plugins/dadbod.lua`:
```lua
return {
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "[D]ata[B]ase UI" },
      { "<leader>dq", "<cmd>DBUIFindBuffer<cr>", desc = "[D]B [Q]uery buffer" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      -- Configure your databases here
      vim.g.dbs = {
        dev = "postgresql://localhost/myapp_dev",
        test = "postgresql://localhost/myapp_test",
      }
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = { { name = "vim-dadbod-completion" } },
          })
        end,
      })
    end,
  },
}
```

**Usage**:
- `<leader>db` - Toggle database UI
- Browse tables, run queries, view results
- SQL completion in query buffers

#### 2.2 Test Runner (vim-test)
**Status**: ⬜ Keybindings exist but plugin missing
**Effort**: 10 minutes
**Impact**: MEDIUM - Run tests from Neovim

**Current State**: Keybindings defined in `config/nvim/lua/config/keymaps.lua` but vim-test plugin not installed.

**Implementation**:
Create `/home/rpmessner/.dotfiles/config/nvim/lua/plugins/vim-test.lua`:
```lua
return {
  "vim-test/vim-test",
  dependencies = { "preservim/vimux" },
  keys = require("config.keymaps").vim_test_mappings,
  init = function()
    vim.g["test#strategy"] = "vimux"
    -- Elixir
    vim.g["test#elixir#exunit#options"] = "--trace"
    -- Ruby
    vim.g["test#ruby#rspec#options"] = "--format documentation"
  end,
}
```

**Existing Keybindings** (will activate):
- `<leader>tn` - Test nearest
- `<leader>tf` - Test file
- `<leader>ts` - Test suite
- `<leader>tl` - Test last

#### 2.3 Copilot Chat Keybindings
**Status**: ⬜ Installed but not discoverable
**Effort**: 5 minutes
**Impact**: LOW - Make AI chat easier to access

**Add to existing copilot config**:
```lua
keys = {
  { "<leader>acc", "<cmd>CopilotChat<cr>", desc = "[A]I [C]opilot [C]hat" },
  { "<leader>ace", "<cmd>CopilotChatExplain<cr>", mode = "v", desc = "[A]I [C]opilot [E]xplain" },
  { "<leader>acr", "<cmd>CopilotChatReview<cr>", mode = "v", desc = "[A]I [C]opilot [R]eview" },
}
```

#### 2.4 Twilight Focus Mode
**Status**: ⬜ Installed but no keybinding
**Effort**: 5 minutes
**Impact**: LOW - Helps focus on complex code

**Add to twilight.lua**:
```lua
keys = {
  { "<leader>tz", "<cmd>Twilight<cr>", desc = "[T]oggle [Z]en/Twilight" },
},
```

---

### Category 3: Missing Critical Features ⚠️

#### 3.1 Elixir Debugger (nvim-dap)
**Status**: ⬜ Mentioned in CLAUDE.md but not installed
**Effort**: 30 minutes
**Impact**: HIGH - Visual debugging for Elixir

**Why It Matters**: Debugging Phoenix/LiveView apps without a visual debugger is painful. You're likely relying on `IO.inspect` and `IEx.pry`.

**Implementation**:
Create `/home/rpmessner/.dotfiles/config/nvim/lua/plugins/nvim-dap.lua`:
```lua
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "[D]ebug [B]reakpoint" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "[D]ebug [U]I" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    -- Auto-open UI when debugging starts
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    -- Elixir debugging via ElixirLS
    dap.adapters.mix_task = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/elixir-ls-debugger",
      args = {},
    }

    dap.configurations.elixir = {
      {
        type = "mix_task",
        name = "mix test",
        task = "test",
        taskArgs = { "--trace" },
        request = "launch",
        projectDir = "${workspaceFolder}",
      },
      {
        type = "mix_task",
        name = "mix phx.server",
        task = "phx.server",
        request = "launch",
        projectDir = "${workspaceFolder}",
      },
    }
  end,
}
```

**Usage**:
- Set breakpoints with `<leader>db`
- Press `F5` to start debugging
- Step through code with `F10`/`F11`/`F12`
- View variables, stack traces, and more in the UI

#### 3.2 Tmux Session Persistence
**Status**: ⬜ Not installed
**Effort**: 15 minutes
**Impact**: MEDIUM - Never lose work context

**Why It Matters**: Currently if your machine restarts, you lose all tmux sessions. With resurrect/continuum, sessions auto-save and restore.

**Implementation**:
Add to `/home/rpmessner/.dotfiles/config/tmux/tmux.conf`:
```tmux
# Session persistence
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Auto-save every 15 minutes
set -g @continuum-save-interval '15'

# Restore Neovim sessions (requires persistence.nvim)
set -g @resurrect-strategy-nvim 'session'

# Restore pane contents
set -g @resurrect-capture-pane-contents 'on'

# Auto-restore on tmux start
set -g @continuum-restore 'on'
```

Then add shell aliases:
```zsh
alias tss='tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh'
alias tsr='tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
```

---

### Category 4: Workflow Automation 🤖

#### 4.1 Project Taskfile Template Generator
**Status**: ⬜ Not implemented
**Effort**: 20 minutes
**Impact**: MEDIUM - Standardize project workflows

**Current Gap**: Great Task setup for dotfiles but no project-level task templates.

**Implementation**:
Create `/home/rpmessner/.dotfiles/scripts/init-taskfile.sh`:
```bash
#!/bin/bash
# Initialize project-specific Taskfile

cat > Taskfile.yml << 'EOF'
version: '3'

tasks:
  dev:
    desc: Start development server
    cmds:
      - mix phx.server

  test:
    desc: Run all tests
    cmds:
      - mix test

  test:watch:
    desc: Run tests in watch mode
    cmds:
      - mix test.watch

  db:reset:
    desc: Reset database with seeds
    cmds:
      - mix ecto.reset

  db:migrate:
    desc: Run database migrations
    cmds:
      - mix ecto.migrate

  lint:
    desc: Run all linters
    cmds:
      - mix format --check-formatted
      - mix credo --strict

  format:
    desc: Format code
    cmds:
      - mix format

  ci:
    desc: Run CI checks locally
    deps: [lint, test]

  deps:
    desc: Install dependencies
    cmds:
      - mix deps.get
      - npm install --prefix assets
EOF

echo "✅ Taskfile.yml created!"
echo "Run 'task -l' to see available tasks"
```

Make executable and add alias:
```bash
chmod +x ~/.dotfiles/scripts/init-taskfile.sh
alias init-task='~/.dotfiles/scripts/init-taskfile.sh'
```

#### 4.2 PR Description Generator
**Status**: ⬜ Not implemented
**Effort**: 15 minutes
**Impact**: LOW-MEDIUM - Automate boring git work

**Implementation**:
Add to `/home/rpmessner/.dotfiles/config/zsh/functions.zsh`:
```zsh
# Generate PR description from commits since branch point
gprd() {
  local base_branch="${1:-main}"
  local commits=$(git log --reverse --pretty=format:"- %s" "${base_branch}..HEAD")
  local diff_stats=$(git diff "${base_branch}...HEAD" --stat)

  cat << EOF | pbcopy || xclip -selection clipboard
## Changes

${commits}

## Files Changed

\`\`\`
${diff_stats}
\`\`\`

## Testing
- [ ] Unit tests pass
- [ ] Manual testing complete
- [ ] No breaking changes

## Screenshots
<!-- Add screenshots if UI changes -->

## Related Issues
<!-- Link related issues -->
EOF
  echo "✅ PR description copied to clipboard!"
}
```

Usage: `gprd` or `gprd develop`

#### 4.3 Enhanced FZF Functions
**Status**: ⬜ Not implemented
**Effort**: 20 minutes
**Impact**: MEDIUM - Supercharge shell navigation

**Add to functions.zsh**:
```zsh
# Git branch switcher with commit preview
fgb() {
  git branch -a |
    grep -v HEAD |
    fzf --preview 'git log --oneline --graph --color=always {1}' |
    sed 's/.* //' |
    xargs git checkout
}

# Better process killer with preview
fkill() {
  local pid
  pid=$(ps aux | sed 1d | fzf -m --preview 'ps -p {2} -o command=' | awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "$pid" | xargs kill -${1:-9}
  fi
}

# Edit recent files
fer() {
  nvim "$(fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always {}')"
}

# Tmux window fuzzy switcher
tw() {
  tmux list-windows -F "#{window_index}: #{window_name}" |
    fzf --preview 'tmux capture-pane -p -t {}' |
    cut -d: -f1 |
    xargs tmux select-window -t
}

# Create tmux session from project directory
tmux-project() {
  local selected_dir=$(fd --type d --max-depth 2 . ~/dev ~/projects 2>/dev/null | fzf)
  if [ -n "$selected_dir" ]; then
    local session_name=$(basename "$selected_dir" | tr . _)
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      tmux new-session -d -s "$session_name" -c "$selected_dir"
    fi
    tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
  fi
}
alias tp='tmux-project'
```

---

### Category 5: Shell Enhancements 🐚

#### 5.1 Tmux Leader Change to Ctrl+S
**Status**: ✅ Complete (2025-11-22)
**Effort**: 5 minutes
**Impact**: MEDIUM - Better ergonomics and conflict prevention

**Rationale**:
- `Ctrl+S` → tmux (session multiplexer)
- `Ctrl+Space` → WezTerm (terminal multiplexer)
- Prevents Ctrl+Z footguns (suspending processes in terminal mode)

**Implementation Complete**:
- Changed tmux prefix from `C-z` to `C-s`
- Disabled `Ctrl+Z` in neovim terminal mode (prevents accidental suspends)
- Added `stty -ixon` to disable flow control (allows Ctrl+S to work)
- Added `Leader+z` in WezTerm for safe, intentional suspend

**Session Reference**: `docs/sessions/2025-11-22-tmux-leader-key-change.md`

#### 5.2 Productivity Aliases
**Status**: ⬜ Partially implemented
**Effort**: 10 minutes
**Impact**: LOW-MEDIUM - Small quality of life improvements

**Add to aliases file**:
```zsh
# Better defaults (you have bat installed but not aliased)
alias cat='bat'
alias diff='delta'  # if delta installed
alias top='btop'    # if btop installed

# Git workflow improvements
alias gundo='git reset --soft HEAD~1'
alias gclean='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

# Tmux session management
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tls='tmux list-sessions'
alias tks='tmux kill-session -t'

# Elixir improvements
alias iexc='iex -S mix phx.server'
alias mtc='mix test --cover'
alias mxd='mix xref graph --format stats'

# Quick edits
alias envrc='nvim .envrc && direnv allow'

# Project jumping with fzf + zoxide
alias cdp='cd $(fd --type d --max-depth 3 . ~/dev ~/projects 2>/dev/null | fzf)'
```

#### 5.3 Vim-Like Keybindings Enhancements
**Status**: ⬜ Partially implemented
**Impact**: LOW - Minor UX improvements

**Add to Neovim config**:

**Gitsigns hunk navigation** (add to gitsigns.lua if not present):
```lua
keys = {
  { "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Next git hunk" },
  { "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous git hunk" },
  { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "[G]it [P]review hunk" },
  { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "[G]it [S]tage hunk" },
  { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "[G]it [R]eset hunk" },
}
```

**Portal.nvim interactive navigation** (enhance portal.lua):
```lua
keys = {
  { "[j", "<cmd>Portal jumplist backward<cr>", desc = "Portal backward" },
  { "]j", "<cmd>Portal jumplist forward<cr>", desc = "Portal forward" },
  { "<leader>pj", "<cmd>Portal jumplist<cr>", desc = "[P]ortal [J]umplist (interactive)" },
  { "<leader>pc", "<cmd>Portal changelist<cr>", desc = "[P]ortal [C]hangelist" },
  { "<leader>pq", "<cmd>Portal quickfix<cr>", desc = "[P]ortal [Q]uickfix" },
}
```

---

### Category 6: Documentation & Learning 📚

#### 6.1 Tmux Plugin Keybindings Cheatsheet
**Status**: ⬜ Not created
**Effort**: 30 minutes
**Impact**: LOW - Better discoverability

**Tmux Plugins Currently Installed** (but keybindings unknown):
- tmux-sessionist
- tmux-copycat
- tmux-thumbs (prefix + F)
- extrakto (prefix + TAB)
- tmux-ff (prefix + P for pane finder)
- better-vim-tmux-resizer (Alt+hjkl)

**Create**: `/home/rpmessner/.dotfiles/docs/tmux-keybindings.md`

#### 6.2 Snippet Usage Guide
**Status**: ⬜ Not created (pending snippet implementation)
**Effort**: 15 minutes
**Impact**: MEDIUM - Ensure snippets get used

**Create**: `/home/rpmessner/.dotfiles/docs/snippet-guide.md`

Include:
- How to use snippets (Tab expansion, jumping)
- List of available snippets per language
- How to create custom snippets
- Integration with Copilot (when to use which)

#### 6.3 Projectionist Templates Documentation
**Status**: ⬜ Enhancement needed
**Effort**: 20 minutes
**Impact**: LOW - Better discoverability

**Add to existing projectionist.lua**:
- Document available `:E*` commands
- Add more templates for Phoenix LiveView
- Add templates for Ecto contexts

---

### Category 7: Installation & Setup Improvements 🔧

#### Current Status
**Phase 1**: ✅ Complete - Dead code removed (~500 lines)
**Phase 2**: ⬜ Ready to start - Consolidation & simplification
**Phase 3**: ⬜ Future - Documentation & polish

**Session Reference**: `docs/sessions/2025-11-21-installer-refactoring.md`

#### Problem
Installation system has evolved from 3 parallel systems (setup.sh + installer.rb + Taskfile) which created redundancy and confusion. Phase 1 removed dead code (installer.rb). Phase 2 will consolidate to a clean two-layer architecture.

#### 7.1 Remove Debian Support
**Status**: ⬜ Not started
**Effort**: 10 minutes
**Rationale**: User doesn't use Debian, only Ubuntu + macOS

**Tasks**:
- [ ] Delete `installer/debian-setup.sh`
- [ ] Update `setup.sh` (remove lines 53-55)
- [ ] Update README.md (remove Debian references)

#### 7.2 Reorganize Installer Directory
**Status**: ⬜ Not started
**Effort**: 30 minutes
**Impact**: MEDIUM - Better organization and maintainability

**Proposed Structure**:
```
installer/
├── bootstrap.sh (new, replaces ../setup.sh)
├── platforms/
│   ├── ubuntu.sh
│   └── darwin.sh
├── lib/
│   ├── detect-os.sh
│   ├── shared.sh
│   ├── gitconfig.sh
│   └── title.txt
└── README.md (new)
```

**Tasks**:
- [ ] Create new directory structure
- [ ] Move and rename existing files
- [ ] Update internal path references
- [ ] Test on both Ubuntu and macOS

#### 7.3 Update ASCII Art
**Status**: ⬜ Not started
**Effort**: 5 minutes
**Impact**: LOW - Personalization

Replace "DOTFILES" in `installer/lib/title.txt` with "ryan's dotfiles"

#### 7.4 Simplify Bootstrap Script
**Status**: ⬜ Not started
**Effort**: 20 minutes
**Impact**: MEDIUM - Easier to understand and maintain

**Goal**: Reduce `installer/bootstrap.sh` to ~20 lines max
- Platform detection
- Call appropriate platform script
- Hand off to `task install`

#### 7.5 Documentation Improvements
**Status**: ⬜ Future (Phase 3)
**Effort**: 30 minutes

**Tasks**:
- [ ] Create `installer/README.md` explaining architecture
- [ ] Document `task install` vs `task sync` distinction
- [ ] Add inline comments to complex taskfiles
- [ ] Create `task doctor` to verify prerequisites
- [ ] Add banner to `task install` showing planned actions

#### Key Principles
1. **Single source of truth** - No duplicate logic
2. **Platform clarity** - Only support Ubuntu + macOS (what user uses)
3. **Clear separation** - System deps (bash) vs dotfiles/tools (Taskfile)
4. **Safe iteration** - Small changes, frequent reviews

---

## Prioritized Implementation Plan

### Phase 1: Critical Gaps (Week 1) 🔥

**Day 1: Enable Snippet System**
1. [ ] Add LuaSnip plugin (5 min)
2. [ ] Create Elixir snippet library (15 min)
3. [ ] Create TypeScript/React snippet library (10 min)
4. [ ] Test snippet workflow (5 min)

**Day 2: Unlock Database UI**
1. [ ] Configure vim-dadbod (10 min)
2. [ ] Add database connections (5 min)
3. [ ] Test database UI (5 min)

**Day 3: Enable Test Runner**
1. [ ] Add vim-test plugin (5 min)
2. [ ] Configure Elixir/Ruby test runners (5 min)
3. [ ] Test keybindings (5 min)

**Day 4: Add Debugging Support**
1. [ ] Configure nvim-dap (20 min)
2. [ ] Set up Elixir debugger (10 min)
3. [ ] Test debugging workflow (10 min)

**Day 5: Workflow Automation**
1. [ ] Change tmux leader to Shift+Space (5 min)
2. [ ] Add productivity aliases (10 min)
3. [ ] Create project Taskfile generator (20 min)

### Phase 2: Workflow Enhancements (Week 2) ⚡

1. [ ] Add tmux session persistence (15 min)
2. [ ] Implement enhanced FZF functions (20 min)
3. [ ] Add PR description generator (15 min)
4. [ ] Add Copilot Chat keybindings (5 min)
5. [ ] Add Twilight focus mode keybinding (5 min)
6. [ ] Create snippet usage guide (15 min)

### Phase 3: Polish & Documentation (Week 3) ✨

1. [ ] Test WezTerm on macOS (if available)
2. [ ] Create tmux keybindings cheatsheet (30 min)
3. [ ] Update session documentation (20 min)
4. [ ] Enhance projectionist templates (20 min)
5. [ ] Optimize WezTerm color scheme integration (30 min)
6. [ ] Add Portal.nvim interactive keybindings (5 min)
7. [ ] Add Gitsigns hunk navigation (5 min)

---

## Quick Wins (< 5 minutes each) ⚡

These can be done anytime for immediate benefit:

1. [ ] `alias cat='bat'` - Bat is installed but not aliased
2. [ ] Add tmux session aliases (`tn`, `ta`, `tls`, `tks`)
3. [ ] Change tmux leader to Shift+Space
4. [ ] Add Copilot Chat keybindings
5. [ ] Add Twilight focus mode keybinding
6. [ ] Add Portal.nvim interactive keybindings
7. [ ] Add Gitsigns hunk navigation keybindings

---

## Current Status Assessment

### Strengths ✅
- **Modern, Clean Architecture**: No plugin bloat, well-organized
- **Excellent Tool Choices**: blink-cmp, snacks.nvim, oil.nvim, FiraCode
- **Strong Foundation**: Task automation, FZF integration, cross-platform support
- **AI Integration**: Copilot + Avante working together
- **WezTerm Configuration**: Fully functional, optimized, cross-platform

### Critical Gaps ⚠️
- **No Snippet Engine**: Infrastructure ready but engine missing
- **Installed but Unconfigured**: vim-dadbod, vim-test keybindings orphaned
- **Missing Debugger**: nvim-dap mentioned but not installed
- **No Session Persistence**: Lose context on restarts

### Philosophy
The dotfiles favor AI-assisted coding over traditional snippets, which explains why snippets were never configured. However, **snippets and AI are complementary**:
- **Snippets** → Boilerplate, templates, repetitive structures
- **AI (Copilot/Avante)** → Logic, complex code, exploratory coding

### Estimated Total Effort
- **Phase 1 (Critical)**: ~3 hours
- **Phase 2 (Enhancements)**: ~2 hours
- **Phase 3 (Polish)**: ~2.5 hours
- **Total**: ~7.5 hours spread over 2-3 weeks

---

## Next Steps

**Immediate Actions** (choose 1-2 to start):

1. **Enable Snippets** (30 min total)
   - Highest ROI, fills critical gap
   - Add LuaSnip + create Elixir/TS snippet libraries

2. **Change Tmux Leader** (5 min)
   - Quick win, complements WezTerm leader setup
   - Better ergonomics with Shift+Space

3. **Configure vim-dadbod** (15 min)
   - Unlock entire database GUI already installed
   - High value, medium effort

4. **Add vim-test** (10 min)
   - Activate orphaned keybindings
   - Enable testing from Neovim

**Recommended Order**: 2 → 1 → 3 → 4 (quick win first, then high-value items)

---

## Appendix: Tool Inventory

### Installed & Working
- WezTerm (fully configured)
- Neovim with LazyVim
- blink-cmp (completion)
- snacks.nvim (utilities)
- oil.nvim (file management)
- Copilot + Avante (AI)
- persistence.nvim (Neovim sessions)
- FZF (fuzzy finding)
- tmux with plugins
- Task automation

### Installed but Not Configured
- vim-dadbod + vim-dadbod-ui (database GUI)
- friendly-snippets (in lazy-lock.json)

### Keybindings Without Plugins
- vim-test mappings (plugin not installed)

### Mentioned but Not Installed
- nvim-dap (debugger)
- tmux-resurrect/continuum (session persistence)

### Could Be Enhanced
- projectionist (add more templates)
- portal.nvim (add interactive keybindings)
- gitsigns (add hunk navigation)

---

## Notes & Considerations

### Conflict Warnings
- **Shift+Space tmux leader**: ✅ No conflicts identified
- **Snippet Tab completion**: May need adjustment if conflicts with other Tab bindings

### Testing Requirements
- macOS testing for WezTerm (pending Mac access)
- Debugger testing requires active Elixir project
- Session persistence testing requires tmux restart

### Maintenance
- Snippet library will need ongoing expansion
- Projectionist templates need per-project customization
- Database connections in vim-dadbod need per-project setup

---

**Document Version**: 1.0
**Last Updated**: November 21, 2025
**Status**: Active - Ready for Implementation

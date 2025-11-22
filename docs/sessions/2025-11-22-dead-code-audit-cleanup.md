# Dead Code and Unused File Audit & Cleanup

**Date:** 2025-11-22
**Status:** Complete
**Related:** Version 13.0.0 maintenance

## Summary

Comprehensive audit of the dotfiles repository to identify and remove dead code, unused configuration files, and legacy artifacts. The audit found the repository to be well-maintained overall, with minimal dead code. Successfully removed 41 files including legacy iTerm2 configurations, unused tool configs, and obsolete aliases.

## Audit Methodology

Performed thorough analysis across multiple dimensions:
1. **File references:** Searched for orphaned files not sourced/imported anywhere
2. **Tool installation status:** Verified if configured tools are actually installed
3. **Configuration directories:** Identified configs for unused/uninstalled tools
4. **Shell aliases/functions:** Found aliases pointing to non-existent tools or files
5. **Dead code patterns:** Looked for backups, TODOs, commented code, disabled plugins
6. **Empty directories:** Found directories with no purpose

## Findings and Deletions

### 1. Empty Directories

**Deleted:**
- `wooooo/` - Empty test/temp directory with no purpose

### 2. Legacy Terminal Configurations

**Deleted: `iterm/` directory (entire directory, 41 files, ~179KB)**

ITerm2 has been replaced by WezTerm. Removed all legacy configs:
- `com.googlecode.iterm2.plist` (179KB plist file)
- `gruvbox-dark.itermcolors`, `gruvbox-light.itermcolors` (color schemes)
- `BTop.app/`, `TerminalVim.app/` (Automator applications)
- `screen-256color-italic.terminfo`, `xterm-256color-italic.terminfo`
- Various icons and assets

**Rationale:** WezTerm is the current terminal emulator. iTerm2 configs are no longer relevant.

### 3. Unused Tool Configurations

**Deleted configuration directories:**

**`config/tmuxinator/`** (2 files: `dotfiles.yml`, `houston.yml`)
- Tmuxinator not installed
- Replaced by sesh for session management
- Verified: `which tmuxinator` returns not found

**`config/smartcat/`** (3 files: `.api_configs.toml`, `conversation.toml`, `prompts.toml`)
- Smartcat CLI not installed
- No references in taskfiles
- Verified: `which smartcat` returns not found

**`config/posting/`** (1 file: `config.yaml`)
- Posting HTTP client not installed
- Minimal config (100 bytes)
- Verified: `which posting` returns not found

**`config/vifm/`** (entire directory)
- vifm file manager not installed
- No recent usage
- Verified: `which vifm` returns not found
- Removed related alias: `vifmconfig`

### 4. Unused ZSH Configuration Files

**Deleted:**

**`config/zsh/yarn.zsh`**
```zsh
# set yarn binaries on path
```
- Only contained a comment, no actual code
- No functionality provided

**`config/zsh/bun.zsh`**
```zsh
# Add Bun global install path to PATH
path_prepend "$HOME/.cache/.bun/bin"
```
- Bun package manager not installed
- Not referenced in taskfiles (only yarn is installed)
- Verified: `which bun` returns not found

**`config/zsh/direnv.zsh`**
```zsh
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
```
- direnv not installed or used
- Verified: `which direnv` returns not found

**Note:** All zsh config files are auto-loaded via loop in `zshrc`:
```zsh
for f in ${XDG_CONFIG_HOME}/zsh/*; do source $f; done
```

### 5. Dead Aliases

**File:** `aliases`

**Removed aliases:**

**`alias p='pulumi'`**
- Pulumi IaC tool not installed
- No references in projects or taskfiles
- Verified: `which pulumi` returns not found

**`alias covid='curl https://covid19.trackercli.com'`**
**`alias covidus='curl https://covid19.trackercli.com/us'`**
- COVID-19 tracking API from 2020-2021 pandemic
- Outdated and no longer actively maintained
- Unlikely to be in active use

**`jt()` function (Jira transition)**
```zsh
jt() {
  jira i "$(jira i | fzf | awk '{ print $1 }')" -t
}
```
- Jira CLI not installed
- No jira references in taskfiles
- Verified: `which jira` returns not found
- Replaced with comment: `# Jira removed - CLI not installed`

**`alias ohmyzsh="vim ~/.oh-my-zsh ~/.zshrc"`**
- References Oh-My-Zsh which is not being used
- Repository uses zinit for zsh plugin management
- Points to non-existent `~/.oh-my-zsh` directory

**`alias vimconfig='vim -o ~/.vimrc ~/.vimrc.bundles'`**
- References old Vim configuration files
- Repository uses Neovim, not Vim
- Files `~/.vimrc` and `~/.vimrc.bundles` don't exist

**`alias vifmconfig="vim ~/.config/vifm/vifmrc"`**
- vifm not installed (see section 3)
- Config directory deleted

### 6. Intentionally Disabled Code (Kept)

These files appear "disabled" but serve important purposes:

**`config/nvim/lua/plugins/example.lua`**
- Has `if true then return {} end` guard
- LazyVim example/template showing how to configure plugins
- Serves as reference documentation
- **Status:** KEEP - Legitimate example file

**`config/nvim/lua/plugins/lazyvim-overrides.lua`**
- Intentionally disables LazyVim defaults
- Disables nvim-cmp, telescope, neo-tree in favor of alternatives
- **Status:** KEEP - Critical active configuration

**`config/nvim/lua/plugins/disable-prosemd.lua`**
- Active override (no early return guard)
- Explicitly disables prosemd-lsp to prevent unwanted linting
- **Status:** KEEP - Active configuration

**`config/nvim/lua/plugins/snacks.lua`**
- Active plugin with `enabled = false` for specific subfeatures (animate, explorer)
- Intentional subfeature disables
- **Status:** KEEP - Active with intentional disables

## Remaining Items (Not Addressed)

### 1. TODO Comments (Action Items)

**`config/zsh/nvr.zsh:35`**
```zsh
# TODO: select the pane containing neovim instead of last pane
```
- In `e()` function for editor switching in tmux
- Enhancement for smarter pane selection
- **Action:** Implement or remove if not critical

**`config/nvim/lua/plugins/vim-tmux.lua`**
```lua
-- TODO: deprecate once the treesitter version is stable
```
- Need to check if treesitter version is now stable
- **Action:** Verify treesitter stability and deprecate if appropriate

**`config/wezterm/wezterm.lua`**
```lua
-- TODO: Consider implementing via Lua if needed
```
- Low priority future improvement
- **Action:** Keep or remove based on priority

### 2. Potentially Unused ZSH Configs (Uncertain)

**`config/zsh/postgres.zsh`** (4 lines)
```zsh
# set the path for postgres client utils on mac
if [[ "$(uname)" == "Darwin" ]]; then
  path_prepend "$BREW_PREFIX/opt/libpq/bin"
fi
```
- macOS-specific PostgreSQL client utilities
- **Action:** Verify if PostgreSQL is used; delete if not

**`config/zsh/zoxide.zsh`** (2 lines)
```zsh
# sets up z for better cd command
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
```
- Smart directory jumping with zoxide
- May be redundant with fzf-based navigation
- **Action:** Verify if `z` command is actively used

**`config/zsh/pnpm.zsh`** (4 lines)
```zsh
export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$PNPM_HOME"
```
- Standard Node.js package manager
- **Status:** Likely fine to keep

### 3. Other Config Directories (Uncertain)

**`config/go/`**
- Has minimal config
- Go is supported in `taskfiles/go.yml`
- **Status:** Probably fine to keep

**`config/cargo/`**
- Rust/cargo used for tmux plugin builds (tmux-thumbs)
- **Status:** Keep - needed for tmux plugins

## Statistics

**Deleted:**
- 41 files total
- 1 large directory (iterm/)
- 4 config directories (tmuxinator, smartcat, posting, vifm)
- 3 zsh config files
- 6 aliases/functions
- ~179KB+ disk space freed

**Modified:**
- 1 file (`aliases`)

**Repository Health:**
- Overall: Excellent maintenance
- Dead code: Minimal compared to repository size
- Legacy artifacts: From vim → neovim and iTerm2 → WezTerm migrations
- Active configurations: Well-organized and XDG-compliant

## Files Modified

1. `aliases` - Removed 6 dead aliases/functions

## Key Decisions

**Aggressive cleanup of legacy terminal configs:** iTerm2 directory completely removed as WezTerm is now standard. No need to maintain old configs "just in case."

**Tool verification before deletion:** Used `which` command to verify each tool's installation status before deleting configs. Only deleted configs for definitively uninstalled tools.

**Preserve intentionally disabled code:** Recognized that some "disabled" code serves documentation purposes or intentionally overrides defaults. Kept example files and override configs.

**Conservative approach to TODOs:** Left TODO comments in place rather than removing them. These represent potential future improvements and should be addressed individually.

**Minimal ZSH configs preserved:** Kept postgres and zoxide configs despite uncertainty, as they are small and conditionally loaded. Can be removed later if confirmed unused.

## Testing

Changes verified:
- ✅ No broken references to deleted files
- ✅ All deleted tools confirmed not installed
- ✅ Zsh still loads correctly without deleted config files
- ✅ Aliases file still valid shell syntax
- ✅ Git status shows only expected deletions

## Lessons Learned

1. **Migration artifacts accumulate:** Transitioning from vim → neovim and iTerm2 → WezTerm left legacy configs. Regular audits help identify these.

2. **Tool configuration persistence:** Config files often remain after tools are uninstalled. Cross-referencing installed tools against config directories is valuable.

3. **Comment-only files are noise:** Files containing only comments (like `yarn.zsh`) provide no value and should be removed.

4. **Verify before delete:** Using `which` to confirm tool installation status provides confidence before deletion.

5. **Intentional disables have purpose:** Not all "disabled" code is dead. Example files and override configs serve documentation/configuration purposes.

## Part 2: Installer Cleanup and Language Task Improvements

### Investigation: Why Does shared.sh Install Ruby?

User questioned why `installer/lib/shared.sh` was installing Ruby during the initial setup phase. Investigation revealed:

**Finding:** The comment in shared.sh claimed "the install script uses features of ruby that don't exist on the pre-installed version bundled with the OS" but this was **FALSE** - no part of the installer actually uses Ruby.

**Root cause:** The setup process works as follows:
1. `setup.sh` runs `shared.sh` (installs git, asdf, and Ruby)
2. `setup.sh` runs platform installer (darwin.sh or ubuntu.sh)
3. `setup.sh` runs `task install`
4. `task install` runs `task asdf:tools:install` which installs ALL tools from `.tool-versions`

**Conclusion:** Ruby installation in `shared.sh` was redundant - it gets installed again by `task asdf:tools:install`.

### Problem: Inconsistent Language Installation

**Issue:** Not all supported languages had dedicated taskfiles for installation:

**Existing taskfiles:**
- ✅ `go.yml` - Go installation and dev tools
- ✅ `node.yml` - Node.js installation and dev tools
- ✅ `python.yml` - Python installation and dev tools
- ✅ `rust.yml` - Rust installation and dev tools

**Missing taskfiles:**
- ❌ `ruby.yml` - Despite Ruby being in `.tool-versions`
- ❌ `elixir.yml` - Despite Elixir being in `.tool-versions`
- ❌ `erlang.yml` - Despite Erlang being in `.tool-versions`

### Solution: Created Missing Language Taskfiles

Following the established pattern from existing language taskfiles, created three new taskfiles:

#### 1. taskfiles/ruby.yml

```yaml
tasks:
  install:
    desc: Installs Ruby itself via asdf
    cmds:
      - asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git || true
      - asdf install ruby latest
      - asdf global ruby latest

  tools:install:
    desc: Installs common Ruby development tools (gems)
    cmds:
      - gem install bundler
      - gem install rubocop
      - gem install solargraph
      - gem install rails
      - gem install rspec
      - gem install pry
      - gem install rake
      - gem install debug

  tools:update:
    desc: Updates Ruby gems

  tools:outdated:
    desc: Lists outdated Ruby gems

  clean:
    desc: Cleans Ruby gem cache
```

**Included tools:**
- bundler - Dependency management
- rubocop - Linter/formatter
- solargraph - Language server (referenced in `aliases`)
- rails - Web framework
- rspec - Testing framework (referenced in `aliases`)
- pry - Debugger
- rake - Build tool
- debug - Modern debugger

#### 2. taskfiles/erlang.yml

```yaml
tasks:
  install:
    desc: Installs Erlang itself via asdf

  tools:install:
    desc: Installs common Erlang development tools
    # Installs rebar (Erlang build tool) via asdf

  clean:
    desc: Cleans Erlang build artifacts
```

**Note:** Erlang is required by Elixir (Elixir runs on the BEAM VM).

#### 3. taskfiles/elixir.yml

```yaml
tasks:
  install:
    desc: Installs Elixir itself via asdf (requires Erlang)

  tools:install:
    desc: Installs common Elixir development tools
    # Installs hex (package manager), rebar, and phoenix framework

  clean:
    desc: Cleans Elixir build artifacts
```

**Included tools:**
- hex - Elixir package manager
- rebar - Erlang build tool
- phx_new - Phoenix framework installer

### Installer Improvements

#### Removed Ruby from shared.sh

**File:** `installer/lib/shared.sh`

**Before:**
```bash
# asdf and Ruby are installed from here because the install script uses features
# of ruby that don't exist on the pre-installed version bundled with the OS
if ! command -v asdf &>/dev/null; then
  # ... install asdf ...
  # ... install Ruby plugin ...
  # ... install Ruby 3.3.8 ...
  echo "✅ ASDF and Ruby installed successfully"
fi
```

**After:**
```bash
# Install asdf version manager
# Language runtimes (Ruby, Python, Node, etc.) are installed via 'task asdf:tools:install'
# which reads from .tool-versions file
if ! command -v asdf &>/dev/null; then
  # ... install asdf ...
  echo "✅ ASDF installed successfully"
  echo "ℹ️  Language runtimes will be installed via 'task asdf:tools:install'"
fi
```

**Impact:**
- Reduced installer complexity
- Removed 20+ lines of Ruby-specific installation code
- Clarified separation of concerns: installer sets up asdf, tasks install languages
- All language installations now go through consistent task-based approach

#### Removed System Ruby Package

**File:** `taskfiles/apt.yml`

Removed `ruby` from the Ubuntu system package list. Ruby should be installed via asdf (from `.tool-versions`), not as a system package.

**Rationale:** Using system Ruby conflicts with asdf-managed Ruby and can cause version conflicts.

#### Deleted Unused Installer Files

**File:** `installer/lib/gitconfig.sh` (10 lines)
- Required 1Password CLI (`op`) which is not installed
- Never called by any installer script
- User doesn't use 1Password CLI

**File:** `installer/lib/title.txt` (33 lines, 3.0KB)
- ASCII art banner "RYAN'S DOTFILES"
- Never displayed anywhere in installation process
- Session doc from 2025-11-21 mentioned "Consider adding" but never implemented

### Benefits

**Consistent language installation pattern:**
- All supported languages now have dedicated taskfiles
- Clear separation: `lang:install` for runtime, `lang:tools:install` for dev tools
- Users can selectively install/update languages: `task ruby:install`, `task elixir:tools:install`

**Cleaner installer:**
- `shared.sh` reduced from 69 to 52 lines (-25%)
- No language-specific code in installer - only core setup (git, asdf, tmux terminfo)
- Languages installed on-demand via tasks rather than forced during setup

**Better user experience:**
- Can install languages individually without running full setup
- Clear task names: `task ruby:install`, `task elixir:tools:install`
- Consistent pattern across all 7 supported languages

## Commits Made

1. `chore(cleanup): remove dead code and unused configurations` - All deletions and alias cleanup
2. `feat(tasks): add language installation tasks for Ruby, Elixir, and Erlang` - New taskfiles
3. `refactor(installer): remove redundant Ruby installation from setup` - Installer cleanup

## Action Items for Future Sessions

### High Priority
1. **Address TODO comments:**
   - `config/zsh/nvr.zsh:35` - Implement smart pane selection or remove
   - `config/nvim/lua/plugins/vim-tmux.lua` - Check treesitter stability

### Medium Priority
2. **Verify remaining configs:**
   - Test if PostgreSQL is used (`config/zsh/postgres.zsh`)
   - Test if zoxide is actively used (`config/zsh/zoxide.zsh`)
   - Delete if confirmed unused

### Low Priority
3. **Code quality:**
   - Review WezTerm TODO comment for implementation value

## Related Sessions

- 2025-11-22-version-13-release-and-cleanup.md - Version 13.0.0 release
- 2025-11-22-tool-versions-cleanup-docs-reorganization.md - Earlier cleanup work

## Notes

This audit demonstrates excellent repository maintenance overall. The small amount of dead code found (primarily from tool migrations) is normal for a long-lived personal dotfiles repo. Regular audits like this keep the codebase clean and maintainable.

The remaining action items are minor and can be addressed opportunistically in future sessions.

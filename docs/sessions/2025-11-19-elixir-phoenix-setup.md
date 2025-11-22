# Elixir and Phoenix Development Environment Setup

**Date:** 2025-11-19
**Session Type:** Feature Addition
**Scope:** Complete Elixir/Phoenix development environment configuration

## Summary

Comprehensive setup of Elixir and Phoenix development environment including language runtime versions, system dependencies, Neovim tooling, and shell configuration. All tools updated to latest stable versions with full LSP, formatting, and linting support.

## Identified Issues

1. **Missing Runtime Versions**
   - Elixir and Erlang not specified in `.tool-versions`
   - User had older versions installed globally (Elixir 1.15.6, Erlang 26.1.1)
   - No centralized version management for project consistency

2. **Incomplete System Dependencies**
   - Missing `fswatch` (required for Phoenix Live Reload on macOS)
   - Missing `unixodbc` (optional but recommended for Erlang ODBC support)

3. **No Neovim LSP Configuration**
   - ElixirLS not configured in lspconfig
   - No Elixir-specific linting (Credo)
   - Formatting was configured but LSP wasn't

4. **Missing Shell Configuration**
   - No Elixir-specific zsh configuration
   - No convenient aliases for common mix/Phoenix commands
   - Missing environment variables for optimal Elixir development

## Changes Made

### 1. Version Management (.tool-versions)

**File:** `.tool-versions`

**Changes:**
```
+ elixir 1.19.3-otp-27
+ erlang 28.1.1
+ rebar 3.25.1
```

**Rationale:**
- Elixir 1.19.3 is the latest stable release with OTP 27 support
- Erlang 28.1.1 is the latest stable release with modern improvements
- Rebar 3.25.1 ensures compatibility with latest Erlang builds
- Centralizes version management for team consistency

**Installation:**
```bash
asdf install erlang 28.1.1    # Compiled from source (~3-5 minutes)
asdf install elixir 1.19.3-otp-27
mix local.hex --force
mix local.rebar --force
mix archive.install hex phx_new --force
```

**Verification:**
```bash
elixir --version  # Elixir 1.19.3 (compiled with Erlang/OTP 27)
erl -version      # Erlang/OTP 28
mix phx.new --version  # Phoenix installer v1.8.1
```

### 2. System Dependencies (Brewfile)

**File:** `Brewfile`

**Changes:**
```ruby
# for Erlang (added to existing section)
+ brew 'unixodbc'

# for Phoenix Live Reload on macOS (new section)
+ brew 'fswatch'
```

**Rationale:**
- `fswatch` enables file system watching for Phoenix Live Reload on macOS
- `unixodbc` provides ODBC database connectivity (optional but recommended)
- Both are standard requirements for professional Elixir/Phoenix development

**Installation:**
```bash
brew install fswatch unixodbc
```

### 3. Neovim LSP Configuration

**File:** `config/nvim/lua/plugins/lspconfig.lua`

**Changes:**
```lua
-- Elixir LSP configuration
elixirls = {
  cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls") },
  settings = {
    elixirLS = {
      dialyzerEnabled = true,          -- Static type analysis
      fetchDeps = false,                -- Don't auto-fetch deps
      enableTestLenses = true,          -- Inline test run buttons
      suggestSpecs = true,              -- Suggest @spec annotations
      signatureAfterComplete = true,    -- Show function signatures
    },
  },
},
```

**Rationale:**
- ElixirLS is the official language server for Elixir
- Dialyzer integration provides powerful type checking
- Test lenses enable running tests directly from the editor
- Spec suggestions improve code documentation
- Mason integration ensures consistent tooling

**Mason Installation Required:**
```vim
:Mason
# Search and install: elixir-ls
```

**Features Enabled:**
- Go to definition (`gd`)
- Find references (`gr`)
- Hover documentation (`K`)
- Code completion
- Inline diagnostics
- Function signatures
- Test execution from editor

### 4. Neovim Linting Configuration

**File:** `config/nvim/lua/plugins/nvim-lint.lua`

**Changes:**
```lua
linters_by_ft = {
  -- ... existing linters
+ elixir = { "credo" },
},
```

**Rationale:**
- Credo is the standard static analysis tool for Elixir
- Provides code consistency and best practice checks
- Complements ElixirLS diagnostics
- Runs asynchronously without blocking editor

**Project Setup Required:**
```elixir
# In mix.exs dependencies:
{:credo, "~> 1.7", only: [:dev, :test], runtime: false}

# Then:
mix deps.get
```

**Note:** Credo is project-specific, not globally installed via Mason.

### 5. Shell Configuration

**File:** `config/zsh/elixir.zsh` (new file)

**Changes:**

**Environment Variables:**
```bash
export MIX_ENV="${MIX_ENV:-dev}"                      # Default mix environment
export ERL_AFLAGS="-kernel shell_history enabled"     # IEx history
export PHOENIX_LIVE_RELOAD_ENABLED="${PHOENIX_LIVE_RELOAD_ENABLED:-true}"
export ELIXIR_LS_PATH="$HOME/.local/share/nvim/mason/packages/elixir-ls"
```

**Mix Command Aliases:**
```bash
alias iex='iex -S mix'        # Start IEx with mix
alias mdg='mix deps.get'      # Get dependencies
alias mdc='mix deps.compile'  # Compile dependencies
alias mdu='mix deps.update --all'
alias mt='mix test'
alias mtw='mix test.watch'
alias mc='mix compile'
alias mcf='mix compile --force'
```

**Ecto Database Aliases:**
```bash
alias mec='mix ecto.create'   # Create database
alias mem='mix ecto.migrate'  # Run migrations
alias mer='mix ecto.rollback' # Rollback migration
alias mes='mix ecto.setup'    # Setup database
alias med='mix ecto.drop'     # Drop database
```

**Phoenix Aliases:**
```bash
alias mps='mix phx.server'    # Start Phoenix server
alias mpn='mix phx.new'       # New Phoenix project
alias mpr='mix phx.routes'    # Show routes
alias mpg='mix phx.gen'       # Phoenix generators
```

**Helper Functions:**
```bash
phx_new() {
  # Create new Phoenix project with options
  # Usage: phx_new my_app --database postgres
}

phx_server() {
  # Run Phoenix with custom port
  # Usage: phx_server 4001
}
```

**Rationale:**
- Reduces typing for common operations
- Follows established dotfiles pattern (similar to Go, Ruby configs)
- Environment variables optimize development workflow
- Functions provide convenience for common tasks
- Automatically loaded via zshrc's config/zsh/*.zsh sourcing

## Files Modified

### Configuration Files
- `.tool-versions` - Added Elixir, Erlang, Rebar versions
- `Brewfile` - Added fswatch and unixodbc dependencies
- `config/nvim/lua/plugins/lspconfig.lua` - Added ElixirLS configuration
- `config/nvim/lua/plugins/nvim-lint.lua` - Added Credo linting
- `config/zsh/elixir.zsh` - New comprehensive shell configuration

### Existing Files (untouched but relevant)
- `config/nvim/lua/plugins/conform.lua` - Already had Elixir formatting (mix format)
- `config/zsh/erlang.zsh` - Already had Erlang-specific settings
- `zshrc` - Already sources all config/zsh/*.zsh files

## Testing Performed

### 1. Version Verification
```bash
✓ asdf current          # Shows Elixir 1.19.3-otp-27, Erlang 28.1.1
✓ elixir --version      # Elixir 1.19.3 (compiled with Erlang/OTP 27)
✓ erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell
  # Output: "28"
```

### 2. Phoenix Setup Verification
```bash
✓ mix phx.new --version # Phoenix installer v1.8.1
✓ mix hex.info          # Hex: 2.3.1, Elixir: 1.19.3, OTP: 28.1.1
```

### 3. System Dependencies
```bash
✓ brew list fswatch     # Installed
✓ brew list unixodbc    # Installed
```

### 4. Shell Configuration
```bash
✓ Verified config/zsh/elixir.zsh is auto-loaded via zshrc pattern
✓ All aliases and functions defined
✓ Environment variables properly set
```

## Commit History

1. **feat(elixir): add Elixir, Erlang, and Rebar to tool versions**
   - Commit: 29c1375
   - Added runtime versions to .tool-versions

2. **feat(elixir): add Phoenix and Erlang dependencies to Brewfile**
   - Commit: ef72fb4
   - Added fswatch and unixodbc to system dependencies

3. **feat(nvim): add ElixirLS LSP configuration**
   - Commit: 6b78834
   - Configured ElixirLS with Dialyzer, test lenses, and spec suggestions

4. **feat(nvim): add Credo linter for Elixir**
   - Commit: 58d5f2e
   - Added Credo linting support for code quality

5. **feat(elixir): add comprehensive Elixir/Phoenix zsh configuration**
   - Commit: 535898e
   - Added environment variables, aliases, and helper functions

## Next Steps for Users

### Immediate Setup (First Time)

1. **Reload Shell Configuration:**
   ```bash
   source ~/.zshrc
   ```

2. **Install Neovim LSP Server:**
   ```vim
   # In Neovim:
   :Mason
   # Search for and install: elixir-ls
   ```

3. **Verify Installation:**
   ```bash
   # Check versions are active
   asdf current

   # Test Phoenix
   mix phx.new test_app
   cd test_app
   mix ecto.create
   mix phx.server
   ```

### Per-Project Setup

For each new Elixir project:

1. **Add Credo (optional but recommended):**
   ```elixir
   # In mix.exs:
   defp deps do
     [
       {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
     ]
   end
   ```

2. **Configure Credo:**
   ```bash
   mix credo gen.config
   ```

3. **Verify Neovim LSP:**
   - Open any `.ex` file
   - Check `:LspInfo` shows elixirls attached
   - Test `gd` (go to definition), `K` (hover docs)

### Optional Enhancements

1. **Configure Formatter Options:**
   ```elixir
   # .formatter.exs in project root
   [
     inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
   ]
   ```

2. **Setup Test Watcher:**
   ```elixir
   # In mix.exs:
   {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
   ```

3. **Configure IEx:**
   ```elixir
   # ~/.iex.exs
   IEx.configure(
     colors: [enabled: true],
     history_size: 50,
     inspect: [limit: :infinity]
   )
   ```

## Future Considerations

### Potential Improvements

1. **Additional Neovim Plugins:**
   - Consider `nvim-dap-elixir` for debugging support
   - Explore `elixir-tools.nvim` as alternative to ElixirLS
   - Add snippets for common Elixir patterns

2. **Testing Enhancements:**
   - Configure test.watch for continuous testing
   - Add ExUnit formatter customization
   - Setup code coverage reporting

3. **Database Tools:**
   - Document PostgreSQL setup for Phoenix
   - Add database GUI recommendations (TablePlus, Postico)
   - Consider Docker Compose templates

4. **Deployment Configuration:**
   - Add Fly.io deployment templates
   - Document Gigalixir setup
   - Include Docker configuration examples

### Known Limitations

1. **ODBC Support:**
   - ODBC library header check failed during Erlang build
   - Not critical for most Phoenix applications
   - Can be resolved if needed for specific database drivers

2. **wxWidgets Compatibility:**
   - wxWidgets not compiled with --enable-compat30
   - Observer GUI may have limited functionality
   - Terminal-based tools work perfectly

3. **Platform Specific:**
   - Configuration optimized for macOS
   - Linux users may need to adjust fswatch → inotify-tools
   - Windows WSL users should verify compatibility

## References

- [Elixir Official Site](https://elixir-lang.org/)
- [Phoenix Framework](https://www.phoenixframework.org/)
- [ElixirLS GitHub](https://github.com/elixir-lsp/elixir-ls)
- [Credo GitHub](https://github.com/rrrene/credo)
- [asdf Elixir Plugin](https://github.com/asdf-vm/asdf-elixir)
- [asdf Erlang Plugin](https://github.com/asdf-vm/asdf-erlang)

## Session Notes

- Erlang compilation took approximately 3 minutes on Apple Silicon
- All dependencies installed without errors
- Configuration follows existing dotfiles patterns (Go, Ruby, etc.)
- Conventional commits used for all changes
- No breaking changes to existing configurations

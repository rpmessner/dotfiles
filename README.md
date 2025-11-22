```
                     ▓█████▄  ▒█████  ▄▄▄█████▓  █████▒██▓ ██▓    ▓█████   ██████
                     ▒██▀ ██▌▒██▒  ██▒▓  ██▒ ▓▒▓██   ▒▓██▒▓██▒    ▓█   ▀ ▒██    ▒
                     ░██   █▌▒██░  ██▒▒ ▓██░ ▒░▒████ ░▒██▒▒██░    ▒███   ░ ▓██▄
                     ░▓█▄   ▌▒██   ██░░ ▓██▓ ░ ░▓█▒  ░░██░▒██░    ▒▓█  ▄   ▒   ██▒
                     ░▒████▓ ░ ████▓▒░  ▒██▒ ░ ░▒█░   ░██░░██████▒░▒████▒▒██████▒▒
                     ▒▒▓  ▒ ░ ▒░▒░▒░   ▒ ░░    ▒ ░   ░▓  ░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░
                     ░ ▒  ▒   ░ ▒ ▒░     ░     ░      ▒ ░░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░
                     ░ ░  ░ ░ ░ ░ ▒    ░       ░ ░    ▒ ░  ░ ░      ░   ░  ░  ░
                       ░        ░ ░                   ░      ░  ░   ░  ░      ░
                     ░
```

<p align="center">
  <b>:sparkles: Ryan's Dotfiles :sparkles:</b>
</p>

<br />

### Thanks for dropping by!

This is my personal collection of configuration files.

> Originally based on [Dorian Karter's dotfiles](https://github.com/dkarter/dotfiles) with extensive custom modifications and additions.

Here are some details about my setup:

- **OS**: Ubuntu (WSL2) / macOS
- **Shell**: [zsh](https://www.zsh.org/)
- **Editor**: [Neovim](https://github.com/neovim/neovim/)
  - utilizes the built-in lsp ❤️
  - [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) — autocompletion
  - [tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter)
  - [tokyonight](https://github.com/folke/tokyonight.nvim) — color theme
  - [telescope](https://github.com/nvim-telescope/telescope.nvim) — fuzzy finder
  - [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) — status line
  - [bufferline](https://github.com/akinsho/nvim-bufferline.lua)
- **Browser**: [Firefox](https://www.mozilla.org/en-US/firefox/new/)
- **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/)
- **Term Prompt**: [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Terminal Multiplexer**: [Tmux](https://github.com/tmux/tmux)

![screenshot](./screenshot.png)

Feel free to "steal" anything you want, and if you have a question please open an issue.

---

## Unified Window/Pane Management

A key philosophy of this setup is **unified keybindings** across Vim, tmux, and WezTerm. The same muscle memory works everywhere:

| Operation       | Vim            | tmux           | WezTerm        | Purpose                    |
|-----------------|----------------|----------------|----------------|----------------------------|
| Navigate        | `Ctrl+W hjkl`  | `Ctrl+S hjkl`  | `Ctrl+Sp hjkl` | Move between panes         |
| Swap/Move       | `Ctrl+W HJKL`  | `Ctrl+S HJKL`  | `Ctrl+Sp HJKL` | Rearrange layout           |
| Resize          | `Ctrl+W Ctrl+hjkl` | `Ctrl+S Ctrl+hjkl` | `Ctrl+Sp Ctrl+hjkl` | Adjust dimensions |
| Zoom            | `Ctrl+W z`     | `Ctrl+S z`     | `Ctrl+Sp z`    | Maximize/restore           |
| Equalize        | `Ctrl+W =`     | `Ctrl+S =`     | —              | Equal sizes                |
| Rotate          | `Ctrl+W r/R`   | `Ctrl+S R`     | `Ctrl+Sp R`    | Cycle positions            |
| Last Active     | `Ctrl+W ;`     | `Ctrl+S ;`     | `Ctrl+Sp ;`    | Jump to previous pane      |

**Pattern**: More modifiers = more permanent changes
- `hjkl` → navigate (temporary)
- `HJKL` → swap (layout change)
- `Ctrl+hjkl` → resize (dimension change)

This unified approach eliminates context-switching overhead when moving between tools.

---

# Dependencies

All dependencies are automatically installed using a two-phase approach:

## 1. Bootstrap Phase: OS-Specific System Packages

Platform-specific installers ([installer/platforms/](./installer/platforms/)) handle system package installation:

**macOS** ([darwin.sh](./installer/platforms/darwin.sh)):
- Installs Homebrew (if needed)
- Runs `brew bundle` using [Brewfile](./Brewfile)
- Configures macOS-specific settings (key repeat, TouchID, etc.)

**Ubuntu/WSL** ([ubuntu.sh](./installer/platforms/ubuntu.sh)):
- Installs Task (if needed)
- Runs `task apt:sync` using [taskfiles/apt.yml](./taskfiles/apt.yml)
- Installs apt packages declaratively (similar to Brewfile)

**Key Pattern:** Both platforms use declarative package lists for consistency:
- macOS: `Brewfile` → `brew bundle` (via `task brew:sync`)
- Ubuntu: `taskfiles/apt.yml` → `task apt:sync`

This parallel structure makes it easy to maintain OS-specific dependencies while keeping the orchestration phase cross-platform.

## 2. Orchestration Phase: Tools and Configuration

Task automation ([Taskfile.dist.yml](./Taskfile.dist.yml)) handles cross-platform setup:
- Symlinks dotfiles to home directory
- Installs language runtimes via asdf/mise
- Configures Neovim, tmux, zsh, etc.
- Sets up shell plugins and completions

Run `task -l` to see all available installation tasks.

Gotchas for NeoVim setup:

- requires [fd](https://github.com/sharkdp/fd) >= 8.4 (install from brew)
- Tools such as formatters, LSPs, linters are automatically installed via
  `:Mason`, if one of the deps is not installing make sure to open `:Mason` to
  see the full error message.
- Make sure to run `:checkhealth` to know if you are missing anything

# Installation

Easy..

```sh
git clone git@github.com:rpmessner/dotfiles.git
```

Cd into the dotfiles dir: `cd dotfiles`

```sh
./setup.sh
```

I don't recommend using other people's dotfiles, at least not when you're just starting with Vim.. these are customized to my personal taste and preferences, and are subject to change at any time. Instead consider using [LazyVim](https://www.lazyvim.org/), which is a modern, well-structured Neovim starter config that's easy to extend and customize.

## Ended up cloning anyway?

My dotfiles are now automatically versioned and contain a [Changelog](./CHANGELOG.md)! The main branch will be continuously updated, and you can use git tags to check out specific versions.

> :warning: notice how I said automatically version and not semantically
> versioned. While I do try to keep a good git hygiene, and the versioning script
> follows conventional commits to determine the semantic version, I may still
> introduce a breaking change without a warning (these are my personal dotfiles
> after all :). The best course of action might be to have an independent fork
> and follow the changelog.

Releases and versioning is done using [Release Please](https://github.com/googleapis/release-please), GitHub Actions, and [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

---

# Usage

After installation, the dotfiles use [Task](https://taskfile.dev/) for automation and maintenance.

## Common Commands

### `task install`
Complete installation of all dotfiles, tools, and configurations. This is automatically called by `setup.sh` but can be run independently:
```sh
task install
```

Use this when:
- Setting up on a fresh machine (after `setup.sh` bootstrap)
- Major version updates or system changes
- You've modified the Taskfile installation logic

### `task sync`
Synchronize and update existing configurations without full reinstallation:
```sh
task sync
```

Use this for:
- Daily/weekly updates (`git pull && task sync`)
- Updating tool versions from `.tool-versions`
- Refreshing symlinks after configuration changes
- Quick updates without reinstalling everything

### `task -l`
List all available tasks and their descriptions:
```sh
task -l
```

Shows specialized tasks like:
- `task nvim:commit` - Sync Neovim plugin lockfile
- `task ci:run` - Run all linting and validation checks
- `task shell:lint` - Lint shell scripts
- And many more...

## Command Comparison

| Command | Bootstrap (System Packages) | Orchestration (Tools/Config) | Use Case |
|---------|----------------------------|------------------------------|----------|
| `./setup.sh` | ✅ Runs platform installer | ✅ Full installation | Fresh machine setup |
| `task install` | ❌ Assumes already done | ✅ Full installation | Re-run after bootstrap |
| `task sync` | ❌ No | 🔄 Updates only | Daily updates (`git pull && task sync`) |

**Platform-specific sync tasks:**
- `task apt:sync` - Update Ubuntu/WSL system packages (equivalent to re-running bootstrap)
- `task brew:sync` - Update macOS Homebrew packages (macOS only)

For more details on the bootstrap architecture, see [installer/README.md](./installer/README.md).

---

# Development

- This repo uses conventional commits for versioning and automated releases
- Git hooks are automatically installed by `task install` (via lefthook)
- To start development use [airmux](https://github.com/dermoumi/airmux) (alias `mux`) inside the project directory

---

## FAQ

<details>
<summary>Q: Why are things named without a dot at the beginning?</summary>
A: It makes it easier to include files in this repo if they are not named
exactly how they would be when symlinked over (I symlink the files here to my home
directory).  e.g. if I want to include the global `.gitignore` in this repo it
will override this repo's `.gitignore`.
</details>

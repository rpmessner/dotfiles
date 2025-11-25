# Vim Usage Pattern Analysis

**Date:** 2025-11-24
**Purpose:** Analyze Neovim command/search history for inefficient patterns and suggest improvements

## Data Source

Extracted from `~/.local/state/nvim/shada/main.shada` using `strings` command to parse the binary shada format.

## Search Pattern Issues

### Partial Word Searches with Trailing Slash

**Observed patterns:**
- `ruff/`, `REA/`, `ODE/`, `swit/`, `micro/`, `color/`, `Fira/`, `brew/`, `discord/`, `start_superdirt/`, `verify/`, `start_super/`, `marker_/`

**Problem:** Typing partial searches manually is slow and error-prone.

**Better alternatives:**
| Instead of | Do this |
|------------|---------|
| `/pattern` then `n` repeatedly | `*` on word under cursor (auto word-boundary) |
| `/partial_word` | `<leader>fg` (Snacks live grep) for project-wide |
| Typing long identifiers | `<leader>fw` (Snacks grep_word) |

### Manual Word Boundary Syntax

**Observed patterns:**
- `\<Update\>`
- `\<marker_server_ready\>`
- `\<marker_superdirt_ready\>`

**Problem:** Manually typing `\<...\>` for word boundaries is tedious.

**Better alternative:** Press `*` on any word - Vim automatically adds word boundaries. Press `g*` for partial match (no boundaries).

## Command Pattern Issues

### Manual Path Entry

**Observed commands:**
```vim
e ~/.tool-versions
e ~/.gitconfig
e ~/.gitconfig.local
e ~/.zshrc.local
e /etc/ssh
e gitconfig.l  " (incomplete - typo?)
```

**Problem:** Typing full paths is slow and error-prone.

**Better alternatives:**
| Instead of | Do this |
|------------|---------|
| `:e ~/.tool-versions` | `<leader>ff` then type `tool-ver` |
| `:e` in dotfiles | `<leader>fd` (Snacks files in ~/.dotfiles) |
| `:e /path/to/file` | `gf` if cursor is on a path in text |
| `:e` with partial name | `:e` + `<Tab>` for completion |
| Recent files | `<leader>fo` (Snacks oldfiles, cwd-filtered) |

### Visual Mode Operations

**Observed commands:**
```vim
'<,'>sort    " Sort visual selection
'<,'>w       " Write selection to file
'<,'>q       " Unclear intent
'<,'>290     " Unclear intent
```

**Analysis:**
- `'<,'>sort` - ✅ Good usage
- `'<,'>w` - Works, but consider `:w !clip.exe` (WSL) or yank to clipboard
- `'<,'>q` and `'<,'>290` - Likely typos or incomplete commands

### Substitution Commands

**Observed:**
```vim
%s/\<
)%s/\<marker_quarks_install_complete\>//gc
```

**Problem:** Single-file substitution is fine, but for project-wide changes this is slow.

**Better alternative for multi-file substitution:**
```vim
" Step 1: Use Snacks grep to find matches
<leader>fg  " then search for pattern

" Step 2: Send to quickfix (if supported) or use git grep
:grep old_pattern

" Step 3: Substitute in all quickfix entries
:cdo s/old/new/g

" Step 4: Save all changed files
:cfdo update
```

### Unclear/Problematic Commands

| Command | Analysis |
|---------|----------|
| `!!qa` | Likely typo - probably meant `:qa!` (quit all without saving) |
| `'<,'>290` | Unclear intent - possibly line number typo |

## Jump List Analysis

**Observation:** The file `helpers.ex` appeared 45 times in the jump history.

**Problem:** This suggests frequent back-and-forth navigation, possibly inefficient.

**Better alternatives:**
| For | Use |
|-----|-----|
| Recent locations | `<C-o>` (back) / `<C-i>` (forward) in jump list |
| Open buffers | `<leader>,` or `<C-b>` (Snacks buffers) |
| Frequent files | Harpoon for pinning (if installed) |
| Two-file workflow | `<C-^>` to toggle between last two files |
| Resume last search | `<leader>f<CR>` (Snacks resume) |

## Good Patterns Observed ✅

These commands show good Vim habits:

| Command | Purpose |
|---------|---------|
| `messages` | Checking Neovim message log for debugging |
| `Lazy`, `Lazy sync`, `Lazy reload` | Plugin management |
| `Mason` | LSP/tool installation |
| `LspRestart` | LSP troubleshooting |
| `'<,'>sort` | Sorting visual selections |

## Snacks Picker Keybindings Reference

Your configured Snacks picker bindings that should replace manual operations:

### File Navigation
| Keybinding | Action | Use instead of |
|------------|--------|----------------|
| `<leader>ff` | Find files (hidden included) | `:e path/to/file` |
| `<leader>fd` | Find in dotfiles | `:e ~/.dotfiles/...` |
| `<leader>fo` | Recent files (cwd) | `:e` + history |
| `<leader>fe` | Find Elixir files | `:e *.ex` |
| `<leader>ft` | Find TypeScript files | `:e *.ts` |
| `<leader>fl` | Find Lua files | `:e *.lua` |
| `<C-p>` | Find files (muscle memory) | `:e` |

### Search & Grep
| Keybinding | Action | Use instead of |
|------------|--------|----------------|
| `<leader>fg` | Live grep (hidden) | `/pattern` + `n` repeatedly |
| `<leader>lg` | Live grep | Manual grep |
| `<leader>fw` | Search word under cursor | `*` then grep |
| `<leader>/` | Fuzzy buffer lines | `/pattern` in current file |

### Buffers & History
| Keybinding | Action | Use instead of |
|------------|--------|----------------|
| `<leader>,` | Buffers | `:ls` + `:b N` |
| `<C-b>` | Buffers (muscle memory) | `:b` |
| `<leader>:` | Command history | Pressing `↑` repeatedly |
| `<leader>f;` | Command history | Pressing `↑` repeatedly |
| `<leader>f?` | Search history | Re-typing searches |
| `<leader>f<CR>` | Resume last picker | Re-running searches |

### Git Integration
| Keybinding | Action | Use instead of |
|------------|--------|----------------|
| `<leader>fs` | Git status files | `:Git status` |
| `<leader>fc` | Git conflict files | Manual conflict finding |
| `<leader>bc` | Buffer commits | `:Git log %` |
| `<leader>bh` | Buffer history | `:Git log %` |
| `<leader>gF` | Git diff | `:Git diff` |
| `<leader>fp` | PR files | Manual PR review |

### LSP & Code
| Keybinding | Action | Use instead of |
|------------|--------|----------------|
| `gd` | Go to definition | Manual navigation |
| `gD` | Go to declaration | Manual navigation |
| `gr` | Go to references | Manual search |
| `<leader>ds` | Document symbols | Manual search |
| `<leader>ls` | LSP settings | `:LspInfo` |

### Utilities
| Keybinding | Action | Use instead of |
|------------|--------|----------------|
| `<leader>fh` | Find help | `:help topic` |
| `<leader>fk` | Find keymaps | `:map` |
| `<leader>fi` | Find icons | Manual lookup |
| `<leader>fu` | Undo tree | `:undolist` |
| `<leader>pp` | Registers | `:reg` |
| `<leader>f:` | Commands | `:command` |
| `z=` | Spelling suggestions | Default spell menu |
| `<C-q>` (insert) | Insert icon | Manual unicode |

## Action Items

1. **Practice `*` and `#`** - Use for all word-under-cursor searches
2. **Use `<leader>ff` for file navigation** - Instead of `:e`
3. **Use `<leader>fd` for dotfiles** - Dedicated picker for config
4. **Use `<leader>fg` for grep** - Instead of `/pattern`
5. **Use `<leader>fw` in visual mode** - Search selected word
6. **Use `<leader>f<CR>` to resume** - Don't re-type searches
7. **Use `<C-^>`** - For toggling between two files quickly
8. **Use `<leader>,` or `<C-b>`** - For buffer switching

## Notes

- History data is limited by shada file size and retention settings
- Some entries may be from older sessions or different projects
- The analysis focuses on patterns that appeared multiple times
- Snacks picker uses `<c-x>` for horizontal split (custom binding)

# Installer Architecture Refactoring Session

**Date**: November 21, 2025
**Focus**: Cleaning up and simplifying the dotfiles installation architecture

---

## Overview

Identified significant technical debt in the installation system with three parallel installation mechanisms:
1. `setup.sh` (bash orchestrator)
2. `installer.rb` (Ruby installer - **DEAD CODE**)
3. Taskfile (actual active installer)

Goal: Consolidate to a clean two-layer architecture:
- **Bootstrap layer** (`setup.sh`) - System packages only
- **Orchestration layer** (Taskfile) - Everything else

---

## Problems Identified

### 1. Dead Code
- `installer.rb` (470 lines) - Never called, duplicates Taskfile functionality
- `installer/string.rb` - Helper for dead code
- `installer/request.rb` - Helper for dead code
- Last refactored away in commit `6a22f79` but files never deleted

### 2. Redundant Package Definitions
- Font installation logic duplicated (installer.rb + taskfiles/fonts.yml)
- ASDF plugins list duplicated (installer.rb + .tool-versions)
- External packages duplicated (gems, npm, cargo in installer.rb + taskfiles)
- Symlink logic duplicated (installer.rb + taskfiles/dotfiles.yml)

### 3. Unused Platform Support
- `debian-setup.sh` - User only uses Ubuntu, script has outdated packages
- Setup.sh has complex detection for Debian that's never used

### 4. Poor Discoverability
- Not clear that `task install` is the main entry point
- Documentation references deleted installer.rb
- No clear explanation of the two-phase architecture

---

## Phase 1: Completed ✅

**Deleted Dead Code:**
- Removed `installer.rb` (470 lines)
- Removed `installer/string.rb` (helper)
- Removed `installer/request.rb` (helper)
- Updated `README.md` to remove reference and clarify two-phase architecture

**Files Changed:**
```
D  installer.rb
D  installer/request.rb
D  installer/string.rb
M  README.md
```

**Result:** Removed ~500 lines of dead code with zero risk

---

## Phase 2: Planned (Next Session)

### 2.1 Remove Unused Debian Support
- Delete `installer/debian-setup.sh` (outdated, never used)
- Remove Debian detection logic from `setup.sh` (lines 53-55)
- Update `README.md` to only reference Ubuntu for Linux

### 2.2 Reorganize Installer Directory
**Current structure:**
```
installer/
├── debian-setup.sh    (delete)
├── ubuntu-setup.sh
├── mac-setup.sh
├── shared.sh
├── gitconfig_installer.sh
└── title.txt
```

**Proposed structure:**
```
installer/
├── bootstrap.sh       (simplified setup.sh)
├── platforms/
│   ├── ubuntu.sh      (was ubuntu-setup.sh)
│   └── darwin.sh      (was mac-setup.sh)
├── lib/
│   ├── detect-os.sh   (extracted from setup.sh)
│   └── title.txt      (ASCII art)
└── README.md          (explain bootstrap process)
```

### 2.3 Replace ASCII Art
Replace `installer/title.txt` with custom "ryan's dotfiles" ASCII art

### 2.4 Simplify setup.sh
Streamline to:
```bash
#!/bin/bash
source ./installer/lib/detect-os.sh

case "$OS" in
  darwin) ./installer/platforms/darwin.sh ;;
  ubuntu) ./installer/platforms/ubuntu.sh ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

task install "$@"
```

---

## Phase 3: Planned

### 3.1 Documentation
- Create `installer/README.md` explaining bootstrap architecture
- Document `task install` vs `task sync` in main README
- Add comments to key taskfiles explaining their purpose

### 3.2 Improve Discoverability
- Add banner to `task install` showing what will be installed
- Create `task doctor` to verify prerequisites
- Add helpful error messages when dependencies are missing

---

## Next Session TODO

1. Execute Phase 2.1 - Remove debian-setup.sh
2. Get feedback and iterate
3. Execute Phase 2.2 - Reorganize directory structure
4. Get feedback and iterate
5. Execute Phase 2.3 & 2.4 - ASCII art and simplify setup.sh
6. Get feedback, then move to Phase 3 if approved

---

## Benefits of This Refactoring

1. **Single source of truth** - No duplicate logic across Ruby and Taskfile
2. **Easier maintenance** - One place to update each concern
3. **Clear separation** - System packages (bootstrap) vs dotfiles/tools (orchestration)
4. **Better discoverability** - `task -l` shows all operations
5. **Reduced complexity** - ~500+ lines of dead code removed
6. **Platform clarity** - Clear about what's supported (Ubuntu + macOS, not generic Debian)

---

## Files to Review Next Session

- `installer/debian-setup.sh` - Target for deletion
- `setup.sh` - Lines 53-55 to remove
- `installer/title.txt` - Replace ASCII art
- `README.md` - Update Linux installation instructions

---

## Git Status at End of Session

```
M  README.md           # Updated dependencies documentation
M  gitconfig           # Pre-existing unrelated change
D  installer.rb        # Deleted dead code
D  installer/request.rb # Deleted dead code helper
D  installer/string.rb  # Deleted dead code helper
```

Ready to commit Phase 1 changes before starting Phase 2.

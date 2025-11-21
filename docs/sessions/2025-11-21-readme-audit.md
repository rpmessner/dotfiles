# README.md Audit - Issues Found

**Date**: November 21, 2025
**Status**: Documented, not yet fixed

---

## Overview

README.md contains outdated information from the original fork (Dorian's dotfiles) that needs updating to reflect Ryan's actual setup.

---

## Critical Issues (Wrong Information)

### 1. Clone URL - Line 77
**Current:**
```sh
git clone git@github.com:dkarter/dotfiles.git
```

**Should be:**
```sh
git clone git@github.com:rpmessner/dotfiles.git
```

---

### 2. Debian Setup Reference - Line 60
**Current:**
```
- For Linux: [installer/ubuntu-setup.sh](./installer/ubuntu-setup.sh) or [installer/debian-setup.sh](./installer/debian-setup.sh)
```

**Should be:**
```
- For Linux: [installer/ubuntu-setup.sh](./installer/ubuntu-setup.sh)
```

**Reason:** We don't use Debian, only Ubuntu. debian-setup.sh will be deleted in Phase 2.

---

### 3. Operating System - Line 28
**Current:**
```
- **OS**: [Pop!\_OS](https://pop.system76.com/) / macOS
```

**Should be:**
```
- **OS**: Ubuntu (WSL2) / macOS
```

**Reason:** Ryan uses WSL2 Ubuntu, not Pop!_OS

---

### 4. Desktop Environment / Window Manager - Lines 29-30
**Current:**
```
- **DE**: [Gnome](https://www.gnome.org)
- **WM**: [Mutter](https://gitlab.gnome.org/GNOME/mutter)
```

**Should be:** Remove these lines entirely

**Reason:** Not applicable to WSL2 environment

---

### 5. Terminal Emulator - Line 41
**Current:**
```
- **Terminal**: [Alacritty](https://alacritty.org/)
```

**Should be:**
```
- **Terminal**: [WezTerm](https://wezfurlong.org/wezterm/)
```

**Reason:** Brewfile shows `cask 'wezterm'`, not Alacritty

---

## Minor Issues (Outdated/Misleading)

### 6. Screenshot Links - Lines 45-47
**Current:**
```
![screenshot](./screenshot.png)
![image](https://user-images.githubusercontent.com/551858/188434274-2df6fe83-7824-4b45-a797-51a96a1b928b.png)
<img width="2226" alt="image" src="https://user-images.githubusercontent.com/551858/189501141-a442b7b8-4089-4721-aaff-7d467b3d8bf4.png">
```

**Issues:**
- Local `screenshot.png` exists and is valid
- External GitHub images (user 551858) are likely Dorian's screenshots
- Two external images use different markdown formats for no reason

**Proposed fix:**
- Keep only the local `./screenshot.png`
- Remove the two external GitHub image links
- Consider taking fresh screenshots that show Ryan's actual setup

---

### 7. Development Instructions - Line 105
**Current:**
```
- This repo now uses conventional commits. To install the git hooks simply run `yarn` in the project directory
```

**Issues:**
- Not clear that `yarn` is ONLY for git hooks (commitlint)
- package.json only contains commitlint devDependencies
- Most users won't need to run this unless contributing

**Proposed fix:**
```
- This repo uses conventional commits for versioning
- For contributors: Run `yarn` to install git hooks (commitlint)
- Or use `lefthook install` (preferred method, already handled by `task install`)
```

---

## Correct Information (Keep as-is)

✅ Attribution to Dorian Karter (line 24)
✅ Shell: zsh (line 31)
✅ Editor: Neovim with correct plugins (lines 32-39)
✅ Browser: Firefox (line 40)
✅ Term Prompt: Powerlevel10k (line 42)
✅ Terminal Multiplexer: Tmux (line 43)
✅ Dependencies section (lines 53-62) - updated in Phase 1
✅ Installation instructions structure (lines 72-84)
✅ Versioning/changelog info (lines 88-99)
✅ FAQ section (lines 110-118)

---

## Recommended Approach for Next Session

1. **Quick fixes** (Lines to change):
   - Line 28: OS
   - Lines 29-30: Delete DE/WM
   - Line 41: Terminal
   - Line 60: Remove debian-setup.sh reference
   - Line 77: Fix clone URL

2. **Content improvements**:
   - Lines 45-47: Clean up screenshots
   - Line 105: Clarify yarn/hooks

3. **Optional enhancements**:
   - Add a "Key Features" or "Highlights" section
   - Add links to interesting configs (nvim, tmux, zsh)
   - Consider adding badges (license, version, etc.)

---

## File Location Reference

Current README: `/home/rpmessner/.dotfiles/README.md`
Git remote: `git@github.com:rpmessner/dotfiles.git`
Package.json: Only commitlint devDeps, yarn is optional

---

## Next Steps

1. Rebase on origin/master first (in case of conflicts)
2. Make the quick fixes listed above
3. Review and commit
4. Continue with Phase 2 of installer refactoring

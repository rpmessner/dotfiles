# Installer Refactoring Plan

**Status**: Phase 1 Complete ✅
**Current Phase**: Phase 2 (Ready to start)
**Session Doc**: [2025-11-21-installer-refactoring.md](./sessions/2025-11-21-installer-refactoring.md)

---

## Quick Summary

Simplifying the dotfiles installation from 3 parallel systems down to 2 clean layers:
- ❌ ~~setup.sh + installer.rb + Taskfile~~ (confusing, redundant)
- ✅ **setup.sh (bootstrap) + Taskfile (orchestration)** (clean, clear)

---

## Phase 1: Remove Dead Code ✅ COMPLETE

- [x] Delete `installer.rb` (470 lines, never called)
- [x] Delete `installer/string.rb` and `installer/request.rb`
- [x] Update `README.md` to clarify two-phase architecture
- [x] Document session findings

**Result**: ~500 lines of dead code removed, zero risk

---

## Phase 2: Consolidate & Simplify 🎯 NEXT

### 2.1 Remove Debian Support (User Doesn't Use It)
```bash
# Delete
- installer/debian-setup.sh

# Update (remove lines 53-55)
- setup.sh

# Update
- README.md (remove debian reference)
```

### 2.2 Reorganize Installer Directory
```
Current:                        Proposed:
installer/                      installer/
├── debian-setup.sh   ❌        ├── bootstrap.sh (new, replaces ../setup.sh)
├── ubuntu-setup.sh             ├── platforms/
├── mac-setup.sh                │   ├── ubuntu.sh
├── shared.sh                   │   └── darwin.sh
├── gitconfig_installer.sh      ├── lib/
└── title.txt                   │   ├── detect-os.sh
                                │   ├── shared.sh
                                │   ├── gitconfig.sh
                                │   └── title.txt
                                └── README.md (new)
```

### 2.3 Create New ASCII Art
Replace "DOTFILES" in `installer/lib/title.txt` with "ryan's dotfiles"

### 2.4 Simplify Main Bootstrap
Clean up `installer/bootstrap.sh` (or simplified `setup.sh`) to be ~20 lines max

---

## Phase 3: Documentation & Polish 📚 FUTURE

### 3.1 Documentation
- [ ] Create `installer/README.md` explaining bootstrap vs orchestration
- [ ] Document `task install` vs `task sync` distinction
- [ ] Add inline comments to complex taskfiles

### 3.2 Discoverability Improvements
- [ ] Add banner to `task install` showing what will happen
- [ ] Create `task doctor` to verify prerequisites
- [ ] Better error messages for missing dependencies

---

## Execution Strategy

**Per-phase approach**: Complete one phase, get user feedback, iterate before moving on.

**Within Phase 2**: Break into smaller steps with checkpoints:
1. Delete debian-setup.sh → Review
2. Reorganize directory structure → Review
3. ASCII art + simplify setup.sh → Review
4. Move to Phase 3 if approved

---

## Key Principles

1. **Single source of truth** - No duplicate logic
2. **Platform clarity** - Only support what user actually uses (Ubuntu + macOS)
3. **Clear separation** - System deps (bash) vs dotfiles/tools (Taskfile)
4. **Safe iteration** - Small changes, frequent reviews

---

## Files to Track

**Phase 2 targets:**
- `installer/debian-setup.sh` → DELETE
- `setup.sh` → SIMPLIFY
- `installer/title.txt` → REPLACE
- `README.md` → UPDATE

**Git status before Phase 2:**
```
M  README.md           # From Phase 1
M  gitconfig           # Unrelated pre-existing
D  installer.rb        # From Phase 1
D  installer/request.rb # From Phase 1
D  installer/string.rb  # From Phase 1
```

---

## Ready for Next Session

**IMPORTANT - Start with:**
1. Rebase on origin/master and resolve any conflicts
2. Continue with Phase 2 and README updates

**Context files:**
- This plan: `docs/INSTALLER_REFACTOR_PLAN.md`
- README issues: `docs/sessions/2025-11-21-readme-audit.md`
- Session history: `docs/sessions/2025-11-21-installer-refactoring.md`

**Actions for next session:**
1. `git fetch origin && git rebase origin/master` (resolve conflicts if any)
2. Fix README.md (see README audit doc)
3. Delete `installer/debian-setup.sh` and update references
4. Continue with rest of Phase 2

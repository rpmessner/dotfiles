# WSL2 Performance Optimization Roadmap

**Platform**: Windows 11 + WSL2 (Ubuntu 24.04)
**Last Updated**: November 23, 2025
**Status**: Active Development

---

## Executive Summary

This document outlines the performance optimization strategy for WSL2 Ubuntu development environment. It consolidates all performance-related action items and provides a prioritized implementation plan.

---

## Completed Optimizations ✅

### 1. Clipboard Integration (Nov 23, 2025)
**Status**: ✅ Complete
**Impact**: HIGH - Essential workflow feature
**Performance**: Instant paste operations (0ms delay)

**Details**:
- Bidirectional clipboard (Windows ↔ tmux)
- Copy: `clip.exe` integration in tmux
- Paste: `Ctrl+Shift+V` in WezTerm
- Optimized paste speed and zsh bracketed paste

**Session**: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`

---

## Performance Baseline (To Be Established)

Before implementing optimizations, we need to establish current performance metrics:

### Metrics to Capture

1. **Shell Startup Time**
   ```bash
   # Test zsh startup time
   time zsh -i -c exit
   ```
   - **Target**: < 300ms
   - **Current**: Unknown (needs measurement)

2. **Git Performance**
   ```bash
   # Test in a large repository
   cd <large-repo>
   time git status
   ```
   - **Target**: < 100ms in large repos
   - **Current**: Unknown (needs measurement)

3. **File System Operations**
   ```bash
   # Test file operations in Linux filesystem
   time fd --type f . ~/dev | wc -l
   time rg "pattern" ~/dev
   ```
   - **Target**: No noticeable lag
   - **Current**: Unknown (needs measurement)

4. **Tmux Responsiveness**
   - Window switching lag
   - Pane navigation lag
   - Copy mode lag
   - **Current**: Seems responsive (subjective)

5. **General System Responsiveness**
   - Terminal input lag
   - Command execution delay
   - Tab completion speed
   - **Current**: Seems good (subjective)

---

## Optimization Areas

### 🔥 Priority 1: Establish Performance Baseline (Week 1)

**Effort**: 30-60 minutes
**Impact**: HIGH - Required before optimization

#### Tasks
1. [ ] Create performance benchmarking script
2. [ ] Measure shell startup time (zsh)
3. [ ] Measure git operations in test repos
4. [ ] Measure file system search performance
5. [ ] Document current state
6. [ ] Identify bottlenecks from measurements

#### Implementation
```bash
# Create benchmarking script: scripts/benchmark-wsl2.sh
#!/bin/bash

echo "=== WSL2 Performance Benchmark ==="
echo "Date: $(date)"
echo "Kernel: $(uname -r)"
echo ""

echo "1. Shell Startup Time (5 runs):"
for i in {1..5}; do
  /usr/bin/time -f "%E real" zsh -i -c exit 2>&1 | grep real
done

echo ""
echo "2. Git Status (current repo):"
time git status

echo ""
echo "3. File Search (fd in home):"
time fd --type f . ~ --max-depth 3 | wc -l

echo ""
echo "4. Code Search (rg in dotfiles):"
time rg "function" ~/.dotfiles --stats

echo ""
echo "5. Directory Jump (zoxide):"
time zoxide query dotfiles
```

---

### ⚡ Priority 2: WSL2 Configuration (.wslconfig) (Week 2)

**Effort**: 1-2 hours (research + testing)
**Impact**: HIGH - System-wide performance improvement

#### Current State
- No `.wslconfig` file exists
- Using WSL2 defaults (likely conservative settings)

#### Research Required
1. [ ] Determine optimal memory allocation for development
2. [ ] Research processor count recommendations
3. [ ] Investigate swap configuration
4. [ ] Research network performance settings
5. [ ] Find I/O optimization settings

#### Resources to Consult
- Official WSL2 docs: https://docs.microsoft.com/en-us/windows/wsl/wsl-config
- GitHub discussions on WSL2 performance
- Dev.to articles on WSL2 optimization
- Reddit r/bashonubuntuonwindows

#### Template to Create
Location: `C:\Users\<username>\.wslconfig`

```ini
# WSL2 Configuration for Development Performance
# Location: C:\Users\<username>\.wslconfig
# After changes: wsl --shutdown (then restart WSL)

[wsl2]
# Memory allocation (default: 50% of total RAM, max 8GB on systems >8GB)
# For 16GB system: 8GB, for 32GB: 12-16GB
memory=8GB

# Processor count (default: all processors)
# Set to all or leave commented for auto
processors=8

# Swap size (default: 25% of RAM)
# Can reduce if enough RAM allocated
swap=2GB

# Swap file location (optional, default: %USERPROFILE%\AppData\Local\Temp\swap.vhdx)
# swapFile=D:\\wsl-swap.vhdx

# Disable page reporting (can improve performance)
pageReporting=false

# Network mode (default: NAT)
# networkingMode=mirrored  # Windows 11 22H2+ for better localhost access

# DNS tunneling (can improve DNS performance)
# dnsTunneling=true

# Firewall (can improve security without perf hit)
# firewall=true

# Kernel command line arguments (advanced)
# kernelCommandLine =

# Enable nested virtualization (if needed for Docker, etc.)
nestedVirtualization=true

# VM idle timeout (default: 60000ms = 1 min)
# Increase to keep VM alive longer
vmIdleTimeout=60000
```

#### Testing Plan
1. [ ] Create baseline `.wslconfig` with documented defaults
2. [ ] Test with conservative optimizations
3. [ ] Measure performance improvements
4. [ ] Iterate based on results
5. [ ] Document final configuration

---

### ⚡ Priority 3: File System Optimization (Week 2-3)

**Effort**: 1 hour
**Impact**: MEDIUM-HIGH - Affects daily operations

#### Current State
- ✅ Projects in `/home/` (Linux filesystem) - correct
- ❌ Unknown: metadata performance settings
- ❌ Unknown: filesystem cache settings

#### Tasks
1. [ ] Verify all projects are in Linux filesystem (not `/mnt/c/`)
2. [ ] Configure `/etc/wsl.conf` for optimal metadata
3. [ ] Test filesystem cache settings
4. [ ] Benchmark improvements

#### /etc/wsl.conf Configuration

Location: `/etc/wsl.conf` (WSL filesystem)

```ini
# WSL Configuration for File System Performance
# Location: /etc/wsl.conf
# After changes: wsl --shutdown (then restart WSL)

[automount]
# Enable metadata for better permission handling
enabled = true
options = "metadata,umask=22,fmask=11"
mountFsTab = true

# Mount Windows drives under /mnt
root = /mnt/

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[boot]
# Run commands on WSL startup (optional)
# command =

[user]
default = rpmessner
```

#### Verification
```bash
# Check where projects are located
ls -la ~/dev/
ls -la ~/projects/

# Should NOT see projects in:
ls /mnt/c/Users/*/dev  # Slow Windows filesystem
```

---

### ⚡ Priority 4: Git Performance Tuning (Week 3)

**Effort**: 30 minutes
**Impact**: HIGH - Used constantly in dev workflow

#### Current State
- Unknown: Current git performance
- Unknown: git config optimizations

#### Git Configuration Optimizations

Add to `gitconfig` or test individually:

```gitconfig
[core]
    # Enable file system monitor for faster status
    fsmonitor = true

    # Cache untracked files for faster status
    untrackedCache = true

    # Use faster hash algorithm (Git 2.29+)
    # commitGraph = true

    # Preload index for faster operations
    preloadindex = true

[feature]
    # Enable experimental performance features
    manyFiles = true

[index]
    # Use version 4 index (more compact)
    version = 4

[pack]
    # Use multiple threads for packing
    threads = 0  # 0 = auto-detect CPU count

[fetch]
    # Fetch commits in parallel
    parallel = 0  # 0 = auto-detect CPU count

[checkout]
    # Use multiple workers for checkout
    workers = 0  # 0 = auto-detect CPU count
```

#### Testing Plan
1. [ ] Benchmark git status in large repo (before)
2. [ ] Enable optimizations incrementally
3. [ ] Benchmark after each change
4. [ ] Document improvements
5. [ ] Add successful optimizations to gitconfig

#### Target Repos for Testing
- Dotfiles repo (small, current)
- Large work repo (if available)
- Clone large public repo for testing (e.g., Linux kernel)

---

### 🔧 Priority 5: Shell Startup Optimization (Week 3-4)

**Effort**: 1-2 hours
**Impact**: MEDIUM - Affects new shell startup

#### Current State
- Unknown: Current startup time
- Likely fast already due to good practices

#### Profiling Method
```bash
# Profile zsh startup
zsh -i -c 'zprof'

# Time individual components
time source ~/.config/zsh/brew.zsh
time source ~/.config/zsh/fzf.zsh
# ... etc for each config file
```

#### Common Optimization Techniques
1. [ ] Lazy-load heavy plugins (defer until needed)
2. [ ] Remove duplicate `compinit` calls
3. [ ] Optimize plugin loading order
4. [ ] Cache completion dumps
5. [ ] Defer non-essential initializations

#### Targets to Check
- zinit plugin loading
- asdf initialization
- fzf initialization
- zoxide initialization
- Completion system

---

### 🔧 Priority 6: Kernel & I/O Optimization (Advanced)

**Effort**: 2-3 hours (research heavy)
**Impact**: MEDIUM - System-level improvements

#### Tasks
1. [ ] Check current WSL2 kernel version
2. [ ] Research WSL2 kernel parameters
3. [ ] Test I/O scheduler settings
4. [ ] Investigate kernel compile options (advanced)

#### Kernel Info
```bash
# Check kernel version
uname -r

# Check kernel parameters
cat /proc/cmdline

# Check I/O scheduler
cat /sys/block/sda/queue/scheduler
```

#### Potential Optimizations
- Custom kernel parameters via `.wslconfig`
- I/O scheduler tuning
- VM settings optimization

**Note**: This is advanced and may have limited ROI. Only pursue if easier optimizations don't meet targets.

---

### 💡 Priority 7: Tool-Specific Optimizations (Ongoing)

**Effort**: Variable
**Impact**: MEDIUM - Quality of life improvements

#### Tmux
- [ ] Verify no unnecessary plugins causing lag
- [ ] Check status bar update frequency
- [ ] Optimize history limit if needed

#### Neovim
- [ ] Check LSP performance in large files
- [ ] Verify treesitter performance
- [ ] Profile plugin load times

#### Terminal (WezTerm)
- [x] Font rendering optimized (OpenGL backend)
- [x] Paste speed optimized (paste_speed = 0)
- [ ] Review other performance settings

---

## Success Metrics

### Target Performance (Week 4)

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Shell Startup | TBD | < 300ms | 📊 Need baseline |
| Git Status (large repo) | TBD | < 100ms | 📊 Need baseline |
| File Search (fd) | TBD | No lag | 📊 Need baseline |
| Code Search (rg) | TBD | No lag | 📊 Need baseline |
| Terminal Input | Good | No lag | ✅ Seems fine |
| Tmux Responsiveness | Good | Instant | ✅ Seems fine |

### Optimization Impact Tracking

After each optimization, document:
- What was changed
- Benchmark before/after
- Subjective improvement notes
- Any issues encountered

---

## Implementation Timeline

### Week 1: Baseline & Quick Wins
- Day 1-2: Create benchmarking script and establish baseline
- Day 3-4: Research `.wslconfig` best practices
- Day 5: Document findings and plan Week 2

### Week 2: Configuration Optimization
- Day 1-2: Implement and test `.wslconfig` changes
- Day 3-4: Optimize `/etc/wsl.conf` for filesystem
- Day 5: Benchmark improvements, document results

### Week 3: Git & Shell Optimization
- Day 1-2: Git performance tuning and testing
- Day 3-4: Shell startup profiling and optimization
- Day 5: Final benchmarks, document results

### Week 4: Advanced & Polish
- Day 1-2: Kernel/I/O research if needed
- Day 3-4: Tool-specific optimizations
- Day 5: Final documentation and roadmap update

**Total Estimated Time**: 15-20 hours over 4 weeks (can be done in parallel with regular work)

---

## Quick Reference: Optimization Commands

### Benchmarking
```bash
# Run benchmark script
~/. dotfiles/scripts/benchmark-wsl2.sh

# Shell startup time
time zsh -i -c exit

# Git performance
cd <repo> && time git status

# File operations
time fd --type f . ~/dev | wc -l
time rg "pattern" ~/dev
```

### Configuration Reload
```bash
# After .wslconfig changes (Windows PowerShell)
wsl --shutdown
wsl

# After /etc/wsl.conf changes
wsl --shutdown  # then restart WSL

# After gitconfig changes
# No reload needed, takes effect immediately

# After zsh config changes
source ~/.zshrc
```

### Performance Monitoring
```bash
# WSL2 memory usage (Windows PowerShell)
wsl -l -v

# Linux resource usage
htop
# or
btop

# Disk I/O
iostat -x 1

# Process monitoring
ps aux --sort=-%cpu | head -10
```

---

## Known Issues & Workarounds

### Issue: Windows Defender Scanning WSL2 Files
**Impact**: Can cause file operation slowdowns
**Workaround**: Exclude WSL2 virtual disk from Windows Defender
**Location**: `%LOCALAPPDATA%\Packages\CanonicalGroupLimited.Ubuntu*\LocalState\ext4.vhdx`

### Issue: Memory Not Released After WSL2 Shutdown
**Impact**: WSL2 VM may consume memory even when idle
**Workaround**: Set `vmIdleTimeout` in `.wslconfig` or manually shutdown: `wsl --shutdown`

### Issue: DNS Slow on Corporate Networks
**Impact**: Network operations may be slow
**Workaround**: Custom `/etc/resolv.conf` or DNS settings in `/etc/wsl.conf`

---

## Resources

### Official Documentation
- [WSL2 Configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
- [WSL2 Advanced Settings](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configuration-settings)

### Performance Guides
- [WSL2 Performance Best Practices](https://docs.microsoft.com/en-us/windows/wsl/compare-versions#performance-across-os-file-systems)
- [Git Performance on WSL2](https://github.blog/2019-09-05-get-up-to-speed-with-partial-clone-and-shallow-clone/)

### Community Resources
- Reddit: r/bashonubuntuonwindows
- GitHub: WSL issue tracker
- Stack Overflow: wsl2 tag

---

## Future Considerations

### Potential Future Optimizations
1. **win32yank**: Faster clipboard tool (alternative to clip.exe)
2. **Custom WSL2 Kernel**: Compile with optimizations for workload
3. **RAM Disk**: For ultra-fast temporary storage
4. **Profile-Guided Optimization**: For frequently-used tools

### Monitoring & Maintenance
- Monthly performance baseline checks
- Update `.wslconfig` when upgrading RAM
- Review new WSL2 features in Windows updates
- Keep kernel updated

---

## Related Documentation

- **Session Logs**: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`
- **Project Roadmap**: `docs/ROADMAP.md`
- **WSL2 Installation**: `docs/sessions/2025-11-20-wsl2-ubuntu-installation.md`
- **Testing Guide**: `docs/clipboard-integration-test.md`

---

## Appendix: Template Files

### A. Benchmark Script Template

See implementation in "Priority 1: Establish Performance Baseline"

### B. .wslconfig Template

See implementation in "Priority 2: WSL2 Configuration"

### C. /etc/wsl.conf Template

See implementation in "Priority 3: File System Optimization"

### D. Git Performance Config

See implementation in "Priority 4: Git Performance Tuning"

---

**Document Owner**: Ryan Messner
**Last Review**: November 23, 2025
**Next Review**: After Week 1 baseline completion
**Status**: Ready for Implementation

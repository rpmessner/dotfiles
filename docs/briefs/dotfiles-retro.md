You are a build session in ~/dev/dotfiles (branch feat/ai-agent-orchestration). A coordinator session (Claude Code, another tmux window) dispatched you and will read your output. Work autonomously; ask only when a decision is genuinely the user's.

These dotfiles are live: ~/.zshrc, ~/.gitconfig, ~/.aliases and ~/.config/<tool> are symlinks into this repo (taskfiles/dotfiles.yml), and the repo is pushed to GitHub. Every edit changes the user's running environment. After any shell-config edit, prove a fresh `zsh -ic 'echo ok'` still starts cleanly and `git config --get user.email` still resolves.

## Context: a retro found these problems (all decided by the user; apply, don't re-ask)
1. The guardrail exists on paper only: lefthook.yml declares gitleaks (pre-commit), cog (commit-msg) and `task ci:run` (pre-push), but lefthook, gitleaks and cog are not installed and no hooks are active.
2. Nothing catches secret-file paths: default gitleaks rules detect secret values, not references to a key file under the ssh directory.
3. Machine-specific lines are committed: gitconfig `[safe] directory = /mnt/c/Users/...` (~line 137); zshrc `/home/rpmessner/.local/bin` (~line 131), which duplicates `path_prepend "$HOME/.local/bin"` (~line 52); aliases ~line 153 names a private key file under the ssh directory; the gh credential helper uses the absolute `/usr/bin/gh` (gitconfig ~139-140). Also uncommitted `[beads] role = maintainer` in gitconfig, written by a tool.
4. Beads is half set up: CLAUDE.md has an uncommitted beads block, .codex/hooks.json and .agents/skills/beads exist, but there is no .beads workspace.
5. CLAUDE.md is ~400 lines and partly stale (wrong tmux.conf line refs, nonexistent `task shell:lint`, cocogitto vs `committed` contradiction, macOS-primary claims vs WSL reality, "CI runs on pre-push" false, ~120 lines of Nov-2025 status logs). AGENTS.md (untracked) holds only a beads/codex block.
6. CI (.github/workflows/ci.yml) has no secret scan.
7. config/go/telemetry/ lands in the repo via the ~/.config/go symlink.

## Do
1. **Tools.** Install lefthook, gitleaks and cocogitto (`cog`) without sudo — asdf is available (add plugins, pin versions in this repo's .tool-versions); fall back to release binaries in ~/.local/bin if a plugin is missing. Say which you used and why.
2. **Beads, house mode** (see ~/dev/AGENTS.md "Beads is local and flat-file"): `bd init` with prefix `dot`, embedded store, no server, no remote. Append the house export block (copy it verbatim from ~/dev/music/form-engine/.beads/hooks/pre-commit, the `HOUSE BEADS EXPORT` section) so `.beads/issues.jsonl` is exported and staged on every commit.
3. **One hook runner.** bd init points core.hooksPath at .beads/hooks; lefthook installs its own hooks. They must not fight. Make one runner own the git hooks (lefthook is the likely choice: call bd's hook logic and the house export from lefthook jobs, then `lefthook install`), and prove every hook fires: a commit runs gitleaks, the format check, cog on the message, and the beads export; pre-push runs `task ci:run` (prove with `lefthook run pre-push` rather than pushing). Wire `lefthook install` into `task dot:install`/`dot:sync` if it isn't, and add a `task doctor` check that fails when the active pre-commit hook isn't lefthook's.
4. **Path rule.** Add `.gitleaks.toml` extending the default rules with a rule for paths to files under `.ssh/` in any spelling (`~`, `$HOME`, `${HOME}`, `/home/<user>`), excluding config, known_hosts, authorized_keys and `*.pub`. Negative-test it: stage a planted line, see the commit blocked by gitleaks, unstage it.
5. **Machine-specific lines.** Move the safe.directory entry and `[beads] role` to ~/.gitconfig.local; delete the duplicated zshrc PATH line; move the tnnl alias to ~/.aliases.local; make the gh credential helper path-independent (`!gh auth git-credential`). The .local files are untracked and must keep working (they are already sourced/included; verify).
6. **Agent docs.** Make AGENTS.md canonical (~30–50 lines): what the repo is, the symlink map and the .local escape hatches, the check commands that actually exist (verify each one runs), the hook setup, beads in house mode, "don't read CHANGELOG.md", pointers to docs/ and the README keybinding section. Drop the status logs and stale claims. Replace CLAUDE.md with a symlink to AGENTS.md. Decide what to do with .codex/ and .agents/skills/beads (keep only if they work with the beads setup; .codex/hooks.json must not call anything that fails).
7. **CI.** Add a gitleaks job (gitleaks/gitleaks-action or the CLI) using the same .gitleaks.toml. Make sure the workflow file stays valid YAML.
8. **Ignore** config/go/telemetry/ (and check `git status` for any other tool state under config/ that should be ignored; list what you find).
9. Keep the user's own uncommitted `alias gct='git commit --verbose'` in aliases.

## Rules
- No commits, no pushes. The coordinator commits per slice after review. Do not run `git push` or `lefthook run pre-push` in a way that pushes.
- Don't touch ~/.claude, ~/.ssh, or anything outside this repo except ~/.gitconfig.local, ~/.aliases.local, ~/.zshrc.local (create if missing) and tool installs under ~/.asdf or ~/.local/bin.
- Never print secret values. Paths are fine in your report, but not in tracked files.

## Report back
Write docs/sessions/dotfiles-retro.md: per item what changed, the evidence (commands + trimmed output: hooks firing, gitleaks negative test, fresh shell start, git config resolution), what moved to .local files, anything left for the user. Then print DOTFILES-RETRO DONE alone on the last line.

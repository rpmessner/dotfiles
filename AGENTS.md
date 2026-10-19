# AGENTS.md — dotfiles

Ryan's dotfiles (fork of dkarter/dotfiles): zsh, tmux, Neovim, WezTerm, git, driven by Task (`taskfiles/`) and asdf
(`.tool-versions`). Primary machine is Windows 11 + WSL2 Ubuntu; macOS is secondary. `CLAUDE.md` is a symlink to this
file — edit `AGENTS.md`.

## These files are live

`task dot:symlink` links each root file in its `FILES` list (`zshrc`, `zshenv`, `aliases`, `gitconfig`, `gitignore`,
`gitmessage`, ...) to `~/.<name>`, and every `config/<tool>/` to `~/.config/<tool>`. Editing them changes the running
environment, and the repo is public on GitHub. After a shell or git config edit, check `zsh -ic 'echo ok'` starts
cleanly and `git config --get user.email` resolves.

Machine-specific lines, secrets and key paths go in untracked `.local` files, never in the repo:

- `~/.zshrc.local` (sourced from `zshrc`), `~/.zshenv.local` (from `zshenv`), `~/.aliases.local` (end of `aliases`)
- `~/.gitconfig.local` (`[include]` in `gitconfig`; sections after the include, like `[credential]` and `[user]`, win)
- `~/.tmux.conf.local` (sourced from `config/tmux/tmux.conf`)

Tool state written through a `~/.config/<tool>` symlink lands in the repo: add it to `.gitignore`.

## Checks (all verified to run)

- `task ci:run`: dprint format check, shellcheck, yamllint, typos, Lua syntax. Same as the pre-push hook.
- `task ci:fmt:check` / `task fmt`: check / apply dprint formatting. shfmt is not run on `.zsh` (it corrupts zsh).
- `task dot:leaks`: gitleaks over full history with `.gitleaks.toml`; `.gitleaksignore` is the history baseline.
- `task doctor`: prerequisites, symlinks, and that lefthook owns the git hooks.

## Git hooks

lefthook is the only hook runner (`lefthook.yml`; installed by `task install`/`task sync` via `lefthook install`).
`core.hooksPath` must stay unset — `bd init`/`bd hooks install` set it, so unset it afterwards.

- pre-commit: gitleaks on staged changes (default rules + `.ssh/` path rule), dprint on staged files, then
  `.beads/hooks/pre-commit` (bd hook + house export of `.beads/issues.jsonl`, staged).
- commit-msg: `cog verify` (conventional commits; `committed.toml` is not used by the hooks).
- pre-push: `.beads/hooks/pre-push` and `task ci:run`. CI (`.github/workflows/ci.yml`) adds a gitleaks history scan.

## Beads (house mode)

Issues use prefix `dot`, embedded Dolt store, no server, no Dolt remote; `.beads/issues.jsonl` is the record that
travels with the code. Never `bd dolt push/pull` or add remotes. Some bd commands (`init`, `dolt remote remove`)
make their own git commits — check `git log` after them. `.codex/hooks.json` and `.agents/skills/beads/` are bd's
Codex integration and are kept.

## Pointers

- Don't read `CHANGELOG.md` (release-please output, large).
- Keybindings: `KEYBINDINGS.md` and README "Unified Window/Pane Management".
- Install/bootstrap: README "Dependencies" and `installer/README.md`; plans in `docs/`; past sessions in
  `docs/sessions/`.

<!-- BEGIN FOREMAN -->
## Tickets

Use the globally linked `foreman` skill (`~/.agents/skills/foreman/SKILL.md`).
<!-- END FOREMAN -->

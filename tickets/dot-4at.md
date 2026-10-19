---
id: dot-4at
title: "Decide zsh formatting: shfmt corrupts zsh, so dprint no longer formats .zsh"
type: task
status: open
priority: 3
parent: null
blocked_by: []
related: []
supersedes: []
discovered_from: null
labels: []
created: 2026-10-16
closed: null
close_reason: null
---

Proven: shfmt -ln zsh rewrites ${widgets[complete-word]} to ${widgets[complete - word]} in scripts/profile-completion.zsh. .zsh removed from the dprint exec shfmt exts. Options: leave unformatted, or find a zsh-safe formatter.

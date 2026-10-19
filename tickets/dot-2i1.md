---
id: dot-2i1
title: "Rotate/confirm-dead the two DigitalOcean tokens in pushed history (zshrc-dorian, commit 233658f)"
type: task
status: closed
priority: 1
parent: null
blocked_by: []
related: []
supersedes: []
discovered_from: null
labels: []
created: 2026-10-16
closed: 2026-10-16
close_reason: "Not ours: inherited history. Commit 233658f (Dorian Karter, 2016-12-19) in his zshrc-dorian from the forked dkarter dotfiles; tokens are his personal and Hashrocket DigitalOcean tokens, public in his repo since 2016. Nothing for us to revoke; kept in .gitleaksignore."
---

gitleaks generic-api-key findings baselined in .gitleaksignore. History can't be cleaned without a rewrite; the values must be revoked if they were ever live. Likely inherited from the dkarter fork.

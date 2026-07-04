# Agent Orchestration Hub
export HUB_REPO_DIR="${HUB_REPO_DIR:-$HOME/dev/utils/agent-hub}"
export HUB_COOKIE="${HUB_COOKIE:-hub}"

if [[ -n "${HUB_REPO_DIR:-}" && -d "$HUB_REPO_DIR/bin" ]]; then
  path_prepend "$HUB_REPO_DIR/bin"
fi

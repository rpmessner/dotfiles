# Elixir configuration

# Mix environment - use test for faster compilation in development
export MIX_ENV="${MIX_ENV:-dev}"

# Enable IEx history
export ERL_AFLAGS="-kernel shell_history enabled"

# Phoenix-specific settings
export PHOENIX_LIVE_RELOAD_ENABLED="${PHOENIX_LIVE_RELOAD_ENABLED:-true}"

# Elixir LS (Language Server) configuration
export ELIXIR_LS_PATH="$HOME/.local/share/nvim/mason/packages/elixir-ls"

# Aliases for common Elixir/Phoenix commands
alias iex='iex -S mix'
alias mdg='mix deps.get'
alias mdc='mix deps.compile'
alias mdu='mix deps.update --all'
alias mt='mix test'
alias mtw='mix test.watch'
alias mc='mix compile'
alias mcf='mix compile --force'
alias mec='mix ecto.create'
alias mem='mix ecto.migrate'
alias mer='mix ecto.rollback'
alias mes='mix ecto.setup'
alias med='mix ecto.drop'
alias mps='mix phx.server'
alias mpn='mix phx.new'
alias mpr='mix phx.routes'
alias mpg='mix phx.gen'

# Function to create a new Phoenix project with common options
phx_new() {
  if [ -z "$1" ]; then
    echo "Usage: phx_new <project_name> [options]"
    echo "Example: phx_new my_app --database postgres --no-html"
    return 1
  fi
  mix phx.new "$@"
}

# Function to run Phoenix with custom port
phx_server() {
  local port="${1:-4000}"
  PORT="$port" mix phx.server
}

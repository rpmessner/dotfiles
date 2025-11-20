# Go environment configuration

# Set GOPATH to ~/.go
export GOPATH="$HOME/.go"

# Add Go installation to PATH
path_prepend "/usr/local/go/bin"

# Add Go workspace binaries to PATH
path_append "$GOPATH/bin"

# Enable Go modules
export GO111MODULE=on

# Set private repo patterns (add your own if needed)
# export GOPRIVATE="github.com/yourorg/*"

# Go build cache
export GOCACHE="$HOME/.cache/go-build"

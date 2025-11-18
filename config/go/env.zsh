# Go environment configuration

# Set GOPATH to ~/.go
export GOPATH="$HOME/.go"

# Add Go binaries to PATH
export PATH="$GOPATH/bin:$PATH"

# Enable Go modules
export GO111MODULE=on

# Set private repo patterns (add your own if needed)
# export GOPRIVATE="github.com/yourorg/*"

# Go build cache
export GOCACHE="$HOME/.cache/go-build"

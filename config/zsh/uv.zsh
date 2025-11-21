if command -v uv &> /dev/null; then
  export UV_PYTHON_PREFERENCE=only-system
  export UV_PYTHON_DOWNLOADS=never
  export PATH="$(uv tool dir):$PATH"
fi

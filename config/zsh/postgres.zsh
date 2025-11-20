# set the path for postgres client utils on mac
if [[ "$(uname)" == "Darwin" ]]; then
  path_prepend "$BREW_PREFIX/opt/libpq/bin"
fi

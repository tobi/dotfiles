# Activate mise-managed runtimes (node, ruby, uv, etc.) when mise is installed.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate "$SHELL_ENV")"
fi

#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home" DOTFILES_PATH="$repo"
mkdir -p "$HOME"

bash "$repo/src/ghostty.sh"
test "$(readlink "$HOME/.config/ghostty/config")" = "$repo/config/_config.ghostty.config"
printf 'font-size = 17\n' > "$HOME/.config/ghostty/local.conf"
bash "$repo/src/ghostty.sh"
test "$(< "$HOME/.config/ghostty/local.conf")" = 'font-size = 17'

rm "$HOME/.config/ghostty/config"
printf 'font-size = 19\n' > "$HOME/.config/ghostty/config"
bash "$repo/src/ghostty.sh"
test ! -L "$HOME/.config/ghostty/config"
test "$(< "$HOME/.config/ghostty/config")" = 'font-size = 19'

rm "$HOME/.config/ghostty/config"
ln -s "$tmp/missing" "$HOME/.config/ghostty/config"
bash "$repo/src/ghostty.sh"
test "$(readlink "$HOME/.config/ghostty/config")" = "$tmp/missing"
printf 'Ghostty config linking: fresh install, idempotency, overrides, existing config, dangling symlink OK\n'

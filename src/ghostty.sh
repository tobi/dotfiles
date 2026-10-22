#!/usr/bin/env bash
# Link shared Ghostty preferences without replacing an existing user config.
set -euo pipefail

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.local/share/dotfiles}"
config_dir="$HOME/.config/ghostty"
source_path="$DOTFILES_PATH/config/_config.ghostty.config"
destination="$config_dir/config"

if [[ -L "$destination" ]] && [[ "$(readlink "$destination")" == "$source_path" ]]; then
  exit 0
fi
if [[ -e "$destination" || -L "$destination" ]]; then
  echo "* Keeping existing Ghostty config: $destination"
  echo "  Shared preferences available at $source_path; local overrides belong in $config_dir/local.conf."
  exit 0
fi

mkdir -p "$config_dir"
ln -s "$source_path" "$destination"
echo "linked Ghostty preferences: $destination"

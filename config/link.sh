#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/.local/share/dotfiles/config"

for file in *; do
  [[ -f "$file" && "$file" != "link.sh" ]] || continue

  source_path=$(realpath "$file")
  destination="$HOME/$(printf '%s' "$file" | sed 's|\.|/|g; s|_|.|g')"

  if [[ "${1:-}" != "-f" && -e "$destination" ]]; then
    echo "File $destination already exists, skipping... (or use -f)"
    continue
  fi

  mkdir -p "$(dirname "$destination")"
  echo "linking $destination to $source_path"
  ln -nfs "$source_path" "$destination"
done

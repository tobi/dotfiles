#!/usr/bin/env bash
set -e

DOTFILES_PATH="$HOME/.local/share/dotfiles"
LEGACY_DOTFILES_PATH="$HOME/dotfiles"

append() {
  local text="$1" file="$2"
  [[ -f "$file" ]] || touch "$file"
  grep -qF -- "$text" "$file" || echo "$text" >>"$file"
}

echo "fetching public key..."
mkdir -p "$HOME/.ssh"
append "$(curl -fsSL https://github.com/tobi.keys)" "$HOME/.ssh/authorized_keys"

echo "installing dotfiles..."
mkdir -p "$(dirname "$DOTFILES_PATH")"

if [[ -d "$DOTFILES_PATH/.git" ]]; then
  echo "dotfiles already exist at $DOTFILES_PATH"
elif [[ -d "$LEGACY_DOTFILES_PATH/.git" ]]; then
  echo "moving legacy dotfiles to $DOTFILES_PATH"
  mv "$LEGACY_DOTFILES_PATH" "$DOTFILES_PATH"
else
  git clone https://github.com/tobi/dotfiles "$DOTFILES_PATH"
fi

exec "$DOTFILES_PATH/apply.sh"

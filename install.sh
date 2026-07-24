#!/usr/bin/env bash

set -e

DOTFILES_PATH="$HOME/.local/share/dotfiles"
LEGACY_DOTFILES_PATH="$HOME/dotfiles"

append() {
  local text="$1" file="$2"

  [[ -f "$file" ]] || touch "$file"

  if ! grep -qF -- "$text" "$file"; then
    echo "$text" >>"$file"
  fi
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

cd "$DOTFILES_PATH"

echo "installing mise and managed tools..."
"$DOTFILES_PATH/bin/install-mise"

echo "installing herdr..."
curl -fsSL https://herdr.dev/install.sh | sh

echo "configuring git..."
bash "$DOTFILES_PATH/src/git.sh"

echo "installing dotfiles for zsh/bash"
chmod +w "$HOME/.zshrc" 2>/dev/null || true
printf '%s\n' "# Dotfiles" "source \"$DOTFILES_PATH/shell\"" >"$HOME/.zshrc"
touch "$HOME/.zshrc.local"

chmod -w "$HOME/.zshrc"
ln -nfs "$HOME/.zshrc" "$HOME/.bashrc"

if command -v zsh >/dev/null 2>&1 && [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
  echo "setting zsh as the login shell..."
  chsh -s "$(command -v zsh)" || echo "could not change login shell; run: chsh -s $(command -v zsh)"
fi

echo
echo "done"

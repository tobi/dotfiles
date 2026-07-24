#!/usr/bin/env bash
set -euo pipefail

export DOTFILES_PATH="$HOME/.local/share/dotfiles"
export PATH="$HOME/.local/bin:$PATH"
[[ ! -d /opt/homebrew/bin ]] || export PATH="/opt/homebrew/bin:$PATH"

if [[ "${1:-}" != "--skip-pull" ]]; then
  echo "updating dotfiles..."
  git -C "$DOTFILES_PATH" pull --rebase
  exec "$DOTFILES_PATH/apply.sh" --skip-pull
fi

run_as_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "sudo is required to update system packages" >&2
    return 1
  fi
}

echo "updating mise and managed tools..."
"$DOTFILES_PATH/bin/install-mise"

# Load the declarative native package list after mise so portable tools are not
# redundantly requested from the system package manager.
source "$DOTFILES_PATH/src/std.sh"
source "$DOTFILES_PATH/src/packages.sh"

echo "updating system packages..."
case "$VENDOR" in
  ubuntu|debian)
    run_as_root apt-get update
    run_as_root apt-get upgrade -y
    if [[ ${#missing_apt_package[@]} -gt 0 ]]; then
      run_as_root apt-get install -y "${missing_apt_package[@]}"
    fi
    ;;
  arch)
    run_as_root pacman -Syu --needed --noconfirm "${missing_pacman_package[@]}"
    ;;
  apple)
    brew update
    brew upgrade
    if [[ ${#missing_brew_package[@]} -gt 0 ]]; then
      brew install "${missing_brew_package[@]}"
    fi
    ;;
  *)
    echo "* system package updates unsupported for vendor: $VENDOR"
    ;;
esac

echo "configuring git..."
bash "$DOTFILES_PATH/src/git.sh"

echo "installing shell entrypoints..."
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
echo "dotfiles applied"

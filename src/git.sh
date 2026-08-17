#!/usr/bin/env bash
set -euo pipefail

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.local/share/dotfiles}"
shared_config="$DOTFILES_PATH/config/gitconfig"
shared_include="~/.local/share/dotfiles/config/gitconfig"

# Reconcile whichever global config git actually reads. A hand-rolled
# ~/.gitconfig wins when present; otherwise build up the machine-local config
# under ~/.config/git. `apply` keeps the chosen file and ensures it includes
# the shared config.
if [[ -e "$HOME/.gitconfig" ]]; then
  local_config="$HOME/.gitconfig"
else
  local_config="$HOME/.config/git/config"
  mkdir -p "$(dirname "$local_config")"
  touch "$local_config"
fi

# Let GitHub CLI keep its machine-local HTTPS credential helpers in the local
# config. Nothing it writes belongs in the public dotfiles checkout.
if command -v gh >/dev/null 2>&1; then
  gh auth setup-git >/dev/null 2>&1 || true
fi

# These settings moved from the local config into the tracked shared include.
# Removing stale copies keeps a single source of truth while preserving every
# machine-local credential, include, URL rewrite and maintenance setting.
shared_keys=(
  user.name
  user.email
  user.signingkey
  gpg.format
  commit.verbose
  commit.gpgsign
  tag.sort
  tag.gpgsign
  init.defaultbranch
  alias.co
  alias.br
  alias.ci
  alias.st
  pull.rebase
  push.autosetupremote
  diff.algorithm
  diff.colormoved
  diff.mnemonicprefix
  column.ui
  branch.sort
  rerere.enabled
  rerere.autoupdate
)
for key in "${shared_keys[@]}"; do
  git config --file "$local_config" --unset-all "$key" >/dev/null 2>&1 || true
done

# Append the shared include once. The local file remains writable for dev and
# other machine-specific tools; apply never replaces or symlinks it.
include_present=0
while IFS= read -r path; do
  if [[ "$path" == "$shared_include" || "$path" == "$shared_config" ]]; then
    include_present=1
    break
  fi
done < <(git config --file "$local_config" --get-all include.path 2>/dev/null || true)

if [[ "$include_present" == 0 ]]; then
  git config --file "$local_config" --add include.path "$shared_include"
fi

# This setting is intentionally local to the dotfiles checkout. A global
# hooksPath would disable repository-specific hooks in every other checkout.
# apply reruns this on existing machines and immediately after a fresh clone.
git -C "$DOTFILES_PATH" config --local core.hooksPath .githooks

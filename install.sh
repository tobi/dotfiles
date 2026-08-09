#!/usr/bin/env bash
set -e

DOTFILES_PATH="$HOME/.local/share/dotfiles"
LEGACY_DOTFILES_PATH="$HOME/dotfiles"

# Root, NOPASSWD, and password-prompt sudoers can all run apply. Anything else
# means the account has no sudo rights at all.
can_sudo() {
  [[ "$(id -u)" -eq 0 ]] && return 0
  command -v sudo >/dev/null 2>&1 || return 1
  local out
  out=$(sudo -nv 2>&1) || [[ "$out" == *"password is required"* ]]
}

# apply needs sudo for system packages. It cannot grant itself rights, so print
# the fix as a copy&paste command to run as root on the console or via an admin.
if ! can_sudo; then
  user=$(id -un)
  echo "$user has no sudo rights; run this as root first:"
  echo "  echo \"$user ALL=(ALL) ALL\" >> /etc/sudoers.d/$user"
  echo
fi

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

exec "$DOTFILES_PATH/bin/apply"

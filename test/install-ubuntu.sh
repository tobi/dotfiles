#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ubuntu:24.04}"
INSTALL_URL="https://raw.githubusercontent.com/tobi/dotfiles/main/install.sh"

echo "Testing dotfiles installation on $IMAGE"

docker run --rm -i \
  -e INSTALL_URL="$INSTALL_URL" \
  "$IMAGE" bash -s <<'CONTAINER'
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# The documented install command assumes curl and git exist. The stock Ubuntu
# image is intentionally minimal, so install only those transport prerequisites.
apt-get update -qq
apt-get install -y -qq ca-certificates curl git >/dev/null

run_installer() {
  curl -fsSL "$INSTALL_URL" | bash
}

run_apply() {
  "$HOME/.local/share/dotfiles/bin/apply"
}

assert_install() {
  local dotfiles="$HOME/.local/share/dotfiles"
  local mise="$HOME/.local/bin/mise"
  export PATH="$HOME/.local/bin:$PATH"

  test -d "$dotfiles/.git"
  test -x "$mise"
  test "$("$mise" settings get github.use_git_credentials)" = "true"
  # Each rc file is a real file that sources dotfiles plus its own .local
  # override (sourced last), without clobbering user content.
  test -f "$HOME/.bashrc"
  test ! -L "$HOME/.bashrc"
  grep -qF "source \"$dotfiles/shell\"" "$HOME/.bashrc"
  grep -qF "[ -f \"$HOME/.bashrc.local\" ] && source \"$HOME/.bashrc.local\"" "$HOME/.bashrc"
  grep -qF "source \"$dotfiles/shell\"" "$HOME/.zshrc"
  grep -qF "[ -f \"$HOME/.zshrc.local\" ] && source \"$HOME/.zshrc.local\"" "$HOME/.zshrc"
  test -L "$HOME/.config/starship.toml"

  test "$(git config user.name)" = "Tobi Lutke"
  test "$(git config user.email)" = "tobi@shopify.com"

  # Tools are visible immediately but remain uninstalled until first use.
  test -x "$dotfiles/bin/shims/node"
  test -x "$dotfiles/bin/shims/ffmpeg"
  test -x "$dotfiles/bin/shims/gitleaks"
  test -x "$dotfiles/bin/shims/pi"
  test -x "$dotfiles/bin/shims/s"

  bash --noprofile --rcfile "$HOME/.bashrc" -i -c '
    set -e
    test "$DOTFILES_APPLY_NEEDED" -eq 0
    case ":$PATH:" in
      *":$HOME/.local/share/dotfiles/bin/shims:$HOME/.local/share/mise/shims:"*) ;;
      *) exit 1 ;;
    esac
    command -v node
    command -v ruby
    command -v uv
    command -v herdr
    command -v starship
    command -v ffmpeg
    command -v gitleaks
    command -v pi
    command -v s
    type try
    type apply
    alias t
    alias lg
    exit
  '

  # First use installs; subsequent runs use the installed version.
  "$dotfiles/bin/shims/node" --version
  node_version_before=$("$mise" latest --installed node@lts)
  "$dotfiles/bin/shims/node" --version
  test "$("$mise" latest --installed node@lts)" = "$node_version_before"

  DOTFILES_NO_SHIMS=1 bash --noprofile --rcfile "$HOME/.bashrc" -i -c '
    case ":$PATH:" in
      *":$HOME/.local/share/dotfiles/bin/shims:"*) exit 1 ;;
    esac
  '
}

run_installer
# The bootstrap installs mise itself, not its managed tools.
! "$HOME/.local/bin/mise" latest --installed node@lts >/dev/null 2>&1
assert_install

# Re-applying must update and preserve a working installation.
run_apply
assert_install

# Re-applying must not rewrite the rc entrypoints once they contain the lines.
rc_sum_before=$(cksum "$HOME/.zshrc" "$HOME/.bashrc")
run_apply
assert_install
test "$(cksum "$HOME/.zshrc" "$HOME/.bashrc")" = "$rc_sum_before"

# The installer must never provision SSH access.
test ! -e "$HOME/.ssh/authorized_keys"

echo "Ubuntu dotfiles E2E: OK"
CONTAINER

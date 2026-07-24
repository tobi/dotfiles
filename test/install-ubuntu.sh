#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ubuntu:24.04}"
INSTALL_URL="https://raw.githubusercontent.com/tobi/dotfiles/main/install.sh"

echo "Testing dotfiles installation on $IMAGE"

docker run --rm \
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

assert_install() {
  local dotfiles="$HOME/.local/share/dotfiles"
  local mise="$HOME/.local/bin/mise"

  test -d "$dotfiles/.git"
  test -x "$mise"
  test -L "$HOME/.bashrc"
  grep -qF "source \"$dotfiles/shell\"" "$HOME/.zshrc"

  test "$(git config --global user.name)" = "Tobi Lutke"
  test "$(git config --global user.email)" = "tobi@shopify.com"

  "$mise" exec -- node --version
  "$mise" exec -- ruby --version
  "$mise" exec -- uv --version

  # Confirm the generated Bash entrypoint activates mise-managed runtimes.
  bash --noprofile --rcfile "$HOME/.bashrc" -i -c '
    set -e
    command -v node
    command -v ruby
    command -v uv
    exit
  '
}

run_installer
assert_install

# A second run must preserve a working installation.
key_lines_before=$(wc -l < "$HOME/.ssh/authorized_keys")
run_installer
assert_install
key_lines_after=$(wc -l < "$HOME/.ssh/authorized_keys")
test "$key_lines_before" -eq "$key_lines_after"

echo "Ubuntu dotfiles E2E: OK"
CONTAINER

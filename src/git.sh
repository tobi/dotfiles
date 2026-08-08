# Keep Git identity and GitHub authentication wired up on every machine.
# These settings are global and idempotent, so sourcing this file is safe.
if command -v git >/dev/null 2>&1; then
  git config --global user.name "Tobi Lutke"
  git config --global user.email "tobi@shopify.com"

  # Sign commits with SSH. Reuses the existing ed25519 key (no GPG expiry
  # to manage). Only configure signing on machines that actually have the
  # key, so `apply` on a fresh host does not force gpgsign with nothing to
  # sign with.
  if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    git config --global gpg.format ssh
    git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub"
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
  fi

  # Let GitHub CLI manage HTTPS credentials when it is installed.
  if command -v gh >/dev/null 2>&1; then
    gh auth setup-git >/dev/null 2>&1 || true
  fi
fi

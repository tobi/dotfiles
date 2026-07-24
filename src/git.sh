# Keep Git identity and GitHub authentication wired up on every machine.
# These settings are global and idempotent, so sourcing this file is safe.
if command -v git >/dev/null 2>&1; then
  git config --global user.name "Tobi Lutke"
  git config --global user.email "tobi@shopify.com"

  # Let GitHub CLI manage HTTPS credentials when it is installed.
  if command -v gh >/dev/null 2>&1; then
    gh auth setup-git >/dev/null 2>&1 || true
  fi
fi

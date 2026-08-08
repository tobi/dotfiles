# Dotfiles bootstrap

Minimum viable shell env for linux machines

## Install

  ```bash
  curl https://raw.githubusercontent.com/tobi/dotfiles/main/install.sh | bash
  ```

The checkout is installed at `~/.local/share/dotfiles`.

Reconcile an existing machine—including Git, system packages, and Mise—with:

```bash
apply
```

Portable tools are installed lazily on first use from `bin/shims`; an existing
system or Homebrew command wins because that directory is last on `PATH`. Disable
them entirely with `DOTFILES_NO_SHIMS=1`. Upgrade tools already installed by a
shim with:

```bash
apply -u
```

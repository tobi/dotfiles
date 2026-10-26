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
them entirely with `DOTFILES_NO_SHIMS=1`. Agent CLIs (`pi`, `omp`, `opencode`,
`codex`) opt into mise `auto_update` and check for a newer build every four
hours. Upgrade other tools already installed by a shim with:

```bash
apply -u
```

## Ghostty

`apply` links shared Ghostty preferences from `config/_config.ghostty.config`
on machines without an existing config. Existing configs are left untouched.
The shared preferences enable all shell integration features (including automatic
SSH terminfo installation), close confirmation for active commands, and hiding
the mouse pointer while typing. Modified Enter and clipboard bindings are shared
as well. Ghostty and a particular font are not installed by this step.

Keep machine-specific fonts, themes, rendering options, and bindings in
`~/.config/ghostty/local.conf`. This optional file loads after the shared config
and can override it. To adopt shared preferences on an existing machine, back up
its config, move the settings you want to preserve into `local.conf`, then replace
`~/.config/ghostty/config` with a symlink to the shared file. Open a new terminal
to pick up shell integration changes. `tailscale ssh` bypasses Ghostty's shell
`ssh` wrapper; normal `ssh` over Tailscale can use that wrapper.

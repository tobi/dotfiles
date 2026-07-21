# Package recommendations ported from dotnix home.nix.
# Tools that need shell integration are handled in tools.sh; this file
# registers the remaining useful CLI tools so add_package_report can
# suggest installs for anything missing.

# Shell (dotfiles are zsh-first)
add_package "zsh"

# ── Core utilities ────────────────────────────────────────────────────
add_package "bc"
add_package "curl"
add_package "wget"
add_package "jq"
add_package "zstd"
add_apt_package "fswatch"
add_brew_package "fswatch"
add_apt_package "gh"
add_brew_package "gh"
add_pacman_package "github-cli"

# ── System tools ──────────────────────────────────────────────────────
add_package "dust"
add_package "htop"
add_package "btop"
add_package "psmisc"
add_package "mtr"
add_package "procs"
add_package "pv"
add_package "yazi"

# ── Development tools ─────────────────────────────────────────────────
add_package "ast-grep"
add_package "duckdb"
add_apt_package "envsubst"
add_brew_package "envsubst"
add_pacman_package "gettext"
add_package "ffmpeg"
add_package "hyperfine"
add_package "shellcheck"
add_package "sqlite"
add_package "tokei"
add_package "unzip"
add_package "git-lfs"
add_package "gitleaks"
add_package "socat"
add_package "glow"
add_apt_package "poppler-utils"
add_brew_package "poppler"
add_pacman_package "poppler"
add_package "tmux"

# ── Nice-to-have utilities ────────────────────────────────────────────
add_package "fastfetch"
add_package "gum"
add_apt_package "gcalcli"
add_brew_package "gcalcli"
add_package "rclone"

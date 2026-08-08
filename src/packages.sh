# Package recommendations ported from dotnix home.nix.
# Tools that need shell integration are handled in tools.sh. apply sources
# this declarative list when reconciling native system packages.

# Shell — zsh is optional (needed for right-prompt and richer keybindings);
# the dotfiles work fully in bash. Install only if you want rprompt.
# add_package "zsh"
# ── Core utilities ────────────────────────────────────────────────────
add_package "bc"
add_package "curl"
add_apt_package "libatomic1" # Required by mise's prebuilt Node binary.
add_package "wget"
add_package_mise "jq" "jq"
add_package "zstd"
add_apt_package "fswatch"
add_brew_package "fswatch"
add_package_mise "gh" "gh" "gh" "github-cli"

# ── System tools ──────────────────────────────────────────────────────
add_package_mise "dust" "" "dust" "dust"
add_package "htop"
add_package_mise "btop" "btop"
add_package "psmisc"
add_package "mtr"
add_brew_package "procs"
add_pacman_package "procs"
add_package "pv"
add_package_mise "yazi" "" "yazi" "yazi"

# ── Development tools ─────────────────────────────────────────────────
add_package_mise "ast-grep" "" "ast-grep" "ast-grep"
add_package_mise "duckdb" "" "duckdb" "duckdb"
add_package_mise "envsubst" "gettext-base" "gettext" "gettext"
add_package_mise "ffmpeg" "ffmpeg"
add_package_mise "hyperfine" "hyperfine"
add_package_mise "shellcheck" "shellcheck"
add_package_mise "sqlite" "sqlite3" "sqlite" "sqlite"
add_package "unzip"
add_package_mise "git-lfs" "git-lfs"
add_package_mise "gitleaks" "gitleaks"
add_package "socat"
add_package_mise "glow" "" "glow" "glow"
add_apt_package "poppler-utils"
add_brew_package "poppler"
add_pacman_package "poppler"
add_package_mise "tmux" "tmux"

# ── Nice-to-have utilities ────────────────────────────────────────────
add_package "grc"
add_apt_package "trash-cli"
add_brew_package "trash"
add_pacman_package "trash-cli"
add_package_mise "fastfetch" "" "fastfetch" "fastfetch"
add_package_mise "gum" "" "gum" "gum"
add_package_mise "rclone" "rclone"

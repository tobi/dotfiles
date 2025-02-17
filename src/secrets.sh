
secrets() {
    eval "$(~/dotfiles/bin/secrets activate)"
    unset -f secrets
}


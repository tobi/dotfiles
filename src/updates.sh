#!/usr/bin/env bash
set -e

git -C "$DOTFILES_PATH" pull --rebase

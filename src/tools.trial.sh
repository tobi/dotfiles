# trial - Quick trial directory creator and navigator.
# Wraps the `trial` bin (gum-based picker) and cd's into the selected path.

trial() {
  local path
  path="$("$DOTFILES_PATH/bin/trial" "$@")" || return $?
  [[ -n "$path" ]] && cd "$path"
}

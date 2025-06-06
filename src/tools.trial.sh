# test - Quick trial directory creator and navigator

words() {
  local num=${1:-2}
  local words
  words=$(cat /usr/share/dict/words | shuf -n "$num" | tr '\n' '-' | tr '[:upper:]' '[:lower:]')
  echo "${words%-}" # Remove trailing hyphen
}

trial() {
  local TRIAL_DIR=$HOME/src/trials
  local PROJECT_NAME=${*:-$(words 2)}
  local DATE_PREFIX=$(date +%Y-%m-%d)
  local DEFAULT_NAME="${DATE_PREFIX}-${PROJECT_NAME}"
  local selected_trial
  local existing_trials
  local FULL_PATH

  # Create trial directory if it doesn't exist
  mkdir -p "$TRIAL_DIR"

  # Find existing trial directories (excluding the parent directory itself)
  existing_trials=$(find "$TRIAL_DIR" -maxdepth 1 -type d -not -path "$TRIAL_DIR" 2>/dev/null | sort -r)

  # Use fzf to select or create new trial
  if [ -n "$existing_trials" ]; then
    # Show existing trials and allow creating new one
    selected_trial=$(printf "%s\n%s" "$DEFAULT_NAME" "$(basename -a $existing_trials)" |
      fzf --prompt="Select existing trial or create new: " \
        --header="↑↓ to navigate, Enter to select, Ctrl-C to cancel" \
        --height=15 \
        --reverse \
        --query="$DEFAULT_NAME")
  else
    # No existing trials, just use the default name
    selected_trial="$DEFAULT_NAME"
  fi

  # Handle cancellation
  if [ -z "$selected_trial" ]; then
    echo "Cancelled."
    return 1
  fi

  # Create the selected directory
  FULL_PATH="$TRIAL_DIR/$selected_trial"
  mkdir -p "$FULL_PATH"

  echo "Created/selected: $FULL_PATH"

  cd "$FULL_PATH" || return 1
}

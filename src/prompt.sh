#!/usr/bin/env bash

# Define the function to parse git branch and modifications
git_branch_to_env() {
  local git_status
  git_status=$(git status --porcelain --branch 2>/dev/null)
  GIT_BRANCH=$(echo "$git_status" | sed -n 's/^## //;s/\.\.\..*//p')
  GIT_MODS=$(echo "$git_status" | grep -cv "^??")
  export GIT_BRANCH GIT_MODS
}

# Color function
color() {
  echo "\[\033[38;5;${1}m\]"
}

# Reset color
reset_color() {
  echo "\[\033[0m\]"
}

# Define color variables
cyan=$(color 6)
magenta=$(color 5)
blue=$(color 4)
green=$(color 2)
red=$(color 1)
reset=$(reset_color)

# Chevron prompt
chevron=$(printf '%s❯%s❯%s❯%s' "$(color 70)" "$(color 220)" "$(color 209)" "$reset")

# Function to update the prompt for Zsh
update_prompt_zsh() {
  local exit_code=$?
  local branch=""
  local rprompt=""

  # Check for GIT_BRANCH and set the branch and rprompt
  if [[ -n $GIT_BRANCH ]]; then
    branch=" ${cyan}($GIT_BRANCH)${reset}"
    rprompt="${green}(git) $GIT_BRANCH: +$GIT_MODS${reset}"
  fi

  # Check for virtual environments
  if [[ -n $VIRTUAL_ENV ]]; then
    rprompt="$rprompt ${magenta}[venv:$(basename "$VIRTUAL_ENV")]${reset}"
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    rprompt="$rprompt ${magenta}(conda) $CONDA_DEFAULT_ENV${reset}"
  fi

  # Set host for SSH connections
  local host=""
  if [[ -n $SSH_CONNECTION ]]; then
    host="${green}[$(hostname)] "
  fi

  # Set exit code indicator
  local exit_indicator=""
  if [[ $exit_code -ne 0 ]]; then
    exit_indicator="${red}✘ ${exit_code}${reset}"
  fi

  # Set prompt
  PS1="${exit_indicator}${host}${blue}\u ${blue}\w${branch} ${chevron}${reset} "

  # Set right-side prompt on a new line
  PS1+="\n\$(echo -e \"$rprompt\")"

  # Set terminal title
  echo -ne "\033]0;${PWD##*/}${GIT_BRANCH:+ ($GIT_BRANCH)}\007"
}

# Function to update the prompt for Bash
update_prompt_bash() {
  local exit_code=$?
  local branch=""
  local rprompt=""

  # Check for GIT_BRANCH and set the branch and rprompt
  if [[ -n $GIT_BRANCH ]]; then
    branch=" ${cyan}($GIT_BRANCH)${reset}"
    rprompt="${green}(git) $GIT_BRANCH: +$GIT_MODS${reset}"
  fi

  # Check for virtual environments
  if [[ -n $VIRTUAL_ENV ]]; then
    rprompt="$rprompt ${magenta}[venv:$(basename "$VIRTUAL_ENV")]${reset}"
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    rprompt="$rprompt ${magenta}(conda) $CONDA_DEFAULT_ENV${reset}"
  fi

  # Set host for SSH connections
  local host=""
  if [[ -n $SSH_CONNECTION ]]; then
    host="${green}[$(hostname)] "
  fi

  # Set exit code indicator
  local exit_indicator=""
  if [[ $exit_code -ne 0 ]]; then
    exit_indicator="${red}✘ ${exit_code}${reset}"
  fi

  if [[ -n $rprompt ]]; then
    rprompt="-> $rprompt\n"
  fi

  # Set prompt
  PS1="[bash] ${exit_indicator}${host}${blue}\u ${blue}\w${branch} ${chevron}${reset} "

  # Set terminal title (works in most terminal emulators)
  PS1+="\[\033]0;\w\007\]"
}

if [[ -n $BASH ]]; then
  PROMPT_COMMAND="git_branch_to_env; update_prompt_bash"
else
  PROMPT_COMMAND="git_branch_to_env; update_prompt_zsh"
fi

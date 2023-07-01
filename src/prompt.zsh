function git_branch_to_env() {
  local git=$(git status 2>/dev/null)
  export GIT_BRANCH=$(echo $git | head -n 1 | sed -e 's/^On branch \(.*\)/\1/')
  export GIT_MODS=$(echo $git | grep "\t" | wc -l)
}


local chevron="%F{#A5D6A7}❯%F{FFF59D}❯%F{#FFAB91}❯%f"
[[ $SSH_CONNECTION ]] && local host="%F{#FFAB91}@ssh:%n" || local host=""

function update_prompt() {
  local branch=""
  local rprompt=""

  if [[ $GIT_BRANCH != "" ]]; then
    branch=" %F{cyan}($GIT_BRANCH) "
    rprompt="%F{green}(git) $GIT_BRANCH: +$GIT_MODS %f"
  fi

  # PS1
  export PROMPT="%F{#A5D6A7}%n$host %F{blue}%~$branch $chevron%f "
  export RPROMPT="$rprompt"

  # terminal title
  export PROMPT_COMMAND='echo -ne "\033]0;$(basename "$(dirname $PWD)")/$(basename $PWD) $GIT_BRANCH\007"'
}

precmd_functions+=(git_branch_to_env update_prompt)


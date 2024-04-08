local sentinel=/tmp/dotfiles.sentinel
# check if the sentinel file exists, or if its older than 2 days
if [ ! -f $sentinel ] || [ $(find $sentinel -mtime +2) ]; then
  cd $DOTFILES_PATH
  git pull
  [[ $? -eq 0 ]] && touch $sentinel
  cd $HOME
fi

# Change to the dotfiles/config directory
cd $HOME/dotfiles/config

# Loop through all files in the directory
for file in *; do
  basename=$(basename "$file")
  # Skip if it's not a file
  [ -f "$file" ] || continue
  [ "$basename" == "link.sh" ] && continue

  ext=$(echo "$file" | awk -F. '{print $NF}')
  basename_without_ext=$(echo "$basename" | sed 's/\.'$ext'//g')

  # Replace . with / and _ with .
  destination=$HOME/$(echo "$basename_without_ext" | sed 's/\./\//g' | sed 's/_/./g').$ext

  if [ -f "$destination" ]; then
    echo "File $destination already exists"
    continue
  fi

  echo "linking $destination to ./$file"

  # link the file
  ln -s "$HOME/$file" "$destination"

  echo "linked $destination to $file"
done

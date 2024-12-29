# Change to the dotfiles/config directory
cd $HOME/dotfiles/config

# Loop through all files in the directory
for file in *; do
  realpath=$(realpath "$file")
  basename=$(basename "$file")
  # Skip if it's not a file
  [ -f "$file" ] || continue
  [ "$basename" == "link.sh" ] && continue

  ext=$(echo "$file" | awk -F. '{print $NF}')
  #basename_without_ext=$(echo "$basename" | sed 's/\.'$ext'//g')

  # Replace:
  #   .  -> /
  #   _  -> .

  destination=$HOME/$(echo "$basename" | sed 's/\./\//g' | sed 's/_/./g')

  if [ "$1" != "-f" ] && [ -f "$destination" ]; then
    echo "File $destination already exists, skipping... (or use -f)"
    continue
  fi

  echo "linking $destination to ./$file"

  # link the file
  ln -nfs "$realpath" "$destination"

  echo " [OK]"
done

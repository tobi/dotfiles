# Change to the dotfiles/config directory
cd $HOME/dotfiles/config

# Loop through all files in the directory
for file in *; do
  # Skip if it's not a file
  [ -f "$file" ] || continue

  # Replace . with / and _ with .
  destination=$(echo "$file" | sed 's/\./_/g' | sed 's/_/./g')

  # link the file
  ln -s "$file" "$destination"

  echo "linked $destination to $file"
done

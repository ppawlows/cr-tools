#!/bin/bash

# Check if a URL is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

# Assign the provided URL to a variable
url="$1"

# Remove the sampleEndTime parameter
modified_url=$(echo "$url" | sed -E 's/(&|\?)sampleEndTime=[^&]*//g' | sed -E 's/&{2,}/&/g' | sed -E 's/\?$//g')

# Determine the OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  echo "$modified_url" | pbcopy
  echo "Modified URL has been copied to the clipboard on macOS."
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux (Fedora or others)
  if command -v wl-copy &> /dev/null; then
    echo "$modified_url" | wl-copy
    echo "Modified URL has been copied to the clipboard using wl-copy (Wayland)."
  elif command -v xclip &> /dev/null; then
    echo "$modified_url" | xclip -selection clipboard
    echo "Modified URL has been copied to the clipboard using xclip (X11)."
  else
    echo "Error: Clipboard tool not found. Install 'xclip' or 'wl-clipboard'."
    exit 1
  fi
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# Display the modified URL
echo "$modified_url"


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

# Detect the OS and calculate 7 days ago at midnight
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: Use BSD date
  sample_start_time=$(date -v-7d '+%Y-%m-%d 00:00:00')
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux: Use GNU date
  if command -v date &>/dev/null && date --version 2>/dev/null | grep -q "GNU"; then
    sample_start_time=$(date -d "-7 days" '+%Y-%m-%d 00:00:00')
  else
    echo "Error: Unsupported date command on Linux. Please use a GNU-compatible date command."
    exit 1
  fi
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# Replace or append sampleStartTime with the calculated value
if [[ "$modified_url" =~ sampleStartTime= ]]; then
  # Update existing sampleStartTime parameter
  modified_url=$(echo "$modified_url" | sed -E "s/(sampleStartTime=)[^&]*/\1$(echo $sample_start_time | sed 's/ /%20/g')/")
else
  # Append sampleStartTime if it doesn't exist
  separator="&"
  [[ "$modified_url" != *"?"* ]] && separator="?"
  modified_url="${modified_url}${separator}sampleStartTime=$(echo $sample_start_time | sed 's/ /%20/g')"
fi

# Determine the clipboard tool and copy the URL
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
  echo "Unsupported OS for clipboard copying: $OSTYPE"
  exit 1
fi

# Display the modified URL
echo "$modified_url"


#!/bin/zsh

# Brandon Chesser - CPU IT, inc
# This is the actual worst script I've ever written and I'm embarrased to put it on GitHub

# This script checks if a specific launchd is running and disables it
# You can use an exact or partial name of a running launchd

# The launchd you would like to search for
search_term="connectwisecontrol"
echo "Searching for $search_term."
# Checks for a loaded launchd
launchd_actual=$(sudo launchctl list | awk -v term="$search_term" '$0 ~ term {print $3}')
echo "Found $launchd_actual."
# Searches system launchd folder for a plist
launchd_actual_plist=$(ls -a /Library/LaunchDaemons | grep "$launchd_actual")
# Adds the full path as a separate variable
launchd_actual_path="/Library/LaunchDaemons/$launchd_actual_plist"

# CODE
if [ -z "$launchd_actual" ]; then
    echo "launchd $search_term not found."
else
    echo "Unloading $launchd_actual at $launchd_actual_path"
    sudo launchctl unload -w $launchd_actual_path
fi
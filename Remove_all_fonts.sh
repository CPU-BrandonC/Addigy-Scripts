#!/bin/zsh

# Font removal script

# WARNING!!! THIS SCRIPT REMOVES ALL USER/SYSTEM FONTS

current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

sudo rm -f /Users/$current_user/Library/Fonts/*.*
sudo rm -f /Library/Fonts/*.*
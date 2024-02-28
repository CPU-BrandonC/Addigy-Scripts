#!/bin/zsh

# Font removal script.

# WARNING!!! THIS SCRIPT REMOVES ALL FONTS WITH A SIMILAR NAME (SEE WILDCARDS)!!!

font_to_remove="FontName"
current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

sudo rm -f  /Users/$current_user/Library/Fonts/*$font_to_remove*
sudo rm -f /Library/Fonts/*$font_to_remove*
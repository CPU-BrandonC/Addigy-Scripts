#!/bin/zsh

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

sudo rm -f  /Users/$currentUser/Library/Fonts/*STIHL*
sudo rm -f /Library/Fonts/*STIHL*
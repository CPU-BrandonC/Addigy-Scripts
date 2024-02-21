#!/bin/zsh

# Brandon Chesser - CPU IT, inc
# This script is a crude reversal of the Disable_launchd script

search_term="connectwisecontrol"
launchd_actual_plist=$(sudo ls -a /Library/LaunchDaemons/ | grep "$search_term")

if [ -z "$launchd_actual_plist" ]; then
    echo "Unable to find $search_term in /Library/LaunchDaemons"
    return 1
else
    echo "Found /Library/LaunchDaemons/$launchd_actual_plist. Loading $launchd_actual_plist."
    sudo launchctl load -w /Library/LaunchDaemons/$launchd_actual_plist
    if [ $? -eq 0 ]; then
        echo "Successfully loaded $launchd_actual_plist."
        return 0
    else
        echo "Failed to load $launchd_actual_plist"
        return 1
    fi
fi
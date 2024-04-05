#!/bin/zsh

# Updates app with Adobe RUM and prompts user to save their work with SwiftDialog2

# Change these to fit your needs
version_to_update="25" # The version does not necessarily match the year
app_full_name="Adobe Photoshop 2024" # This must exactly match the app name
app_short_name="PHSP" # This is the 4 character code Adobe assigns to each app in RUM
timeout=120 # How long in seconds the user should be given to save their work. It may take longer than expected to timeout based on proccessing speed.

# Dialog options
dialog_button1_text="Install Update"
dialog_button2_text="Cancel"
dialog_title="Update Available"
dialog_message="A new update is available for $app_full_name. Clicking $dialog_button1_text will prompt you to save any open files and quit $app_full_name."

# Don't change anything after this line

current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# Check if app update is available
echo "INFO: Checking for app updates..."
rum_update_list=$(sudo /usr/local/bin/RemoteUpdateManager --action=list | grep -q "$app_code/$version_to_update")
if [[ $?  -eq 0 ]]
then
    echo "INFO: $app_full_name update available."
    update_full_version=$(echo $rum_update_list | awk -F '/' '{print $2}')
    update_short_version=$(echo $update_full_version | awk -F '.' '{print $1}')
else
    echo "WARNING: $app_full_name not installed or update not available"
    exit 0 # <---- This is not an error and will end the script as a "success."
fi

# Update command
update_app() {
    /usr/local/bin/RemoteUpdateManager "--productVersions=$app_short_name#$version_to_update.0"
    case $? in
        0)
            echo "INFO: $app_full_name update successful."
            echo "INFO: Reopening $app_full_name."
            sudo -u $current_user open "/Applications/$app_full_name/$app_full_name.app"
            exit 0
            ;;
        2)
            echo "ERROR: $app_full_name update failed because it was open. It may have been opened by the user before the update way complete."
            exit 2
            ;;
        *)
            echo "ERROR: $app_full_name update failed for an unknown reason. The installation may be corrupted or network is not available."
            exit 1
    esac
}

# Check for SwiftDialog2
echo "INFO: Checking for SwiftDialog"
if [ -f "/usr/local/bin/dialog" ]
then
    echo "INFO: SwiftDialog is installed."
else
    echo "ERROR: SwiftDialog NOT installed."
    exit 1
fi

# Check for Adobe Remote Update Manager
echo "INFO: Checking for Adobe RUM"
if [ -f "/usr/local/bin/RemoteUpdateManager" ]
then
    echo "INFO: Adobe RUM is installed."
else
    echo "ERROR: Adobe RUM NOT installed."
    exit 1
fi

# Check if Photoshop is currently running
if pgrep "$app_full_name" > /dev/null
then
    echo "WARNING: $app_full_name is open."
    echo "INFO: Prompting user to close $app_full_name."
    # I'm putting each option on its own line for better readability.
    /usr/local/bin/dialog --title "$dialog_title" \
        --message "$dialog_message" \
        --button1text "$dialog_button1_text" \
        --button2text "$dialog_button2_text" \
        --icon "/Applications/$app_full_name/$app_full_name.app" \
        --moveable \
        --mini
    case $? in
        0)
            echo "INFO: User clicked $dialog_button1_text"
            echo "INFO: Quitting $app_full_name gracefully."
            osascript -e "tell application \"$app_full_name\" to quit"
            # Check that app is actually closed. Wait for timeout.
            count=0
            while pgrep "$app_full_name" > /dev/null
            do
                sleep 1
                count=$((count+1))
                if [ $count -ge $timeout ]
                then
                    echo "WARNING: Timeout reached. The user did not save their work on time. $(tput bold)BAILING.$(tput sgr0)"
                    break
                fi
            done

            if [ $count -lt $timeout ]
            then
                echo "INFO: $app_full_name closed. Starting update."
                update_app
            fi
            ;;
        2)
            echo "WARNING: User clicked $dialog_button2_text."
            echo "ERROR: The update failed because the user clicked $dialog_button2_text."
            exit 1
            ;;        
    esac
else
    echo "INFO: $app_full_name not open. Proceeding with update."
    update_app
fi
#!/bin/zsh

# Brandon Chesser - CPU IT, inc | https://www.c-p-u.com/
# brandon.chesser@c-p-u.com | 573.708.7003

# Updates app with Adobe RUM and prompts user to save their work with SwiftDialog2

#### Common Adobe Apps and SAP codes ### 
# Full list can be found here: https://helpx.adobe.com/enterprise/kb/apps-deployed-without-base-versions.html

# NAME                         | SAP  |  Version
# ---------------------------- |------|----------
# Adobe Photoshop 2024         | PHSP |  25
# Adobe Illustrator            | ILST |  28   <----This app doesn't have the year in the title 🤷‍♂️
# Adobe InDesign 2024          | IDSN |  19
# Adobe Premiere Rush          | RUSH |  2    <----This app doesn't have the year in the title 🤷‍♂️
# Adobe Premiere Pro 2024      | PPRO |  24
# Adobe Audition 2024          | AUDT |  24
# Adobe Lightroom CC           | LRCC |  7    <----This app doesn't have the year in the title 🤷‍♂️
# Adobe Lightroom Classic      | LTRM |  13   <----This app doesn't have the year in the title 🤷‍♂️
# Adobe After Effects 2024     | AEFT |  24
# Adobe Bridge 2024            | KBRG |  14
# Adobe Animate                | FLPR |  24
# Adobe Media Encoder 2024     | AME  |  24

# Change these to fit your needs
version_to_update="14" # The version does not necessarily match the year
app_full_name="Adobe Bridge 2024" # This must exactly match the app name
sap_code="KBRG" # This is the 3-4 character code Adobe assigns to each app in RUM
timeout=300 # How long in seconds the user should be given to save their work. It may take longer than expected to timeout based on proccessing speed.

# Dialog options
dialog_button1_text="Install Update"
dialog_button2_text="Cancel"
dialog_title="Update Available"
dialog_message="Update available for $app_full_name. Clicking $dialog_button1_text will quit and update $app_full_name. The update can take up to 20 minutes and will automatically reopen $app_full_name."

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
    # Send Toast
    /usr/local/bin/dialog --notification --title "Update started" --message "$app_full_name update started." --icon "/Applications/$app_full_name/$app_full_name.app"
    /usr/local/bin/RemoteUpdateManager "--productVersions=$sap_code" # This should have a version but it doesn't seem to work with a version listed...
    case $? in
        0)
            echo "INFO: $app_full_name update successful."
            # Sends toast 
            /usr/local/bin/dialog --notification --title "Update complete" --message "$app_full_name update complete." --icon "/Applications/$app_full_name/$app_full_name.app"
            # Reopen App
            if [[ $app_open == "true" ]]
            then
                echo "INFO: Reopening $app_full_name."
                sudo -u $current_user open "/Applications/$app_full_name/$app_full_name.app"
                exit 0
            else
                echo "INFO: $app_full_name was not open when update was started. No action will be taken."
                exit 0
            fi
            ;;
        2)
            echo "ERROR: $app_full_name update failed because it was open. It may have been opened by the user before the update was completed."
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
    echo "WARNING: SwiftDialog NOT installed."
    # Checks if Installomator is installed before attempting to install SwiftDialog
    if [ -f "/usr/local/Installomator/Installomator.sh" ]
    then
        echo "INFO: Installing SwiftDialog."
        echo "INFO: Waiting up to 120 seconds for SwiftDialog to install."
        /usr/local/Installomator/Installomator.sh dialog DEBUG=0 PROMPT_TIMEOUT=120
        if [ $? -ne 0 ]
        then
            echo "ERROR: SwiftDialog installation failed. Unable to proceed with update."
            exit 1
        fi
    else
        echo "ERROR: Installomator not installed. Unable to proceed with update."
        exit 1
    fi
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

# Check if app is currently open
if pgrep "$app_full_name" > /dev/null
then
    app_open="true"
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
            echo "INFO: Waiting up to $timeout seconds for user to save their work..."
            # Check that app is actually closed. Wait for timeout.
            count=0
            while pgrep "$app_full_name" > /dev/null
            do
                sleep 1
                count=$((count+1))
                if [ $count -ge $timeout ]
                then
                    echo "ERROR: Timeout reached. The user did not save their work on time. Unable to proceed with update."
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
    app_open=false
    update_app
fi
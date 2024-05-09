#!/bin/zsh

current_user=""

# log to disk
if [[ -f "/var/log/chrome_sso_repair.log" ]]
then
    echo "Start of logging history.." > /var/log/chrome_sso_repair.log
else
    touch /var/log/chrome_sso_repair.log
fi

while [ -z $current_user ]
do
    sleep 5
    current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
done

echo "INFO: Current user is $current_user" >> /var/log/chrome_sso_repair.log

echo "INFO: Verifying Chrome is installed..." >> /var/log/chrome_sso_repair.log
if [[ -d "/Applications/Google Chrome.app" ]]
then
    echo "INFO: Google Chrome installed." >> /var/log/chrome_sso_repair.log
else
    echo "ERROR: Google Chrome Not installed! Please install Google Chrome before running this utility." >> /var/log/chrome_sso_repair.log
    exit 1
fi

echo "INFO: Verifying Company Portal is installed..." >> /var/log/chrome_sso_repair.log
if [[ -d "/Applications/Company Portal.app" ]]
then
    echo "INFO: Company Portal installed." >> /var/log/chrome_sso_repair.log
else
    echo "ERROR: Company Portal not installed! Please install Company Portal before running this utility." >> /var/log/chrome_sso_repair.log
    exit 1
fi

echo "INFO: Waiting 60 seconds to ensure no race conditions when creating new folders..." >> /var/log/chrome_sso_repair.log
sleep 60

echo "INFO: Verifying Application Support Folder exists..."
if [[ ! -d "/Users/$current_user/Library/Application Support" ]]
then
    echo "ERROR: Application Support Folder does not exist!"
    exit 1
fi

echo "INFO: Verifying Google Chrome SSO Extension directory exists..." 
if [[ -d "/Users/$current_user/Library/Application Support/Google/Chrome/NativeMessagingHosts" ]]
then
    echo "INFO: Directory exists." >> /var/log/chrome_sso_repair.log
else
    echo "INFO: Directory does not exist. Creating new directory..." >> /var/log/chrome_sso_repair.log
    mkdir -p "/Users/$current_user/Library/Application Support/Google/Chrome/NativeMessagingHosts" 2>> /var/log/chrome_sso_repair.log
    echo "INFO: Changing ownership to $current_user..."
    chown -R $current_user:staff "/Users/$current_user/Library/Application Support/Google" 2>> /var/log/chrome_sso_repair.log
fi

echo "INFO: Copying SSO Extension file to Google Chrome directory..." >> /var/log/chrome_sso_repair.log
cp "/Applications/Company Portal.app/Contents/Resources/com.microsoft.browsercore.json" "/Users/$current_user/Library/Application Support/Google/Chrome/NativeMessagingHosts/" 2>> /var/log/chrome_sso_repair.log
echo "INFO: Changing ownership to $current_user..."
chown $current_user:staff "/Users/$current_user/Library/Application Support/Google/Chrome/NativeMessagingHosts/"


if [ -f "/Users/$current_user/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.microsoft.browsercore.json" ]
then
    echo "INFO: SSO Extension files successfully copied." >> /var/log/chrome_sso_repair.log
    exit 0
else
    echo "ERROR: SSO Extension files not copied!" >> /var/log/chrome_sso_repair.log
    exit 1
fi
#!/bin/sh

#### Conditions Script ####

# Script is based off of nopkg code written by Walter Meyer and Nick McSpadden in the early days of Munki. Rewritten in 2019 by Michael Page for use with Addigy.

### Printer Variables ###
current_version="2.0.0"
display_name="Upstairs Printer"
address="192.168.0.243"
use_ipp_everywhere=true
protocol="ipp"

### Nothing below this line needs to change. ###

if [ "$use_ipp_everywhere" = true ]; then
    if ! ping -c 1 -W 500 "${address}" &> /dev/null; then
        echo "IPP Everywhere Printer not accessible on the network, can't install"
        exit 1
    fi

    if [ "$protocol" = ipps ]; then
        if ! ipptool ipps://"${address}"/ipp/print get-printer-attributes.test &> /dev/null; then
            echo "ipps Secure Connection can not be made, try ipp as your protocol instead"
            exit 1
        fi
    fi
fi 
# Function to convert dot separated version numbers into an integer for comparison purposes.
# Examples: "2.1.0" -> 2001000, "52.14.7" -> 52014007.
function version {
    echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }';
}

# Set name to be lowercased display_name with only alphanumeric characters.
name=$(echo "$display_name" | /usr/bin/tr -dc '[:alnum:]' | /usr/bin/tr '[:upper:]' '[:lower:]')

# Determine if the printer was previously installed.
if [ -f "/private/etc/cups/deployment/receipts/${name}.plist" ]; then
    # Get the script version number that was used to install the printer.
    installed_version=$(/usr/libexec/PlistBuddy -c "Print :version" "/private/etc/cups/deployment/receipts/${name}.plist")
    echo "Previously installed version of ${name}: $installed_version"
else
    echo "Printer ${name} was not previously installed."
    installed_version="0"
fi

# If a matching print queue with that name already exists.
if /usr/bin/lpstat -p "$name"; then
    # If the installed printer version is equal (or somehow newer) to the printer version in this script.
    if [ "$(version "$installed_version")" -ge "$(version "$current_version")" ]; then
        # The printer installed is the current or newer version, no need to reinstall it.
        echo "The installed printer (${name}) is already up-to-date, no need to reinstall."
        exit 1
    fi
fi

# Printer configuration is outdated or missing, trigger install printer.
exit 0

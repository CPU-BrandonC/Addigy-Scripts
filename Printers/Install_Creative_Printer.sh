#!/bin/sh

#### Installation Script ####

# Script is based off of nopkg code written by Walter Meyer and Nick McSpadden in the early days of Munki. Rewritten in 2019 by Michael Page for use with Addigy.

### Printer Variables ###
# Variable current_version is useful for deploying printer alterations over time. The version should always match the Custom Software version in Addigy.
# Incrementation examples: 1.1.0 = Printer location description changed, 2.0.0 = Printer has been replaced with a newer model. 
current_version="2.0.0"

# The printer name displayed to users, once printer has been deployed this should not change, as changing the name will result in duplicate printers.
display_name="Upstairs Printer"

# Physical location of the printer.
location="3rd floor"

# Protocol used to connect to the printer (dnssd, lpd, ipp, ipps, http, socket).
protocol="ipp"

# Network address of the printer can be an IP address, hostname or DNS-SD address.
# DNS-SD address example: "HP%20LaserJet%20400%20colorMFP%20M475dn%20(626EDC)._ipp._tcp.local./?uuid=434e4438-4637-3934-3737-a45d36626edc"
# 
address="192.168.0.243"

# Use the 'Everywhere' model - soon to be the only supported model in CUPS. We assume that the IPP path is /ipp/print below.
use_ipp_everywhere="true"

### If use_ipp_everywhere is true, then the below options are not needed

# Path to printer driver (PPD).
driver_ppd="Library/Printers/PPDs/Contents/Resources/en.lproj/Xerox EX-c C9065-70 Printer 2.0 Xerox EX-c C9065-70 Printer 2.0"

# Specific options for the printer.
# To find available options, manually add the printer to a Mac and run: lpoptions -p "$insert_cups_printer_name_here" -l
# To list installed CUPS printer queue names run: lpstat -p | /usr/bin/awk '{print $2}'
# option_1="PageSize=A4"
# option_2="Duplex=None"
# option_3=""

### Nothing below this line needs to change. ###

# Function to convert dot separated version numbers into an integer for comparison purposes.
# Examples: "2.1.0" -> 2001000, "52.14.7" -> 52014007.
function version {
    echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }';
}

# Set name to be lowercased display_name with only alphanumeric characters.
name=$(echo "$display_name" | /usr/bin/tr -dc '[:alnum:]' | /usr/bin/tr '[:upper:]' '[:lower:]')

# Ensure required printer driver is on disk.
if [ "$use_ipp_everywhere" = "false" ]; then
    /bin/ls "$driver_ppd"
fi

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
        exit 0
    fi
    # Printer installed is of a lesser version, therefore we will remove the outdated printer, ready for reinstall.
    echo "The installed printer (${name}) needs to be updated, will remove and reinstall."
    /usr/sbin/lpadmin -x "$name"
fi

# Install the printer.
if [ "$use_ipp_everywhere" = "true" ]; then
    /usr/sbin/lpadmin -p "$name" -L "$location" -D "$display_name" -v "${protocol}"://"${address}"/ipp/print -m everywhere -E -o landscape -o printer-is-shared=false #(this was causing errors) -o printer-error-policy=abort-job
else
    /usr/sbin/lpadmin -p "$name" -L "$location" -D "$display_name" -v "${protocol}"://"${address}" -P "$driver_ppd" -E -o landscape -o printer-is-shared=false -o printer-error-policy=abort-job -o "$option_1" -o "$option_2" -o "$option_3"
fi


# Create/update a receipt for the printer.
/bin/mkdir -p /private/etc/cups/deployment/receipts
/usr/libexec/PlistBuddy -c "Add :version string" "/private/etc/cups/deployment/receipts/${name}.plist" 2> /dev/null || true
/usr/libexec/PlistBuddy -c "Set :version $current_version" "/private/etc/cups/deployment/receipts/${name}.plist"

# Permission the directories properly.
/usr/sbin/chown -R root:_lp /private/etc/cups/deployment
/bin/chmod 755 /private/etc/cups/deployment
/bin/chmod 755 /private/etc/cups/deployment/receipts

exit 0
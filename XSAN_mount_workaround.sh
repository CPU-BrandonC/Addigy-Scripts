#!/bin/sh

# This script manually mounts an XSAN volume when unable to mount with 'xsanctl'
# This is a workaround for a bug introduced in MacOS 12.7.2+, 13.6.2+ 14.2+

xsan_logging_directory="/Library/Logs/Xsan/debug/"
# Check xsan_logging_directory for mount-debug.xxxx log files for the most recent
latest_log=$(find $xsan_logging_directory -type f -name 'mount-debug.*' -exec ls -t {} + | head -n 1)
xsan_mount_error="Unrecognized option: 'owners'"
mount_point="/Volumes/QSAN"

echo "Latest log is $latest_log"

function xsan_manual_mount {
    # Checks the XSAN disk in $latest_log and stores it as a variable
    # This line is dumb as **** but it works
    xsan_disk=$(cat $latest_log | grep "find_IORegistryBSDName: searching for" | awk -F'[<>]' '{print $2}')
    # Create a mount point
    echo "Creating empty directory at $mount_point"
    mkdir $mount_point
    # I know, I'm a monster. Just ignore this part. It's only temporary.
    echo "Modifying permissions"
    sudo chmod 777 $mount_point
    # Manually mounts the XSAN disk
    echo "Manually mounting /dev/$xsan_disk @ $mount_point"
    # I don't know why but this doesn't work right without sudo, even when running as root
    sudo /System/Library/Filesystems/acfs.fs/Contents/bin/mount_acfs -o rw -o nofollow /dev/$xsan_disk $mount_point
    sleep 2
    if [ "$(ls -A $mount_point)" ]; then
        echo "$mount_point is not empty"
        return 0
    else
        echo "$mount_point is empty! Failed to mount QSAN"
        return 1
    fi
}

function reload_xsan {
    echo "Restarting com.apple.xsan."
    # Sometimes this command fails if com.apple.xsan isn't running
    launchctl unload /System/Library/LaunchDaemons/com.apple.xsan.plist || true
    sleep 1
    launchctl load -w /System/Library/LaunchDaemons/com.apple.xsan.plist
    sleep 2
    xsanctl mount QSAN
    if [ $? -eq 0 ]; then
        echo "Successfully restarted com.apple.xsan"
        return 0
    else
        echo "Failed to restart com.apple.xsan. Manually reload it and try again."
        return 1
    fi
}

# Check if any log files were found
if [ -n "$latest_log" ]; then
    # Checks for mount error in $latest_log without spamming the entire log file :)
    if grep -q "$xsan_mount_error" "$latest_log"; then
        xsan_manual_mount
        if [ $? -eq 0 ]; then
            echo "Succesfully connected to $mount_point"
        else
            echo "Failed to connect to $mount_point"
        fi
    else
        echo "No mount error found in $latest_log. Is com.apple.xsan running?"
        # Checks is $mount_point exists
        if [ -d "$mount_point" ]; then
            # Checks if $mount_point is empty
            if [ "$(ls -A $mount_point)" ]; then
                echo "$mount_point is not empty! Aborting. Unmount $mount_point and try again."  
                echo "$mount_point may already be mounted. "
                echo "Try running 'sudo umount $mount_point' if you want to disconnect $mount_point."                  
            else
                echo "$mount_point is empty!"
                # Checks if $mount_point is mounted
                if mount | grep -q "$mount_point"; then
                    echo  "$mount_point is somehow empty yet still mounted. Unmounting."
                    umount "$mount_point"
                else
                    echo "Deleting $mount_point."
                    rmdir "$mount_point"
                fi
            fi
        else
            echo "$mount_point does not exist. "
            reload_xsan || true
            xsan_manual_mount
        fi
    fi
else
    echo "No log files found in $xsan_logging_directory. Is com.apple.xsan running?"
    echo "restarting com.apple.xsan"
    reload_xsan || true
    xsan_manual_mount
fi
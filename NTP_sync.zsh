#/bin/zsh

# Brandon Chesser - CPU IT, Inc


echo "Current system time is $(date). Running ntpdate."
# Attempts to use deprecated ntupdate first
sudo ntpdate -u time.apple.com 2> /dev/null
if [ $? != 0 ]; then
    echo "$(tput bold)ntpdate failed. Running sntp.$(tput sgr0)"
    sudo sntp -sS pool.ntp.org
    if [ $? = 0 ]; then
        echo "sntp success. New system time is $(tput bold)$(date).$(tput sgr0)"
    else
        echo "Failed to update time."
        return 0
    fi
fi
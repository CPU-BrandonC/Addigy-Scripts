#!/bin/zsh

# Checks for Xcode Command Line Tools and Python 3.7.9 before installing

current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# Check Xcode
if xcode-select -p &> /dev/null
then
    echo "Xcode Command Line Tools is installed. Proceeding..."
else
    echo "Xcode Command Line Tools is NOT installed. Please install before proceeding."
    exit 2
fi

#Check Python
python_version=$(sudo -u $current_user python3 --version 2>&1 | awk '{print $2}')
if [[ "$python_version" == "3.7.9" ]]
then
    echo "Current Python version is already 3.7.9. Proceeding..."
    exit 0
else
    echo "Python 3.7.9 is NOT installed. Please install before proceeding"
    exit 1
fi
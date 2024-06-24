#!/bin/zsh

# Checks for Xcode Command Line Tools and Python 3.7.9 before installing

# current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# Check Xcode
if xcode-select -p &> /dev/null
then
    echo "Xcode Command Line Tools is installed. Proceeding..."
else
    echo "Xcode Command Line Tools is NOT installed. Please install before proceeding."
    exit 2
fi

# Check Python version
if [[ -f "/usr/local/bin/python3" ]]
then
    python_version=$(/usr/local/bin/python3 --version 2>&1 | awk '{print $2}')
else
    echo "/usr/local/bin/python3 does not exist. Please install before Proceeding."
    exit 1
fi


if [[ "$python_version" == "3.7.9" ]]
then
    echo "Python 3.7.9 is installed. Proceeding..."
    exit 0
else
    echo "Python 3.7.9 is NOT installed. Please install before proceeding"
    exit 1
fi
#!/bin/zsh

# Completely removes a specified verison of Python...
# See https://stackoverflow.com/questions/72005302/completely-uninstall-python-3-on-mac

python_version="3.7"

if [[ -d "/Library/Frameworks/Python.framework/Versions/$python_version" ]]
then
    echo "Removing Python frameworks..."
    rm -rf "/Library/Frameworks/Python.framework/Versions/$python_version"
else
    echo "Python frameworks directory does not exist! Proceeding..."
fi

if [[ -d "/Applications/Python $python_version" ]]
then
    echo "Removing Python application directory..."
    rm - rf "/Applications/Python $python_version"
else
    echo "Python Applications directory does not exist! Proceeding..."
fi

# Remove Symlinks

echo "Removing Symlinks..."
cd /usr/local/bin && ls -l  | grep "/Library/Frameworks/Python.framework/Versions/$python_version" | awk '{print $9}' | xargs rm
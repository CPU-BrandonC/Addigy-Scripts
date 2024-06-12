#!/bin/zsh

# For Python 3.7.9
# Checks if the correct version of Python is already installed.

python_version=$(python3 --version | awk -F ' ' '{print $2}')

if [[ $python_version = "3.7.9" ]]
then
    echo "Current Python version is already $python_version."
    exit 1
else
    echo "Current Python version is $python_version. Proceeding with installation..."
    exit 0
fi
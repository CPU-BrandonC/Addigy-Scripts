#!/bin/zsh

# Checks for Xcode Command Line Tools before installing


# Check Xcode
if xcode-select -p &> /dev/null
then
    echo "Xcode Command Line Tools is installed. Proceeding..."
else
    echo "Xcode Command Line Tools is NOT installed. Please install before proceeding."
    exit 2
fi

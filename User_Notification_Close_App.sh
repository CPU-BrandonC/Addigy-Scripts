#!/bin/bash

# Adjust these variables as they will replace the text in the flags
title="A Notification"
description="Example of a description text"
acceptText="Accept"
closeText="Close"
timeOut=600
forefront="False"

if /Library/Addigy/macmanage/MacManage.app/Contents/MacOS/MacManage action=notify title="${title}" description="${description}" closeLabel="${closeText}" acceptLabel="${acceptText}" timeout="$timeOut" forefront="$forefront"; then
    # executes a desired command if the user clicks the Accept label.
    echo "Accept label clicked"
    exit 0
else
    # executes a desired command if the user clicks the Close label.
    echo "Close label clicked"
    exit 1
fi
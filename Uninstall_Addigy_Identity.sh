#!/usr/bin/env bash

synchronization_flag="addigy.synchronized.user"
accounts=$(dscl . list /Users | grep -v "_" | grep -v "daemon" | grep -v "nobody" | grep -v "root" | grep -v "AddigySSH")
for account in $accounts; do
    record_names=$(dscl . read /Users/${account} RecordName)
    for record in $record_names; do
        if [[ $record == *$synchronization_flag* ]]; then
            dscl . delete /Users/${account} RecordName ${record}
        fi
    done
done

/usr/bin/security authorizationdb read system.login.console > /Library/Addigy/AddigyIDSync/authdb.plist || true
index=$(plutil -p /Library/Addigy/AddigyIDSync/authdb.plist | grep 'AddigyIDSync:VerifyUser' | cut -d'=' -f1 | xargs) || true
/usr/bin/plutil -remove mechanisms.$index /Library/Addigy/AddigyIDSync/authdb.plist || true
/usr/bin/plutil -remove mechanisms.$index /Library/Addigy/AddigyIDSync/authdb.plist || true
/usr/bin/plutil -insert mechanisms.$index -string 'loginwindow:login' /Library/Addigy/AddigyIDSync/authdb.plist || true
/usr/bin/security authorizationdb write system.login.console < /Library/Addigy/AddigyIDSync/authdb.plist || true
/bin/rm -rf /Library/Addigy/AddigyIDSync/authdb.plist || true

/bin/rm -rf "/Library/Addigy/AddigyIDSync" || true
/bin/rm -rf "/Library/Security/SecurityAgentPlugins/AddigyIDSync.bundle" || true
/bin/rm -rf "/Library/LaunchDaemons/com.addigy.identity-monitor.plist" || true

killall loginwindow
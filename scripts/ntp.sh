#!/usr/bin/env bash
# Install and configure NTP client
sudo apt update
sudo apt -y install ntp

if [ '' != "$NTP_SERVER" ] ; then
    SERVER_ENTRY="server $NTP_SERVER"
    grep --invert-match --quiet "$SERVER_ENTRY" /etc/ntp.conf && cat <<EOF | sudo tee -a /etc/ntp.conf > /dev/null
$SERVER_ENTRY
EOF
    sudo systemctl restart ntp.service
fi

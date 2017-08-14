#!/usr/bin/env bash
if [ '' != "$PROXY_URL" ] ; then
    cat <<EOF | sudo tee /etc/apt/apt.conf > /dev/null
Acquire::http::Proxy "$PROXY_URL";
EOF

    cat <<EOF | sudo tee -a /tmp/environment > /dev/null
http_proxy=$PROXY_URL
https_proxy=$PROXY_URL
HTTP_PROXY=$PROXY_URL
HTTPS_PROXY=$PROXY_URL
EOF

    for line in $( grep -e proxy -e PROXY /tmp/environment ) ; do export $line ; done

    git config --global http.proxy $PROXY_URL
fi
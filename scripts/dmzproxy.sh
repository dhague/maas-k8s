#!/usr/bin/env bash

cat <<EOF | sudo tee /etc/apt.conf > /dev/null
Acquire::http::Proxy "http://proxy.dmzwdf.sap.corp:8080/";
EOF

cat <<EOF | sudo tee -a /etc/environment > /dev/null
http_proxy=http://proxy.dmzwdf.sap.corp:8080/
https_proxy=http://proxy.dmzwdf.sap.corp:8080/
HTTP_PROXY=http://proxy.dmzwdf.sap.corp:8080/
HTTPS_PROXY=http://proxy.dmzwdf.sap.corp:8080/
EOF

for line in $( cat /etc/environment ) ; do export $line ; done

git config --global http.proxy http://proxy.dmzwdf.sap.corp:8080/

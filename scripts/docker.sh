#!/usr/bin/env bash
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
sudo apt-get update 
sudo apt-get install -y docker-ce

# Configure Docker's proxy settings based on environment
if env | grep -q PROXY ; then
    sudo mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF |head -c -1| sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null
[Service]
Environment=
EOF
    for line in $( env | grep PROXY ) ; do echo -n '"'$line'" ' | sudo tee -a /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null ; done
    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi

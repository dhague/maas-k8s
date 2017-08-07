#!/usr/bin/env bash
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
sudo apt-get update 
sudo apt-get install -y docker-ce

# Copy proxy lines from /etc/environment to /etc/default/docker
for line in $( grep proxy /etc/environment ) ; do echo 'export '$line | sudo tee -a /etc/default/docker > /dev/null ; done

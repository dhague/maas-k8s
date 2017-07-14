#!/bin/bash
sudo apt-get install -y cachefilesd
sudo sed -i -e 's/#RUN=yes/RUN=yes/g' /etc/default/cachefilesd
cat <<EOF | sudo tee /etc/cachefilesd.conf > /dev/null
dir /var/cache/fscache
#dir /raid
tag dgx1cache
brun 25%
bcull 15%
bstop 5%
frun 10%
fcull 7%
fstop 3%
EOF
sudo modprobe cachefiles
sudo service cachefilesd start


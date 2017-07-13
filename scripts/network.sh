#/bin/bash

: ${MAAS_GW:=192.168.8.254}
: ${INET_GW:=192.168.0.4}

# Use Internet LAN for default route
sudo route add default gw $INET_GW    # Internet LAN
sudo route delete default gw $MAAS_GW # MaaS LAN

# Modify /etc/network/interfaces to use Internet LAN for default route in future
grep -q 'route delete default' /etc/network/interfaces || sudo sed -i '/inet static/a \    up route delete default gw '$MAAS_GW /etc/network/interfaces
grep -q 'route add default' /etc/network/interfaces || sudo sed -i '/inet dhcp/a \    up route add default gw '$INET_GW /etc/network/interfaces

# Make sure we can mount NFS (host needs to be able to do this for Kubernetes to do it)
sudo apt-get install -y nfs-common


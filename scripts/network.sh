#!/usr/bin/env bash

if [ "$MAAS_GW" != "$INET_GW" ] ; then
    ./fix_routing.sh
fi

# Make sure we can mount NFS (host needs to be able to do this for Kubernetes to do it)
sudo apt-get update
sudo apt-get install -y nfs-common


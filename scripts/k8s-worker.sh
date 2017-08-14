#!/usr/bin/env bash
: ${K8S_HOSTIP:=$1}
: ${TOKEN:=$2}
# Token must match regex [a-z0-9]{6}\.[a-z0-9]{16}
[[ $TOKEN =~ ^[a-z0-9]{6}\.[a-z0-9]{16}$ ]] || (echo "`basename "$0"`: Token is invalid" && exit 1)
  
./network.sh
./docker.sh
./k8s-packages.sh
./cachefilesd.sh

# Join K8S Master
sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
sudo -E kubeadm join --token $TOKEN $K8S_HOSTIP


#!/usr/bin/env bash
: ${MASTER_IP:=$1}
: ${MASTER_PORT:=$2}
: ${TOKEN:=$3}
# Token must match regex [a-z0-9]{6}\.[a-z0-9]{16}
[[ $TOKEN =~ ^[a-z0-9]{6}\.[a-z0-9]{16}$ ]] || (echo "`basename "$0"`: Token is invalid" && exit 1)

if [ '' == "$MASTER_PORT" ] ; then
  MASTER_PORT=6443
fi

./network.sh
./docker.sh
./k8s-packages.sh
./cachefilesd.sh

# Join K8S Master
sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
sudo -E kubeadm join --token $TOKEN $MASTER_IP:$MASTER_PORT

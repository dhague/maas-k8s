#!/usr/bin/env bash
# If an parameter is specified, use it to match the desired API server subnet address (e.g. '192.168.8.0')
if [ '' != "$1" ] ; then
  MASTER_IP=`ip addr show  | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | grep "${1/%.0/}"`
fi
if [ '' != "$MASTER_IP" ] ; then
  MASTER_IP_ARG="--apiserver-advertise-address=$MASTER_IP"
fi
if [ '' != "$2" ] ; then
  TOKEN=$2
  # Token must match regex [a-z0-9]{6}\.[a-z0-9]{16}
  [[ $TOKEN =~ ^[a-z0-9]{6}\.[a-z0-9]{16}$ ]] || (echo "`basename "$0"`: Token is invalid" && exit 1)
fi
if [ '' != "$TOKEN" ] ; then
  TOKEN_ARG="--token $TOKEN"
fi

./network.sh
./docker.sh
./k8s-packages.sh

# Initialise K8S Master
echo Running: kubeadm init $MASTER_IP_ARG $TOKEN_ARG
sudo kubeadm init $MASTER_IP_ARG $TOKEN_ARG

# Set up kube config
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

if [ "$POD_NETWORK" == "calico" ] ; then
    # Set up Calico pod networking
    kubectl apply -f https://docs.projectcalico.org/v2.4/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
else
    # Set up WeaveNet pod networking
    kubectl apply -f https://git.io/weave-kube-1.6
fi

# Add dashboard
kubectl create -f https://git.io/kube-dashboard


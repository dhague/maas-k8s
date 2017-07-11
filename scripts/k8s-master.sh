#/bin/bash

./network.sh
./docker.sh
./k8s-packages.sh

# Initialise K8S Master
# If an parameter is specified, use it to match the desired API server subnet address (e.g. '192.168.8.0')
if [ '' != "$1" ] ; then
  MASTER_IP=`ip addr show  | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | grep "${1/%.0/}"`
  : ${MASTER_IP_ARG:="--apiserver-advertise-address=$MASTER_IP"}
fi
sudo kubeadm init $MASTER_IP_ARG

# Set up kube config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Set up WeaveNet pod networking
kubectl  apply -f https://git.io/weave-kube-1.6

# Add dashboard
kubectl create -f https://git.io/kube-dashboard


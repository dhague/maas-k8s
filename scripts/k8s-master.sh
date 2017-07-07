#/bin/bash
./network.sh
./docker.sh
./k8s-packages.sh

# Initialise K8S Master
sudo kubeadm init

# Set up kube config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Set up WeaveNet pod networking
kubectl  apply -f https://git.io/weave-kube-1.6

# Add dashboard
kubectl create -f https://git.io/kube-dashboard


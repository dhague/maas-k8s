#/bin/bash
: ${TOKEN:=$1}
: ${K8S_HOSTIP:=$2}

./network.sh
./docker.sh
./k8s-packages.sh

# Join K8S Master
sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
sudo kubeadm join --token $TOKEN $K8S_HOSTIP


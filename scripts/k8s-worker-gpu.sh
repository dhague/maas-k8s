#/bin/bash
: ${TOKEN:=$1}
: ${K8S_HOSTIP:=$2}

: ${NVIDIA_VERSION:=375}

./network.sh
./docker.sh
./k8s-packages.sh

wget --directory-prefix=/tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker_1.0.1-1_amd64.deb
#sudo ln -s .../volumes/nvidia_driver/375.31 /usr/local/lib/nvidia

# Install kubectl, kubelet and kubeadm
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
#deb http://apt.kubernetes.io/ kubernetes-xenial main
#EOF
#sudo apt-get update
#sudo apt-get install -y kubeadm kubectl

# Join K8S Master
#sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
#sudo kubeadm join --token $TOKEN $K8S_HOSTIP


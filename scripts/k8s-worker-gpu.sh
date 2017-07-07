#/bin/bash

: ${MAAS_GW:=192.168.8.254}
: ${INET_GW:=192.168.0.4}
: ${TOKEN:=$1}
: ${K8S_HOSTIP:=$2}
#: ${NVIDIA_VERSION:=381}
: ${NVIDIA_VERSION:=375}

# Use Internet LAN for default route
sudo route add default gw $INET_GW    # Internet LAN
sudo route delete default gw $MAAS_GW # MaaS LAN

# Modify /etc/network/interfaces to use Internet LAN for default route in future
grep -q 'route delete default' /etc/network/interfaces || sudo sed -i '/inet static/a \    up route delete default gw '$MAAS_GW /etc/network/interfaces
grep -q 'route add default' /etc/network/interfaces || sudo sed -i '/inet dhcp/a \    up route add default gw '$INET_GW /etc/network/interfaces

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
sudo apt-get update 
sudo apt-get install -y docker-ce

# GPU drivers
#sudo add-apt-repository -y ppa:graphics-drivers
#sudo apt-get update
#sudo apt-get install -y nvidia-$NVIDIA_VERSION nvidia-modprobe --no-install-recommends
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
#sudo apt-get update
#sudo apt-get install -y nvidia-$NVIDIA_VERSION nvidia-$NVIDIA_VERSION-dev libcuda1-$NVIDIA_VERSION nvidia-modprobe --no-install-recommends

wget https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
sudo dpkg -i nvidia-docker_1.0.1-1_amd64.deb
#sudo ln -s .../volumes/nvidia_driver/375.31 /usr/local/lib/nvidia
# Might possibly need a reboot at this point

# Install kubectl, kubelet and kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubeadm kubectl

# Join K8S Master
#sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
#sudo kubeadm join --token $TOKEN $K8S_HOSTIP


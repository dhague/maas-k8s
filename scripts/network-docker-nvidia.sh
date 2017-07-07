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
#wget --directory-prefix=/tmp https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
#sudo dpkg -i /tmp/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
#sudo apt-get update
#sudo apt-get install -y nvidia-$NVIDIA_VERSION nvidia-$NVIDIA_VERSION-dev libcuda1-$NVIDIA_VERSION nvidia-modprobe --no-install-recommends

#echo sudo shutdown -r now
# After this reboot, run k8s-worker-gpu.sh


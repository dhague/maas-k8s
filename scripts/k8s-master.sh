#/bin/bash

: ${MAAS_GW:=192.168.8.254}
: ${INET_GW:=192.168.0.4}

# Use Internet LAN for default route
sudo route add default gw $INET_GW      # Internet LAN
sudo route delete default gw $MAAS_GW # MaaS LAN

# Modify /etc/network/interfaces to use Internet LAN for default route in future
grep -q 'route delete default' /etc/network/interfaces || sudo sed -i '/inet static/a \    up route delete default gw '$MAAS_GW /etc/network/interfaces
grep -q 'route add default' /etc/network/interfaces || sudo sed -i '/inet dhcp/a \    up route add default gw '$INET_GW /etc/network/interfaces

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
sudo apt-get update 
sudo apt-get install docker-ce

# Install kubectl, kubelet and kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
	deb http://apt.kubernetes.io/ kubernetes-xenial main
	EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

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


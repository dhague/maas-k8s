#/bin/bash

: ${MAAS_GW:=192.168.8.254}
: ${INET_GW:=192.168.0.4}
: ${TOKEN:=$1}
: ${K8S_HOSTIP:=$2}

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

# Install kubectl, kubelet and kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubeadm kubectl

# Join K8S Master
sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
sudo kubeadm join --token $TOKEN $K8S_HOSTIP


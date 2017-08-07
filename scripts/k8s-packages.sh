#!/usr/bin/env bash

# Create kubelet service override file to enable GPU support
sudo mkdir /etc/systemd/system/kubelet.service.d
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/override.conf > /dev/null
[Service]
Environment='KUBELET_EXTRA_ARGS=--feature-gates="Accelerators=true"'
EOF

# Install kubectl, kubelet and kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubeadm kubectl


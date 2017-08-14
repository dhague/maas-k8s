#!/usr/bin/env bash
: ${MASTER_IP:=$1}
: ${MASTER_PORT:=$2}
: ${TOKEN:=$3}
# Token must match regex [a-z0-9]{6}\.[a-z0-9]{16}
[[ $TOKEN =~ ^[a-z0-9]{6}\.[a-z0-9]{16}$ ]] || (echo "`basename "$0"`: Token is invalid" && exit 1)

if [ '' == "$MASTER_PORT" ] ; then
  MASTER_PORT=6443
fi

: ${NVIDIA_VERSION:=375}

./network.sh
./docker.sh
./k8s-packages.sh
./cachefilesd.sh

wget --directory-prefix=/tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker_1.0.1-1_amd64.deb
sudo ln -s /usr/lib/nvidia-$NVIDIA_VERSION /usr/local/lib/nvidia
sudo cp /usr/lib/x86_64-linux-gnu/libcuda* /usr/local/lib/nvidia

NVIDIA_GPU_NAME=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader --id=0)
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/override.conf > /dev/null
[Service]
Environment="KUBELET_EXTRA_ARGS=--feature-gates='Accelerators=true' --node-labels='alpha.kubernetes.io/nvidia-gpu-name=${NVIDIA_GPU_NAME// /-}'"
EOF

# Join K8S Master
sudo kubeadm reset # Workaround for https://github.com/kubernetes/kubeadm/issues/1
sudo kubeadm join --token $TOKEN $MASTER_IP:$MASTER_PORT


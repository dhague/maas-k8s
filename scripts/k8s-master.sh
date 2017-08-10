#!/usr/bin/env bash
# If an parameter is specified, use it to match the desired API server subnet address (e.g. '192.168.8.0')
if [ '' != "$1" ] ; then
  MASTER_IP=`ip addr show  | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | grep "${1/%.0/}"`
fi
if [ '' != "$MASTER_IP" ] ; then
  MASTER_IP_ARG="--apiserver-advertise-address=$MASTER_IP"
fi
if [ '' != "$2" ] ; then
  TOKEN=$2
  # Token must match regex [a-z0-9]{6}\.[a-z0-9]{16}
  [[ $TOKEN =~ ^[a-z0-9]{6}\.[a-z0-9]{16}$ ]] || (echo "`basename "$0"`: Token is invalid" && exit 1)
fi
if [ '' != "$TOKEN" ] ; then
  TOKEN_ARG="--token $TOKEN"
fi

./network.sh
./docker.sh
./k8s-packages.sh

# Initialise K8S Master
: ${PODNET_CIDR:="192.168.0.0/16"}
if [ "$POD_NETWORK" == "calico" ] ; then
    POD_NETWORK_ARG='--pod-network-cidr='$PODNET_CIDR
else
    WEAVE_NETWORK_ARG='&env.IPALLOC_RANGE='$PODNET_CIDR
fi
echo Running: kubeadm init $MASTER_IP_ARG $TOKEN_ARG $POD_NETWORK_ARG
sudo kubeadm init $MASTER_IP_ARG $TOKEN_ARG $POD_NETWORK_ARG

# Set up kube config
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

if [ "$POD_NETWORK" == "calico" ] ; then
    # Set up Calico pod networking
    kubectl apply -f https://docs.projectcalico.org/v2.4/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
else
    # Set up WeaveNet pod networking
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')$WEAVE_NETWORK_ARG"
fi

# Add dashboard
kubectl create -f https://git.io/kube-dashboard

# Create a browser certificate file from .kube/config
sudo apt install -y python-pip
pip install shyaml
shyaml get-value users.0.user.client-certificate-data < ~/.kube/config | base64 -d > ~/k8s-admin-cert.cer
shyaml get-value users.0.user.client-key-data < ~/.kube/config | base64 -d > ~/k8s-admin-key.cer
openssl pkcs12 -inkey ~/k8s-admin-key.cer -in ~/k8s-admin-cert.cer -export -out ~/k8s-admin.pfx -passout pass:


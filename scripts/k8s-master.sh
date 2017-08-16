#!/usr/bin/env bash
# If an parameter is specified, use it to match the desired API server subnet address (e.g. '192.168.8.0')
if [ '' != "$1" ] ; then
  MASTER_IP=`ip addr show  | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | grep "${1/%.0/}"`
fi
if [ '' != "$MASTER_IP" ] ; then
  MASTER_IP_ARG="--apiserver-advertise-address=$MASTER_IP"
fi
: ${MASTER_HOSTPORT:=$2}
if [ '' != "$MASTER_PORT" ] ; then
  MASTER_PORT_ARG="--apiserver-bind-port=$MASTER_PORT"
fi
if [ '' != "$3" ] ; then
  TOKEN=$3
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
echo Running: kubeadm init $MASTER_IP_ARG $MASTER_PORT_ARG $TOKEN_ARG $POD_NETWORK_ARG
sudo -E kubeadm init $MASTER_IP_ARG $MASTER_PORT_ARG $TOKEN_ARG $POD_NETWORK_ARG

# Set up kube config
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Allow pods to be scheduled to the master, if so configured
if [ -n "$SCHEDULE_TO_MASTER" ] ; then
    kubectl taint nodes --all node-role.kubernetes.io/master-
fi

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
kubectl config view --flatten | grep client-key-data |  # Get the client key, including field name
   cut -d ":" -f 2 | sed -e 's/^[[:space:]]*//' |       # Strip "    client-key-data: "
   base64 -d > ~/k8s-admin-key.cer
kubectl config view --flatten | grep client-certificate-data |  # Get the client cert, including field name
   cut -d ":" -f 2 | sed -e 's/^[[:space:]]*//' |               # Strip "    client-certificate-data: "
   base64 -d > ~/k8s-admin-cert.cer
openssl pkcs12 -inkey ~/k8s-admin-key.cer -in ~/k8s-admin-cert.cer -export -out ~/k8s-admin.pfx -passout pass:

# Get rid of the (proxy) env vars set in kube-apiserver.yaml
if [ '' != "$HTTP_PROXY" ] ; then
    #  Note to explain the sed-fu below:
    #   This deletes all lines from the one starting "    env:" up to but not including the next tag with the same indentation
    sudo sed -i -r -e '
        /^\s{4}env:.*$/,/^\s{4}[a-zA-Z0-9\-]+:.*$/ {
          /^\s{4}[a-zA-Z0-9\-]+:.*$/ !{
           d
          }
        }
    ' -e '/^\s{4}env:.*$/d' /etc/kubernetes/manifests/kube-apiserver.yaml

    sudo systemctl restart kubelet

    echo 'Restarted kubelet - wait for control plane to come back'
    until (kubectl -n=kube-system get pods | grep -q READY) ; do
        sleep 10
    done

fi

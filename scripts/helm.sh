#!/usr/bin/env bash
if [ -z ${helm+x} ]; then
    # Install helm
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh
    kubectl create clusterrolebinding kube-system-default-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
    helm init && export helm=installed
fi

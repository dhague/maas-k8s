#!/usr/bin/env bash
if [ -z ${helm+x} ]; then
    # Install helm
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh
    kubectl create clusterrolebinding kube-system-default-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
    helm init
    echo 'Waiting up to 5 minutes for Helm Tiller pod to enter state "Running"'
    for i in {1..60}
    do
       if (kubectl -n=kube-system get pods | grep tiller-deploy | grep -q Running) ; then
         export helm=installed
         break
       fi
       sleep 5
    done
    if [ -z ${helm+x} ]; then
      echo 'Helm Tiller pod failed to enter state "Running"'
      kubectl -n=kube-system get pods | grep tiller-deploy
      exit 1
    fi
fi

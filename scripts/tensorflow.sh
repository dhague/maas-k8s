#!/bin/bash

# Install Helm, if it's not already installed
source helm.sh

# If we are installing to a named cluster, use its values
if [ -n "$CLUSTER_BASE" -a -n "$CLUSTER_NAME" ]; then
    HELM_VALUES=" --values $CLUSTER_BASE/$CLUSTER_NAME/helm-values.yaml "
fi

CHART_NAME=tensorflow

kubectl create namespace $CHART_NAME
helm upgrade $HELM_VALUES $CHART_NAME ../helm-charts/$CHART_NAME --namespace $CHART_NAME --install

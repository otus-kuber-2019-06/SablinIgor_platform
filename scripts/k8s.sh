#!/bin/bash

echo "Start kubernetes in HA-mode..."

kind create cluster --config ~/.kube/kind-ha-config.yaml --name kind-ha

export KUBECONFIG="$(kind get kubeconfig-path --name="kind-ha")"  

#!/usr/bin/env sh

kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.4.0/keda-2.4.0.yaml
kubectl apply -f ./k8s_deployment/keda.yml

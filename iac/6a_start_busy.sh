#!/usr/bin/env sh

BUSY=true

aws eks --region us-east-1 update-kubeconfig --name eks-cluster
sed "s!<BUSY>!$BUSY!g" ./k8s_deployment/test_service_configmap_template.yml > test_service_configmap.yml
kubectl apply -f ./test_service_configmap.yml

#!/usr/bin/env sh

aws eks --region us-east-1 update-kubeconfig --name eks-cluster
kubectl apply -f ./k8s_deployment/v1_horizontal_autoscale.yml

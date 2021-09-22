#!/usr/bin/env sh

aws eks --region us-east-1 update-kubeconfig --name eks-cluster

REGION=us-east-1
REPO_NAME=test_service
AUTOSCALER_ROLE=eks-cluster-aws-node
ACCOUNT_NUMBER=$(aws sts get-caller-identity --query 'Account' --output text)
CLUSTER_NAME=eks-cluster

# create service account, apply to cluster
kubectl apply -f k8s_deployment/eks_admin_service_account.yml

# deploy metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# deploy dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
kubectl get deployment metrics-server -n kube-system

# get admin token
TOKEN=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}') | awk '/token:/{print $2}')
echo "TOKEN: $TOKEN"
echo $TOKEN > token.txt

echo
echo "Hit this URL for the dashboard (paste in the token from token.txt):"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login"
echo

# run proxy
kubectl proxy

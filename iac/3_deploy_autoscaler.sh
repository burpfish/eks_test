#!/usr/bin/env sh

aws eks --region us-east-1 update-kubeconfig --name eks-cluster

REGION=us-east-1
REPO_NAME=test_service
AUTOSCALER_ROLE=eks-cluster-aws-node
ACCOUNT_NUMBER=$(aws sts get-caller-identity --query 'Account' --output text)
CLUSTER_NAME=eks-cluster

# deploy autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_NUMBER:role/$AUTOSCALER_ROLE --overwrite
kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'
# KUBE_EDITOR="nano" kubectl -n kube-system edit deployment.apps/cluster-autoscaler
sed "s/<CLUSTER_NAME>/$CLUSTER_NAME/g" ./k8s_deployment/cluster_autoscaler_template.yml > cluster_autoscaler.yml
kubectl apply -f ./cluster_autoscaler.yml
kubectl set image deployment cluster-autoscaler -n kube-system cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.22.0

# to get logs:
#kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler

# to delete:
# kubectl delete deploy cluster-autoscaler -n kube-system
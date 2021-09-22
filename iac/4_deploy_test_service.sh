#!/usr/bin/env sh

aws eks --region us-east-1 update-kubeconfig --name eks-cluster

# deploy test service
REGION=us-east-1
REPO_NAME=test_service
AUTOSCALER_ROLE=eks-cluster-aws-node
ACCOUNT_NUMBER=$(aws sts get-caller-identity --query 'Account' --output text)
CLUSTER_NAME=eks-cluster

TEST_SERVICE_IMAGE=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
sed "s!<IMAGE>!$TEST_SERVICE_IMAGE!g" ./k8s_deployment/test_service_template.yml > test_service.yml

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com

REPO_NAME=test_service
IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep hello-world | cut -d' ' -f2)
export TEST_SERVICE_IMAGE=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest
docker tag $IMAGE_ID $TEST_SERVICE_IMAGE
docker push $TEST_SERVICE_IMAGE

# Create namespace, deploy service
echo ">> Update the image in test_service.yml to $TEST_SERVICE_IMAGE"
# kubectl delete ns test-namespace
kubectl create namespace test-namespace
kubectl apply -f ./test_service.yml
kubectl get all -n test-namespace

kubectl autoscale deployment test-deployment --cpu-percent=50 --min=1 --max=10  -n test-namespace

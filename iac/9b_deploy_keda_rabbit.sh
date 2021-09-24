#!/usr/bin/env sh

# See https://github.com/kedacore/sample-go-rabbitmq

# Rabbit MQ
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq --set auth.username=user --set auth.password=PASSWORD bitnami/rabbitmq
echo ("Waiting to give rabbit a chance to spin up; should check output of kubectl get po")
sleep 5m

# Test Consumer
kubectl apply -f k8s_deployment/deploy_rabbit_consumer.yml
kubectl get deploy

# Push some messages
kubectl apply -f k8s_deployment/deploy_rabbit_publisher.yml

echo "Watch the pods ... (ctrl-c when done)"

kubectl get deploy -w
#kubectl get hpa

# To see the rabbit ui:
#  kubectl port-forward --namespace default svc/rabbitmq 15672:15672
#  hit http://127.0.0.1:15672/ (user/PASSWORD)
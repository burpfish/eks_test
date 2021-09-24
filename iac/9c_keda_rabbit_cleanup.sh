#!/usr/bin/env sh

# See https://github.com/kedacore/sample-go-rabbitmq

kubectl delete job rabbitmq-publish
kubectl delete ScaledObject rabbitmq-consumer
kubectl delete deploy rabbitmq-consumer
helm delete rabbitmq
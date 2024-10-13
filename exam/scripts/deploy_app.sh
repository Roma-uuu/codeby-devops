#!/bin/bash

# Применить манифесты Kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Проверить статус Deployment и Pods
kubectl get deployments
kubectl get pods

#!/bin/bash

# Использовать Docker-демон Minikube
eval $(minikube docker-env)

# Собрать Docker-образ
docker build -t java-app:v1.0.0 .

# Вернуться к использованию локального Docker-демона (опционально)
eval $(minikube docker-env -u)

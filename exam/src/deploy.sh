#!/bin/bash

# Остановить скрипт при ошибке
set -e

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Проверяем, есть ли директория проекта
if [ ! -d "spring-petclinic" ]; then
  echo "Директория 'spring-petclinic' не найдена. Клонируем репозиторий..."
  git clone https://github.com/spring-projects/spring-petclinic.git
fi

cd spring-petclinic

# Шаг 1: Запуск Minikube
echo "Запуск Minikube..."
minikube start --driver=docker

# Шаг 2: Сборка проекта
echo "Сборка проекта с помощью Maven..."
mvn clean package

# Шаг 3: Использование Docker-демона Minikube
echo "Настройка окружения Docker для Minikube..."
eval $(minikube docker-env)

# Шаг 4: Сборка Docker-образа
echo "Сборка Docker-образа..."
docker build -t spring-petclinic:latest .

# Шаг 5: Возвращение к локальному Docker-демону
echo "Возвращение к локальному Docker-демону..."
eval $(minikube docker-env -u)

# Шаг 6: Применение манифестов Kubernetes
echo "Применение манифестов Kubernetes..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Шаг 7: Ожидание запуска подов
echo "Ожидание запуска подов..."
kubectl rollout status deployment/petclinic-deployment

# Шаг 8: Получение URL сервиса
echo "Получение URL сервиса..."
minikube service petclinic-service --url

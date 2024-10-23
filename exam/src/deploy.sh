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
mvn clean package -Dcheckstyle.skip=true

# Шаг 3: Использование Docker-демона Minikube
echo "Настройка окружения Docker для Minikube..."
eval $(minikube docker-env)

# Шаг 4: Сборка Docker-образа
echo "Сборка Docker-образа..."
docker build -t spring-petclinic:latest -f ../Dockerfile ../

# Шаг 5: Возвращение к локальному Docker-демону
echo "Возвращение к локальному Docker-демону..."
eval $(minikube docker-env -u)

# Шаг 6: Установка Helm, если он не установлен
if ! command -v helm &> /dev/null; then
  echo "Helm не найден, устанавливаю Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Шаг 7: Добавление репозиториев Helm
echo "Добавление репозиториев Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Шаг 8: Установка Prometheus, Loki и Grafana через Helm
echo "Установка Prometheus, Loki и Grafana через Helm..."
helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
helm upgrade --install loki grafana/loki-stack --namespace monitoring
helm upgrade --install grafana grafana/grafana --namespace monitoring --set adminPassword=admin --set service.type=NodePort --set service.nodePort=32000

# Шаг 9: Применение манифестов Kubernetes для приложения
echo "Применение манифестов Kubernetes для приложения spring-petclinic..."
kubectl apply -f ../k8s/deployment.yaml
kubectl apply -f ../k8s/service.yaml

# Шаг 10: Ожидание запуска подов
echo "Ожидание запуска подов..."
kubectl rollout status deployment/petclinic-deployment

# Шаг 11: Получение URL сервиса приложения
echo "Получение URL сервиса приложения..."
minikube service petclinic-service --url

# Шаг 12: Получение URL для доступа к Grafana
echo "Получение URL сервиса Grafana..."
grafana_url=$(minikube service grafana --url -n monitoring)
echo "Grafana доступна по адресу $grafana_url"
echo "Войти в Grafana можно с логином admin и паролем admin."

# Шаг 13: Добавление Prometheus и Loki как источников данных в Grafana
echo "Добавление Prometheus и Loki как источников данных в Grafana..."

# Добавляем Prometheus как источник данных
curl -X POST "$grafana_url/api/datasources" \
    -H "Content-Type: application/json" \
    -d '{
          "name": "Prometheus",
          "type": "prometheus",
          "url": "http://prometheus-server.monitoring.svc.cluster.local:80",
          "access": "proxy",
          "isDefault": true
        }' \
    -u admin:admin

# Добавляем Loki как источник данных
curl -X POST "$grafana_url/api/datasources" \
    -H "Content-Type: application/json" \
    -d '{
          "name": "Loki",
          "type": "loki",
          "url": "http://loki.monitoring.svc.cluster.local:3100",
          "access": "proxy"
        }' \
    -u admin:admin

# Шаг 14: Загрузка готовых дашбордов для Kubernetes, Loki и Docker
echo "Добавление готовых дашбордов для Kubernetes, Loki и Docker..."

# Добавление дашборда для мониторинга Kubernetes Nodes (ID: 3119)
curl -X POST "$grafana_url/api/dashboards/import" \
    -H "Content-Type: application/json" \
    -d '{
          "dashboard": {
            "id": 3119
          },
          "overwrite": true
        }' \
    -u admin:admin

# Добавление дашборда для мониторинга Kubernetes Pods (ID: 3131)
curl -X POST "$grafana_url/api/dashboards/import" \
    -H "Content-Type: application/json" \
    -d '{
          "dashboard": {
            "id": 3131
          },
          "overwrite": true
        }' \
    -u admin:admin

# Добавление дашборда для мониторинга Docker и контейнеров (ID: 179)
curl -X POST "$grafana_url/api/dashboards/import" \
    -H "Content-Type: application/json" \
    -d '{
          "dashboard": {
            "id": 179
         

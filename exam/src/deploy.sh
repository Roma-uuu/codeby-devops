#!/bin/bash

# Остановить скрипт при ошибке
set -e

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Проверка на наличие Docker, Minikube и ngrok
if ! command -v docker &> /dev/null || ! command -v minikube &> /dev/null || ! command -v ngrok &> /dev/null; then
  echo "Необходимы Docker, Minikube и ngrok. Установите их и повторите попытку."
  exit 1
fi

# Запуск Minikube с использованием Docker-драйвера
echo "Запуск Minikube..."
minikube start --driver=docker

# Настройка Docker-окружения для работы с Minikube
echo "Настройка Docker-окружения для Minikube..."
eval $(minikube docker-env)

# Сборка Docker-образа для приложения
echo "Сборка Docker-образа приложения..."
docker build -t myapp:latest -f Dockerfile .

# Возвращение к локальному Docker-демону
echo "Возвращение к локальному Docker-демону..."
eval $(minikube docker-env -u)

# Установка Helm, если он не установлен
if ! command -v helm &> /dev/null; then
  echo "Установка Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Добавление Helm-репозиториев и обновление
echo "Добавление и обновление Helm-репозиториев..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Установка Prometheus, Loki и Grafana для мониторинга
echo "Установка Prometheus, Loki и Grafana через Helm..."
helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
helm upgrade --install loki grafana/loki-stack --namespace monitoring
helm upgrade --install grafana grafana/grafana --namespace monitoring --set adminPassword=admin --set service.type=NodePort --set service.nodePort=32000

# Применение конфигурации Kubernetes из манифестов Helm Chart и values.yaml
echo "Применение манифестов Kubernetes для приложения..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Ожидание запуска подов
echo "Ожидание завершения развёртывания подов..."
kubectl rollout status deployment/myapp-deployment

# Запуск ngrok для публичного доступа
echo "Запуск ngrok для доступа к приложению..."
nohup ngrok http $(minikube service myapp-service --url | sed 's|http://||') &

# Получение URL для доступа к ngrok
sleep 5
ngrok_url=$(curl -s http://localhost:4040/api/tunnels | grep -o "https://[a-z0-9]*.ngrok.io")
echo "Приложение доступно по адресу $ngrok_url"

# Получение URL Grafana
echo "Получение URL для Grafana..."
grafana_url=$(minikube service grafana --url -n monitoring)
echo "Grafana доступна по адресу $grafana_url"
echo "Логин: admin, Пароль: admin"

# Настройка источников данных в Grafana для Prometheus и Loki
echo "Настройка источников данных в Grafana..."
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

curl -X POST "$grafana_url/api/datasources" \
    -H "Content-Type: application/json" \
    -d '{
          "name": "Loki",
          "type": "loki",
          "url": "http://loki.monitoring.svc.cluster.local:3100",
          "access": "proxy"
        }' \
    -u admin:admin

# Добавление дашбордов для мониторинга в Grafana
echo "Добавление дашбордов для мониторинга в Grafana..."
curl -X POST "$grafana_url/api/dashboards/import" \
    -H "Content-Type: application/json" \
    -d '{
          "dashboard": {
            "id": 3119
          },
          "overwrite": true
        }' \
    -u admin:admin
curl -X POST "$grafana_url/api/dashboards/import" \
    -H "Content-Type: application/json" \
    -d '{
          "dashboard": {
            "id": 3131
          },
          "overwrite": true
        }' \
    -u admin:admin
curl -X POST "$grafana_url/api/dashboards/import" \
    -H "Content-Type: application/json" \
    -d '{
          "dashboard": {
            "id": 179
          },
          "overwrite": true
        }' \
    -u admin:admin

# Запуск Ansible playbook для мониторинга
echo "Запуск Ansible playbook для настройки мониторинга..."
ansible-playbook monitoring_playbook.yml

echo "Развёртывание завершено."

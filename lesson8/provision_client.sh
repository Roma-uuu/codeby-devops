#!/bin/bash

# Добавление записи в /etc/hosts
echo "192.168.56.10 rsshabanov" | sudo tee -a /etc/hosts

# Создание каталога для сертификатов, если он не существует
sudo mkdir -p /usr/local/share/ca-certificates

# Копирование самоподписанного SSL сертификата сервера на клиент
sudo cp /vagrant/provision_server.sh /etc/apache2/ssl/cert.pem /usr/local/share/ca-certificates/rsshabanov.crt

# Обновление доверенных сертификатов
sudo update-ca-certificates

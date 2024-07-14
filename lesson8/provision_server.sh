#!/bin/bash

# Обновление списка пакетов
sudo apt-get update

# Установка Apache
sudo apt-get install -y apache2

# Создание директории для SSL сертификатов
sudo mkdir -p /etc/apache2/ssl

# Создание файла случайных чисел, если он отсутствует
sudo touch /root/.rnd

# Создание самоподписанного SSL сертификата
sudo openssl req -x509 -newkey rsa:4096 -keyout /etc/apache2/ssl/key.pem -out /etc/apache2/ssl/cert.pem -days 365 -nodes -subj "/CN=rsshabanov"

# Конфигурация Apache для SSL
sudo bash -c 'cat > /etc/apache2/sites-available/default-ssl.conf' <<EOF
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/cert.pem
    SSLCertificateKeyFile /etc/apache2/ssl/key.pem

    <FilesMatch "\\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0

    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
</VirtualHost>
EOF

# Включение SSL модуля и сайта
sudo a2enmod ssl
sudo a2ensite default-ssl

# Конфигурация перенаправления HTTP на HTTPS
sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf' <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    Redirect "/" "https://rsshabanov/"

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Перезапуск Apache
sudo systemctl restart apache2

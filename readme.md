Spring PetClinic Sample Application
Это проект демонстрационного приложения Spring PetClinic с использованием Spring Boot, развертываемого в Minikube с помощью Helm, автоматизированного пайплайна в Jenkins и доступного в интернете через ngrok.

О проекте
Spring PetClinic — это образец приложения для управления данными о питомцах и владельцах с использованием Java и Spring Boot. В этом проекте вы найдете инструкции для локального запуска приложения, а также для его развертывания в Kubernetes с помощью Minikube и Helm.

Возможности проекта
Автоматическая сборка и деплой: Jenkins автоматически собирает, тестирует и деплоит Docker-образ приложения.
Интеграция с Helm и Kubernetes: Приложение развертывается в Minikube с помощью Helm-чартов.
Мониторинг и логирование: Используется Ansible для настройки стека мониторинга (Grafana и Prometheus) и логирования.
Доступ через ngrok: ngrok используется для проброса локального порта в интернет, предоставляя внешний доступ к приложению.
Установка и настройка
1. Клонирование репозитория
bash
Копировать код
git clone https://github.com/Roma-uuu/codeby-devops.git
cd codeby-devops/exam/src
2. Локальный запуск приложения
Сборка и запуск с Maven
Вы можете собрать и запустить приложение локально с помощью Maven:

bash
Копировать код
./mvnw package
java -jar target/*.jar
После запуска приложение будет доступно по адресу http://localhost:8080.

Локальный запуск для разработки
С помощью Spring Boot Maven плагина можно запустить приложение с отслеживанием изменений:

bash
Копировать код
./mvnw spring-boot:run
3. Развертывание в Kubernetes с помощью Helm и Minikube
Запуск Minikube
Убедитесь, что Minikube установлен и запущен:

bash
Копировать код
minikube start
Сборка и загрузка Docker-образа в Minikube
Постройте Docker-образ:
bash
Копировать код
docker build -t apkerigz/devops:<appVersion> .
Загрузите образ в Minikube:
bash
Копировать код
minikube image load apkerigz/devops:<appVersion>
Установка приложения с помощью Helm
Перейдите в директорию с Helm-чартами и установите приложение:

bash
Копировать код
cd exam/src/mychart
helm upgrade --install petclinic-app . --set image.repository=apkerigz/devops --set image.tag=<appVersion> --kubeconfig=/home/rsshabanov/codeby-devops/exam/src/kubeconfig-jenkins.yaml
Экспонируйте сервис с помощью NodePort:

bash
Копировать код
kubectl expose deployment petclinic --type=NodePort --port=8080 --target-port=8080 --name=petclinic-service
4. Автоматизация с помощью Jenkins
Конфигурация Jenkins Pipeline
Jenkins Pipeline (Jenkinsfile) автоматизирует сборку, деплой и проброс порта через ngrok. Основные этапы:

Сборка Docker-образа: Образ создается с использованием Maven и загружается в Minikube.
Деплой с использованием Helm: Пайплайн использует Helm-чарты для деплоя в Minikube.
Настройка стека мониторинга с помощью Ansible: Ansible плейбук настраивает Grafana и Prometheus для мониторинга приложения.
Проброс порта с помощью ngrok: Туннель ngrok используется для внешнего доступа к приложению через интернет.
Для запуска пайплайна Jenkins:

Убедитесь, что Jenkins настроен и подключен к вашему репозиторию и Minikube.
Выполните пайплайн, используя Jenkinsfile в корне репозитория.
5. Настройка доступа через ngrok
Чтобы обеспечить доступ к приложению через интернет:

Пробросите порт 8081 (или другой локальный порт):
bash
Копировать код
kubectl port-forward svc/petclinic-service 8081:8080
Запустите ngrok для проброса порта:
bash
Копировать код
ngrok http 8081
Скопируйте публичный URL, предоставленный ngrok, и используйте его для доступа к приложению извне.
6. Настройка мониторинга и логирования
Мониторинг приложения осуществляется с помощью стека Prometheus и Grafana:

Prometheus собирает метрики приложения и системы.
Grafana отображает метрики в виде графиков.
Ansible плейбук автоматически настраивает этот стек и пробрасывает порты для локального доступа через NodePort.

Работа с базой данных
По умолчанию используется встроенная база данных H2, но можно подключить MySQL или PostgreSQL:

bash
Копировать код
docker run -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:8.0
или

bash
Копировать код
docker run -e POSTGRES_USER=petclinic -e POSTGRES_PASSWORD=petclinic -e POSTGRES_DB=petclinic -p 5432:5432 postgres:14
Для переключения базы данных измените активный профиль Spring (spring.profiles.active=mysql или postgres).

Требования
Java 17 или новее
Docker и Minikube
Jenkins
ngrok
Helm
Ansible
Лицензия
Spring PetClinic распространяется под лицензией Apache 2.0.

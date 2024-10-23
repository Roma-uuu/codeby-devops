# Используем официальный образ OpenJDK 17 с Alpine Linux
FROM openjdk:17-jdk-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем собранный JAR-файл в контейнер
COPY target/spring-petclinic-*.jar petclinic.jar

# Открываем порт 8080
EXPOSE 8080

# Запускаем приложение
ENTRYPOINT ["java", "-jar", "petclinic.jar"]

# Сначала создаем билд-образ на основе OpenJDK 17 с Maven
FROM openjdk:17-jdk-alpine
WORKDIR /app

# Копируем pom.xml и зависимости для предварительной сборки и кэширования
COPY pom.xml ./
COPY src ./src

# Сборка и создание jar файла
RUN mvn clean package -DskipTests

# Финальный образ только с JRE для минимального размера
FROM openjdk:17-jre-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем сгенерированный jar файл из предыдущего этапа
COPY --from=build /app/target/spring-petclinic-*.jar petclinic.jar

# Открываем порт 8080
EXPOSE 8080

# Запускаем приложение
ENTRYPOINT ["java", "-jar", "petclinic.jar"]

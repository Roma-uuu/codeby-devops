# Сначала создаем билд-образ на основе OpenJDK 17 с Maven
FROM openjdk:17-jdk
WORKDIR /app

# Копируем pom.xml и зависимости для предварительной сборки и кэширования
COPY pom.xml ./ 
COPY src ./src

# Сборка и создание jar файла
RUN mvn clean package -DskipTests

# Финальный образ с JDK для выполнения приложения
FROM openjdk:17-jdk-slim  # Используем существующий образ

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем сгенерированный jar файл из предыдущего этапа
COPY --from=build /app/target/spring-petclinic-*.jar petclinic.jar

# Открываем порт 8080
EXPOSE 8080

# Запускаем приложение
ENTRYPOINT ["java", "-jar", "petclinic.jar"]

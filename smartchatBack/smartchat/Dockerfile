# syntax=docker/dockerfile:1.2

# ---------- Etapa 1: build ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Cache de dependencias
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Código fuente
COPY src ./src

# Montamos el Secret File de Render SOLO durante este RUN (no queda en la imagen final)
# y lo copiamos justo donde tu código ya lo espera, antes de compilar.
RUN --mount=type=secret,id=serviceAccountKey_json,dst=/etc/secrets/serviceAccountKey.json \
    cp /etc/secrets/serviceAccountKey.json src/main/resources/firebase/serviceAccountKey.json && \
    mvn clean package -DskipTests -B

# ---------- Etapa 2: imagen final ----------
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 10000
ENTRYPOINT ["java", "-jar", "app.jar"]

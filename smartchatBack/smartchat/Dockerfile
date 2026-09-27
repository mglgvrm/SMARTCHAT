# ---------- Etapa 1: build ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Estas ARG reciben el valor de las variables de entorno que configures en Render
ARG FIREBASE_PRIVATE_KEY_ID
ARG FIREBASE_PRIVATE_KEY
ARG FIREBASE_CLIENT_EMAIL
ARG FIREBASE_CLIENT_ID

# Cache de dependencias
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Código fuente (incluye el template versionado en git)
COPY src ./src

# Generamos el archivo REAL a partir del template, reemplazando los placeholders
RUN sed -e "s|\${FIREBASE_PRIVATE_KEY_ID}|$FIREBASE_PRIVATE_KEY_ID|g" \
        -e "s|\${FIREBASE_PRIVATE_KEY}|$FIREBASE_PRIVATE_KEY|g" \
        -e "s|\${FIREBASE_CLIENT_EMAIL}|$FIREBASE_CLIENT_EMAIL|g" \
        -e "s|\${FIREBASE_CLIENT_ID}|$FIREBASE_CLIENT_ID|g" \
        src/main/resources/firebase/serviceAccountKey.json

RUN mvn clean package -DskipTests -B

# ---------- Etapa 2: imagen final ----------
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 10000
ENTRYPOINT ["java", "-jar", "app.jar"]
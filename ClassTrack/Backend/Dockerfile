# syntax=docker/dockerfile:1
FROM maven:3.9.11-eclipse-temurin-21 AS build
WORKDIR /workspace
ENV MAVEN_OPTS="-Xmx384m -XX:ActiveProcessorCount=2"
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -B -ntp dependency:go-offline
COPY src ./src
# Integration tests require a separate database; run them before building this image.
RUN --mount=type=cache,target=/root/.m2 mvn -B -ntp package -DskipTests

FROM eclipse-temurin:21-jre-alpine AS runtime
RUN addgroup -S -g 10001 classtrack && adduser -S -D -H -u 10001 -G classtrack classtrack
WORKDIR /app
COPY --from=build --chown=10001:10001 /workspace/target/classtrack-1.0.0.jar /app/app.jar
USER 10001:10001
ENV JAVA_TOOL_OPTIONS="-Xms64m -Xmx384m -XX:ActiveProcessorCount=2"
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s --start-period=90s --retries=5 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

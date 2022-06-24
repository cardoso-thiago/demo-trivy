FROM maven:3.8.6-openjdk-11-slim as maven

COPY pom.xml /pom.xml
RUN mvn clean package -DskipTests

FROM aquasec/trivy

COPY --from=maven /root/.m2 /root/.m2
COPY --from=maven pom.xml /pom.xml

RUN trivy -d fs --security-checks vuln --vuln-type library pom.xml
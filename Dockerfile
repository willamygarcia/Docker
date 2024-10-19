FROM ubuntu:20.04 AS awsconnect
RUN apt-get update && apt-get install unzip
RUN apt-get install curl -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN mkdir /arqconfig
WORKDIR /arqconfig
RUN aws s3 cp s3://config-application/arq-config-application/application.properties .

FROM maven:3.8.5-openjdk-17 AS build
RUN mkdir /project
COPY . /project
WORKDIR /project
RUN mvn clean package -DskipTests
 
FROM openjdk:17
RUN mkdir /app
ENV TZ="America/Fortaleza"
COPY --from=build /project/target/Application-1.0-SNAPSHOT.jar /app/Application-1.0-SNAPSHOT.jar
COPY /config /app/config/
COPY --from=awsconnect /arqconfig/application.properties /app/config/application.properties
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["java","-jar","Application-1.0-SNAPSHOT.jar"]

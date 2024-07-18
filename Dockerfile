ARG RUN_TOMCAT_IMAGE
ARG BUILD_IMAGE

## --- Base image (do not use)
FROM tomcat:${RUN_TOMCAT_IMAGE} as base
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install git iputils-ping wget npm unzip
WORKDIR /spring-petclinic
# Add dockerize for chain booting containers
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ARG AGENT_FOLDER
ENV AGENT_FOLDER=${AGENT_FOLDER}
ENV AGENT_JAR=${AGENT_FOLDER}/nudge.jar
ENTRYPOINT ["/entrypoint.sh"]
CMD java -javaagent:${AGENT_JAR} -jar -Dspring.profiles.active=${DB_PROFILE:-h2} petclinic.jar


## --- Run without building
FROM base as copy-and-run
ARG HOST_PETCLINIC_JAR=target/*.jar
COPY ${HOST_PETCLINIC_JAR} .


## --- Build
FROM gradle:${BUILD_IMAGE} as build
COPY src/ src/
COPY gradle/ gradle/
COPY build.gradle gradlew settings.gradle ./
RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon -i build
RUN ls -halt build/libs
RUN mv ./build/libs/spring-petclinic-?.?.?.jar /petclinic.jar


## --- Build and run
FROM base as build-and-run
COPY --from=build petclinic.jar .

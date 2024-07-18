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

ENV AGENT_FOLDER=${AGENT_FOLDER}
ARG AGENT_URL=https://ph-apm.download-agent.atakama-technologies.com/java/nudge-java.zip
RUN [ ! -f "${AGENT_FOLDER}/nudge.jar" ] && wget -O nudge.zip ${AGENT_URL} && unzip nudge.zip && mv nudge*.jar ${AGENT_FOLDER}/nudge.jar
CMD java -javaagent:${AGENT_FOLDER}/nudge.jar -jar -Dspring.profiles.active=${DB_PROFILE:-h2} petclinic.jar


## --- Build
FROM gradle:${BUILD_IMAGE} as build
COPY src/ src/
COPY gradle/ gradle/
COPY build.gradle gradlew settings.gradle ./
RUN --mount=type=cache,target=/root/.gradle ./gradlew --no-daemon -i build
RUN ls -halt build/libs
RUN mv ./build/libs/spring-petclinic-?.?.?.jar /petclinic.jar


## --- Run without building
FROM base as copy-and-run
ARG HOST_PETCLINIC_JAR=target/*.jar
COPY ${HOST_PETCLINIC_JAR} .


## --- Build and run
FROM base as build-and-run
COPY --from=build petclinic.jar .


## --- Copy agent (do not use)
FROM alpine as build-copy-agent
ARG COPY_AGENT_JAR=./nudge-agent/nudge.jar
ARG AGENT_FOLDER=/nudge-agent
RUN mkdir -p ${AGENT_FOLDER}
COPY ${COPY_AGENT_JAR}/nudge.jar ${AGENT_FOLDER}/nudge.jar

FROM tomcat:jdk21

# Update
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install git iputils-ping

# Copy petclinic app
COPY spring-petclinic/ /spring-petclinic
RUN  cd /spring-petclinic && ./mvnw package
WORKDIR /spring-petclinic

CMD java -javaagent:/spring-petclinic/nudge-agent/nudge.jar -jar target/*.jar
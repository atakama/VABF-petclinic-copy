FROM tomcat:jdk21

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install git iputils-ping
COPY petclinic/ /spring-petclinic
RUN  cd /spring-petclinic && ./mvnw package
WORKDIR /spring-petclinic

RUN mkdir -p /spring-petclinic/nudge-agent
COPY agent/* /spring-petclinic/nudge-agent/

CMD java -javaagent:/spring-petclinic/nudge-agent/nudge.jar -jar target/*.jar
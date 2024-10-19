#Base Image
FROM tomcat:9.0.96-jre8

#Change working directory
WORKDIR /usr/local/tomcat/webapps

#Copy app artifact inside the docker image
COPY app/target/simple-web-app.war .

#Listen on port 8080
EXPOSE 8080

FROM maven as builder
COPY ./app /app
WORKDIR /app
RUN ls && mvn clean install
FROM tomcat
RUN ["rm", "-rf", "/usr/local/tomcat/webapps/ROOT"]
COPY --from=builder /app/target/*.jar /usr/local/tomcat/webapps/ROOT.jar
CMD ["java","-jar","/usr/local/tomcat/webapps/ROOT.jar"]
#RUN mvnw spring-boot:run

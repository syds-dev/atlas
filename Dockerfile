FROM tomcat:8-jdk8

#RUN rm -rf /usr/local/tomcat/webapps/manager/META-INF/context.xml
#RUN rm -rf /usr/local/tomcat/conf/tomcat-users.xml

#COPY context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
#COPY tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

COPY WebAPI/target/WebAPI.war /usr/local/tomcat/webapps/WebAPI.war
COPY atlas.war /usr/local/tomcat/webapps/atlas.war

#WORKDIR /usr/local/tomcat/webapps/WebAPI
#RUN jar xvf WebAPI.war
#RUN rm -rf WebAPI.war
#WORKDIR /usr/local/tomcat/webapps/atlas
#RUN tar xvf front.tar
#RUN rm -rf front.tar


#!/bin/bash

echo "front IP:" $1 
echo "DB IP:" $2
if [ ! "$(ls WebAPI)" ] ; then
	git clone -b v2.7.2 https://github.com/OHDSI/WebAPI.git
fi
cp atlas/js/config/app.js.bak atlas/js/config/app.js
sed -i s/localhost:8080/$1/g atlas/js/config/app.js
cp WebAPI/sample_settings.xml WebAPI/settings.xml
sed -i s/localhost:5432/$2/g WebAPI/settings.xml
sed -i s/!PASSWORD!/admin1/g WebAPI/settings.xml
rm -rf  WebAPI/target
mvn clean package -f WebAPI/pom.xml -DskipTests -s WebAPI/settings.xml -P webapi-postgresql
rm -rf atlas.war
jar cvfM atlas.war -C atlas/ .
if [ "$(docker images -f dangling=true)" ] ; then
	docker rmi $(docker images -q -f dangling=true)	
fi
docker build -t ajou/atlas-tomcat:v1 .
if [ "$(docker ps -q -f name=atlas-tomcat)" ] ; then
        docker stop atlas-tomcat && docker rm atlas-tomcat
fi
if [ ! "$(docker ps -q -f name=atlas-tomcat)" ] ; then
	docker run --restart=always -d -p 80:8080  --name atlas-tomcat ajou/atlas-tomcat:v1
fi

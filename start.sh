DOCKER_IMAGE="atlas-tomcat"

if [ "$1" = "atlas" ] ; then
	if [ "$2" = "build" ] ; then
		echo "=============================================================================================="
		echo "\033[1;33matlas source build start \033[0m"
		echo "=============================================================================================="
		echo "\033[1;35mWeb IP:" $3
		echo "DB IP: " $4 "\033[0m"
		echo "=============================================================================================="
		if [ ! "$(ls WebAPI)" ] ; then
			git clone -b v2.7.2 https://github.com/OHDSI/WebAPI.git
		fi
		if [ ! "$(ls atlas/js/config/app.js_bak)" ] ; then
			cp atlas/js/config/app.js atlas/js/config/app.js_bak
		else 
			cp atlas/js/config/app.js_bak atlas/js/config/app.js
		fi
		sed -i s/localhost:8080/$3/g atlas/js/config/app.js
		cp WebAPI/sample_settings.xml WebAPI/settings.xml
		sed -i s/localhost:5432/$4/g WebAPI/settings.xml
		sed -i s/!PASSWORD!/admin1/g WebAPI/settings.xml
		rm -rf  WebAPI/target
		mvn clean package -f WebAPI/pom.xml -DskipTests -s WebAPI/settings.xml -P webapi-postgresql
			if [ ! "$(ls atlas.war)" ] ; then
				rm -rf atlas.war
			fi
		jar cvfM atlas.war -C atlas/ .
		docker build -t $DOCKER_IMAGE:v1 .
	elif [ "$2" = "docker" ] ; then
		
		if [ "$(docker images -f dangling=true)" ] ; then
			docker rmi $(docker images -q -f dangling=true)
		fi
		if [ "$3" = "start" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33matlas docker start \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$DOCKER_IMAGE)" ] ; then
				docker stop $DOCKER_IMAGE && docker rm $DOCKER_IMAGE
			fi
			if [ ! "$(docker ps -q -f name=$DOCKER_IMAGE)" ] ; then
				docker run --restart=always -d -p 80:8080  --name $DOCKER_IMAGE $DOCKER_IMAGE:v1
			fi
		elif [ "$3" = "stop" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33matlas docker stop \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$DOCKER_IMAGE)" ] ; then
				docker stop $DOCKER_IMAGE && docker rm $DOCKER_IMAGE
			fi
		fi
	
	fi
elif [ "$1" = "Rstudio" ] ; then
	if [ "$2" = "docker" ] ; then
			if [ "$3" = "start" ] ; then
				if [ "$(docker ps -q -f name=$DOCKER_IMAGE)" ] ; then
					echo "=============================================================================================="
					echo "\033[1;33mRstudio docker start \033[0m"
					echo "=============================================================================================="
					docker stop $DOCKER_IMAGE && docker rm $DOCKER_IMAGE
				fi
				if [ ! "$(docker ps -q -f name=$DOCKER_IMAGE)" ] ; then
					docker run --restart=always --name plp -e USER=user -e PASSWORD=password1 -d -p 8787:8787 chandryou/patientlevelprediction_cpu:3.0.0
				fi
				elif [ "$3" = "stop" ] ; then
					echo "=============================================================================================="
					echo "\033[1;33mRstudio docker stop \033[0m"
					echo "=============================================================================================="
				if [ "$(docker ps -q -f name=$DOCKER_IMAGE)" ] ; then
					docker stop plp && docker rm plp
				fi
		fi
	fi
fi

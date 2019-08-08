WEB_URL="169.56.100.186:80"
DB_URL="169.56.100.186:5432"
ATLAS_IMAGE="atlas-tomcat:v1"
ATLAS_NAME="atlas-tomcat"
RSTUDIO_IMAGE="chandryou/patientlevelprediction_cpu:3.0.0"
RSTUDIO_NAME="plp"
OHDSI_ADMIN_USER_PASS="admin1"
OHDSI_APP_USER="app1"
WEB_PORT="80"
RSTUDIO_PORT="8787"
RSTUDIO_USER="user"
RSTUDIO_PASS="password1"

if [ "$1" = "atlas" ] ; then
	if [ "$2" = "build" ] ; then
		if [ ! "$3" = "" ] ; then
			WEB_URL=$3
		fi
		if [ ! "$4" = "" ] ; then
			DB_URL=$4
		fi
		echo "=============================================================================================="
		echo "\033[1;33mAtlas Source Build Start \033[0m"
		echo "=============================================================================================="
		echo "\033[1;35mWeb IP:" $WEB_URL
		echo "DB IP: " $DB_URL "\033[0m"
		echo "=============================================================================================="
		if [ ! "$(ls WebAPI)" ] ; then
			git clone -b v2.7.2 https://github.com/OHDSI/WebAPI.git
		fi
		if [ ! "$(ls atlas/js/config/app.js_bak)" ] ; then
			cp atlas/js/config/app.js atlas/js/config/app.js_bak
		else 
			cp atlas/js/config/app.js_bak atlas/js/config/app.js
		fi
		sed -i s/localhost:8080/$WEB_URL/g atlas/js/config/app.js
		cp WebAPI/sample_settings.xml WebAPI/settings.xml
		sed -i s/localhost:5432/$DB_URL/g WebAPI/settings.xml
		sed -i s/!PASSWORD!/$OHDSI_ADMIN_USER_PASS/g WebAPI/settings.xml
		sed -i s/app1/$OHDSI_APP_USER/g WebAPI/settings.xml
		rm -rf  WebAPI/target
		mvn clean package -f WebAPI/pom.xml -DskipTests -s WebAPI/settings.xml -P webapi-postgresql
			if [ "$(ls atlas.war)" ] ; then
				rm -rf atlas.war
			fi
		jar cvfM atlas.war -C atlas/ .
		docker build -t $ATLAS_IMAGE .
			if [ "$(ls atlas.war)" ] ; then
				rm -rf atlas.war
			fi
	elif [ "$2" = "service" ] ; then
		
		if [ "$(docker images -q -f dangling=true)" ] ; then
			if [ "$(docker rmi $(docker images -q -f dangling=true))" ] ; then
				echo ""
			fi
		fi
		if [ "$3" = "start" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mAtlas Service Start \033[0m"
			echo "=============================================================================================="
			if [ ! "$(docker ps -q -f name=$ATLAS_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Starting...... \033[0m"
				if [ "$(docker run --restart=always -d -p $WEB_PORT:8080  --name $ATLAS_NAME $ATLAS_IMAGE)" ] ; then
					echo "\033[1;35mStatus : Service Started \033[0m"
				fi
			fi
		elif [ "$3" = "restart" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mAtlas Service Restart \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$ATLAS_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Stopping........... \033[0m"
				if [ "$(docker stop $ATLAS_NAME && docker rm $ATLAS_NAME)" ] ; then
					echo "\033[1;35mStatus : Service Stopped \033[0m"
				fi
			fi
			if [ ! "$(docker ps -q -f name=$ATLAS_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Restarting........... \033[0m"
				if [ "$(docker run --restart=always -d -p $WEB_PORT:8080  --name $ATLAS_NAME $ATLAS_IMAGE)" ] ; then
					echo "\033[1;35mStatus : Service Started \033[0m"
				fi		
			fi		
		elif [ "$3" = "stop" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mAtlas Service Stop \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$ATLAS_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Stopping..... \033[0m"
				if [ "$(docker stop $ATLAS_NAME && docker rm $ATLAS_NAME)" ] ; then
					echo "\033[1;35mStatus : Service Stopped \033[0m"

				fi	
			else
				echo "\033[1;35mStatus : Service Stopped \033[0m"

			fi
		elif [ "$3" = "status" ] ; then

			echo "=============================================================================================="
			echo "\033[1;33matlas docker status \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$ATLAS_NAME)" ] ; then
				echo "\033[1;35mStatus : atlas Running\033[0m"
			else	
				echo "\033[1;35mStatus : atlas Stopped\033[0m"
			fi
			echo "=============================================================================================="
		elif [ "$3" = "log" ] ; then	
			docker logs -f $ATLAS_NAME
		fi
	
	fi
elif [ "$1" = "rstudio" ] ; then
	if [ "$2" = "service" ] ; then
		if [ "$(docker images -q -f dangling=true)" ] ; then
			docker rmi $(docker images -q -f dangling=true)
		fi
		
		if [ "$3" = "start" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mRstudio Service Start \033[0m"
			echo "=============================================================================================="
			if [ ! "$(docker ps -q -f name=$RSTUDIO_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Starting..... \033[0m"
				if [ "$(docker run --restart=always --name $RSTUDIO_NAME -e USER=$RSTUDIO_USER -e PASSWORD=$RSTUDIO_PASS -d -p $RSTUDIO_PORT:8787 $RSTUDIO_IMAGE)" ] ; then
					echo "\033[1;35mStatus : Service Started \033[0m"
				fi
				
			fi
		elif [ "$3" = "restart" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mRstudio Service Restart \033[0m"
			echo "=============================================================================================="
				
			if [ "$(docker ps -q -f name=$RSTUDIO_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Stopping..... \033[0m"
				if [  "$(docker stop $RSTUDIO_NAME && docker rm $RSTUDIO_NAME)" ] ; then
					echo "\033[1;35mStatus : Service Stopped \033[0m"
				fi
			fi
			if [ ! "$(docker ps -q -f name=$RSTUDIO_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Starting..... \033[0m"
					if [ "$(docker run --restart=always --name $RSTUDIO_NAME -e USER=$RSTUDIO_USER -e PASSWORD=$RSTUDIO_PASS -d -p $RSTUDIO_PORT:8787 $RSTUDIO_IMAGE)" ] ; then
						echo "\033[1;35mStatus : Service Started \033[0m"
					fi
			fi
		elif [ "$3" = "stop" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mRstudio Service Stop \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$RSTUDIO_NAME)" ] ; then
				echo "\033[1;35mStatus : Service Stopping..... \033[0m"
				if [ "$(docker stop $RSTUDIO_NAME && docker rm $RSTUDIO_NAME)" ] ; then
					echo "\033[1;35mStatus : Service Stopped \033[0m"
				fi
			fi
		elif [ "$3" = "status" ] ; then
			echo "=============================================================================================="
			echo "\033[1;33mRstudio docker status \033[0m"
			echo "=============================================================================================="
			if [ "$(docker ps -q -f name=$RSTUDIO_NAME)" ] ; then
				echo "\033[1;35mStatus : RStudio Running\033[0m"
			else	
				echo "\033[1;35mStatus : RStudio Stopped\033[0m"
			fi
			echo "=============================================================================================="
		elif [ "$3" = "log" ] ; then	
			docker logs -f $RSTUDIO_NAME
		fi
	fi
fi


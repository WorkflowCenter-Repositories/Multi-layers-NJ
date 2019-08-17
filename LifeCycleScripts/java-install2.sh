#!/bin/bash

set -e

CONTAINER_ID=$1
blueprint=$2
version=$3
task=$4

# Start Timestamp
STARTTIME=`date +%s.%N`

#--------------------------------------------------------------------------------#
#------------------------------------ Java installation -------------------------#


if ! sudo docker exec -it $CONTAINER_ID which java >/dev/null; then
   sudo docker exec -it $CONTAINER_ID [ ! -d opt/jdk ] && sudo docker exec -it $CONTAINER_ID mkdir opt/jdk
   if [[ ! -d ~/$blueprint/libs ]]; then
      mkdir ~/$blueprint/libs
   fi

   if [[ $version = '8' ]]; then
    if [[ ! -f ~/.TDWF/libs/jdk-8u131-linux-x64.tar.gz ]]; then
       ctx logger info "download java 8"
       wget -O ~/.TDWF/libs/jdk-8u131-linux-x64.tar.gz --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
    fi
    ctx logger info "installing java 8"
    cp ~/.TDWF/libs/jdk-8u131-linux-x64.tar.gz ~/$blueprint/libs/jdk-8u131-linux-x64.tar.gz
    sudo docker exec -it $CONTAINER_ID tar -zxf root/$blueprint/libs/jdk-8u131-linux-x64.tar.gz -C /opt/jdk
    sudo docker exec -it $CONTAINER_ID update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_131/bin/java 100
    sudo docker exec -it $CONTAINER_ID update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_131/bin/javac 100
   else if [[ $version = '7' ]]; then
        if ! grep -Fxq "java7" ~/.TDWF/libs/libs.txt
      then
        echo "java7" >> ~/.TDWF/libs/libs.txt
        if [[ ! -f ~/.TDWF/libs/jdk-7u79-linux-x64.tar.gz ]]; then
           #ctx logger info "download java 7"
           wget -O ~/.TDWF/libs/jdk-7u79-linux-x64.tar.gz --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz"
        fi
      else
        size=0
        size2=$(stat --printf=%s ~/.TDWF/libs/jdk-7u79-linux-x64.tar.gz)
        ctx logger info "waiting $size $size2"
        while [[ $size != $size2 || $size2 == 0 ]]
        do
          echo "waiting" >> wait.txt
          sleep 3
          size=$size2
          size2=$(stat --printf=%s ~/.TDWF/libs/jdk-7u79-linux-x64.tar.gz)
        done
     fi
        ctx logger info "installing java 7"
        cp ~/.TDWF/libs/jdk-7u79-linux-x64.tar.gz ~/$blueprint/libs/jdk-7u79-linux-x64.tar.gz
        sudo docker exec -it $CONTAINER_ID tar xzf root/$blueprint/libs/jdk-7u79-linux-x64.tar.gz -C /opt/jdk
        sudo docker exec -it $CONTAINER_ID update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.7.0_79/bin/java 100
        sudo docker exec -it $CONTAINER_ID update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.7.0_79/bin/javac 100
        sudo docker exec -it $CONTAINER_ID update-alternatives --install /usr/bin/jar jar /opt/jdk/jdk1.7.0_79/bin/jar 100
     fi
  fi
fi
  
#------------------------------------ Java installation -------------------------#
#--------------------------------------------------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Install Java in ${CONTAINER_ID} $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv


#--------------------------------------------------------------------------------#
#-------------------------------- depend-image creation -------------------------#
create_image="True"
if [[ $create_image = "True" ]]; then

  
  ###### get base image of task container ######
   container=$(sudo docker ps -a | grep ${CONTAINER_ID})
   b=$(echo $container | cut -d ' ' -f2)                 #get base image
   base=${b//['/:']/-}
   ctx logger info "Base image for $container is $base"

   set +e
        #f=$(ssh cache@192.168.56.103 "cat DTDWD/tasks.txt" | grep $task)
   set -e
  if echo "$b" | grep -q $task; then
      ctx logger info "task-image already exist"
  else
   if echo "$b" | grep -q "java8"; then
      image=${b#*/}
      ctx logger info "depend-image already exist dtdwd/$image"
      
   else
      image=$base'_java8'
   
      #if ! grep -Fxq "$image" ~/.TDWF/images.txt
      #then
      #   echo $image >> ~/.TDWF/images.txt
         ctx logger info "Creating dtdwd/$image"
         sudo docker commit -m "new ${image} image" -a "rawa" ${CONTAINER_ID} dtdwd/$image
   fi
  fi

     
   #if [[ -z $f ]]; then
       #echo $task | ssh cache@192.168.56.103 "cat >> DTDWD/tasks.txt"
   
       ctx logger info "start caching"
      #./Caching-Corescripts/caching-policy.sh $image > /dev/null 2>&1 & 
      ./Caching-Corescripts/caching-public.sh $image > /dev/null 2>&1 &    
   #fi
fi

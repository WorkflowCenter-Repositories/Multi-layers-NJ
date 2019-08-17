#!/bin/bash

set -e

CONTAINER_ID=$1
LIBRARY_NAME=$(ctx node properties lib_name)
task=$2

# Start Timestamp
STARTTIME=`date +%s.%N`


#-------------------------------------------------#
#------------------- install wine ----------------#
set +e
  wine=$(sudo docker exec -it ${CONTAINER_ID} which wine)
set -e

if [[ -z ${wine} ]]; then      
 sudo docker exec -it ${CONTAINER_ID} dpkg --add-architecture i386       
 sudo docker exec -it ${CONTAINER_ID} apt-get update
 sudo docker exec -it ${CONTAINER_ID} apt-get -y install ${LIBRARY_NAME}

fi
#------------------- install wine ----------------#
#-------------------------------------------------#


# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "installing Wine tool : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv

#---------------------- creat depend-image --------------------------#
create_image="True"
if [[ $create_image = "True" ]]; then

   ctx logger info "creating dependency-image"  
  ###### get base image of task container ######
   container=$(sudo docker ps -a | grep ${CONTAINER_ID})
   b=$(echo $container | cut -d ' ' -f2)                 #get base image
   base=${b#*'/'}    #${b//['/:']/-}
   
   ctx logger info "base image for $container is $base "
   depend=$(echo "wine" | cut -f1 -d".")
   set +e
        #f=$(ssh cache@192.168.56.103 "cat DTDWD/tasks.txt" | grep $task)
   set -e
  if echo "$b" | grep -q $task; then
      ctx logger info "task-image already exist"
  else
   if echo "$b" | grep -q $depend; then
      image=${b#*/}
      ctx logger info "depend-image already exist dtdwd/$image"
      
   else
      image=$base'_'$depend
   
      #if ! grep -Fxq "$image" ~/.TDWF/images.txt
      #then
      #   echo $image >> ~/.TDWF/images.txt
         ctx logger info "Creating dtdwd/$image"
         sudo docker commit -m "new ${image} image" -a "rawa" ${CONTAINER_NAME} dtdwd/$image
   fi
  fi
fi
     

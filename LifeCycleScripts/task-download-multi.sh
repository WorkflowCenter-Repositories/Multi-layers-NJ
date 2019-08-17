#!/bin/bash

set -e
create_image=$1
block=$(ctx node name)
CONTAINER_ID=$2
BLOCK_NAME=$(ctx node properties block_name)
BLOCK_URL=$3

 ###### get task ID ######
   ctx logger info "download ${block} block"
   source $PWD/LifeCycleScripts/get-task-ID.sh
   var=$(func $BLOCK_URL)
   task=${var,,}
   
  
ctx logger info "Dowload ${task} on ${CONTAINER_ID}"
# Start Timestamp
STARTTIME=`date +%s.%N`

#-----------------------------------------#
#----------- download the task -----------#
ctx logger info "download ${block} block"
flag=0
sudo docker exec -it ${CONTAINER_ID} [ ! -f tasks/$task.jar ] && flag=1
#Checking if the task has been cached
if [[ $flag = 1 ]]; then
  if grep -Fxq "$task" ~/.TDWF/tasks.txt     #is the task already exist in the cache
   then
     size=0
     size2=$(stat --printf=%s ~/.TDWF/$task.jar)
     while [[ $size != $size2 || $size2 == 0 ]]   #check if there is another download for the same task
     do
      sleep 3
      size=$size2
      size2=$(stat --printf=%s ~/.TDWF/$task.jar)
     done
  else
   echo $task >> ~/.TDWF/tasks.txt
   [ ! -f ~/.TDWF/$task.jar ] && wget -O ~/.TDWF/$task.jar  ${BLOCK_URL}
  fi
  sudo docker exec -it ${CONTAINER_ID} [ ! -d tasks ] && sudo docker exec -it ${CONTAINER_ID} mkdir tasks

  cat ~/.TDWF/$task.jar | sudo docker exec -i ${CONTAINER_ID} sh -c 'cat > tasks/'$task.jar
fi
#----------- download the task -----------#
#-----------------------------------------#

 # End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "download ${block} to ${CONTAINER_ID}: $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv   

 

# Start Timestamp
STARTTIME=`date +%s.%N`
########################### image creation ###########################
if [[ $create_image = "True" ]]; then

  
  ###### get base image of task container ######
   container=$(sudo docker ps -a | grep ${CONTAINER_ID})
   b=$(echo $container | cut -d ' ' -f2)                 #get base image
   base=${b//['/:']/-}

   set +e
        #f=$(ssh cache@192.168.56.103 "cat DTDWD/tasks.txt" | grep $task)
   set -e

   if echo "$b" | grep -q "$task"; then
      image=${b#*/}
      ctx logger info "Task image already exist dtdwd/$image"
      
   else
      image=$base'_'$task
   
      #if ! grep -Fxq "$image" ~/.TDWF/images.txt
      #then
      #   echo $image >> ~/.TDWF/images.txt
         ctx logger info "Creating dtdwd/$image"
         if [[ $image == *"dtdwd"* ]]; then
          image=${image#"dtdwd-"}
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
 # End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`

echo "creating image dtdwd/$image : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv  


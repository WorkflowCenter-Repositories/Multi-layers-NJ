#!/bin/bash

set -e
blueprint=$1
block=$(ctx node name)
CONTAINER_ID=$2
BLOCK_NAME=$(ctx node properties block_name)
BLOCK_URL=$3


###### get task ID ######
   
   source $PWD/LifeCycleScripts/get-task-ID.sh
   var=$(func $BLOCK_URL)
   task=${var,,}

ctx logger info "Dowload ${block} on ${CONTAINER_ID}"
# Start Timestamp
STARTTIME=`date +%s.%N`
#-----------------------------------------#
#----------- download the task -----------#
ctx logger info "download ${block} block"

[ ! -f ~/.TDWF/$task.jar ] && wget -O ~/.TDWF/$task.jar  ${BLOCK_URL}

sudo docker exec -it ${CONTAINER_ID} [ ! -d tasks ] && sudo docker exec -it ${CONTAINER_ID} mkdir tasks

cat ~/.TDWF/$task.jar | sudo docker exec -i ${CONTAINER_ID} sh -c 'cat > tasks/'$task.jar

#----------- download the task -----------#
#-----------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "downloading $task task : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv




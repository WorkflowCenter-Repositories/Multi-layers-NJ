#!/bin/bash

set -e
blueprint=$1
block=$(ctx node name)
CONTAINER_ID=$2
BLOCK_URL=$(ctx node properties block_Url)
BLOCK_NAME=$(ctx node properties block_name)
input=$3

# Start Timestamp
STARTTIME=`date +%s.%N`

###### get task ID ######
   
   source $PWD/LifeCycleScripts/get-task-ID.sh
   var=$(func $BLOCK_URL)
   task=${var,,}

ctx logger info "Execute the block ${task}.jar"
sudo docker exec -it ${CONTAINER_ID} java -jar tasks/${task}.jar ${blueprint} ${block} ${input}
ctx logger info "finish of Executing the block ${task}.jar"
 # End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Execute task ${task}.jar : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv   


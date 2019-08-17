#!/bin/bash

set -e
blueprint=$1
block=$(ctx node name)
CONTAINER_ID=$2
BLOCK_NAME=$(ctx node properties block_name)
BLOCK_URL=$(ctx node properties block_Url)
LIB_DIR=$3

# Start Timestamp
STARTTIME=`date +%s.%N`

###### get task ID ######

   source $PWD/LifeCycleScripts/get-task-ID.sh
   var=$(func $BLOCK_URL)
   task=${var,,}

#-----------------------------------------#
#----------- execute the task -----------#


sudo docker exec -it ${CONTAINER_ID} jar xf tasks/$task.jar M6CC.mao
ctx logger info " Executing $task.jar"
sudo docker exec -it ${CONTAINER_ID} java -jar tasks/$task.jar ${blueprint} ${block} ${LIB_DIR}

#----------- execute the task -----------#
#-----------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Execute the task Mega-NJ: $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv 

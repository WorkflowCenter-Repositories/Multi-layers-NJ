#!/bin/bash

set -e

blueprint=$1

# Start Timestamp
STARTTIME=`date +%s.%N`

#----------------------------------------------------------#
#---------------- initiate blueprint folder ---------------#
if [ ! -d ~/${blueprint} ]; then

   mkdir ~/${blueprint}
   mkdir ~/${blueprint}/tasks

fi
if [ ! -d .RPQ ]; then   #dir for task txt file
   mkdir .RPQ
fi
if [ ! -d ~/.TDWF ]; then   #dir for task txt file
   mkdir ~/.TDWF
   mkdir ~/.TDWF/libs
   mkdir ~/.TDWF/tasks
   echo "" >> ~/.TDWF/libs/libs.txt
   echo "" >> ~/.TDWF/tasks/tasks.txt
fi

ctx logger info "copy ${blueprint}.yaml to ~/${blueprint}"

cp ${blueprint}.yaml ~/${blueprint}
#---------------- initiate blueprint folder ---------------#
#----------------------------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Creating WF folder : $TIMEDIFF" | sed 's/[ \t]/, /g' > ~/list.csv

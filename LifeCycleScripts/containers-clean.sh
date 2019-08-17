#!/bin/bash

set -e
container1=$1

container2=$2
# Start Timestamp
STARTTIME=`date +%s.%N`
a=${@}

for var in "$@"
do
  sudo docker rm -f "${var}"
done

 # End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "deleting the containers : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv  

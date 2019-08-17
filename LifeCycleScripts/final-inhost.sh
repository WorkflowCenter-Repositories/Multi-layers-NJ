#!/bin/bash

set -e
blueprint=$1

# Start Timestamp
STARTTIME=`date +%s.%N` 

ctx logger info "cleaning"

for dir in ~/${blueprint}/*/
do
    d=${dir%*/}
    rm -r ${d}
done

rm ~/${blueprint}/${blueprint}.yaml

rm -rf .RPQ

 # End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Finalizing and WF-folder cleaning: $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv

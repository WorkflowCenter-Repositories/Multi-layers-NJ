#!/bin/bash

set -e
blueprint=$1
CONTAINER_ID=$2
input_dir=$3
inputFile=$4

# Start Timestamp
STARTTIME=`date +%s.%N`



ctx logger info "copy the input ${input_dir}/${inputFile}"
#-----------------------------------------------------#
#---------------------- get input --------------------#
cp ${input_dir}/${inputFile} ~/${blueprint}/${inputFile}
#---------------------- get input --------------------#
#-----------------------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Getting Inputs to ${CONTAINER_ID} $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv

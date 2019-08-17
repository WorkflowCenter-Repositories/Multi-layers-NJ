#!/bin/bash

set -e
blueprint=$1
CONTAINER_NAME=$(ctx node properties container_ID)
IMAGE_NAME=$(ctx node properties image_name)
BLOCK_URL=$2
depend=( "$@" )

# Start Timestamp
STARTTIME=`date +%s.%N`
 
#-----------------------------------------#
#----------- pull the image --------------#
set +e
Image=''

#-----------search for task image---------#
###### get task ID ######
   
   source $PWD/LifeCycleScripts/get-task-ID.sh
   var=$(func $BLOCK_URL)
   task=${var,,}

base=${IMAGE_NAME//[':']/-}

#--------------- task image ----------------#
task_image=$base'_'$task

image=$(source $PWD/LifeCycleScripts/image-search.sh $task_image)
  ctx logger info "search for $task_image"
  if [[ ! -z $image ]]
  then
   found=1;
   Image=dtdwd/$task_image
   ctx logger info "task image found $Image"
  else
   arraylength=${#depend[@]}
   task_image=$base
   for (( i=2; i<${arraylength}; i++ ));
   do
     task_image=$task_image'_'${depend[$i]}
   done
   found=0
   for (( i=2; i<${arraylength}+1; i++ ));
   do
    Timage=$task_image'_'$task
    ctx logger info "search for task image $Timage"
    image=$(source $PWD/LifeCycleScripts/image-search.sh $Timage)
    ctx logger info "return value $image"
    if [[ ! -z $image ]]
    then
      Image="dtdwd/"${image}
      found=1
      break
    fi
    ctx logger info "search for depend image $task_image"
    image=$(source $PWD/LifeCycleScripts/image-search.sh $task_image)
    if [[ ! -z $image ]]
    then
      ctx logger info "return value $image"
      Image="dtdwd/"${image}
      found=1
      break
    fi
    # remove dependency after last "_"
    suf="${task_image##*_}"
    task_image=${task_image%"_$suf"}
    #ctx logger info "image $task_image"
   done
  fi
   if [[ $found == 0 ]]
   then
    ctx logger info "Default Image"
    sudo docker pull ubuntu:14.04 &>/dev/null
    Image="ubuntu:14.04"
   fi
 #else
 # Image=$base'_'$task
#fi
#----------- pull the image --------------#
#-----------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "downloading ${Image} image : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv
#------------------------------------------------------------------------------------------------------#
# Start Timestamp
STARTTIME=`date +%s.%N`

#-----------------------------------------#
#---------- creat the container ----------#
ctx logger info "used image $Image"
sudo docker run -P --name ${CONTAINER_NAME} -v ~/${blueprint}:/root/${blueprint} -it -d ${Image} bin/bash

#---------- creat the container ----------#
#-----------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Creating container ${CONTAINER_NAME} : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv

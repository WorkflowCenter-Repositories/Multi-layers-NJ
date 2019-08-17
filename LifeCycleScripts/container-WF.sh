#!/bin/bash

set -e
blueprint=$1
CONTAINER_NAME=$(ctx node properties container_ID)
IMAGE_NAME=$(ctx node properties image_name)
depend=( "$@" )

# Start Timestamp
STARTTIME=`date +%s.%N`
 
#-----------------------------------------#
#----------- pull the image --------------#
set +e
   Image=''
   base=${IMAGE_NAME//['/:']/-}
   tag=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))
   branch=$(git rev-parse --abbrev-ref HEAD)         
   wf=$1                #${PWD##*/}    # get WF name
   if [[ -z $tag ]]; then
     image=$base-$wf-$branch
   else 
     image=$base-$wf-$branch:$tag
   fi 
   WF_image=${image,,}
ctx logger info "image is ${WF_image}"
set -e

image=$(source $PWD/LifeCycleScripts/image-search.sh $WF_image)
  ctx logger info "search for $WF_image"
  if [[ ! -z $image ]]
  then
   found=1;
   Image=dtdwd/$WF_image
   ctx logger info "WF image found $Image"
  else
   arraylength=${#depend[@]}
   task_image=$base
   for (( i=1; i<${arraylength}; i++ ));
   do
     task_image=$task_image'_'${depend[$i]}
   done
   found=0
   for (( i=1; i<${arraylength}; i++ ));
   do
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
   done
  fi
   if [[ $found == 0 ]]
   then
    ctx logger info "Default Image"
    sudo docker pull ubuntu:14.04 &>/dev/null
    Image="ubuntu:14.04"
   fi

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

sudo docker run -P --name ${CONTAINER_NAME} -v ~/${blueprint}:/root/${blueprint} -it -d ${Image} bin/bash

#---------- creat the container ----------#
#-----------------------------------------#

# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "Creating container ${CONTAINER_NAME} : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv

#!/bin/bash

set -e

CONTAINER_ID=$1
create_image=$2
# Start Timestamp
STARTTIME=`date +%s.%N`
if [[ $create_image = "True" ]]; then
   ###### get base image of workflow container ######
   container=$(sudo docker ps -a | grep ${CONTAINER_ID})
   b=$(echo $container | cut -d ' ' -f2)
   base=${b//['/:']/_}
   ctx logger info "base image is $base"
   set +e   
   tag=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))
   branch=$(git rev-parse --abbrev-ref HEAD)         
   wf=$3  #${PWD##*/}    # get WF name
   if [[ -z $tag ]]; then
     image=$wf-$branch
   else 
     image=$wf-$branch:$tag
   fi 
   image=${image,,}
   
   if echo "$b" | grep -q "$image"; then
      image=${b#*/}
      ctx logger info "WF image already exist dtdwd/$image"
   else
      
      image=dtdwd/$base-$image
      ctx logger info "WF image is $image from ${CONTAINER_ID}"
      sudo docker commit -m "new ${image} image" -a "rawa" ${CONTAINER_ID} $image
   fi

   ctx logger info "start local caching dtdwd/$image"
   #./Caching-Corescripts/caching-policy.sh $image > /dev/null 2>&1 & 
   #./Caching-Corescripts/caching-public.sh $image > /dev/null 2>&1 &
fi
# End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "creating ${Image} image : $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv

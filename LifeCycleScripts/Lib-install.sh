#!/bin/bash

set -e

CONTAINER_NAME=$1
Lib_URL=$2
Lib_name=$(ctx node properties lib_name)
Lib_path=$(ctx node properties lib_path)
task=$3

# Start Timestamp
STARTTIME=`date +%s.%N`

sudo docker exec -it ${CONTAINER_NAME} test -f $Lib_path/$Lib_name || test -f $Lib_name && exit 0
        

sudo docker exec -it ${CONTAINER_NAME} test -d $Lib_path && sudo docker exec -it ${CONTAINER_NAME} rm -rf $Lib_path

file_name=$(basename "$Lib_URL")
ctx logger info "before downloading"
[ ! -f ~/.TDWF/libs/$file_name ] && wget -O ~/.TDWF/libs/$file_name ${Lib_URL}

flag=0

sudo docker exec -it ${CONTAINER_NAME} test ! -f $file_name && flag=1

if [[ $flag == 1 ]]; then
  ctx logger info "copy $file_name"
 cat ~/.TDWF/libs/$file_name | sudo docker exec -i ${CONTAINER_NAME} sh -c 'cat > '$file_name
fi

tar="tar.gz"
set +e
ctx logger info "unzip $file_name"
sudo docker exec -it ${CONTAINER_NAME} test "${file_name#*$tar}" != "$file_name" && sudo docker exec -it ${CONTAINER_NAME} tar -zxvf $file_name

ctx logger info "run $Lib_name"
sudo docker exec -it ${CONTAINER_NAME} chmod -R 777 $Lib_path/$Lib_name
set -e

 # End timestamp
ENDTIME=`date +%s.%N`

# Convert nanoseconds to milliseconds
# crudely by taking first 3 decimal places
TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{print $1"."substr($2,1,3)}'`
echo "install $Lib_name in $CONTAINER_NAME: $TIMEDIFF" | sed 's/[ \t]/, /g' >> ~/list.csv   

#---------------------- creat depend-image --------------------------#
create_image="True"
if [[ $create_image = "True" ]]; then

   ctx logger info "creating dependency-image"  
  ###### get base image of task container ######
   container=$(sudo docker ps -a | grep ${CONTAINER_NAME})
   b=$(echo $container | cut -d ' ' -f2)                 #get base image
   base=${b#*'/'}    #${b//['/:']/-}
   
   ctx logger info "base image for $container is $base "
   depend=$(echo $Lib_name | cut -f1 -d".")
   set +e
        #f=$(ssh cache@192.168.56.103 "cat DTDWD/tasks.txt" | grep $task)
   set -e
  if echo "$b" | grep -q $task; then
      ctx logger info "task-image already exist"
  else
   if echo "$b" | grep -q $depend; then
      image=${b#*/}
      ctx logger info "depend-image already exist dtdwd/$image"
      
   else
      image=$base'_'$depend
   
      #if ! grep -Fxq "$image" ~/.TDWF/images.txt
      #then
      #   echo $image >> ~/.TDWF/images.txt
         ctx logger info "Creating dtdwd/$image"
         sudo docker commit -m "new ${image} image" -a "rawa" ${CONTAINER_NAME} dtdwd/$image
   fi
  fi

     
   #if [[ -z $f ]]; then
       #echo $task | ssh cache@192.168.56.103 "cat >> DTDWD/tasks.txt"
   
       ctx logger info "start caching"
      #./Caching-Corescripts/caching-policy.sh $image > /dev/null 2>&1 & 
      ./Caching-Corescripts/caching-public.sh $image > /dev/null 2>&1 &    
   #fi
fi


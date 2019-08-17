#!/bin/bash

image=$1
set -e
Image1=""
if [[ "$(sudo docker images -q dtdwd/${image} 2> /dev/null)" != "" ]]; then
 ctx logger info "local task image"
 Image1=${image}
else 
   set +e
    # connect=$(ssh -o BatchMode=yes -o ConnectTimeout=1 cache@192.168.56.103 echo ok 2>&1)
   set -e
   # ctx logger info "$connect"
   #if [[ $connect == "ok" ]]; then
   
    #ssh cache@192.168.56.103 test -f "DTDWD/${task_image}.tar.gz" && flag=1

    #if [[  $flag = 1  ]]; then
     # ctx logger info "cached task image"
     # set +e           
      # scp -P 22 cache@192.168.56.103:DTDWD/${task_image}.tar.gz ${task_image}.tar.gz
       #zcat --fast ${task_image}.tar.gz | docker load
      # rm ${task_image}.tar.gz
      #set -e    
      #Image=dtdwd/${task_image} 
      
   #else
     dock=$(sudo docker search dtdwd/${image})     #task image from public hub
      set +e
        found=0 #`echo $dock | grep -c dtdwd/${image}`                   
      set -e
      if [[ $found = 1 ]]; then
         ctx logger info "task image from public hub ${image}"
         sudo docker pull dtdwd/${image} &>/dev/null
         Image1=dtdwd/${image}
      fi
fi

echo $Image1

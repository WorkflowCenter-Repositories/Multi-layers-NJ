
#!/bin/bash
task=$1
set -e
found=0   
dock=$(sudo docker search dtdwd/$task)        #search for the task image in remote rep.
echo "$dock"

set +e
 found=`echo $dock | grep -w dtdwd/$task`
set -e
echo "found is $found"
if [[ -z $found ]]; then 
   #echo "start pushing"                                                   
   sudo docker push dtdwd/$task    
fi



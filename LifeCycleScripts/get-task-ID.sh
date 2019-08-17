func () {
Url=$1
phrase="/raw"
repo_Url="${Url%%$phrase*}"   #get url part before raw
var=${Url%/*}     
task=${repo_Url##*/}
item=$(echo ${var##*/})   #get the item after raw e.g: "zip-PW-release"

if [[ ! -f .RPQ/$task.txt ]]; then
 git ls-remote --refs $repo_Url.git > .RPQ/$task.txt 2>&1 
fi
ref=$(grep -n $item .RPQ/$task.txt)
if grep -q "heads" <<< "$ref" ; then
  #echo " it is a branch"
  SHA=$(echo ${ref:2:40})
  #echo $SHA	
  tag=$(grep -n $SHA .RPQ/$task.txt)
  if [[ ! -z $tag ]]; then 
   tag=${tag##*/} 
  #echo "tag $tag"
  else
   #echo "tag is latest"
   tag='latest'
  fi
else
if grep -q "tags" <<< "$ref" ; then
#echo "it's tag"
   tag=$item
fi
fi
echo $task'.'$tag

}

#!/bin/bash
tmpfile="/tmp/tmp.txt"
timestamp=`date +%s` # 系统现在时间

if [ ! -f "$tmpfile" ]; then 
    touch "$tmpfile" 
fi 

falcon(){
  endpoint=$HOSTNAME
  step=60
  metric="log_size_rate"
  tag="log"
  value=`awk -F\| '{print $NF}' $tmpfile |sort -nr|head -1`
  if [ ! -n "$value" ]; then  
      value="0"
  fi  
  bbtree-falconcurl -m $metric -v $value -c GAUGE -s $step -e $endpoint -t $tag &>/dev/null
}
for file in `find /data/logs/ /data/bbtree/www/*/logs/ -mmin -10 -size +10M -type f|grep -v access`;do
    size=`ls -l $file|awk '{print $5}'`
    size=`expr $size / 1024 / 1024`
    #---------------------获取上个大小值,求差值------------------------
    upsize=`grep $file $tmpfile|awk -F\| '{print $2}'`   # 获取文件上个size值
    diffsize=`expr $size - $upsize`
    if [[ $diffsize < 0 ]];then
        diffsize=0
    fi
    #---------------------获取要删除的值-----------------------
    keys=`cat $tmpfile|grep $file|awk -F'|' '{print $1}'`
    keys=`echo "${keys//\//\\/}"`
    sed -i "/$keys/d" $tmpfile
    echo $file"|"$size"|"$diffsize >> $tmpfile 	       # write file
done
falcon

for file in `cat $tmpfile`;do
    filename=`echo $file |awk -F\| '{print $1}'`
    filenameremove=`cat $tmpfile|grep $file|awk -F'|' '{print $1}'`
    filenameremove=`echo "${filenameremove//\//\\/}"`
    filetimestamp=`stat -c %Y $filename`
    timecha=`expr $timestamp - $filetimestamp`
    if [ $timecha -gt 600 ];then
        sed -i "/$filenameremove/d" $tmpfile
    fi
done

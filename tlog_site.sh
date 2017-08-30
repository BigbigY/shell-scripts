#!/bin/bash
tmpfile="/tmp/tmp.txt"
timestamp=`date +%s` # 系统现在时间

falcon(){
  endpoint=$HOSTNAME
  step=60
  metric="log_size_rate"
  tag="log"
  value=`awk -F\| '{print $NF}' $tmpfile |sort -nr|head -1`
  echo "bbtree-falconcurl -m $metric -v $value -c GAUGE -s $step -e $endpoint -t $tag &>/dev/null"
  bbtree-falconcurl -m $metric -v $value -c GAUGE -s $step -e $endpoint -t $tag &>/dev/null
}

echo "--------------------------开始循环----------------------------------"
for file in `find /data/logs/ /data/bbtree/www/*/logs/ -mmin -10 -size +10M -type f`;do
    echo "---------------------获取文件大小--$file--------------------------------"
    size=`ls -l $file|awk '{print $5}'`
    size=`expr $size / 1024 / 1024`
    echo "size:$size"

    echo "---------------------获取项目名----------------------------------"
    keys=`echo $file|awk -F\/ '{print $3}'`      # 
    if [ $keys == logs ];then			 #
        keys=`echo $file|awk -F/ '{print $4}'`   # 获取项目名
    else                                         # 
        keys=`echo $file|awk -F/ '{print $5}'`   #
    fi
    echo "$keys"
    
    echo "---------------------获取上个大小值----------------------------------"
    upsize=`perl -ne 'if (m{'$file'}){s/a/b/;print}' $tmpfile |awk -F\| '{print $3}'|tail -1`   # 获取文件上个size值
    diffsize=`expr $size - $upsize`
    echo "upsize:$upsize"
    echo "diffize:$diffsize"


    echo "---------------------获取要删除的值----------------------------------"
    keys1=`cat $tmpfile|grep $file`                    # 
    keys1=`echo $keys1|awk -F\/ '{print $NF}'|awk -F\| '{print $1"|"$2}'`         #  已经获取完值，删除对应条目，以便下面写入
    echo "del:$keys1"
    if [ $upsize ];then
        sed -i "/"$keys1"/d" $tmpfile                      #  
    fi
    echo 'echo $file"|"$keys"|"$size"|"$diffsize >> $tmpfile'
    echo $file"|"$keys"|"$size"|"$diffsize >> $tmpfile 	       # write file
done

falcon


for file in `cat $tmpfile`;do
    filename=`echo $file |awk -F\| '{print $1}'`
    filenameremove=`echo $file |awk -F\| '{print $1}'|awk -F\/ '{print $NF}'`
    filetimestamp=`stat -c %Y $filename`
    timecha=`expr $timestamp - $filetimestamp`
    if [ $timecha -gt 600 ];then
        sed -i "/$filenameremove/d" $tmpfile
    fi
done


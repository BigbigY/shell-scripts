#!/bin/bash
# 开启黑洞脚本；执行sh xxx.sh [num]

wight_num="$1"
# 获取主机列表
var=$(curl http://yun.ops.bbtree.com/mtree/get_hostnames?treeid=2198)
host_list=`echo $var|sed 's/,/ /g;s/\[/ /g;s/\]/ /g;s/"/ /g'`
for remote_host in $host_list;do
    /usr/bin/salt $remote_host cmd.script salt://scripts/phpwannx/black_hole_on_client.sh $wight_num
    ssh $remote_host "/usr/local/tengine/sbin/nginx -t"
    if [ $? -eq 0 ];then
        ssh $remote_host "/usr/local/tengine/sbin/nginx -s reload" #重启
        echo "reload $remote_host successful!"
    else 
        echo "reload $remote_host error!"
    fi
done

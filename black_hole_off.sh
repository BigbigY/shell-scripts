#!/bin/bash
# 关闭黑洞脚本；执行sh xxx.sh


# 获取主机列表
var=$(curl -s  http://xxx.xxx.xxx/mtree/get_hostnames?treeid=2198)
host_list=`echo $var|sed 's/,/ /g;s/\[/ /g;s/\]/ /g;s/"/ /g'`
for remote_host in $host_list;do
    /usr/bin/salt $remote_host cmd.script salt://scripts/phpwannx/black_hole_off_client.sh
    ssh $remote_host "/usr/local/tengine/sbin/nginx -t"
    if [ $? -eq 0 ];then
        ssh $remote_host "/usr/local/tengine/sbin/nginx -s reload" #重启
        echo "reload $remote_host successful!"
    else 
        echo "reload $remote_host error!"
    fi
done


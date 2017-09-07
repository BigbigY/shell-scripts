#!/bin/bash
# auth: wangyy02
# confluence 开放公网访问开关
# sh confluence_step.sh [on | off]

# off:限制外网访问   on:允许外网访问

# confluence.bbtree.com.conf.off 限制外网访问 
# confluence.bbtree.com.conf.on  允许外网访问

setup="$1"
hostname="hz-confluence-02"

if [[ $setup == off ]];then
    ssh $hostname "cp /usr/local/tengine/conf/vhosts/confluence.bbtree.com.conf.off /usr/local/tengine/conf/vhosts/confluence.bbtree.com.conf"
    ssh $hostname "/usr/local/tengine/sbin/nginx -t"
    if [[ $? != 0 ]];then
        echo "config error,Please log in ${hostname} check!"
        exit 1
    else
        ssh $hostname "/usr/local/tengine/sbin/nginx -s reload"
        echo "Deny Public access successful!"
    fi
elif [[ $setup == on ]];then
    ssh $hostname "cp /usr/local/tengine/conf/vhosts/confluence.bbtree.com.conf.on /usr/local/tengine/conf/vhosts/confluence.bbtree.com.conf"
    ssh $hostname "/usr/local/tengine/sbin/nginx -t"
    if [[ $? != 0 ]];then
        echo "config error,Please log in ${hostname} check!"
        exit 1
    else
        ssh $hostname "/usr/local/tengine/sbin/nginx -s reload"
        echo "Allow Public access successful!"
    fi
else
    echo "参数错误,[ 参数: on | off]"
fi


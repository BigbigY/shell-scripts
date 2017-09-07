#!/bin/bash
# erp 重启脚本

check="$1"

if [[ $check == restart ]];then
    salt 'hz-erp-*' cmd.run "killall -9 java"
    sleep 2
    salt 'hz-erp-*' cmd.run "/data/bbtree/www/bbtree-erp/bin/startup.sh"
    salt 'hz-erp-*' cmd.run "/etc/init.d/jmxmon start"
else
    echo "参数错误,重启:[restart]!"
fi

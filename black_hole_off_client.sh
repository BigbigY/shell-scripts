#`!/bin/bash
# Auth user: wangyy02
# 关闭黑洞脚本

# $1  off   关闭脚本


filename=/usr/local/tengine/conf/vhosts/upstream.conf
echo "配置文件:$filename"

black_hole_switch="off"
echo "动作:$black_hole_switch"

status=`sed -n "/heidong/{/^#/p}" ${filename}|wc -l`
echo "当前状态:$status[0:开启状态 非零:关闭状态]"

date_time=`date "+%Y%m%d"`
cp $filename ${filename}.${date_time}
echo "备份文件:${filename}.${date_time}"

black_hole() {
    if [[ $status == 0 ]];then
        sed -i '/heidong/s/^/#/' $filename
        echo "stop black-hole successful!"
    else
        echo "black-hole already stop!"
    fi
}

black_hole

diff $filename ${filename}.${date_time}

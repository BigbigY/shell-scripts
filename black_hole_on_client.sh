#`!/bin/bash
# Auth user: wangyy02
# 开启黑洞脚本
# $1  开关（on,off）

filename=/usr/local/tengine/conf/vhosts/upstream.conf
echo "配置文件:$filename"

black_hole_switch="on"
echo "动作:$black_hole_switch"

status=`sed -n "/heidong/{/^#/p}" ${filename}|wc -l`
echo "当前状态:$status[0:开启状态 非零:关闭状态]"

date_time=`date "+%Y%m%d"`
cp $filename ${filename}.${date_time}
echo "备份文件:${filename}.${date_time}"

black_hole_on() {
    echo "start black-hole..."
    if [[ $status != 0 ]];then        
        sed -i '/heidong/s/^#//' $filename
        echo "start black-hole successful!"
    else
        echo "black-hole already start!"
    fi
}

wight_num="$1"

black_wight() {
    old_wight=`sed -n '/heidong/p' $filename|head -1`
    if [ $wight_num ];then
        new_wight_tmp="weight=$wight_num;"
        new_wight=${old_wight/weight=*;/$new_wight_tmp}
        echo $new_wight
        sed -i "s/$old_wight/$new_wight/g" $filename
    fi
}

black_wight
black_hole_on

diff $filename ${filename}.${date_time}

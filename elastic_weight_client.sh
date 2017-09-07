#`!/bin/bash
# Auth user: wangyy02
# 设置弹性机权重；sh xxx.sh [num]
# $1  权重 (输入数字)

date_time=`date "+%Y%m%d"`

filename=/usr/local/tengine/conf/vhosts/upstream.conf
cp $filename ${filename}.${date_time}
echo "备份文件:${filename}.${date_time}"

wight_num="$1"
elastic_wight() {
    old_wight=`sed -n '/elastic/p' $filename|head -1`
    if [ $wight_num ];then
        new_wight_tmp="weight=$wight_num;"
        new_wight=${old_wight/weight=*;/$new_wight_tmp}
        echo $new_wight
        sed -i "s/$old_wight/$new_wight/g" $filename
    fi
}

elastic_wight

diff $filename ${filename}.${date_time}

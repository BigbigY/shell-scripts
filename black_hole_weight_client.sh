#`!/bin/bash
# Auth user: wangyy02

# $1  类型（黑洞，弹性）
# $2  开关（on,off）
# $3  权重 (输入数字)

filename=/usr/local/tengine/conf/vhosts/upstream.conf
wight_num="$1"


date_time=`date "+%Y%m%d"`
cp $filename ${filename}.${date_time}
echo "备份文件:${filename}.${date_time}"

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

diff $filename ${filename}.${date_time}

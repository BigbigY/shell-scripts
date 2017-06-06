#/bin/bash

s_dir=("classRuleSync" "dataSync" "dynamicSync" "schoolMailSync" "openRegistrationData" "schoolNewsSync" "syncCardAndDevice")
p_dir=("tuxing_7133" "tuxing_7090" "tuxing_7091" "tuxing_7092" "tuxing_7093" "tuxing_7094" "tuxing_7095" "tuxing_7096" "tuxing_7097" "tuxing_7098")
s_url=/datassd/tuxing_s/
d_url=/datassd/tuxing/
head_num=20

#1-clear
clear_file(){
echo "-----clear file------"
for a in ${p_dir[*]:0};do
  for b in ${s_dir[*]:0};do
   rm -rf ${d_url}${a}/${b}/*
  done
done
}

#2-mv 文件
mv_file(){
num=1
while [[ $num -ne 0 ]];do
  for dirname in ${p_dir[*]:0};do
    #echo "--Astart $dirname"
    for sdir in ${s_dir[*]:0};do
      #echo "--Bstart $sdir"
      for filename in `ls /datassd/tuxing_s/${sdir}/|head -${head_num}`;do
        #echo "--Cstart $filename"
        #echo "mv /datassd/tuxing_s/${sdir}/${filename} /datassd/tuxing/$dirname/${sdir}/"
        mv /datassd/tuxing_s/${sdir}/"${filename}" /datassd/tuxing/$dirname/${sdir}/
      done
    done
  done
  #num=`find /datassd/tuxing_s/${s_dir}/ -type f|wc -l`
  num=`find /datassd/tuxing_s/ -type f|wc -l`
done
}

clear_file
Kong=`find /datassd/tuxing/ -type f|wc -l`
if [[ $num -eq 0 ]];
then  
  echo "模板目录清理完毕，$Kong"
  mv_file
fi
echo "done...."

#!/bin/bash
# auth: wangyy02

hostname="$1"

check=`ssh $hostname "ifconfig"`
if [[ $? != 0 ]];then
    echo "主机还未同步,请稍后再试!"
    exit 255
fi


hostip=`ssh $hostname ip a|awk '$1=="inet" && /eth0/{print $2}'|awk -F/ '{print $1}'`
echo "ip:$hostip"

echo "正在尝试 $hostname 校对修正机器名"
echo "1)check机器名"

ssh $hostname "hostname -s"

echo "2)修正机器名"
echo "ssh $hostname \"hostname $hostname\""
ssh $hostname "hostname $hostname"

echo "3)修正network主机名"
echo "ssh $hostname \"cp /etc/sysconfig/network /etc/sysconfig/network.bak\""
ssh $hostname "cp /etc/sysconfig/network /etc/sysconfig/network.bak"
echo "ssh $hostname \"sed -i \'/HOSTNAME=/c HOSTNAME=$hostname\' /etc/sysconfig/network\""
ssh $hostname "sed -i '/HOSTNAME=/c HOSTNAME=$hostname' /etc/sysconfig/network"
flag=$(ssh $hostname "grep $hostname /etc/sysconfig/network|wc -l")
echo $flag
if [[ $flag -eq 0 ]];then
    echo "修改network失败！"
    exit 1
fi

echo "4)修改salt minion id"
echo "ssh $hostname \">/etc/salt/minion_id\""
ssh $hostname ">/etc/salt/minion_id"
echo "ssh $hostname \"/etc/init.d/salt-minion restart\""
ssh $hostname "/etc/init.d/salt-minion restart"
flag=$(ssh $hostname "grep $hostname /etc/salt/minion_id|wc -l")
echo $flag
if [[ $flag -eq 0 ]];then
    echo "修改minion_id失败,直接插入条目"
    ssh $hostname "echo $hostname >/etc/salt/minion_id"
fi


echo "5)修改hosts主机列表"
echo "sed -i \"/$hostip /c $hostip $hostname\" /etc/hosts"
cp /etc/hosts /tmp/hosts.tmp
sed -i "/$hostip/c $hostip $hostname" /etc/hosts
flag=$(ssh $hostname "grep $hostname /etc/hosts|wc -l")
echo $flag
if [[ $flag -eq "0" ]];then
    echo "替换hosts文件主机条目失败,直接插入一条"
    ssh $hostname "echo \"$hostip $hostname\" >> /etc/hosts"
fi

echo "6)check修改是否完成"
localname=`ssh $hostname "hostname -s"`
if [[ $hostname == $localname  ]];then
    echo "修改主机名完成!"
else
    echo "修改主机名失败!"
fi

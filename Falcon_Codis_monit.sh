#!/bin/bash
#定义字典
#${!Dashboard_URL[*]} all key
#${a_key} key name
#${Dashboard_URL["${a_key}"]}"  value name
declare -A Dashboard_URL
Dashboard_URL=(
[backcodis]="10.172.24.198" 
[newusercodis]="10.25.65.200" 
[passkaoqincodis]="10.26.232.111"
[sharecodis]="10.168.177.145"
)

total() {
  endpoint=$HOSTNAME
  step=60
  tag="name=${a_key},proxy=${Dashboard_URL["${a_key}"]}"
  metric="codis.ops.total"
  value=`curl -s "http://${Dashboard_URL["${a_key}"]}:11080/proxy" |jq '.stats'|jq '.ops.total'`
  bbtree-falconcurl -m $metric -v $value -c COUNTER -s $step -e $endpoint -t $tag &>/dev/null
}
qps() {
  endpoint=$HOSTNAME
  step=60
  tag="name=${a_key},proxy=${Dashboard_URL["${a_key}"]}"
  metric="codis.ops.qps"
  value=`curl -s "http://${Dashboard_URL["${a_key}"]}:11080/proxy" |jq '.stats'|jq '.ops.qps'`
  bbtree-falconcurl -m $metric -v $value -c GAUGE -s $step -e $endpoint -t $tag &>/dev/null
}
fails() {
  endpoint=$HOSTNAME
  step=60
  tag="name=${a_key},proxy=${Dashboard_URL["${a_key}"]}"
  metric="codis.ops.fails"
  value=`curl -s "http://${Dashboard_URL["${a_key}"]}:11080/proxy" |jq '.stats'|jq '.ops.fails'`
  bbtree-falconcurl -m $metric -v $value -c COUNTER -s $step -e $endpoint -t $tag &>/dev/null
}
online() {
  endpoint=$HOSTNAME
  step=60
  tag="name=${a_key},proxy=${Dashboard_URL["${a_key}"]}"
  metric="codis.ops.online"
  if [ "true" == `curl -s "http://${Dashboard_URL["${a_key}"]}:11080/proxy" |jq '.stats'|jq '.online'` ] ;then
    value=0
  else
    value=1
  fi
  bbtree-falconcurl -m $metric -v $value -c GAUGE -s $step -e $endpoint -t $tag &>/dev/null
}

for a_key in ${!Dashboard_URL[*]};do
#  -----$a_key-------"
#  -----curl:${Dashboard_URL["${a_key}"]}----------"
  for ip in `curl -s "http://${Dashboard_URL["${a_key}"]}:18080/topom"|jq .stats.proxy.models[].admin_addr |awk -F'["]' '{print $2}'` 
    do
#      ----read:$ip----"
      total
      qps
      fails
      online
    done
done

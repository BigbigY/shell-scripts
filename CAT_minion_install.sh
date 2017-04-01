#!/bin/bash
# Author:Luck
# This is a CAT minion install scripts.
# sh scripts_name.sh [setting] [project name]

CAT_DIR=/data/appdatas/cat
CAT_FIL=/data/appdatas/cat/client.xml

check_dir() {
if [ ! -d "$CAT_DIR" ];then  
  mkdir -p $CAT_DIR && echo "mkdir cat_dir success" 
  return 0
fi  
}

test_xml() {
cat << EOF >>/data/appdatas/cat/client.xml 
<config mode="client">
  <servers>
    <!--test-->
    <server ip="%MASTER_IP%" port="2280" http-port="8080"/>
  </servers>
</config>
EOF
return 0
}

prod_xml() {
cat << EOF >>/data/appdatas/cat/client.xml 
<config mode="client"> 
  <servers> 
    <!--prod--> 
    <server ip="%MASTER_IP%" port="2280" http-port="8080"/> 
    <server ip="%MASTER_IP%" port="2280" http-port="8080"/> 
  </servers> 
</config>
EOF
return 0
}

pro_name=$2
add_project() {
  DATA=`sed -n "/<domain id=\"${pro_name}\" enabled=\"true\"\/>/p" $CAT_FIL`
  if [ "$DATA" == "" ]; then
    sed -i "/<\/config>/i \    <domain id=\"${pro_name}\" enabled=\"true\"/>" $CAT_FIL
  else
    echo "project is already"
  fi
}

check_dir
if [ $1 == "test" ] && [ ! -f $CAT_FIL ];then
  test_xml
  add_project
elif [ $1 == "prod" ] && [ ! -f $CAT_FIL ];then
  prod_xml
  add_project
else
  add_project
fi

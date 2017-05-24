#!/bin/bash
# wangyy02@bbtree.com
# cp tomcat and sync project
DIR=/data/bbtree/www/
PROJECT_MASTER=bbtree-data-sync

PROJECT_SLAVE_LIST=("bbtree-data-sync-7090" "bbtree-data-sync-7100" "bbtree-data-sync-7120" "bbtree-data-sync-7130" "bbtree-data-sync-7140" "bbtree-data-sync-7150" "bbtree-data-sync-7160" "bbtree-data-sync-7170" "bbtree-data-sync-7180")

Mkdir_project(){
#---------------------
#  拷贝项目并修改端口
#---------------------

cd $DIR
for PROJECT_SLAVE in ${PROJECT_SLAVE_LIST[*]:0};do
    if [ ! -d "$PROJECT_SLAVE" ];then
        # 拷贝项目
        cp -r ${PROJECT_MASTER} ${PROJECT_SLAVE}
        echo "创建 ${PROJECT_SLAVE} done.."
        # 配置修改
        TOMCAT_DIR="${DIR}${PROJECT_SLAVE}"
        http_port=`echo "${PROJECT_SLAVE}"|awk -F- '{print $4}'`
        shutdown_port=$((http_port + 200))
        ajp_port=$((http_port + 400))
        https_port=$((http_port + 600))
        jvm_port=$((http_port + 800))        
        sed -i "s/7133/${http_port}/;s/7333/${shutdown_port}/;s/7533/${ajp_port}/;s/7733/${https_port}/;s/7933/${jvm_port}/;s/catalina-7133-/catalina-${http_port}-/" ${TOMCAT_DIR}/conf/server.xml
        sed -i "s/7133/${http_port}/;s/7933/${jvm_port}/" ${TOMCAT_DIR}/bin/catalina.sh
        echo "修改 ${PROJECT_SLAVE} 配置 done.."
    else
        echo "$PROJECT_SLAVE already"
    fi
done
echo "Done!"
}

Sync_project(){
#---------------------
#     同步代码 
#---------------------
echo "开始同步代码..."
for PROJECT_SLAVE in ${PROJECT_SLAVE_LIST[*]:0};do
    if [ ! -d "$PROJECT_SLAVE" ];then
        S_TOMCAT_DIR="${DIR}${PROJECT_MASTER}/webapps/ROOT/"
        D_TOMCAT_DIR="${DIR}${PROJECT_SLAVE}/webapps/ROOT/"
        echo "rsync -az --delete ${S_TOMCAT_DIR} ${D_TOMCAT_DIR}"
        rsync -az --delete ${S_TOMCAT_DIR} ${D_TOMCAT_DIR}
    fi
done
echo "同步代码完成..."
}

Mkdir_project
Sync_project


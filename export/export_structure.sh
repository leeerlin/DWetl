#!/bin/bash
#export_structure.sh
#*=================================================
#*
#* FileName : export_structure.sh
#* CreateDate: 2015-12-1
#* Abstract : 导出数据库中特定模式的数据
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep DATABASE ../common.cfg)
eval $(grep USERID ../common.cfg)
eval $(grep USERPASSWD ../common.cfg)

if [ $# -ne 1 ] ; then
echo "Input parameter error, there should be 1 parameters ";        
exit 1;
fi;

SCHEMA=$1

#2016年2月2日 16:32:23修改
#解决：当服务器字符集和数据库环境变量不相符时，导出的文件中会存在乱码的问题
CODE=`db2set | grep DB2CODEPAGE | awk -F"=" '{print $2}'`
if [[ ${CODE} -eq 1386 ]] ; then 
	export LANG=zh_CN.GB2312
else
	export LANG=zh_CN.UTF-8
fi;


db2look -d ${DATABASE} -i ${USERID} -w ${USERPASSWD} -ct -e -z ${SCHEMA} -td \# -o ${PWDNOW}/../file/create/${SCHEMA}.sql
sed -i '/CONNECT TO/d' ${PWDNOW}/../file/create/${SCHEMA}.sql ${PWDNOW}/../file/create/${SCHEMA}.sql
#!/bin/bash
#export_data.sh
#*=================================================
#*
#* FileName : export_data.sh
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

if [ ! -d "${PWDNOW}/../file/data/${SCHEMA}" ] ; then        
	mkdir -p "${PWDNOW}/../file/data/${SCHEMA}"
fi;

cd ${PWDNOW}/../file/data/${SCHEMA}
db2move ${DATABASE} export -u ${USERID} -p ${USERPASSWD} -sn ${SCHEMA}

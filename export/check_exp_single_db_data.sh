#!/bin/bash
#check_exp_single_db_data.sh
#*=================================================
#*
#* FileName : check_exp_single_db_data.sh
#* CreateDate: 2016-3-8
#* Abstract : 检验数据库中指定表的记录数
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep DATABASE ../common.cfg)
eval $(grep USERID ../common.cfg)
eval $(grep USERPASSWD ../common.cfg)

if [ $# -ne 3 ] ; then
echo "Input parameter error, there should be 3 parameters ";        
exit 1;
fi;

TYPE=$1
SCHEMA=$2
OBNAME=$3

#检查表是否存在
FLAG=0
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null
FLAG=`db2 -x "SELECT 1 FROM SYSCAT.TABLES WHERE TABSCHEMA = '${SCHEMA}' AND TABNAME = '${OBNAME}' "`
IF 


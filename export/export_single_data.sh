#!/bin/bash
#export_single_data.sh
#*=================================================
#*
#* FileName : export_single_data.sh
#* CreateDate: 2016-2-5
#* 入参：｛结构类型｝ ｛模式名｝ ｛名称｝，例如：TABLE DM T_ORG_BIZ_LVL
#* Abstract : 导出数据库中特定模式的数据
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

if [ ! -d "${PWDNOW}/../file/data/${SCHEMA}" ] ; then        
	mkdir -p "${PWDNOW}/../file/data/${SCHEMA}"
fi;

db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null 2>&1

#输出数据及记录信息
db2 "EXPORT to ../file/data/${SCHEMA}/${OBNAME}.ixf OF ixf SELECT * FROM ${SCHEMA}.${OBNAME}" > ../file/data/${SCHEMA}/${OBNAME}.msg

#记录文件列表
echo "!\"${SCHEMA}\".\"${OBNAME}\"!${OBNAME}.ixf!${OBNAME}.msg!" >> ../file/data/${SCHEMA}/db2move.lst

#导出条数记录
ROWS=`cat ../file/data/${SCHEMA}/${OBNAME}.msg | grep SQL3105N | awk -F" " '{print $8}' | sed "s/\"//g"`
echo "EXPORT:  ${ROWS} rows from table \"${SCHEMA}\".\"${OBNAME}\"" >> ../file/data/${SCHEMA}/EXPORT.out
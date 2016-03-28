#!/bin/bash
#import.sh
#*=================================================
#*
#* FileName : import.sh
#* CreateDate: 2015-12-1
#* Abstract : 导入数据库中特定模式
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep SCHEMAS ../common.cfg)
eval $(grep PARTITIONS ../common.cfg)

if [ $# -eq 1 ] ; then
	SCHEMAS=$1
fi;
echo "This shell will input schema include : ${SCHEMAS} "

for SCHEMA in `echo ${SCHEMAS//,/ }`; #2016年2月29日修改增加循环，避免导入数据时发生不存在的情况导致整个调用退出
	do 		
		sh ${PWDNOW}/import_structure.sh $SCHEMA >> ${PWDNOW}/../file/logs/import_structure.log
		
		if [ $PARTITIONS -eq 1 ] ; then
			sh ${PWDNOW}/import_data.sh $SCHEMA >> ${PWDNOW}/../file/logs/import_data.log
		else
			sh ${PWDNOW}/import_partition_data.sh $SCHEMA >> ${PWDNOW}/../file/logs/import_data.log
		fi;
	done;
	

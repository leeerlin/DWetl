#!/bin/bash
#export.sh
#*=================================================
#*
#* FileName : export.sh
#* CreateDate: 2015-12-1
#* Abstract : 导出数据库中特定模式
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep SCHEMAS ../common.cfg)

if [ $# -eq 1 ] ; then
	SCHEMAS=$1
fi;
echo "This shell will output schema include : ${SCHEMAS} "

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do
		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "开始导出数据结构，模式名：${SCHEMA}"
		echo "查看日志命令：tail -f ${PWDNOW}/../file/logs/export_structure.log"
		sh ${PWDNOW}/export_structure.sh $SCHEMA > ${PWDNOW}/../file/logs/export_structure.log
		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "导出数据机构结束，模式名：${SCHEMA}"

		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "开始导出数据，模式名：${SCHEMA}"
		echo "查看日志命令：tail -f ${PWDNOW}/../file/logs/export_data.log"
		sh ${PWDNOW}/export_data.sh $SCHEMA > ${PWDNOW}/../file/logs/export_data.log
		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "导出数据结束，模式名：${SCHEMA}"

	
	done;
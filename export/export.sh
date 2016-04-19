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

unset OBO 
while [ -n "$1" ]
do
  case $1 in 
   -1by1) OBO=1;;
   -S) SCHEMAS="$2"
   		 shift 1;;
   --) shift
       break;;
   *) echo "$1 不是参数，忽略"
   esac
   shift
done

echo "This shell will output schema include : ${SCHEMAS} "

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do
		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "开始导出数据结构，模式名：${SCHEMA}"
		echo "查看日志命令：tail -f ${PWDNOW}/../file/logs/export_structure.log"
		
		if [[ ${OBO} = '1' ]] ; then
			sh check_exp_db_create.sh $SCHEMA 
			ln -sf ../file/tmp/export_db_create/${SCHEMA}.lst ./${SCHEMA}.lst
			sh export_single.sh -nodata -f ${SCHEMA}.lst >> ${PWDNOW}/../file/logs/export_structure.log
			rm -r ./${SCHEMA}.lst
		else 
			sh ${PWDNOW}/export_structure.sh $SCHEMA >> ${PWDNOW}/../file/logs/export_structure.log
		fi;
		
		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "导出数据机构结束，模式名：${SCHEMA}"

		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "开始导出数据，模式名：${SCHEMA}"
		echo "查看日志命令：tail -f ${PWDNOW}/../file/logs/export_data.log"
		sh ${PWDNOW}/export_data.sh $SCHEMA >> ${PWDNOW}/../file/logs/export_data.log
		echo `date "+%Y-%m-%d %H:%M:%S"`
		echo "导出数据结束，模式名：${SCHEMA}"

	
	done;
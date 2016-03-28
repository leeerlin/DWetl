#!/bin/bash
#export_except.sh
#*=================================================
#*
#* FileName : export_except.sh
#* CreateDate: 2016-2-23
#* Abstract : 导出数据库中特定模式，去掉特定的报表
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

if [ -e ${PWDNOW}/OBJECT.LST ] ; then 
rm -f ${PWDNOW}/OBJECT.LST
fi;

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
		#导出结构
		sh ${PWDNOW}/export_structure.sh $SCHEMA > ${PWDNOW}/../file/logs/export_structure.log 2>&1
		
		#产生模式下所有对象的列表$SCHEMA.lst
		sh ${PWDNOW}/check_exp_db_create.sh $SCHEMA
		
		#生成导出模式的列表文件
		cat ${PWDNOW}/../file/tmp/export_db_create/${SCHEMA}.lst | grep "=TABLE=" | sed "s/ //g" |while read LINE
		do
			if [ -e aaaaa ] ; then 
			rm -f aaaaa
			fi;
			cat EXCEPT.LST | grep "=TABLE=${SCHEMA}="|while read EXCEPT #找出该模式下不需要的对象except.tmp
			do
				if [[ ${LINE} = ${EXCEPT} ]] ; then
					touch aaaaa
				fi;
			done;
			if [ ! -e aaaaa ] ; then
				echo ${LINE} >> ${PWDNOW}/OBJECT.LST
			fi;		
		done;
		if [ -e aaaaa ] ; then 
			rm -f aaaaa
		fi;
		
	
	done;

#根据列表文件导出数据
cat ${PWDNOW}/OBJECT.LST | while read LINES
do
	#e.g.: =VIEW=DPS=T_SC_VCL_PZT_20160114=
	TYPE=`echo ${LINES} | awk -F"=" '{print $2}'`
	SCHEMA=`echo ${LINES} | awk -F"=" '{print $3}'`
	OBNAME=`echo ${LINES} | awk -F"=" '{print $4}'`
	
	sh export_single_data.sh ${TYPE} ${SCHEMA} ${OBNAME}
done;


#!/bin/bash
#export_single.sh
#*=================================================
#*
#* FileName : export_single.sh
#* CreateDate: 2016-2-21
#* 入参：没有时使用模式LIST文件，或者传入自定义的LIST文件全路径
#* Abstract : 根据LIST文件，批量导出数据库对象的结构及数据
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep DATABASE ../common.cfg)
eval $(grep USERID ../common.cfg)
eval $(grep USERPASSWD ../common.cfg)

OBJECT_FILE=OBJECT.LST

unset NOSTRUCTURE NODATA
while [ -n "$1" ]
do
  case $1 in 
   -nostructure) NOSTRUCTURE=1;;
   -nodata) NODATA=1;;
   -f) OBJECT_FILE="$2"
   		 shift 1;;
   --) shift
       break;;
   *) echo "$1 不是参数，忽略"
   esac
   shift
done

if [ ! -e "${OBJECT_FILE}" ] ; then        
	echo "${OBJECT_FILE} is not exists"
	exit 1;
fi;

cat ${OBJECT_FILE} | while read LINE
do
	#e.g.: =VIEW=DPS=T_SC_VCL_PZT_20160114=
	TYPE=`echo ${LINE} | awk -F"=" '{print $2}'`
	SCHEMA=`echo ${LINE} | awk -F"=" '{print $3}'`
	OBNAME=`echo ${LINE} | awk -F"=" '{print $4}'`
	echo "-------------------------------------"
	echo "deal with object：${SCHEMA}.${OBNAME}"
	echo "-------------------------------------"
	#查找在数据库中是否存在该对象
	#查找导出的文件中是否已存在该对象的信息
	#导出该对象的结构
	STRU_FLAG=0
	
	if [[ ${NOSTRUCTURE} = '1' ]] ; then
		STRU_FLAG=1 #参数设定不导出结构
		echo "***发现结构导出跳过参数，数据结构不导出***"
	fi;
	
	if [ ${STRU_FLAG} = '0' ] ; then
		echo "开始导出结构"
		sh export_single_structure.sh ${TYPE} ${SCHEMA} ${OBNAME}
		echo "导出结构完成"
	fi;
	#导出该对象的数据
	DATA_FLAG=0
	if [ ${TYPE} != 'TABLE' ] ; then
		DATA_FLAG=1 #数据类型异常
		echo "***非数据表，没有数据可以导出***"
	else
		if [[ ${NODATA} = '1' ]] ; then
		DATA_FLAG=2 #参数设定不导出数据
		echo "***发现数据导出跳过参数，数据不导出***"
		fi;
	fi;
	if [ ${DATA_FLAG} = '0' ] ; then
		echo "开始导出数据"
		sh export_single_data.sh ${TYPE} ${SCHEMA} ${OBNAME}
		echo "导出数据完成"
	fi;
	#完成后校验
	#输出导出后的统计信息
done



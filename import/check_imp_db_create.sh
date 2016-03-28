#!/bin/bash
#check_imp_db_create.sh
#*=================================================
#*
#* FileName : check_imp_db_create.sh
#* CreateDate: 2016-3-3 
#* Abstract : 
#* 入参：模式名
#* 根据check_imp_file_create.sh产生的lst文件，查看对应的对象是否已经在数据库中存在，
#* 如果不存在则将对象输出到文件$DW_HOME/file/tmp/import_db_create/{模式名}.lst
#* 包含信息：=｛结构类型｝=｛模式名｝=｛名称｝=，例如：=TABLE=DM=T_ORG_BIZ_LVL=
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

if [ ! -e ${PWDNOW}/../file/tmp/import_file_create/${SCHEMA}.lst ] ; then
echo "import_file_create/${SCHEMA}.lst is not exists , please run \'sh ${PWDNOW}/check_imp_file_create.sh ${SCHEMA}\' first"
exit 2;
fi;

echo "" > ../file/tmp/import_db_create/${SCHEMA}.lst

cat ${PWDNOW}/../file/tmp/import_file_create/${SCHEMA}.lst | while read LINE
do
	#拆分出三个参数
	#e.g.: =VIEW=DPS=T_SC_VCL_PZT_20160114=
	TYPE=`echo ${LINE} | awk -F"=" '{print $2}'`
	SCHEMA=`echo ${LINE} | awk -F"=" '{print $3}'`
	OBNAME=`echo ${LINE} | awk -F"=" '{print $4}'`
	#根据不同的类型进行对比    	
	db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null
	case ${TYPE} in
		TABLE)
			NUM=`db2 -x "SELECT 1 FROM SYSCAT.TABLES WHERE TABSCHEMA = '${SCHEMA}' AND TABNAME = '${OBNAME}' " | wc -l`
			;;
		VIEW)
			NUM=`db2 -x "SELECT 1 FROM SYSCAT.VIEWS WHERE VIEWSCHEMA = '${SCHEMA}' AND VIEWNAME = '${OBNAME}' " | wc -l`
			;;
		PROCEDURE)
			NUM=`db2 -x "SELECT 1 FROM SYSCAT.PROCEDURES WHERE PROCSCHEMA = '${SCHEMA}' AND PROCNAME = '${OBNAME}' " | wc -l`
			;;
		FUNCTION)
			NUM=`db2 -x "SELECT 1 FROM SYSCAT.FUNCTIONS WHERE FUNCSCHEMA = '${SCHEMA}' AND FUNCNAME = '${OBNAME}' " | wc -l`
			;;
		INDEX)
			NUM=`db2 -x "SELECT 1 FROM SYSCAT.INDEXES WHERE INDSCHEMA = '${SCHEMA}' AND INDNAME = '${OBNAME}' " | wc -l`
			;;
		SEQUENCE)
			NUM=`db2 -x "SELECT 1 FROM SYSCAT.SEQUENCES WHERE SEQSCHEMA = '${SCHEMA}' AND SEQNAME = '${OBNAME}' " | wc -l`
			;;
		*)
			echo "-------------Type: ${TYPE} is wrong-------------"
			;;
	esac
	
	#如果存在则忽略，不存在则需导出到lst文件中，再次入库
	if [ ${NUM} -eq 0 ] ; then 
		echo ${LINE} >> ../file/tmp/import_db_create/${SCHEMA}.lst
	fi;
done;

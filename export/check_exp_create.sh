#!/bin/bash
#check_exp_create.sh
#*=================================================
#*
#* FileName : check_exp_create.sh
#* CreateDate: 2016-2-2
#* Abstract : 
#* 入参：模式名
#* 对$DW_HOME/file/tmp/export_db_create/{模式名}.lst和$DW_HOME/file/tmp/export_file_create/{模式名}.lst两个文件进行分析，产生分析结果到文件$DW_HOME/file/check/{模式名}/export_db_create.info和$DW_HOME/file/check/{模式名}/export_file_create.info
#* 对产生的分析结果文件进行对比，如通过则生成正确文件$DW_HOME/file/check/｛模式名｝.success，反之生成$DW_HOME/file/check/｛模式名｝.error
#* 并将匹配不到的问题记录在$DW_HOME/file/check/｛模式名｝.error文件中
#* 包含信息：=｛模式名｝=｛对象类型｝=｛数据库中的数量｝=｛导出文件中的数量｝=
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep DATABASE ../common.cfg)
eval $(grep USERID ../common.cfg)
eval $(grep USERPASSWD ../common.cfg)

unset SINGLE_FLAG
while [ -n "$1" ]
do
  case $1 in 
   -single) SINGLE_FLAG=1;;
   -S) SCHEMA="$2"
   		 shift 1;;
   --) shift
       break;;
   *) echo "$1 不是参数，忽略"
   esac
   shift
done

if [[ ${SCHEMA} = "" ]] ; then
echo "Input parameter error, one schema name should be given ";  
echo "Usage: sh check_exp_create.sh -S schemaname"      
exit 1;
fi;


echo "check_exp_file_create.sh is begin:" `date "+%Y-%m-%d %H:%M:%S"`
sh ./check_exp_file_create.sh ${SCHEMA}
echo "check_exp_file_create.sh has finished" `date "+%Y-%m-%d %H:%M:%S"`
echo ""
if [[ ${SINGLE_FLAG} = "1" ]] ; then   #当从OBJECT.LST列表中导出数据时，直接将OBJECT.LST作为db_check的结果
cp ${PWDNOW}/OBJECT.LST ${PWDNOW}/../file/tmp/${INFO_FROM}/${SCHEMA}.lst
else  
echo "check_exp_db_create.sh is begin:" `date "+%Y-%m-%d %H:%M:%S"`
sh ./check_exp_db_create.sh ${SCHEMA}
echo "check_exp_db_create.sh has finished." `date "+%Y-%m-%d %H:%M:%S"`
fi;

if [ ! -d "../file/check/${SCHEMA}" ] ; then
	mkdir -p "../file/check/${SCHEMA}"
fi

#文件类型
TYPES=TABLE,VIEW,PROCEDURE,FUNCTION,INDEX,SEQUENCE
#文件来源
INFO_FROMS=export_file_create,export_db_create

#产生信息汇总文件
for INFO_FROM in `echo ${INFO_FROMS//,/ }`;
	do
		echo "" > ../file/check/${SCHEMA}/${INFO_FROM}.info
		for TYPE in `echo ${TYPES//,/ }`;
		do 
			count=`cat ../file/tmp/${INFO_FROM}/${SCHEMA}.lst | grep -i "=${TYPE}=" | wc -l`
			echo "=${TYPE}=${count}=" >> ../file/check/${SCHEMA}/${INFO_FROM}.info
		done;
	done;

#校验汇总信息，产生对应的文件

if [ -e ../file/check/${SCHEMA}.success ] ; then
	rm -f ../file/check/${SCHEMA}.success
fi;
if [ -e ../file/check/${SCHEMA}.success ] ; then
	rm -f ../file/check/${SCHEMA}.error
fi;

for TYPE in `echo ${TYPES//,/ }`;
	do
		DB_NUM=`cat ../file/check/${SCHEMA}/export_db_create.info | grep -i "=${TYPE}=" | awk -F"=" '{print $3}'`
		FILE_NUM=`cat ../file/check/${SCHEMA}/export_file_create.info | grep -i "=${TYPE}=" | awk -F"=" '{print $3}'`
		if [ ${DB_NUM} -eq ${FILE_NUM} ] ; then
			echo "=${SCHEMA}=${TYPE}=${DB_NUM}=${FILE_NUM}=" >> ../file/check/${SCHEMA}.success
		else
			echo "=${SCHEMA}=${TYPE}=${DB_NUM}=${FILE_NUM}=" >> ../file/check/${SCHEMA}.error
			#开始遍历明细数据，找出数据库中存在，但是导出的文件中不存在的记录
			cat ../file/tmp/export_db_create/${SCHEMA}.lst | grep -i "=${TYPE}=" | while read OBJECT_NAME
			do
				NUM=`cat ../file/tmp/export_file_create/${SCHEMA}.lst | grep -i "${OBJECT_NAME}" | wc -l` 
				if [ ${NUM} -eq 0 ] ; then
					echo "${OBJECT_NAME}" >> ../file/check/${SCHEMA}.error
				fi;
			done;
		fi;
	done;
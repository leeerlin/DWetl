#!/bin/bash
#export_single_structure.sh
#*=================================================
#*
#* FileName : export_single_structure.sh
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

#判断输入的数据类型是否符合规范
if [[ ${TYPE} != 'TABLE' && ${TYPE} != 'VIEW' && ${TYPE} != 'PROCEDURE' && ${TYPE} != 'FUNCTION' && ${TYPE} != 'SEQUENCE' ]] ; then
	echo "Input parameter error , TYPE:${TYPE} is not match , please check !"
	echo "TYPE should be one of (TABLE,VIEW,PROCEDURE,FUNCTION,SEQUENCE)"
	exit 1;
fi;

#2016年2月2日 16:32:23修改
#解决：当服务器字符集和数据库环境变量不相符时，导出的文件中会存在乱码的问题
CODE=0
CODE=`db2set | grep DB2CODEPAGE | awk -F"=" '{print $2}'`
if [[ ${CODE} -eq 1386 ]] ; then 
	export LANG=zh_CN.GB2312
else
	export LANG=zh_CN.UTF-8
fi;

if [ -e ../file/tmp/DDL.tmp ] ; then 
rm -f ../file/tmp/DDL.tmp
fi;

#表
if [ ${TYPE} = 'TABLE' ] ; then
db2look -e -d ${DATABASE} -i ${USERID} -w ${USERPASSWD} -z ${SCHEMA} -t ${OBNAME} -noview -td \# -o ../file/tmp/DDL.tmp > /dev/null 2>&1
sed -i '/CONNECT TO/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
sed -i '/CONNECT RESET/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
sed -i '/TERMINATE/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
fi;
#视图
if [ ${TYPE} = 'VIEW' ] ; then
db2look -e -d ${DATABASE} -i ${USERID} -w ${USERPASSWD} -z ${SCHEMA} -v ${OBNAME} -td \# -o ../file/tmp/DDL.tmp > /dev/null 2>&1
sed -i '/CONNECT TO/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
sed -i '/CONNECT RESET/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
sed -i '/TERMINATE/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
sed -i '/SET CURRENT/d' ${PWDNOW}/../file/tmp/DDL.tmp ${PWDNOW}/../file/tmp/DDL.tmp
fi;
#存过
if [ ${TYPE} = 'PROCEDURE' ] ; then
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null 2>&1
db2 "export to /dev/null of del lobs to ../file/tmp lobfile DDL.TMP modified by lobsinfile select text||'#' from syscat.procedures where procschema='${SCHEMA}' and procname='${OBNAME}'" > /dev/null 2>&1
mv ${PWDNOW}/../file/tmp/DDL.TMP.* ${PWDNOW}/../file/tmp/DDL.tmp
fi;
#函数
if [ ${TYPE} = 'FUNCTION' ] ; then
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null 2>&1
db2 "export to /dev/null of del lobs to ../file/tmp lobfile DDL.TMP modified by lobsinfile SELECT BODY||'#' FROM SYSCAT.FUNCTIONS WHERE FUNCSCHEMA = '${SCHEMA}' AND FUNCNAME = '${OBNAME}'" > /dev/null 2>&1
mv ${PWDNOW}/../file/tmp/DDL.TMP.* ${PWDNOW}/../file/tmp/DDL.tmp
fi;
#序列
if [ ${TYPE} = 'SEQUENCE' ] ; then
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null 2>&1
db2 -x "SELECT 'CREATE SEQUENCE '||TRIM(SEQSCHEMA)||'.'||TRIM(SEQNAME)||' AS INTEGER MINVALUE '||MINVALUE||' MAXVALUE '||MAXVALUE||' START WITH '||START||' INCREMENT BY '||INCREMENT||' CACHE '||CACHE||' '||CASE WHEN CYCLE = 'Y' THEN 'CYCLE' ELSE 'NO CYCLE' END||' '||CASE WHEN ORDER = 'Y' THEN 'ORDER' ELSE 'NO ORDER' END||' #'  FROM SYSCAT.SEQUENCES WHERE SEQSCHEMA = '${SCHEMA}' AND SEQNAME = '${OBNAME}'" >> ../file/tmp/DDL.tmp
db2 -x "SELECT 'ALTER SEQUENCE '||TRIM(SEQSCHEMA)||'.'||TRIM(SEQNAME)||' RESTART WITH '||TO_CHAR(INTEGER(NEXTCACHEFIRSTVALUE)+INTEGER(CACHE)-1)||' #' FROM SYSCAT.SEQUENCES WHERE SEQSCHEMA = '${SCHEMA}' AND SEQNAME = '${OBNAME}'" >> ../file/tmp/DDL.tmp
fi;

#将结果导出到对应的文件中
cat ${PWDNOW}/../file/tmp/DDL.tmp >> ${PWDNOW}/../file/create/${SCHEMA}.sql
echo "" >> ${PWDNOW}/../file/create/${SCHEMA}.sql



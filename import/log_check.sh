#!/bin/bash
#log_check.sh
#*=================================================
#*
#* FileName : log_check.sh
#* CreateDate: 2015-12-1
#* Abstract : 寻找导入日志中的错误
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

cd ${PWDNOW}/../file/logs/

LOG_NAME=import_structure.log
if [ $# -eq 1 ] ; then
	LOG_NAME=$1
fi;

awk '{printf("%s ",$0)}' $LOG_NAME | sed 's/CREATE /\nCREATE /g' | sed 's/ALTER /\nALTER /g' | sed 's/COMMENT ON /\nCOMMENT ON /g' | grep -v SQLSTATE=42710 | while read LINE 
	do 
		if [[ $LINE =~ "SQLSTATE=" ]] ; then
			echo "---------------------------------------" >> ${PWDNOW}/../file/logs/log.error
			echo $LINE >> ${PWDNOW}/../file/logs/log.error
			echo "---------------------------------------" >> ${PWDNOW}/../file/logs/log.error
			echo "" >> ${PWDNOW}/../file/logs/log.error
			echo "" >> ${PWDNOW}/../file/logs/log.error
			#FLAG=`echo $LINE | awk -F'SQLSTATE=' '{print $2}' `
			#if [ $FLAG -eq 42704 ] ; then
			#	#CREATE FUNCTION "ETL"."F_TABLE_TO_COL_ETL_FIDM2" ("V_STR" VARCHAR(4000) ) RETURNS VARCHAR(4000) SPECIFIC "ETL"."F_TABLE_TO_COL_ETL" LANGUAGE SQL NOT DETERMINISTIC READS SQL DATA STATIC DISPATCH CALLED ON NULL INPUT EXTERNAL ACTION INHERIT SPECIAL REGISTERS BEGIN ATOMIC DECLARE str_return VARCHAR(4000); set str_return = ''; for v_c as select FIDM_COL_NAME from QYP.FIDM_TO_ODSDWDM T1 INNER JOIN SYSCAT.COLUMNS T2 ON TRIM(TABSCHEMA)||'.'||TABNAME=FIDM_TABLE_NAME AND UPPER(FIDM_COL_NAME) = T2.COLNAME WHERE FIDM_TABLE_NAME=V_STR ORDER BY RN do set str_return = str_return||','||FIDM_COL_NAME; end for; return substr(str_return,2); END  DB21034E  The command was processed as an SQL statement because it was not a  valid Command Line Processor command.  During SQL processing it returned: SQL0204N  "QYP.FIDM_TO_ODSDWDM" is an undefined name.  LINE NUMBER=17.   SQLSTATE=42704
			#	YIN=`echo $line | awk -F"SQL0204N " '{print $2}' | awk -F" is" '{print $1}'`
			#	
			#elif
			#
			#fi;
		fi;
	done
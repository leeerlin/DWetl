#!/bin/bash
#check_exp_file_create.sh
#*=================================================
#*
#* FileName : check_exp_file_create.sh
#* CreateDate: 2016-01-30 23:20:19
#* Abstract : 
#* 入参：模式名
#* 导出文件中提取信息，通过多导出的结构文件进行分析，将明细数据导出到临时文件$DW_HOME/file/tmp/export_file_create/{模式名}.lst
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

echo "" > ../file/tmp/export_file_create/${SCHEMA}.lst
LINE2=""
cat ${PWDNOW}/../file/create/$SCHEMA.sql | while read LINE
    do
    	LINE1=${LINE2}          #修改处理的对象，将两行数据合并为一行进行处理，避免对象名称和标识不再一行的情况，2016年3月1日 李斌
    	LINE2=${LINE}
    	LONE_LINE=`echo ${LINE1} ${LINE2}`
    if [[ ${LINE1} != "" ]] ; then
    	if [[ $LONE_LINE =~ "CREATE " || $LONE_LINE =~ "create " ]] ; then
    		if [[ $LONE_LINE =~ " PROCEDURE " ]] ; then
    			INFO=`echo $LONE_LINE | sed "s/CREATE PROCEDURE/=PROCEDURE=/g" | sed "s/CREATE OR REPLACE PROCEDURE/=PROCEDURE=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " procedure " ]] ; then
    			INFO=`echo $LONE_LINE | sed "s/create procedure/=PROCEDURE=/g" | sed "s/create or replace procedure/=PROCEDURE=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " TABLE " ]] ; then
    			INFO=`echo $LONE_LINE | awk -F" AS " '{print $1}' | sed "s/ SUMMARY / /g"| sed "s/CREATE TABLE/=TABLE=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    	  elif [[ $LONE_LINE =~ " table " ]] ; then
    			INFO=`echo $LONE_LINE | awk -F" as " '{print $1}' | sed "s/ summary / /g"| sed "s/create table/=TABLE=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " VIEW" ]] ; then
    			INFO=`echo $LONE_LINE | awk -F" as " '{print $1}' | awk -F" AS " '{print $1}' | sed "s/CREATE VIEW/=VIEW=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " view" ]] ; then
    			INFO=`echo $LONE_LINE | awk -F" as " '{print $1}' | awk -F" AS " '{print $1}' | sed "s/create view/=VIEW=/g" | sed "s/CREATE view/=VIEW=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " SEQUENCE " ]] ; then
    			INFO=`echo $LONE_LINE | awk -F" as " '{print $1}' | awk -F" AS " '{print $1}' | sed "s/CREATE SEQUENCE/=SEQUENCE=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " FUNCTION " ]] ; then
    			INFO=`echo $LONE_LINE | sed "s/CREATE FUNCTION/=FUNCTION=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		elif [[ $LONE_LINE =~ " INDEX " ]] ; then
    			INFO=`echo $LONE_LINE | awk -F" ON " '{print $1}' | sed "s/CREATE INDEX/=INDEX=/g" | sed "s/ //g" | sed "s/\"//g" | awk -F"(" '{print $1}' | sed "s/\./=/g"`
    			echo $INFO'=' >> ${PWDNOW}/../file/tmp/export_file_create/${SCHEMA}.lst
    		fi;
    	fi;
    fi;
    done

#!/bin/bash
#split.sh
#*=================================================
#*
#* FileName : split.sh
#* CreateDate: 2015-11-30
#* Abstract : 导出数据库中特定模式的数据
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep SCHEMAS ../common.cfg)

if [ $# -eq 1 ] ; then
SCHEMAS=$1
fi;

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
    
    pose="N" 
    
    if [ ! -d ${PWDNOW}/../file/create/$SCHEMA ] ; then
            mkdir ${PWDNOW}/../file/create/$SCHEMA
    fi;
    
    cat ${PWDNOW}/../file/create/$SCHEMA.sql | while read LINE
    do
    	if [[ $pose = "table" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/table.sql
    	fi;
    	if [[ $pose = "procedure" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/procedure.sql
    	fi;
    	if [[ $pose = "view" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/view.sql
    	fi;
    	if [[ $pose = "comment" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/comment.sql
    	fi;
    	if [[ $pose = "function" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/function.sql
    	fi;
    	if [[ $pose = "sequence" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/sequence.sql
    	fi;
    	if [[ $pose = "index" ]] ; then
    		echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/index.sql
    	fi;
    	if [[ $pose = "N" ]] ; then
    		if [[ $LINE =~ "PROCEDURE" ]] ; then
    			pose="procedure"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/procedure.sql
    		elif [[ $LINE =~ "TABLE" ]] ; then
    			pose="table"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/table.sql
    		elif [[ $LINE =~ "VIEW" ]] ; then
    			pose="view"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/view.sql
    		elif [[ $LINE =~ "view" ]] ; then
    			pose="view"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/view.sql
    		elif [[ $LINE =~ "COMMENT" ]] ; then
    			pose="comment"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/comment.sql
    		elif [[ $LINE =~ "SEQUENCE" ]] ; then
    			pose="sequence"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/sequence.sql
    		elif [[ $LINE =~ "FUNCTION" ]] ; then
    			pose="function"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/function.sql
    		elif [[ $LINE =~ "INDEX" ]] ; then
    			pose="index"
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/index.sql
    		else
    			echo $LINE >> ${PWDNOW}/../file/create/$SCHEMA/other.sql
    		fi;
    	fi;
    	END=`echo ${LINE} | grep -o .$`  #显示最后一个字符，如果为分隔符则是一段SQL的终结
    	if [[ $END = "#" ]] ; then
    		pose="N"
    	fi;
    done
  done
#!/bin/bash
#import_structure.sh
#*=================================================
#*
#* FileName : import_structure.sh
#* CreateDate: 2015-12-1
#* Abstract : 导出数据库中特定模式的结构
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep DATABASE ../common.cfg)
eval $(grep USERID ../common.cfg)
eval $(grep USERPASSWD ../common.cfg)
eval $(grep SCHEMAS ../common.cfg)

if [ $# -eq 1 ] ; then
SCHEMAS=$1
fi;

OBTYPES=table,sequence,index,function,view,comment,procedure

db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}

for OBTYPE in `echo ${OBTYPES//,/ }`;
do 
	for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
		
		if [ ! -d ${PWDNOW}/../file/create/$SCHEMA ] ; then
        echo "The file is not exists , please checking it ."
        exit 1
		fi;
		
		if [ -e ${PWDNOW}/../file/create/$SCHEMA/$OBTYPE.sql ] ; then
				echo "-----importing structure of ${SCHEMA}'s ${OBTYPE}s"
        db2 -td\# -vf ${PWDNOW}/../file/create/$SCHEMA/$OBTYPE.sql
		fi;
	
	done;
	
done;

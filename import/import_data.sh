#!/bin/bash
#import_data.sh
#*=================================================
#*
#* FileName : import_data.sh
#* CreateDate: 2015-12-1
#* Abstract : 导入数据库中特定模式的数据
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`

eval $(grep DATABASE ../common.cfg)
eval $(grep USERID ../common.cfg)
eval $(grep USERPASSWD ../common.cfg)
eval $(grep SCHEMAS ../common.cfg)
eval $(grep IMPORTMODE ../common.cfg)

if [ $# -eq 1 ] ; then
SCHEMAS=$1
fi;

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
		
		if [ ! -d ${PWDNOW}/../file/data/$SCHEMA ] ; then
        echo "The file is not exists , please checking it ."
        exit 1
		fi;
		echo "-----importing data of schema: ${SCHEMA}"
		cd ${PWDNOW}/../file/data/$SCHEMA
		db2move ${DATABASE} load -lo ${IMPORTMODE} -u ${USERID} -p ${USERPASSWD}
	
	done;

echo "begin with call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}	
db2 -x "select 'set integrity for '||trim(TABSCHEMA)||'.'||TABNAME||' immediate checked ;' from syscat.tables where STATUS='C'" > ${PWDNOW}/../file/tmp/check.tmp
db2 -tvf ${PWDNOW}/../file/tmp/check.tmp
echo "ending call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
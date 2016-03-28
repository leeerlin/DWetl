#!/bin/bash
#import_partition_data.sh
#*=================================================
#*
#* FileName : import_partition_data.sh
#* CreateDate: 2015-12-1
#* Abstract : 导入分区数据库中特定模式的数据
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
eval $(grep PARTITIONS ../common.cfg)

if [ $# -eq 1 ] ; then
SCHEMAS=$1
fi;

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
		
		if [ ! -d ${PWDNOW}/../file/data/$SCHEMA ] ; then
        echo "The file is not exists , please checking it ."
        exit 1
		fi;
		
		cd ${PWDNOW}/../file/data/$SCHEMA
		
		if [ ! -e ${PWDNOW}/../file/data/$SCHEMA/db2move.lst ] ; then
        echo "The file db2move.lst is not exists , please checking it ."
        exit 2
		fi;
		
		
		#查询数据文件中的lst文件
		cat db2move.lst | while read line
		do
			IXF_NAME=`echo $line | awk -F'!' '{printf("%s\n",$3)}'`
			TAB_NAME=`echo $line | awk -F'!' '{printf("%s\n",$2)}' | sed 's/"//g'`
			
			#创建各个节点的数据链接
			PARTITION_NUM=0
			while ((${PARTITION_NUM} < ${PARTITIONS}))
			do
				END_NUM_TMP=0000$PARTITION_NUM
				END_NUM=${END_NUM_TMP:$((${#END_NUM_TMP} -3))}
				ln -sf ${IXF_NAME} ${IXF_NAME}.${END_NUM}
				PARTITION_NUM=`expr $PARTITION_NUM + 1`				
			done
			
			db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}
			db2 "load from ${IXF_NAME} of ixf ${IMPORTMODE} into ${TAB_NAME} partitioned db config mode load_only_verify_part "

			PARTITION_NUM=0
			while ((${PARTITION_NUM} < ${PARTITIONS}))
			do
				END_NUM_TMP=0000$PARTITION_NUM
				END_NUM=${END_NUM_TMP:$((${#END_NUM_TMP} -3))}
				rm -r ${IXF_NAME}.${END_NUM}
				PARTITION_NUM=`expr $PARTITION_NUM + 1`		
			done;
			
			
		done;
	
	done;
	
echo "begin with call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}	
db2 -x "select 'set integrity for '||trim(TABSCHEMA)||'.'||TABNAME||' immediate checked ;' from syscat.tables where STATUS='C'" > ${PWDNOW}/../file/tmp/check.tmp
db2 -tvf ${PWDNOW}/../file/tmp/check.tmp
echo "ending call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
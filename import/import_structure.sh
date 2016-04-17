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

db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}
db2 UPDATE DB CFG USING auto_reval DEFERRED_FORCE


for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
		
		if [ ! -e ${PWDNOW}/../file/create/$SCHEMA.sql ] ; then
        echo "The file is not exists , please checking it ."
        exit 1
		fi;
		
		#判断文件的字符集,修改为utf-8
		TYPE=`file ${PWDNOW}/../file/create/$SCHEMA.sql`
		if [[ $TYPE =~ "ISO-8859" ]] ; then
			iconv -c -f gbk -t utf-8 ${PWDNOW}/../file/create/$SCHEMA.sql > ${PWDNOW}/../file/create/$SCHEMA.tmp #2016年2月29日，修改，添加-c参数，当数据中存在不符合规范的字节时，不再会报错推出
			rm -f ${PWDNOW}/../file/create/$SCHEMA.sql 
			mv ${PWDNOW}/../file/create/$SCHEMA.tmp ${PWDNOW}/../file/create/$SCHEMA.sql
		fi;
		
		if [ -e ${PWDNOW}/../file/create/$SCHEMA.sql ] ; then
				echo "-----importing structure of schema: ${SCHEMA}"
				db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}
        db2 -td\# -vf ${PWDNOW}/../file/create/$SCHEMA.sql
		fi;
	
	done;

echo "begin with call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD}
db2 "call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
echo "ending call SYSPROC.ADMIN_REVALIDATE_DB_OBJECTS()"
	


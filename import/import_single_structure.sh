#!/bin/bash
#import_single_structure.sh
#*=================================================
#*
#* FileName : import_single_structure.sh
#* CreateDate: 2016-3-3 
#* Abstract : 
#* 入参：｛结构类型｝ ｛模式名｝ ｛名称｝，例如：TABLE DM T_ORG_BIZ_LVL
#* 根据create目录下的文件，创建指定的数据库对象
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

#判断模式文件是否存在
if [ ! -e ${PWDNOW}/../file/create/${SCHEMA}.sql] ; then
	echo "${PWDNOW}/../file/create/${SCHEMA}.sql is not exists!"
	exit 2;	
fi;

#从文件中寻找是否存在对应的对象的创建语句，并创建
echo "" > ${PWDNOW}/../file/tmp/.single_structure.ddl

cat ${PWDNOW}/../file/create/${SCHEMA}.sql | while read LINE
do
    	LINE1=${LINE2}          #修改处理的对象，将两行数据合并为一行进行处理，避免对象名称和标识不再一行的情况
    	LINE2=${LINE}
    	LONE_LINE=`echo ${LINE1} ${LINE2}`
  if [[ ${LINE1} != "" ]] ; then
    if [[ ${pose} = "Y" ]] ; then
    	echo ${LINE} >> ${PWDNOW}/../file/tmp/.single_structure.ddl
    else
    	if [[ $LONE_LINE =~ "CREATE " || $LONE_LINE =~ "create " || $LONE_LINE =~ "ALTER " || $LONE_LINE =~ "alter " || $LONE_LINE =~ "COMMENT " || $LONE_LINE =~ "comment " ]] ; then
    		if [[ $LONE_LINE =~ " ${OBNAME} " ]] ; then
    			echo "$LONE_LINE" >> ${PWDNOW}/../file/tmp/.single_structure.ddl
    			pose="Y"
    		fi;
    	fi;  	
    fi;
    END=`echo ${LINE} | grep -o .$`  #显示最后一个字符，如果为分隔符则是一段SQL的终结 
    if [[ $END = "#" ]] ; then
    	pose="N"
    fi;
  fi;
done;

echo "开始执行创建语句=${TYPE}=${SCHEMA}=${OBNAME}=" `date "+%Y-%m-%d %H:%M:%S"`
if [[ $TYPE =~ "ISO-8859" ]] ; then
	iconv -c -f gbk -t utf-8 ${PWDNOW}/../file/create/$SCHEMA.sql > ${PWDNOW}/../file/create/$SCHEMA.tmp #2016年2月29日，修改，添加-c参数，当数据中存在不符合规范的字节时，不再会报错推出
	rm -f ${PWDNOW}/../file/create/$SCHEMA.sql 
	mv ${PWDNOW}/../file/create/$SCHEMA.tmp ${PWDNOW}/../file/create/$SCHEMA.sql
fi;
db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null
db2 -td\# -vf ${PWDNOW}/../file/tmp/.single_structure.ddl
rm -f ${PWDNOW}/../file/tmp/.single_structure.ddl
echo "=${TYPE}=${SCHEMA}=${OBNAME}=创建语句执行完成" `date "+%Y-%m-%d %H:%M:%S"`


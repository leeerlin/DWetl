#!/bin/bash
#check_exp_db_create.sh
#*=================================================
#*
#* FileName : check_exp_db_create.sh
#* CreateDate: 2016-1-28
#* Abstract : 
#* 入参：模式名
#* 数据库中提取信息，通过查询syscat模式下的视图，将明细数据导出到临时文件$DW_HOME/file/tmp/export_db_create/{模式名}.lst
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

echo "" > ../file/tmp/export_db_create/${SCHEMA}.lst

db2 connect to ${DATABASE} user ${USERID} using ${USERPASSWD} > /dev/null
#提取数据库中所有的表信息
db2 -x "SELECT '=TABLE='||TRIM(TABSCHEMA)||'='||TABNAME||'=' FROM SYSCAT.TABLES WHERE TABSCHEMA = '${SCHEMA}' AND TYPE in ('T','S') " >> ../file/tmp/export_db_create/${SCHEMA}.lst
#提取数据库中所有的视图信息
db2 -x "SELECT '=VIEW='||TRIM(VIEWSCHEMA)||'='||VIEWNAME||'=' FROM SYSCAT.VIEWS WHERE VIEWSCHEMA = '${SCHEMA}' and text not like '% TABLE %' and text not like '% table %' " >> ../file/tmp/export_db_create/${SCHEMA}.lst
#提取数据库中所有的存过信息
db2 -x "SELECT '=PROCEDURE='||TRIM(PROCSCHEMA)||'='||PROCNAME||'=' FROM SYSCAT.PROCEDURES WHERE PROCSCHEMA = '${SCHEMA}' " >> ../file/tmp/export_db_create/${SCHEMA}.lst
#提取数据库中所有的函数信息
db2 -x "SELECT '=FUNCTION='||TRIM(FUNCSCHEMA)||'='||FUNCNAME||'=' FROM SYSCAT.FUNCTIONS WHERE FUNCSCHEMA = '${SCHEMA}' " >> ../file/tmp/export_db_create/${SCHEMA}.lst
#提取数据库中所有的索引信息
db2 -x "SELECT '=INDEX='||TRIM(INDSCHEMA)||'='||INDNAME||'=' FROM SYSCAT.INDEXES WHERE TABSCHEMA = '${SCHEMA}' AND USER_DEFINED = '1' " >> ../file/tmp/export_db_create/${SCHEMA}.lst
#提取数据库中所有的序列信息
db2 -x "SELECT '=SEQUENCE='||TRIM(SEQSCHEMA)||'='||SEQNAME||'=' FROM SYSCAT.SEQUENCES WHERE SEQSCHEMA = '${SCHEMA}' " >> ../file/tmp/export_db_create/${SCHEMA}.lst


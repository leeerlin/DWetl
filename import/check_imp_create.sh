#!/bin/bash
#check_exp_create.sh
#*=================================================
#*
#* FileName : check_exp_create.sh
#* CreateDate: 2016-2-2
#* Abstract : 
#* 入参：模式名
#* 对$DW_HOME/file/tmp/export_db_create/{模式名}.lst和$DW_HOME/file/tmp/export_file_create/{模式名}.lst两个文件进行分析，产生分析结果到文件$DW_HOME/file/check/{模式名}/export_db_create.info和$DW_HOME/file/check/{模式名}/export_file_create.info
#* 对产生的分析结果文件进行对比，如通过则生成正确文件$DW_HOME/file/check/｛模式名｝.success，反之生成$DW_HOME/file/check/｛模式名｝.error
#* 并将匹配不到的问题记录在$DW_HOME/file/check/｛模式名｝.error文件中
#* 包含信息：=｛模式名｝=｛对象类型｝=｛数据库中的数量｝=｛导出文件中的数量｝=
#* Author : LiBin
#* 
#*==================================================

cd `dirname $0`
PWDNOW=`pwd`


#通过.sql文件分析本次导入的对象，并生成文件
sh ./check_imp_file_create.sh ${SCHEMA}
#读取文件从数据库中查找对象是否存在，并生成检查文件，输出没有创建成功的对象名称
sh ./check_imp_db_create.sh ${SCHEMA}
#从文件中查找对象的名称，重新创建
sh ./import_single.sh -f ${PWDNOW}/../file/tmp/import_db_create/${SCHEMA}.lst


#!/bin/bash
#check_exp.sh
#*=================================================
#*
#* FileName : check_exp.sh
#* CreateDate: 2016-2-3
#* Abstract : 
#* 入参：模式名
#* 导出数据校验的总调度过程
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

echo "This shell will output schema include : ${SCHEMAS} "

for SCHEMA in `echo ${SCHEMAS//,/ }`;
	do 
		echo "对比分析"
		#对比分析
		sh check_exp_create.sh ${SCHEMA}
		echo "完成，请切换到目录查看结果文件： cd ${PWDNOW}/../file/check/"
	done;
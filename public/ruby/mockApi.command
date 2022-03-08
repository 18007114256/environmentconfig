#!/bin/sh
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
echo 'start..'
echo "======参数打印begin======="
# CURPATH=$(cd "$(dirname "$0")"; pwd)
# cd $CURPATH
input_param=$1
echo ${input_param} # 本地工程路径
if [ "$input_param" =  "" ] ;then
    echo "ele_fail,-100,工程根路径为空"
    exit
fi
input_host=$2
echo ${input_host} # Mock host路径
input_apis=$3
echo ${input_apis} # api集合
echo "======参数打印end======="
echo "======ruby start======="
result=$(echo $(ruby ./mockApi.rb ${input_param} ${input_host} ${input_apis}))
if [[ $result == "" ]];then
    echo "ele_fail,-1,api配置失败,请查看调试版信息(-3)"
    exit
fi
echo "======ruby   end======="
i=1
error_info=""
if [[ $result =~ "$" ]];then
    while((1==1))  
    do  
        split=`echo $result|cut -d "$" -f$i`
        if [ "$split" != "" ];then  
            ((i++))   
            if [[ $split =~ "ele_fail" ]];then
                echo "包含error"
                error_info=$split
            else
                echo "不包含error" 
                echo $split
            fi
        else  
            break  
        fi  
    done
fi
if [[ $error_info == "" ]];then
    echo "ele_success,1,Mock apis配置完成"
else
    echo ${error_info}
fi

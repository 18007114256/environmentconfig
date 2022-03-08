#!/bin/sh
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
echo 'start..'
echo "=================================="
#获取文件运行的当前目录
# CURPATH=$(cd "$(dirname "$0")"; pwd)
# cd $CURPATH
input_param=$1       #根目录 /Users/apple/Desktop/网银/IOS
echo ${input_param} # 本地工程路径
input_param_native_path=$2       #根目录 /Users/apple/Desktop/网银/IOS
echo ${input_param_native_path} # 本地工程路径


target_project=$3
echo ${target_project} # 本地工程路径
echo "=================================="

if [ "$input_param" =  "" ] ;then
    echo "ele_fail,-100,工程根路径为空"
    exit
fi

if [ "$input_param_native_path" =  "" ] ;then
    echo "ele_fail,-100,参数错误，未传内置Mock工程路径"
    exit
fi

if [ "$target_project" =  "" ] ;then
    echo "waring,1,未输入需要控制的工程名称"
fi



# 工程拷贝
sysRoot=$HOME
echo ${sysRoot}

svn_username="wench"
svn_password="Wen123456789"
svn_path="https://sz-its-svn-001.sino.sz/svn/TChat/银企通银行项目/开发库/交付平台开发/APP/2.SRC/SDP5.0/iOS/挡板2@HEAD"
native_path=$input_param_native_path
# native_path=${sysRoot}/"Desktop/Mock_Download"
# ${sysRoot}/"Desktop/Mock_Download"
# svn co ${svn_path} ${native_path} --username ${svn_username} --password ${svn_password}

# ruby ./wsControl.rb ${input_param} ${native_path} ${target_project}
# exit
echo "start run ruby wsControl"
result=$(echo $(ruby ./wsControl.rb ${input_param} ${native_path} ${target_project}))
# echo ${result}
if [[ $result == "" ]];then
    echo "ele_fail,-1,工程配置失败,请查看调试版信息(-1)"
    exit
fi
echo "end run ruby wsControl"
# result=$(echo $(ruby ./wsControl.rb ${input_param} ${native_path}))

# echo ${result}
i=1
error_info=""
if [[ $result =~ "$" ]];then
    while((1==1))  
    do  
        split=`echo $result|cut -d "$" -f$i`

        if [[ $split =~ "Uncaught Error" ]];then
            echo $split
            error_info = "ele_fail,-1"$split
            break
        fi

        if [[ $split =~ "No such file or directory" ]];then
            echo $split
            error_info = "ele_fail,-1"$split
            break
        fi

        
        if [ "$split" != "" ];then  
            ((i++))   
            if [[ $split =~ "ele_fail" ]];then
                echo "包含error"
                error_info=$split
                break
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
    if [ "`find $input_param -name MockCommunication.xcodeproj`" = "" ]; then
        echo "ele_fail,-2,工程配置失败,请查看调试版信息(-2)"
    else
        echo "ele_success,1,工程配置完毕"
    fi
else
    echo ${error_info}
fi
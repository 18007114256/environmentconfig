#!/bin/sh 

input_param=$1 
echo $input_param
input_param2=$2 
if [ "$input_param" =  "" ] ;then
    echo "ele_fail,-100,npm 配置文件不能为空"
    exit
fi

if [ "$input_param2" =  "" ] ;then
    echo "ele_fail,-100,npm 该操作需要使用您的开机密码"
    exit
fi


ssh_ip(){
    expect -c "
    set timeout 200;
    spawn sudo cp $1 $2
    expect {
        \"*yes/no*\" {send \"yes\r\"; exp_continue}
        \"*ass*\" {send \"$input_param2\r\";}
    }
    expect eof; "
}

node_exc_path=`which node`
if [ "$node_exc_path" =  "" ] ;then
    node_exc_path='/usr/local/bin/node'
fi

echo $node_exc_path

cnpm_exc_path=`which cnpm`

if [ "$cnpm_exc_path" =  "" ] ;then
    cnpm_exc_path='/usr/local/bin/cnpm'
fi
# cnpm_exc_path='/usr/local/bin/cnpm'
echo $cnpm_exc_path
# echo $(dirname $(readlink -f "$0"))


# test=`greadlink -f $cnpm_exc_path`

#  echo $test


real_path=`/usr/local/bin/greadlink -f $cnpm_exc_path`

if [ "$real_path" =  "" ] ;then
    real_path='/usr/local/lib/node_modules/cnpm/bin/cnpm'
fi

# real_path='/usr/local/lib/node_modules/cnpm/bin/cnpm'
echo $real_path

 sysRoot=$HOME

eleExchangPath=$sysRoot/Documents/scp_mock

eleExchangPathFile=$sysRoot/Documents/scp_mock/cnpm.txt

rm -rf $eleExchangPath
mkdir $eleExchangPath/
touch $eleExchangPathFile
ssh_ip $real_path  $eleExchangPathFile
ssh_ip $real_path  $eleExchangPath

# sed -i "s\/#!/usr/bin/env node/#!/usr/bin/env /usr/local/bin/node/g" $real_path
# cd  /usr/local/lib/node_modules/cnpm/bin
sed -i '' "s/\#\!\/usr\/bin\/env node/\#\!\/usr\/bin\/env \/usr\/local\/bin\/node/g" $eleExchangPathFile
# sed -i '' "s/\#\!\/usr\/bin\/env node/\#\!\/usr\/bin\/env ${node_exc_path}/g" $eleExchangPathFile

ssh_ip $eleExchangPathFile  $real_path


cd $input_param

/usr/local/bin/cnpm i

ssh_ip $eleExchangPath/cnpm /usr/local/lib/node_modules/cnpm/bin/

#!/bin/sh
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
echo 'start..'
input_param=$1 
echo $input_param
echo "========="
i=1
while(($i<5))
do
    echo $i
    ruby -v
    if [ "$?" == 0 ];then
        #环境变量已添加
        xcodeproj --version
        if [ "$?" == 0 ];then
            break
        else
        #未环境变量已添加  
            /usr/local/bin/xcodeproj --version
            if [ "$?" == 0 ];then
                break
            else
                # 兼容rvm
                xcodeproj_path=`which xcodeproj`
                echo $xcodeproj_path
                $xcodeproj_path --version
                if [ "$?" == 0 ];then
                    break
                else
                    ((i++))
                    if [ "$input_param" =  "" ] ;then
                        # echo "ele_fail,-1,检测到您的环境缺少xcodeproj,请输入开机密码后重试或在控制台运行sudo gem install xcodeproj"
                        echo "ele_password,-2,环境检查需要需要输入您的开机密码"
                        exit
                    fi
                    echo $input_param | sudo -S gem install xcodeproj
                fi
            fi
            # sudo gem install xcodeproj
        fi
    else
        ((i++)) 
        brew install ruby 
    fi
done
# brew -v
# if [ "$?" == 0 ];then   
#     echo "brew installed"
# else
#     # /usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)"
#     # if [ "$input_param" =  "" ] ;then
#     #     echo 'ele_fail,-1,brew env error, 请手动安装HomeBrew ，在控制台执行 /usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)"命令,'
#     #     echo "ele_password,环境检查需要需要输入您的开机密码"
#     #     exit
#     # fi
#     echo 'ele_fail,-1,brew env error, 请手动安装HomeBrew ，在控制台执行 /usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)"命令,'
#     exit
# fi
ruby -v
if [ "$?" == 0 ];then
    xcodeproj --version
    if [ "$?" == 0 ];then
        sysRoot=$HOME
        echo  "ENV_HOME"${sysRoot}"ENV_HOME" 
        echo 'ele_success,1,ruby installed'
    else
        /usr/local/bin/xcodeproj --version
        if [ "$?" == 0 ];then
            sysRoot=$HOME
            echo  "ENV_HOME"${sysRoot}"ENV_HOME" 
            echo 'ele_success,1,ruby installed'
        else
            xcodeproj_path=`which xcodeproj`
            echo $xcodeproj_path
            $xcodeproj_path --version
            if [ "$?" == 0 ];then
                sysRoot=$HOME
                echo  "ENV_HOME"${sysRoot}"ENV_HOME" 
                echo 'ele_success,1,ruby installed'
            else
                echo 'ele_fail,-1,ruby env error, run sudo gem install xcodeproj first'
            fi
        fi
    fi
else
    echo 'ele_fail,-1,ruby env error, run brew install ruby first'
fi
# if (($i>=5));then

# fi


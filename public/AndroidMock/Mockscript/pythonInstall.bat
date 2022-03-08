@echo off
echo ----------------------------------
echo start install Python, please waitting...
python-3.8.6-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
if %errorlevel%==0 (
	echo Python3.8 install success! 
	rem 1、先删除mock配置信息
	rem python check_mock_flag.py %projectRootPath%
	echo ele_python_install_competed
) else (
	echo ele_python_install_failed	
) 
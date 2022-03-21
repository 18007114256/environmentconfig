@echo off
set projectRootPath=%1%
set envName=%2%
set baseName=%3%

rem 1、add
echo "modify env name..."
python modify_env_name.py %projectRootPath% %envName% %baseName%
echo "modifyName end..."



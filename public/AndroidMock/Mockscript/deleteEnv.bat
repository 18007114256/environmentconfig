@echo off
set projectRootPath=%1%
set envName=%2%

rem 1、add
echo "delete env..."
python delete_env.py %projectRootPath% %envName%
echo "deleteEnv end..."






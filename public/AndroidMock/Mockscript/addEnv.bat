@echo off
set envPath=%1%
set projectRootPath=%2%
set envName=%3%

rem 1、add
echo "add env..."
python add_env.py %envPath% %projectRootPath% %envName%
python set_env.py %envPath% %projectRootPath% %envName%
echo "add env end..."



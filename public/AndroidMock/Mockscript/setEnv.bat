@echo off
set envPath=%1%
set projectRootPath=%2%
set envName=%3%

rem 1、set
echo "set env..."
python set_env.py %envPath% %projectRootPath% %envName%
echo "set env end..."



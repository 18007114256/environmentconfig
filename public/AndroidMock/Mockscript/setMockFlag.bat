@echo off
set projectRootPath=%1%

echo "start set mock flag"
rem 1、设置mock标识信息
python set_mock_flag.py %projectRootPath%

echo "ele_success---set mock flag completed---"

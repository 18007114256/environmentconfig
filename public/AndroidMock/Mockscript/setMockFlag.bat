@echo off
set projectRootPath=%1%

echo "start set mock flag"
rem 1������mock��ʶ��Ϣ
python set_mock_flag.py %projectRootPath%

echo "ele_success---set mock flag completed---"

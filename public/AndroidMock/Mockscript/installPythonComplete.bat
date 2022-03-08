@echo off
set projectRootPath=%1%

echo "start call install_python_complete"

rem python check_mock_flag.py %projectRootPath%

python --version 

python check_mock_flag.py %projectRootPath%
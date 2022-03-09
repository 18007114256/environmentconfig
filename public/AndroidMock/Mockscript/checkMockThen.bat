@echo off
set projectRootPath=%1%

reg query "hklm\software\Python\pythoncore" >nul 2>nul
if %errorlevel%==0 (
	echo Python has installed sucess
	
	echo "check mock is exsits "
	rem 1°¢œ»…æ≥˝mock≈‰÷√–≈œ¢
	rem python check_mock_flag.py %projectRootPath%
	print("ele_Python_exsits")
	echo "---check mock flag completed---"
) else (
	echo ele_python_not_installed Python not installed, Please Install Python first...
	
	
	call pythonInstall.bat
)

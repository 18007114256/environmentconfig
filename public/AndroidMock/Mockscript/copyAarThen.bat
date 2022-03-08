@echo off
set projectRootPath=%1%

echo "start copy aar to project..."

python copy_aar.py %projectRootPath%
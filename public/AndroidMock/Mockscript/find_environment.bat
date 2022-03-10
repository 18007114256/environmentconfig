@echo off
set projectRootPath=%1%

echo "find src..."
python find_env_gradle.py %projectRootPath%

echo "find src success"



@echo off
set projectRootPath=%1%

python copy_jar.py %projectRootPath%

echo ele_makeAar Compiling the AAR...

for /f "delims=" %%a in (scpui_studio_path.txt) do (
    set suspvalue=%%a	
)
for /f "delims=" %%b in (sb_path.txt) do (
    set sbvalue=%%b	
)

%projectRootPath:~0,2%
cd %suspvalue%
gradlew :SCP_Browser:assembleDebug&gradlew :SCP_UiLib:assembleDebug&cd %sbvalue%&gradlew :SCP_BaseUI:assembleDebug&echo ele_copy_aar_then

echo "compile aar success"

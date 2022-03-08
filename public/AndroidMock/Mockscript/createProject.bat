@echo off
set mockRootPath=%1%
set projectRootPath=%2%

rem 1、拷贝SCP_MockCommunication组件
echo "make and copy SCP_MockCommunication file..."
python copy_scp_mockcommunication_file.py %mockRootPath% %projectRootPath%

rem 2、拷贝其他类文件
echo "start copy other files..."
python copy_other_file.py %mockRootPath% %projectRootPath%

rem 3、拷贝mock config文件
python copy_org_mock_config_file.py %mockRootPath% %projectRootPath%

rem 4、在settings.gradle中添加SCP_MockCommunication组件信息
echo "modify settings.gradle..."
echo include ':SCP_MockCommunication' >> %projectRootPath%\SCP_Studio\settings.gradle
python modify_settingsgradle.py %projectRootPath%

rem 5、修改其他几个类文件和build.gradle文件
python modify_itcommunication.py %projectRootPath%
python modify_tchat_request.py %projectRootPath%
python modify_http_manager.py %projectRootPath%
python modify_volley_adapter.py %projectRootPath%
python modify_communication_manager.py %projectRootPath%
python modify_messagebus.py %projectRootPath%
python modify_scp_browser_build.py %projectRootPath%
python modify_browserFunctionMgr.py %projectRootPath%

rem python modify_mainApp.py %projectRootPath%
python modify_tchatApp.py %projectRootPath%

rem python modify_parentActivity.py %projectRootPath%
python modify_parentActivity.py %projectRootPath%


rem 6、查询scp_studio scpui_studio ui目录路径
python find_scp_studio_path.py %mockRootPath% %projectRootPath%
python find_scpui_studio_path.py %mockRootPath% %projectRootPath%
python find_ui_path.py %mockRootPath% %projectRootPath%

echo ele_makeJar Compiling the JAR... ele_makeJar 

rem 7、 读取路径
for /f "delims=" %%a in (scp_studio_path.txt) do (
    set sspvalue=%%a	
) 
for /f "delims=" %%b in (scpui_studio_path.txt) do (
    set suspvalue=%%b	
)

rem 8、cd到scp_studio目录里去生成jar包
echo %projectRootPath:~0,2%
echo %sspvalue%
echo %suspvalue%
%projectRootPath:~0,2%
cd %sspvalue%
gradlew clean&gradlew :SCP_Base:makeJar&gradlew :SCP_TChatApp:makeJar&gradlew :SCP_Communitcation:makeJar&gradlew :SCP_MessageBus:makeJar&gradlew :SCP_MockCommunication:makeJar&echo ele_compile_then

echo "create project ele_success"



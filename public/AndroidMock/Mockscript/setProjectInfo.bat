@echo off
set projectRootPath=%1%
set projectIp=%2%
set paramsList=%3%

rem echo "setProjectInfo.bat F:\SINOSUN_NATIVE http://10.2.30.231/~scpmock message.bindDeliveryToken%*user.getOrganizationInfo%*user.getaaa"

echo "start set mock info"
rem 1����ɾ��mock������Ϣ
python delete_mock_config.py %projectRootPath%
rem 2������������mock������Ϣ
python set_mock_config.py %projectRootPath% %projectIp% %paramsList%


echo "ele_success, set mock info"

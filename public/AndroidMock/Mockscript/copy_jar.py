import os
import sys
import shutil

print(sys.argv[1])
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            print(os.path.join(root, name))
            scp_studio_path = os.path.join(root, name)
            break

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_BaseUI":
            print(os.path.join(root, name))
            scp_base_ui_path = os.path.join(root, name)
            break

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Browser":
            print(os.path.join(root, name))
            scp_browser_path = os.path.join(root, name)
            break
            
old_base_jar_path = scp_studio_path + "\\build\libs\scp_base.jar"
old_communitcation_jar_path = scp_studio_path + "\\build\libs\scp_communitcation.jar"
old_messagebus_jar_path = scp_studio_path + "\\build\libs\scp_messagebus.jar "
old_mockcommunication_jar_path = scp_studio_path + "\\build\libs\scp_mockcommunication.jar"
old_tchat_jar_path = scp_studio_path + "\\build\libs\scp_tchatapp.jar"

new_base_jar_path = scp_base_ui_path + "\libs\scp_base.jar"
new_communitcation_jar_path = scp_base_ui_path + "\libs\scp_communitcation.jar"
new_messagebus_jar_path = scp_base_ui_path + "\libs\scp_messagebus.jar"
new_mockcommunication_jar_path = scp_base_ui_path + "\libs\scp_mockcommunication.jar"
new_tchat_jar_path = scp_base_ui_path + "\libs\scp_tchatapp.jar"

new_sb_mock_jar_path = scp_browser_path + "\libs\scp_mockcommunication.jar"

shutil.copy(old_base_jar_path, new_base_jar_path)
shutil.copy(old_communitcation_jar_path, new_communitcation_jar_path)
shutil.copy(old_messagebus_jar_path, new_messagebus_jar_path)
shutil.copy(old_mockcommunication_jar_path, new_mockcommunication_jar_path)
shutil.copy(old_tchat_jar_path, new_tchat_jar_path)

shutil.copy(old_mockcommunication_jar_path, new_sb_mock_jar_path)
        
print("copy jar success")
    
    
    
    
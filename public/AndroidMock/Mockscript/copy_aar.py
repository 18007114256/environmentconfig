import os
import sys
import shutil

print(sys.argv[1])
mainProject_list = []
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "mainProject":
            print(os.path.join(root, name))
            mainProject_path = os.path.join(root, name)
            mainProject_path = mainProject_path.replace("\\a", "\\\\a").replace("\\b", "\\\\b").replace("\\e", "\\\\e").replace("\\n", "\\\\n").replace("\\v", "\\\\v").replace("\\t", "\\\\t").replace("\\r", "\\\\r").replace("\\f", "\\\\f")
            #print(mainProject_path)
            mainProject_list.append(mainProject_path)
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
            
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_UiLib":
            print(os.path.join(root, name))
            scp_uilib_path = os.path.join(root, name)
            break
            

org_base_aar_path = scp_base_ui_path + "\\build\outputs\\aar\SCP_BaseUI-debug.aar"
rename_base_aar_path = scp_base_ui_path + "\\build\outputs\\aar\SCP_BaseUI.aar"
os.rename(org_base_aar_path, rename_base_aar_path)

org_browser_aar_path = scp_browser_path + "\\build\outputs\\aar\SCP_Browser-debug.aar"
rename_browser_aar_path = scp_browser_path + "\\build\outputs\\aar\SCP_Browser.aar"
os.rename(org_browser_aar_path, rename_browser_aar_path)

org_uilib_aar_path = scp_uilib_path + "\\build\outputs\\aar\SCP_UiLib-debug.aar"
rename_uilib_aar_path = scp_uilib_path + "\\build\outputs\\aar\SCP_UiLib.aar"
os.rename(org_uilib_aar_path, rename_uilib_aar_path)

print("rename aar success")


for mainProjectPath in mainProject_list: 
    if "MinimumApp" in mainProjectPath:
        continue
    elif ".idea" in mainProjectPath:
        continue
    else:
        new_base_aar_path = mainProjectPath + "\libs\SCP_BaseUI.aar"
        new_browser_aar_path = mainProjectPath + "\libs\SCP_Browser.aar"
        new_uilib_aar_path = mainProjectPath + "\libs\SCP_UiLib.aar"
        
        shutil.copy(rename_base_aar_path, new_base_aar_path)
        shutil.copy(rename_browser_aar_path, new_browser_aar_path)
        shutil.copy(rename_uilib_aar_path, new_uilib_aar_path)
        
        print("ele_mock_flag_then")

        
print("copy aar success")
    
    
    
    
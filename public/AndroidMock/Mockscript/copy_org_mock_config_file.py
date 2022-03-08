import sys
import os
import shutil

if len(sys.argv) < 2:
    print("ele_error, copy mock config file need two parameter")
    
#查找mainProject目录#
mainProject_list = []
for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "mainProject":
            mainProject_path = os.path.join(root, name)
            #print(mainProject_path)
            mainProject_list.append(mainProject_path)
            break

old_mock_config_path = sys.argv[1] + "\mock_config.xml"
for mainProject_path in mainProject_list: 
    if "MinimumApp" in mainProject_path:
        continue 
    else:
        new_mock_config_path = mainProject_path + "\src\main\\res\\values\mock_config.xml"
        shutil.copy(old_mock_config_path, new_mock_config_path)

print("---copy mock config success---")
    


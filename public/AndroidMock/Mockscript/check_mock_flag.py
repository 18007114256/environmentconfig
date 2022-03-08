import sys
import os

#查找mainProject目录#
mainProject_list = []
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "mainProject":
            mainProject_path = os.path.join(root, name)
            #print(mainProject_path)
            mainProject_list.append(mainProject_path)
            break

#查找mock_config.xml目录#
strings_list = []
for mainProject in mainProject_list:    
    for root, dirs, files in os.walk(mainProject):
        for name in files:
            if name == "mock_config.xml":
                strings_path = os.path.join(root, name)
                strings_path = strings_path.replace("\\a", "\\\\a").replace("\\b", "\\\\b").replace("\\e", "\\\\e").replace("\\n", "\\\\n").replace("\\v", "\\\\v").replace("\\t", "\\\\t").replace("\\r", "\\\\r").replace("\\f", "\\\\f")
                #print(strings_path)
                strings_list.append(strings_path)
                break
stringLen=len(strings_list)
if stringLen>0:    
    #设置mock配置信息#
    for string_path in strings_list:  
        if "MinimumApp" in string_path:
            continue 
        else:
            with open(string_path, "r", encoding="utf-8-sig") as f1:
                fcontent = f1.readlines()
                for line_num, line_content in enumerate(fcontent):
                    sub_str_index = line_content.find("<string name=\"mock_flag\">true</string>")
                    if sub_str_index != -1:
                        print("ele_mock_exsits")
                        sys.exit(1)
                    else:
                        continue
            print("ele_mock_then")                    
else:                        
    print("ele_mock_then")
                

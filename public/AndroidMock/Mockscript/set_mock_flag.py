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

#设置mock配置信息#
for string_path in strings_list:  
    if "MinimumApp" in string_path:
        continue 
    else:
        with open(string_path, "r", encoding="utf-8-sig") as f1:
            fcontent = f1.readlines()
            for line_num, line_content in enumerate(fcontent):
                sub_str_index = line_content.find("<resources>")
                if sub_str_index != -1:
                    print("---在第{}行{}列".format(line_num, sub_str_index))
                    break
                else:
                    continue
        lines=[]
        f=open(string_path,'r', encoding='utf-8-sig')  #your path!
        for line in f:
            lines.append(line)
        f.close()

        #插入mockFlag
        mockFlag="    <string name=\"mock_flag\">true</string>\n"
        line_num = line_num + 1
        lines.insert(line_num, mockFlag)
        print("---set mock flag success---")
        s=''.join(lines)
        f=open(string_path,'w+', encoding='utf-8') #重新写入文件
        f.write(s)
        f.close()
        del lines[:]                      #清空列表
       
print("ele_success")
                

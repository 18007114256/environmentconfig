import sys
import os

print(sys.argv[1])
#查找mainProject目录#
mainProject_list = []
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "mainProject":
            mainProject_path = os.path.join(root, name)
            print(mainProject_path)
            mainProject_list.append(mainProject_path)
            break

#查找strings.xml目录#
strings_list = []
for mainProject in mainProject_list:    
    for root, dirs, files in os.walk(mainProject):
        for name in files:
            if name == "mock_config.xml":
                strings_path = os.path.join(root, name)
                strings_path = strings_path.replace("\\a", "\\\\a").replace("\\b", "\\\\b").replace("\\e", "\\\\e").replace("\\n", "\\\\n").replace("\\v", "\\\\v").replace("\\t", "\\\\t").replace("\\r", "\\\\r").replace("\\f", "\\\\f")
                print(strings_path)
                strings_list.append(strings_path)
                break

#删除mock配置信息#
for string_path in strings_list:  
    if "MinimumApp" in string_path:
        continue 
    else:
        with open(string_path, "r", encoding="ISO-8859-1") as f1:
            b_num=0
            line_num=0
            fcontent = f1.readlines()
            for line_num, line_content in enumerate(fcontent):
                sub_str_index = line_content.find("<string-array name=\"mock_urls\">")
                if sub_str_index != -1:
                    print("---在第{}行{}列".format(line_num, sub_str_index))
                    for b_num, b_content in enumerate(fcontent):
                        b_index = b_content.find("</string-array>")
                        if b_index != -1:
                            if b_num > line_num:
                                print("---在第{}行{}列".format(b_num, b_index))
                                break
                            else:
                                continue


                    #print(line_num)  
                    #print(b_num)     
                    with open(string_path, "w", encoding="ISO-8859-1") as f_w:       
                        for c_num, c_content in enumerate(fcontent):
                            #print(c_num) 
                            if c_num >=line_num and c_num<=b_num:
                                continue;
                            else:
                                f_w.write(c_content)
                                
                                
        with open(string_path, "r", encoding="ISO-8859-1") as fa:
            lines = fa.readlines()
            #print(lines)
        with open(string_path, "w", encoding="ISO-8859-1") as fa_w:
            for line in lines:
                if "<string name=\"mock_addr\">" in line:
                    continue
                if "<string name=\"mock_switch\">" in line:
                    continue
                fa_w.write(line)
                
print("---del mock config success---")

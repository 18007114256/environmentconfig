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
print("+++++++++++++++++++++++++++")
print(mainProject_list)
#查找mock_config.xml目录#
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
print("------------------------------")
print(strings_list)
#设置mock配置信息#
for string_path in strings_list:  
    if "MinimumApp" in string_path:
        continue 
    else:
        with open(string_path, "r", encoding="utf-8-sig") as f1:
            fcontent = f1.readlines()
            for line_num, line_content in enumerate(fcontent):
                sub_str_index = line_content.find("</resources>")
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

        #插入IP
        mockAddr="    <string name=\"mock_addr\">" + sys.argv[2] + "</string>\n"
        lines.insert(line_num, mockAddr)
        print("---insert mock_ip success---")

        #判断是否有接口
        paramsStr=sys.argv[3]
        lists=paramsStr.split("%*")
        #print("***************")
        #print(lists)
        #print("***************")
        paramLen=len(lists)
        #print(paramLen)
        mSwitch="0"
        if paramLen>0:
            mSwitch="1"    
        mockSwitch="    <string name=\"mock_switch\">" + mSwitch + "</string>\n"
        #插入mock开关
        lines.insert(line_num, mockSwitch)    

        #插入mock接口stringArray
        if paramLen>0:
            lines.insert(line_num,"     </string-array>\n")      
            for param in lists:
                itemLine="          <item>/" + param + "</item>\n"
                lines.insert(line_num, itemLine)
            lines.insert(line_num,"     <string-array name=\"mock_urls\">\n")    

        #lines.insert(line_num,"      <string name=\"mock_switch\">1</string>\"\n")
        s=''.join(lines)
        f=open(string_path,'w+', encoding='utf-8') #重新写入文件
        f.write(s)
        f.close()
        del lines[:]                      #清空列表

print("---set mock config success---")
                

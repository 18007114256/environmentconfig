import sys
import os
import re

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scp_studio_path = os.path.join(root, name)
            break
                
itc_file=scp_studio_path + '\SCP_Base\src\main\java\com\sinosun\\tchat\communication\ITCommunication.java'
with open(itc_file, "r", encoding="utf-8-sig") as f1:
    fcontent1 = f1.readlines()
    for line_num, line_content in enumerate(fcontent1):
        sub_str_index = line_content.find("void installHttpAdapter(IHttpAdapter adapter)")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break                     
    
lines=[]
f=open(itc_file,'r', encoding='utf-8-sig')  #your path!
for line in f:
    lines.append(line)
f.close()
line_num = line_num + 1
lines.insert(line_num,"    public void installMockAdapter(IHttpAdapter adapter);\n")              #插入并回车
lines.insert(line_num,"    //安装mock适配器\n")           #插入并回车
lines.insert(line_num,"    \n")           #插入并回车

s=''.join(lines)
f=open(itc_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify itcommunication success---")
                

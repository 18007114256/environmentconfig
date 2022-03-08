import sys
import os
import re

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scp_studio_path = os.path.join(root, name)
            break
             
cm_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\CommunicationManager.java'
with open(cm_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for d_num, d_content in enumerate(fcontent):
        d_str_index = d_content.find("public void installHttpAdapter(IHttpAdapter adapter)")
        if d_str_index != -1:
            print("---在第{}行{}列".format(d_num, d_str_index))
            break
		                     
    
lines=[]
f=open(cm_file,'r', encoding='utf-8-sig')  #your path!
for line in f:
    lines.append(line)
f.close()
d_num = d_num - 1
lines.insert(d_num,"     \n")              #插入并回车
lines.insert(d_num,"    }\n")              #插入并回车
lines.insert(d_num,"        }\n")              #插入并回车
lines.insert(d_num,"            ((HttpManager) sender).installMockAdapter(adapter);\n")              #插入并回车
lines.insert(d_num,"        if (sender instanceof HttpManager) {\n")              #插入并回车
lines.insert(d_num,"        ICommunicationSender sender = senderMap.get(COMMUNICATION_SENDTYPE_HTTP);\n")              #插入并回车
lines.insert(d_num,"    public void installMockAdapter(IHttpAdapter adapter) {\n")              #插入并回车
lines.insert(d_num,"    @Override\n")           #插入并回车

s=''.join(lines)
f=open(cm_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify CommunicationManager success---")
                

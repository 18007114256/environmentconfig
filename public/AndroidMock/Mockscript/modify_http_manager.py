import sys
import os
import re

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scp_studio_path = os.path.join(root, name)
            break
                

httpm_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\http\HttpManager.java'
with open(httpm_file, 'r', encoding='utf-8-sig') as f1:
    message=''
    for line in f1:
        line=re.sub('private static final String SERVER_UPDATE_ERROER', 'protected static final String SERVER_UPDATE_ERROER', line)
        line=re.sub('private void processResponse(String responseJson)', 'protected void processResponse(String responseJson)', line)  
        message+=line
with open(httpm_file, 'w', encoding='utf-8') as f2:
    f2.write(message)
with open(httpm_file, "r", encoding="utf-8-sig") as f3:
    fcontent = f3.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("private IHttpAdapter mainAdapter")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break
			
    for a_num, a_content in enumerate(fcontent):
        a_str_index = a_content.find("private void sendMessage(HttpMessage msg)")
        if a_str_index != -1:
            print("---在第{}行{}列".format(a_num, a_str_index))
            break
		 
    for b_num, b_content in enumerate(fcontent):
        b_str_index = b_content.find("public void release()")
        if b_str_index != -1:
            print("---在第{}行{}列".format(b_num, b_str_index))
            break
		 
    for c_num, c_content in enumerate(fcontent):
        c_str_index = c_content.find("public void installHttpAdapter(IHttpAdapter adapter)")
        if c_str_index != -1:
            print("---在第{}行{}列".format(c_num, c_str_index))
            break
		 
lines=[]
f4=open(httpm_file,'r', encoding='utf-8-sig')  #your path!
for line in f4:
    lines.append(line)
f4.close()
line_num = line_num + 1
lines.insert(line_num, "    private IHttpAdapter mockAdapter;\n")           #插入并回车

a_num = a_num +2
lines.insert(a_num,"        }\n")										#插入并回车
lines.insert(a_num,"           }\n")										#插入并回车
lines.insert(a_num,"              return;\n")							#插入并回车
lines.insert(a_num,"           if (ret == 0) {\n")						#插入并回车
lines.insert(a_num,"           int ret = mockAdapter.send(msg);\n")      #插入并回车
lines.insert(a_num,"        if (mockAdapter != null) {\n")               #插入并回车

b_num = b_num + 8
lines.insert(b_num,"        }\n") 
lines.insert(b_num,"            mockAdapter.release();\n")				#插入并回车
lines.insert(b_num,"        if (mockAdapter != null) {\n")				#插入并回车 

c_num =c_num + 14
lines.insert(c_num,"    }\n")
lines.insert(c_num,"        mockAdapter.setHttpResponse(this);\n")           #插入并回车
lines.insert(c_num,"        mockAdapter = adapter;\n")					#插入并回车
lines.insert(c_num,"    public void installMockAdapter(IHttpAdapter adapter) {\n")           #插入并回车
lines.insert(c_num,"    \n")

s=''.join(lines)
f5=open(httpm_file,'w+', encoding='utf-8') #重新写入文件
f5.write(s)
f5.close()
del lines[:]                      #清空列表

print("---modify HttpManager success---")
                

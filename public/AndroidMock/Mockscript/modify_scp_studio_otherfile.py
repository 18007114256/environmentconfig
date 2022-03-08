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
with open(itc_file, "r", encoding="GBK") as f1:
    fcontent1 = f1.readlines()
    for line_num, line_content in enumerate(fcontent1):
        sub_str_index = line_content.find("void installHttpAdapter(IHttpAdapter adapter)")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break                     
    
lines=[]
f=open(itc_file,'r', encoding='GBK')  #your path!
for line in f:
    lines.append(line)
f.close()
line_num = line_num + 1
lines.insert(line_num,"        //安装mock适配器\n")           #插入并回车
lines.insert(line_num,"        public void installMockAdapter(IHttpAdapter adapter);\n")              #插入并回车

s=''.join(lines)
f=open(itc_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表


tchatR_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\http\\bean\TchatRequest.java'
with open(tchatR_file, 'r', encoding='utf-8-sig') as f1:
    message=''
    for line in f1:		
        line=re.sub('private int type', 'protected int type', line)
        line=re.sub('private String uniqId', 'protected String uniqId', line)
        line=re.sub('private Response<JSONObject> processErrorResponse', 'protected Response<JSONObject> processErrorResponse', line)
        message+=line
with open(tchatR_file, 'w', encoding='utf-8') as f2:
    f2.write(message)


httpm_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\http\HttpManager.java'
with open(httpm_file, 'r', encoding='utf-8-sig') as f1:
    message=''
    for line in f1:
        line=re.sub('private static final String SERVER_UPDATE_ERROER', 'protected static final String SERVER_UPDATE_ERROER', line)
        line=re.sub('private void processResponse(String responseJson)', 'protected void processResponse(String responseJson)', line)  
        message+=line
with open(httpm_file, 'w', encoding='utf-8') as f2:
    f2.write(message)
with open(httpm_file, "r", encoding="GBK") as f1:
    fcontent = f1.readlines()
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
f=open(httpm_file,'r', encoding='GBK')  #your path!
for line in f:
    lines.append(line)
f.close()
lines.insert(line_num, "    private IHttpAdapter mockAdapter;\n")           #插入并回车

lines.insert(a_num,"           if (mockAdapter != null) {\n")           #插入并回车
lines.insert(a_num,"              int ret = mockAdapter.send(msg);\n")           #插入并回车
lines.insert(a_num,"              if (ret == 0) {\n")           #插入并回车
lines.insert(a_num,"                 return;\n")           #插入并回车
lines.insert(a_num,"              }\n")           #插入并回车
lines.insert(a_num,"           }\n")           #插入并回车

lines.insert(b_num,"           if (mockAdapter != null) {\n")           #插入并回车
lines.insert(b_num,"               mockAdapter.release();\n")           #插入并回车
lines.insert(b_num,"           }\n")  

lines.insert(c_num,"        public void installMockAdapter(IHttpAdapter adapter) {\n")           #插入并回车
lines.insert(c_num,"            mockAdapter = adapter;\n")           #插入并回车
lines.insert(c_num,"            mockAdapter.setHttpResponse(this);\n")           #插入并回车
lines.insert(c_num,"        }\n")

s=''.join(lines)
f=open(httpm_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表


volleya_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\http\VolleyAdapter.java'
with open(volleya_file, 'r', encoding='GBK') as f1:
    message=''
    for line in f1:
        line=re.sub('private Map<String, TchatRequest> mRequestCache', 'protected Map<String, TchatRequest> mRequestCache', line)
        line=re.sub('private Map<String, TchatRequest> tokenErrorRequest', 'protected Map<String, TchatRequest> tokenErrorRequest', line)
        line=re.sub('protected class VolleyListener implements Response.Listener<JSONObject>', 'public class VolleyListener implements Response.Listener<JSONObject>', line)
        line=re.sub('protected class VolleyErrorListener implements TchatListener', 'public class VolleyErrorListener implements TchatListener', line)
	   
        message+=line
with open(volleya_file, 'w', encoding='utf-8') as f2:
    f2.write(message)


cm_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\CommunicationManager.java'
with open(cm_file, "r", encoding="GBK") as f2:
    fcontent2 = f2.readlines()
    for d_num, d_content in enumerate(fcontent2):
        d_str_index = d_content.find("public void installHttpAdapter(IHttpAdapter adapter)")
        if d_str_index != -1:
            print("---在第{}行{}列".format(d_num, d_str_index))
            break
		                     
    
lines=[]
f=open(cm_file,'r', encoding='GBK')  #your path!
for line in f:
    lines.append(line)
f.close()
d_num = d_num - 1
lines.insert(d_num,"        @Override\n")           #插入并回车
lines.insert(d_num,"        public void installMockAdapter(IHttpAdapter adapter) {\n")              #插入并回车
lines.insert(d_num,"            ICommunicationSender sender = senderMap.get(COMMUNICATION_SENDTYPE_HTTP);\n")              #插入并回车
lines.insert(d_num,"            if (sender instanceof HttpManager) {\n")              #插入并回车
lines.insert(d_num,"                ((HttpManager) sender).installMockAdapter(adapter);\n")              #插入并回车
lines.insert(d_num,"            }\n")              #插入并回车
lines.insert(d_num,"        }\n")              #插入并回车

s=''.join(lines)
f=open(cm_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify itcommunication TchatRequest HttpManager VolleyAdapter CommunicationManager success---")
                

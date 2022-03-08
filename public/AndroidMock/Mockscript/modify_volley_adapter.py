import sys
import os
import re

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scp_studio_path = os.path.join(root, name)
            break
             
volleya_file=scp_studio_path + '\SCP_Communitcation\src\main\java\com\sinosun\\tchat\communication\http\VolleyAdapter.java'
with open(volleya_file, 'r', encoding='utf-8-sig') as f1:
    message=''
    for line in f1:
        line=re.sub('private Map<String, TchatRequest> mRequestCache', 'protected Map<String, TchatRequest> mRequestCache', line)
        line=re.sub('private Map<String, TchatRequest> tokenErrorRequest', 'protected Map<String, TchatRequest> tokenErrorRequest', line)
        line=re.sub('protected class VolleyListener implements Response.Listener<JSONObject>', 'public class VolleyListener implements Response.Listener<JSONObject>', line)
        line=re.sub('protected class VolleyErrorListener implements TchatListener', 'public class VolleyErrorListener implements TchatListener', line)
	   
        message+=line
with open(volleya_file, 'w', encoding='utf-8') as f2:
    f2.write(message)

print("---modify VolleyAdapter success---")
                

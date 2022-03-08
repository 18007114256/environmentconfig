import sys
import os
import re

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scp_studio_path = os.path.join(root, name)
            break
                
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

print("---modify TchatRequest success---")
                

import sys
import os

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_MessageBus":
            #print(os.path.join(root, name))
            messagebus_path = os.path.join(root, name)
            break
            
m_file=messagebus_path + '\src\main\java\com\sinosun\\tchat\messagebus\MessageBus.java'
#读取指定行：
lines=[]
f=open(m_file,'r', encoding='utf-8-sig')  #your path!
for line in f:
    lines.append(line)
f.close()

#lines.insert(len(lines)-1,"    public String getUrl(int msgType) { try {return messageContainer.getControllerMessage(msgType).getUrl();} catch (Exception e) {return null;} }\n")           #插入并回车
lines.insert(len(lines)-1,"    public String getUrl(int msgType) { \n")           #插入并回车
lines.insert(len(lines)-1,"        try {\n")           #插入并回车
lines.insert(len(lines)-1,"            return messageContainer.getControllerMessage(msgType).getUrl(); \n")           #插入并回车
lines.insert(len(lines)-1,"        } catch (Exception e) { \n")           #插入并回车
lines.insert(len(lines)-1,"            return null; \n")           #插入并回车
lines.insert(len(lines)-1,"        }\n")           #插入并回车
lines.insert(len(lines)-1,"    }\n")           #插入并回车
s=''.join(lines)
f=open(m_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify_MessageBus success---")

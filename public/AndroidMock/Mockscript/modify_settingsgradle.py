import sys
import os

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scpstudio_path = os.path.join(root, name)
            break
            
m_file=scpstudio_path + '\settings.gradle'
with open(m_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("SCP_Communitcation")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break


#读取指定行：
lines=[]
f=open(m_file,'r')  #your path!
for line in f:
    lines.append(line)
f.close()

lines.insert(line_num,"include ':SCP_MockCommunication'\n")           #插入并回车
s=''.join(lines)
f=open(m_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify settings.gradle success---")

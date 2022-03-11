import sys
import os

#读取MainApp.java
for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "src":
            print(os.path.join(root, name))
            src_path = os.path.join(root, name)
            break

for root, dirs, files in os.walk(src_path):
    for name in dirs:
        if name == sys.argv[3]:
            print(os.path.join(root, name))
            src_env_path = os.path.join(root, name)
            break
			
for root, dirs, files in os.walk(src_env_path):
    for name in files:
        if name == "MainApp.java":
            print(os.path.join(root, name))
            mainApp_file = os.path.join(root, name)
            break
            
#读取域名端口
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name.find(".txt") != -1 and name.find("readme") == -1 and (os.path.join(root, name)).find("cert") == -1:
            print(os.path.join(root, name))
            txt_file = os.path.join(root, name)
            break
			
with open(txt_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("https://")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break

#读取指定行：
lines=[]
f=open(txt_file,'r', encoding="utf-8-sig")  #your path!
for line in f:
    lines.append(line)
f.close()

data = lines[line_num]
data1 = data[sub_str_index + 8 :]
s = data1[:data1.index("/")]
result=[]
result = s.split(":" , 1)
if result:
	print("-Env-host and port success")
	hostName = result[0]
	portName = result[1]
else:
	print("-Env-host and port is null")
	hostName = ""
	portName = ""
print(result)
del lines[:]                      #清空列表
del result[:]                      #清空列表
print("-Env-" + hostName)
print("-Env-" + portName)

#打开MainApp.java 找到需要修改的行
with open(mainApp_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("String privateServerHost")#找到域名行
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break

#读取指定行：
lines=[]
f=open(mainApp_file,'r', encoding="utf-8-sig")  #your path!
for line in f:
    lines.append(line)
f.close()
data = lines[line_num]
result=[]
result = data.split("\"" , 2)
print(result)
if(result):
	lines[line_num] = lines[line_num].replace(result[1],hostName)
	print(lines[line_num])
s=''.join(lines)
f=open(mainApp_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
#配置环境结束
print("---set env end---")

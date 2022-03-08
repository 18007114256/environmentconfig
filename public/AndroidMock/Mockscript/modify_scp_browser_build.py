import sys
import os

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Browser":
            #print(os.path.join(root, name))
            browser_path = os.path.join(root, name)
            break
            
m_file=browser_path + '\\build.gradle'
with open(m_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("dependencies")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            a_str_index = line_content.find("{")
            #print(a_str_index)
            for b_num, b_content in enumerate(fcontent):
                b_index = b_content.find("}")
                if b_index != -1:
                    if b_num > line_num:
                        print("---在第{}行{}列".format(b_num, b_index))
                        break
                    else:
                        continue


#读取指定行：
lines=[]
f=open(m_file,'r')  #your path!
for line in f:
    lines.append(line)
f.close()

lines.insert(b_num,"    compileOnly files('libs/scp_mockcommunication.jar')\n")           #插入并回车
s=''.join(lines)
f=open(m_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify_build.gradle success---")

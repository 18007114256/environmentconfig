import sys
import os

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_Browser":
            #print(os.path.join(root, name))
            browser_path = os.path.join(root, name)
            break
                
m_file=browser_path + '\src\main\java\com\sinosun\\browser\BrowserFunctionMgr.java'
with open(m_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("private void installLocalFunction()")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            for b_num, b_content in enumerate(fcontent):
                b_index = b_content.find("}")
                if b_index != -1:
                    if b_num > line_num:
                        print("---在第{}行{}列".format(b_num, b_index))
                        break
                    else:
                        continue
                        
    for a_num, a_content in enumerate(fcontent):
        a_str_index = a_content.find("package com.sinosun.browser")
        if a_str_index != -1:
            print("---在第{}行{}列".format(a_num, a_str_index))
            break
lines=[]
f=open(m_file,'r',encoding='UTF-8')  #your path!
for line in f:
    lines.append(line)
f.close()
a_num=a_num+2
lines.insert(a_num,"import com.sinosun.browser.commfunction.GetApiFakerFunction;\n")           #插入并回车

#lines.insert(b_num,"    mLocalFunctionHandlers.put(new GetApiFakerFunction().getFunctionName(), new GetApiFakerFunction());\n")           #插入并回车
b_num = b_num + 1
lines.insert(b_num,"        mLocalFunctionHandlers.put(function.getFunctionName(), function); \n")           #插入并回车
lines.insert(b_num,"        function = new GetApiFakerFunction(); \n")           #插入并回车
lines.insert(b_num,"        //H5 ApiFaker \n")           #插入并回车
lines.insert(b_num,"         \n")           #插入并回车

s=''.join(lines)
f=open(m_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify_browserFunctionMgr success---")
                

import sys
import os
import shutil

#读取src
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "src":
            # print(os.path.join(root, name))
            src_path = os.path.join(root, name)
            break

#读取buildconfig目录
buildconfig_path = ""
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "buildConfig" and len(buildconfig_path) == 0:
            # print(os.path.join(root, name))
            path = os.path.join(root, name)
            if(path.find("generated") == -1) :
                buildconfig_path = path
                print("buildconfig_path = " + buildconfig_path)
                break

# 读取buildConfig目录下的环境gradle文件
def readfile(path):
    files = os.listdir(path)
    file_list = []
    for file in files:  # 遍历文件夹
        # print("file name =  " + file)
        # print("file name =  " + file)
        if not os.path.isdir(file) and file.find("Setting") == -1 and file == sys.argv[2] + ".gradle":  
            file_list.append(path + '/'+file)
    return file_list

# 读取src目录下的环境目录
def readfilePath(path):
    files = os.listdir(path)
    # print(files)
    file_list = []
    for file in files:  # 遍历文件夹
        if file != "main" and file == sys.argv[2]:  
            file_list.append(os.path.join(path, file))
    # print(file_list)
    return file_list

listEnv=[]
listEnv = readfile(buildconfig_path)
# print("---------")
# print(listEnv)
# 删除.gradle文件
if(listEnv) :
    os.remove(listEnv[len(listEnv) - 1])

# 复制src下环境目录，改名为新环境名
listSrc =[]
listSrc = readfilePath(src_path)
# 删除src下对应环境目录
if(listSrc) :
    shutil.rmtree(listSrc[len(listSrc) - 1])
    # os.rmdir(listSrc[len(listSrc) - 1])

# 找到build.gradle文件
buildList = []
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name == "build.gradle":
            buildList.append(os.path.join(root, name))
            break
# print(buildList)
if(len(buildList) > 1) :
    print("开始删除build文件")
    # 先删除项目build.gradle文件
    with open(buildList[0], "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            print("buildConfig/" + sys.argv[2])
            sub_str_index = line_content.find("buildConfig/" + sys.argv[2])
            if sub_str_index != -1:
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break 
    #读取指定行：
    lines=[]
    f=open(buildList[0],'r', encoding='utf-8-sig')  #your path!
    for line in f:
        lines.append(line)
    f.close()
    del lines[line_num]
    s=''.join(lines)
    f=open(buildList[0],'w+', encoding='utf-8') #重新写入文件
    f.write(s)
    f.close()  
    del lines[:]                      #清空列表
    with open(buildList[0], "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            print(("load" + sys.argv[2]).lower())
            sub_str_index = line_content.lower().find(("load" + sys.argv[2]).lower())
            if sub_str_index != -1:
                print("找到load行")
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break 
    #读取指定行：
    lines=[]
    f=open(buildList[0],'r', encoding='utf-8-sig')  #your path!
    for line in f:
        lines.append(line)
    f.close()
    for i in range(line_num, len(lines)) :
        if(lines[i].find("}") != -1) :
            endLine = i
            break
    for i in range(0, endLine - line_num + 1) :
        del lines[line_num]
    s=''.join(lines)
    f=open(buildList[0],'w+', encoding='utf-8') #重新写入文件
    f.write(s)
    f.close()  
    del lines[:]                      #清空列表

    # 再修改模块build.gradle文件
    with open(buildList[1], "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            print((sys.argv[2]) + " {")
            sub_str_index = line_content.find((sys.argv[2]) + " {")
            if sub_str_index != -1:
                print("找到productFlavors行")
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break 
    #读取指定行：
    lines=[]
    f=open(buildList[1],'r', encoding='utf-8-sig')  #your path!
    for line in f:
        lines.append(line)
    f.close()
    for i in range(line_num, len(lines)) :
        if(lines[i].find("}") != -1) :
            endLine = i
            break
    for i in range(0, endLine - line_num + 1) :
        del lines[line_num]
    s=''.join(lines)
    f=open(buildList[1],'w+', encoding='utf-8') #重新写入文件
    f.write(s)
    f.close()  
    del lines[:]                      #清空列表
else :
    print("-Env- find build.gradle fail")
print("---modify name end---")

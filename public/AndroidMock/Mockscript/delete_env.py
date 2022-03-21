import sys
import os
import shutil

#替换文件中指定内容
def lm_replace( filePath, oldValue, newValue):
	f = open(filePath,"r+", encoding='utf-8')
	content_before = f.read()
	# print(content_before)
	content_after = content_before.replace(oldValue,newValue)
	# print(content_after)
	f.seek(0,0)
	f.truncate()	#清空文件，配合seek使用，否则清空的位置不对
	f.write(content_after)
	f.close()

#读取环境gradle      
# for root, dirs, files in os.walk(sys.argv[2]):
#     for name in files:
#         if name == sys.argv[3] + ".gradle":
#             # print(os.path.join(root, name))
#             gradle_file = os.path.join(root, name)
#             break

#读取src
for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "src":
            # print(os.path.join(root, name))
            src_path = os.path.join(root, name)
            break

# for root, dirs, files in os.walk(src_path):
#     for name in dirs:
#         if name == sys.argv[3]:
#             # print(os.path.join(root, name))
#             src_env_path = os.path.join(root, name)
#             break
			
# for root, dirs, files in os.walk(src_env_path):
#     for name in files:
#         if name == "MainApp.java":
#             print(os.path.join(root, name))
#             mainApp_file = os.path.join(root, name)
#             break

#读取buildconfig目录
buildconfig_path = ""
for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "buildConfig" and len(buildconfig_path) == 0:
            print(os.path.join(root, name))
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
        if not os.path.isdir(file) and file.find("Setting") == -1:  
            file_list.append(path + '/'+file)
    return file_list

# 读取src目录下的环境目录
def readfilePath(path):
    files = os.listdir(path)
    print(files)
    file_list = []
    for file in files:  # 遍历文件夹
        if file != "main":  
            file_list.append(path + '\\'+file)
    # print(file_list)
    return file_list

# 复制文件和目录
def my_copy(path1,path2,type='file'):
    if type == 'file':
        shutil.copyfile(path1,path2)
        # print('文件复制成功')
    elif type == 'dir1':
        shutil.copytree(path1,path2)
        # print('目录复制成功')
    return

listEnv=[]
listEnv = readfile(buildconfig_path)
# print(listEnv)
# 复制环境gradle文件，改名为新环境名
new_Env_path_file = buildconfig_path + "\\" + sys.argv[3] + ".gradle"
shutil.copy(listEnv[len(listEnv) - 1], new_Env_path_file)

#修改新环境内容
lm_replace(new_Env_path_file, listEnv[len(listEnv) - 1].split("/")[1].split(".")[0], sys.argv[3])

# 复制src下环境目录，改名为新环境名
listSrc =[]
listSrc = readfilePath(src_path)
# print(listSrc)
new_src_path_file = src_path + "\\" + sys.argv[3]
my_copy(listSrc[len(listSrc) - 1], new_src_path_file,type='dir1')

# 找到build.gradle文件
buildList = []
for root, dirs, files in os.walk(sys.argv[2]):
    for name in files:
        if name == "build.gradle":
            buildList.append(os.path.join(root, name))
            break
# print(buildList)
if(len(buildList) > 1) :
    # 先修改项目build.gradle文件

    #读取指定行：
    lines=[]
    f=open(buildList[0],'r', encoding='utf-8-sig')  #your path!
    for line in f:
        lines.append(line)
    f.close()
    # 写入apply gradle
    data = "apply from: 'buildConfig/" + sys.argv[3] + ".gradle'\n"
    lines.insert(5, data)           #插入并回车
    # 写入新环境编译配置
    lines.insert(len(lines) +2 ,"def  load"+ sys.argv[3] + "CompileSetting(){\n")                #插入并回车
    lines.insert(len(lines) +2 ,"   loadGeneralCompileSetting()\n")               #插入并回车
    lines.insert(len(lines) +2 ,"   project.ext.set(\""+ sys.argv[3] + "_ThirdSDKLib\", rootProject.ext."+ sys.argv[3] + "_ThirdSDKLib)\n")           #插入并回车
    lines.insert(len(lines) +2 ,"   project.ext.set(\""+ sys.argv[3] + "_JarLib\", rootProject.ext."+ sys.argv[3] + "_JarLib)\n")           #插入并回车
    lines.insert(len(lines) +2 ,"   project.ext.set(\""+ sys.argv[3] + "_CompileProject\", rootProject.ext."+ sys.argv[3] + "_CompileProject)\n")              #插入并回车
    lines.insert(len(lines) +2 ,"   project.ext.set(\""+ sys.argv[3] + "_ThirdAarLib\", rootProject.ext."+ sys.argv[3] + "_ThirdAarLib)\n")           #插入并回车
    lines.insert(len(lines) +2 ,"}\n")           #插入并回车

    s=''.join(lines)
    f=open(buildList[0],'w+', encoding='utf-8') #重新写入文件
    f.write(s)
    f.close()
    del lines[:]                      #清空列表
    # 再修改模块build.gradle文件
    with open(buildList[1], "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            sub_str_index = line_content.find("productFlavors")
            if sub_str_index != -1:
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break 
    #读取指定行：
    lines=[]
    f=open(buildList[1],'r', encoding='utf-8-sig')  #your path!
    for line in f:
        lines.append(line)
    f.close()  
    # 写入新环境编译配置
    lines.insert(line_num +1 , "        "+ sys.argv[3] + " {\n")                #插入并回车
    lines.insert(line_num +2  ,"            versionName rootProject.ext."+ sys.argv[3] + "_versionName\n")               #插入并回车
    lines.insert(line_num +3  ,"            versionCode rootProject.ext."+ sys.argv[3] + "_versionCode\n")           #插入并回车
    lines.insert(line_num +4  ,"            dimension rootProject.ext."+ sys.argv[3] + "_dimension\n")           #插入并回车
    lines.insert(line_num +5  ,"            applicationId rootProject.ext."+ sys.argv[3] + "_applicationId\n")              #插入并回车
    lines.insert(line_num +6  ,"            manifestPlaceholders = rootProject.ext."+ sys.argv[3] + "_manifestPlaceholders\n")           #插入并回车
    lines.insert(line_num +7  ,"            load"+ sys.argv[3] + "CompileSetting()\n")           #插入并回车
    lines.insert(line_num +8  ,"        }\n")           #插入并回车
    s=''.join(lines)
    f=open(buildList[1],'w+', encoding='utf-8') #重新写入文件
    f.write(s)
    f.close()
    del lines[:]                      #清空列表
else :
    print("-Env- find build.gradle fail")
print("---add env end---")

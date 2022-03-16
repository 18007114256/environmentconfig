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
    print(file_list)
    return file_list

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
print(listSrc)
new_src_path_file = src_path + "\\" + sys.argv[3]
my_copy(listSrc[len(listSrc) - 1], new_src_path_file,type='dir1')

print("---add env end---")

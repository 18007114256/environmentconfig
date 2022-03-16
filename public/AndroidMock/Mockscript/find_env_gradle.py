import sys
import os

# 读取buildConfig目录下的环境gradle
def readfile(path):
    files = os.listdir(path)
    file_list = []
    for file in files:  # 遍历文件夹
        if not os.path.isdir(file) and file.find("Setting") == -1:
            file_list.append(file.split(".")[0])
    return file_list

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "src":
            #print(os.path.join(root, name))
            src_path = os.path.join(root, name)
            break
			
listEnv=[]
#读取buildconfig
buildconfig_path = ""
for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "buildConfig" and len(buildconfig_path) == 0:
            # print(os.path.join(root, name))
            path = os.path.join(root, name)
            if(path.find("generated") == -1) :
                buildconfig_path = path
                # print("buildconfig_path = " + buildconfig_path)
                break
listEnv = readfile(buildconfig_path)
# for root, dirs, files in os.walk(src_path):
#     for name in dirs:
#         if name.find("Env") != -1:
#             #print(os.path.join(root, name))
#             listEnv.append(name)
            #break
print('-Env-'.join(listEnv))
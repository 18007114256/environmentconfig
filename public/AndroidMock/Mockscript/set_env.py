import sys
import os
import shutil
import xlrd

#读取特定目录
def getPath( rootPath, tagetPathName ):
    for root, dirs, files in os.walk(rootPath):
        for name in dirs:
            if name == tagetPathName:
                print(os.path.join(root, name))
                taget_path = os.path.join(root, name)
                break
    return taget_path

#读取特定文件
def getFile( rootPath, tagetFileName ):
    for root, dirs, files in os.walk(rootPath):
        for name in files:
            if name == tagetFileName:
                print(os.path.join(root, name))
                taget_file = os.path.join(root, name)
                break
    return taget_file

#读取yml文件中的特定值
def readFileValue( filePath, tagetValueName ):
    with open(filePath, "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            sub_str_index = line_content.find(tagetValueName)
            if sub_str_index != -1:
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break
    #读取指定行：
    lines=[]
    f=open(filePath,'r', encoding="utf-8-sig")  #your path!
    for line in f:
        lines.append(line)
    f.close()
    data = lines[line_num]
    s = data[data.index(":") + 1:]
    result = s.strip()
    print(result)
    if(len(result) == 0) :
        print("-Env-{}is null".format(tagetValueName))
    return result

#修改mainApp中的特定值
def modifyValue( fileName, old, new ):
    with open(fileName, "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            sub_str_index = line_content.find(old)
            if sub_str_index != -1:
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break
    #读取指定行：
    lines=[]
    f=open(fileName,'r', encoding="utf-8-sig")  #your path!
    for line in f:
        lines.append(line)
    f.close()
    #替换值
    data = lines[line_num]
    result=[]
    result = data.split("\"" , 2)
    if(result) :
        lines[line_num] = lines[line_num].replace(result[1],new)
        print(lines[line_num])
    #重新写入文件
    s=''.join(lines)
    f=open(fileName,'w+', encoding='utf-8')
    f.write(s)
    f.close()
    del lines[:]                      #清空列表
    del result[:]                      #清空列表
    return

#读取环境gradle      
for root, dirs, files in os.walk(sys.argv[2]):
    for name in files:
        if name == sys.argv[3] + ".gradle":
            print(os.path.join(root, name))
            gradle_file = os.path.join(root, name)
            break

#读取src
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

#读取pem文件
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name.find("param.pem") != -1:
            print(os.path.join(root, name))
            pem_name = name
            pem_file = os.path.join(root, name)
            break
            
#将pem文件拷贝到assets下
new_pem_path = getPath( src_env_path, "assets" )
new_pem_path_file = new_pem_path + "\\" + pem_name
shutil.copy(pem_file, new_pem_path_file)

#修改mainApp中的pem配置
modifyValue(mainApp_file, "ExtendConstants.HTTP_SECRET_FILE", pem_name)
modifyValue(mainApp_file, "ExtendConstants.MSTP_SECRET_FILE", pem_name)

#读取安全键盘秘钥文件
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name.find("safeKeyboard") != -1:
            print(os.path.join(root, name))
            safeKey_name = name
            safeKey_file = os.path.join(root, name)
            break
            
#将安全键盘秘钥文件拷贝到assets下
new_safeKey_path = getPath( src_env_path, "assets" )
new_safeKey_path_file = new_safeKey_path + "\\keyboardPublicKey"
new_safeKey_path_file1 = new_safeKey_path + "\\softCertTsSM2PublicKey"
shutil.copy(safeKey_file, new_safeKey_path_file)
shutil.copy(safeKey_file, new_safeKey_path_file1)

#读取tid并修改
#读取yml文件
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name.find(".yml") != -1:
            print(os.path.join(root, name))
            yml_name = name
            yml_file = os.path.join(root, name)
            break
tid = readFileValue(yml_file, "tid:")
modifyValue(mainApp_file, "ExtendConstants.APP_TID", tid)

bsl_sm2_kid = readFileValue(yml_file, "bsl_sm2_kid:")
modifyValue(mainApp_file, "ExtendConstants.PRIVATE_BSL_KID", bsl_sm2_kid)

bsl_sm2_public_key = readFileValue(yml_file, "bsl_sm2_public_key:")
modifyValue(mainApp_file, "ExtendConstants.PRIVATE_BSL_KEY", bsl_sm2_public_key)

mstp_client_id = readFileValue(yml_file, "mstp_group_keycloak_resource:")
modifyValue(mainApp_file, "ExtendConstants.MSTP_CLIENT_ID_ADDR", mstp_client_id)

mstp_client_secret = readFileValue(yml_file, "mstp_group_keycloak_credentials_secret:")
modifyValue(mainApp_file, "ExtendConstants.MSTP_SECRET_ADDR", mstp_client_secret)

#读取包名
#修改.gradle文件中的包名
pName = readFileValue(yml_file, "android_package_name:")
modifyValue(gradle_file, "applicationId", pName)
modifyValue(gradle_file, "applicationIdLowerCase", pName)

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
print("-Env-" + hostName)
print("-Env-" + portName)
print(result)

#读取realm
with open(txt_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("realm")
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
result=[]
result = data.split("\"" , 4)
if result:
	print("-Env-realm success")
	realm = result[3]
else:
	print("-Env-realm is null")
	realm = ""
print(result)
print("-Env-" + realm)

#读取appclint preview
appclint = ""
appclintSecret = ""
preview = ""
previewSecret = ""
numLine = []
with open(txt_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("resource")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            numLine.append(line_num)
            #break
#读取指定行：
lines=[]
f=open(txt_file,'r', encoding="utf-8-sig")  #your path!
for line in f:
    lines.append(line)
f.close()
if(len(numLine) > 0) :
    data = lines[numLine[0]]
    s = data[data.index(":"):]
    result=[]
    result = s.split("\"" , 2)
    data1 = lines[numLine[0] + 2]
    s1 = data1[data1.index(":"):]
    result1=[]
    result1 = s1.split("\"" , 2)
if result:
	print("-Env-appclint success")
	appclint = result[1]
	appclintSecret = result1[1]
else:
	print("-Env-appclint is null")
	appclint = ""
	appclintSecret = ""
if(len(numLine) > 1) :
    data = lines[numLine[1]]
    s = data[data.index(":"):]
    result=[]
    result = s.split("\"" , 2)
    data1 = lines[numLine[1] + 2]
    s1 = data1[data1.index(":"):]
    result1=[]
    result1 = s1.split("\"" , 2)
if result:
	print("-Env-preview success")
	preview = result[1]
	previewSecret = result1[1]
else:
	print("-Env-preview is null")
	preview = ""
	previewSecret = ""
print(result)
print("-Env-" + appclint + appclintSecret + preview + previewSecret)

modifyValue(mainApp_file, "String privateServerHost", hostName)
modifyValue(mainApp_file, "String privateServerPort", portName)
modifyValue(mainApp_file, "String privateAuthRealm", realm)
modifyValue(mainApp_file, "ExtendConstants.PRIVATE_CLIENT_ID_ADDR", appclint)
modifyValue(mainApp_file, "ExtendConstants.PRIVATE_SECRET_ADDR", appclintSecret)
modifyValue(mainApp_file, "ExtendConstants.PREVIEW_CLIENT_ID_ADDR", preview)
modifyValue(mainApp_file, "ExtendConstants.PREVIEW_SECRET_ADDR", previewSecret)

#读取xlsx文件
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name.find(".xlsx") != -1:
            print(os.path.join(root, name))
            xlsx_file = os.path.join(root, name)
            break

# 读取小米，华为appid,appkey
tchat_mi_appid = ""
tchat_mi_appkey = ""
tchat_huawei_appid = ""

wb = xlrd.open_workbook(xlsx_file)#打开文件
print(wb.sheet_names())#获取所有表格名字
sheet1 = wb.sheet_by_index(0)#通过索引获取表格
print(sheet1.name,sheet1.nrows,sheet1.ncols)
for i in range(0, sheet1.nrows) :
    for j in range(0, sheet1.ncols) :
        if(str(sheet1.cell(i,j).value).find("huaweiPush_appId")) != -1 :
            tchat_huawei_appid = str(round(sheet1.cell(i+1,j).value))
        elif(str(sheet1.cell(i,j).value).find("xiaomiPush_appId")) != -1 :
            tchat_mi_appid = str(sheet1.cell(i+1,j).value)
        elif(str(sheet1.cell(i,j).value).find("xiaomiPush_appKey")) != -1 :
            tchat_mi_appkey = str(sheet1.cell(i+1,j).value)
print("tchat_huawei_appid = " + tchat_huawei_appid)
print("tchat_mi_appid = " + tchat_mi_appid)
print("tchat_mi_appkey = " + tchat_mi_appkey)
# 修改strings.xml
strings_path = getFile( src_env_path, "strings.xml" )

#修改strings.xml中的特定值
def modifyStringsValue( fileName, old, new ):
    with open(fileName, "r", encoding="utf-8-sig") as f1:
        fcontent = f1.readlines()
        for line_num, line_content in enumerate(fcontent):
            sub_str_index = line_content.find(old)
            if sub_str_index != -1:
                print("---在第{}行{}列".format(line_num, sub_str_index))
                break
    #读取指定行：
    lines=[]
    f=open(fileName,'r', encoding="utf-8-sig")  #your path!
    for line in f:
        lines.append(line)
    f.close()
    #替换值
    data = lines[line_num]
    result=[]
    result = data.split("\">" , 2)
    print(result)
    if(result) :
        lines[line_num] = lines[line_num].replace(result[1],new + "</string>\n")
        print(lines[line_num])
    #重新写入文件
    s=''.join(lines)
    f=open(fileName,'w+', encoding='utf-8')
    f.write(s)
    f.close()
    del lines[:]                      #清空列表
    del result[:]                      #清空列表
    return
modifyStringsValue(strings_path, "tchat_mi_appid", tchat_mi_appid)
modifyStringsValue(strings_path, "tchat_mi_appkey", tchat_mi_appkey)
modifyStringsValue(strings_path, "tchat_huawei_appid", tchat_huawei_appid)
print("---set env end---")

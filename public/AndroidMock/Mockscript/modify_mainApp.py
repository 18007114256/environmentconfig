import sys
import os

mainApp_list = []
for root, dirs, files in os.walk(sys.argv[1]):
    for name in files:
        if name == "MainApp.java":
            mainProject_path = os.path.join(root, name)
            mainProject_path = mainProject_path.replace("\\a", "\\\\a").replace("\\b", "\\\\b").replace("\\e", "\\\\e").replace("\\n", "\\\\n").replace("\\v", "\\\\v").replace("\\t", "\\\\t").replace("\\r", "\\\\r").replace("\\f", "\\\\f")
            #print(mainProject_path)
            mainApp_list.append(mainProject_path)
            break

for mainAppPath in mainApp_list:    
    if "MinimumApp" in mainAppPath:
        continue
    else:
        #m_file=sys.argv[1] + '\Ebank_Studio\MpaasApp\mainProject\src\\tchatCscbSitEnv\java\com\sinosun\\tchats\MainApp.java'
        with open(mainAppPath, "r", encoding="utf-8-sig") as f1:
            fcontent = f1.readlines()
            for line_num, line_content in enumerate(fcontent):
                sub_str_index = line_content.find("public void onCreate()")
                if sub_str_index != -1:
                    print("---在第{}行{}列".format(line_num, sub_str_index))
                    line_num = line_num + 5
                    break
        lines=[]
        f=open(mainAppPath,'r', encoding='utf-8-sig')  #your path!
        for line in f:
            lines.append(line)
        f.close()

        lines.insert(line_num,"        installModels(\"com.sinosun.tchat.cmockcommunication.TMock\");\n")           #插入并回车
        s=''.join(lines)
        f=open(mainAppPath,'w+', encoding='utf-8') #重新写入文件
        f.write(s)
        f.close()
        del lines[:]                      #清空列表

        print("---modify_MainApp success---")
                

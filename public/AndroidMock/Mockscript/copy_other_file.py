import os
import sys
import shutil

#%mockRootPath%\ApiFakerBean.java %projectRootPath%\SCPUI_Studio\SCP_Browser\src\main\java\com\sinosun\browser\bean\ApiFakerBean.java
#%mockRootPath%\ApiFakerUrlBean.java %projectRootPath%\SCPUI_Studio\SCP_Browser\src\main\java\com\sinosun\browser\bean\ApiFakerUrlBean.java
#%mockRootPath%\GetApiFakerFunction.java %projectRootPath%\SCPUI_Studio\SCP_Browser\src\main\java\com\sinosun\browser\commfunction\GetApiFakerFunction.java

for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "SCP_Browser":
            #print(os.path.join(root, name))
            scpbrowser_path = os.path.join(root, name)
            break

for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scpstudio_path = os.path.join(root, name)
            break
            
old_apifakerbean_path = sys.argv[1] + "\ApiFakerBean.java"
old_apifakerurlbean_path = sys.argv[1] + "\ApiFakerUrlBean.java"
old_apifakerfunction_path = sys.argv[1] + "\GetApiFakerFunction.java"

new_apifakerbean_path = scpbrowser_path + "\src\main\java\com\sinosun\\browser\\bean\ApiFakerBean.java"
new_apifakerurlbean_path = scpbrowser_path + "\src\main\java\com\sinosun\\browser\\bean\ApiFakerUrlBean.java"
new_apifakerfunction_path = scpbrowser_path + "\src\main\java\com\sinosun\\browser\commfunction\GetApiFakerFunction.java"

shutil.copy(old_apifakerbean_path, new_apifakerbean_path)
shutil.copy(old_apifakerurlbean_path, new_apifakerurlbean_path)
shutil.copy(old_apifakerfunction_path, new_apifakerfunction_path)
        
print("---copy other file success---")
    
    
    
    
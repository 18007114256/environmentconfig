import os
import sys
import shutil

for root, dirs, files in os.walk(sys.argv[2]):
    for name in dirs:
        if name == "SCP_Studio":
            #print(os.path.join(root, name))
            scpstudio_path = os.path.join(root, name)
            break
            
source_path = sys.argv[1] + "\SCP_MockCommunication"
target_path = scpstudio_path + '\SCP_MockCommunication'
isExists=os.path.exists(target_path)
if not isExists:
    #os.makedirs(target_path) 
    shutil.copytree(source_path, target_path)
    print("---makedirs and copy SCP_MockCommunication success---")
else:
    print("---SCP_MockCommunication has exists---")
    
    
    
    
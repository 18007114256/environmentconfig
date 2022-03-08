import os
import sys

def get_filepath(rootProjectPath):
    for root, dirs, files in os.walk(rootProjectPath):
        for name in dirs:
            if name == "SCP_Studio":
                scpstudio_path = os.path.join(root, name)
                break
    return scpstudio_path

returnValue = get_filepath(sys.argv[2])
file_path = sys.argv[1] + "\Mockscript\scp_studio_path.txt"
file = open(file_path,'w')
file.write(returnValue)
print("---write SCP_Studio path success---")
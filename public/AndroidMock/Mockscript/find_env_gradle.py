import sys
import os

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "src":
            #print(os.path.join(root, name))
            src_path = os.path.join(root, name)
            break
			
listEnv=[]

for root, dirs, files in os.walk(src_path):
    for name in dirs:
        if name.find("Env") != -1:
            #print(os.path.join(root, name))
            listEnv.append(name)
            #break
print('-Env-'.join(listEnv))
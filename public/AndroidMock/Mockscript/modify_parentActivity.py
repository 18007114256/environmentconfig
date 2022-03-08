import sys
import os

for root, dirs, files in os.walk(sys.argv[1]):
    for name in dirs:
        if name == "SCP_UiLib":
            #print(os.path.join(root, name))
            scp_uilib_path = os.path.join(root, name)
            print(scp_uilib_path)
            break
            

m_file=scp_uilib_path + '\src\main\java\com\sinosun\\ui\ParentActivity.java'
with open(m_file, "r", encoding="utf-8-sig") as f1:
    fcontent = f1.readlines()
    for line_num, line_content in enumerate(fcontent):
        sub_str_index = line_content.find("protected void onStart()")
        if sub_str_index != -1:
            print("---在第{}行{}列".format(line_num, sub_str_index))
            break     

    for a_num, a_content in enumerate(fcontent):
        a_str_index = a_content.find("package com.sinosun.ui;")
        if a_str_index != -1:
            print("---在第{}行{}列".format(a_num, a_str_index))
            break            
    

#读取指定行：
lines=[]
f=open(m_file,'r', encoding='utf-8-sig')  #your path!
for line in f:
    lines.append(line)
f.close()

a_num=a_num+2
lines.insert(a_num, "import com.sinosun.tchat.util.CPResourceUtil;\n")           #插入并回车

line_num = line_num + 3
lines.insert(line_num,"        updateMockView();\n")                                #插入并回车


lines.insert(len(lines)-1,"    private ImageView ivMockmark;\n")                #插入并回车
lines.insert(len(lines)-1,"    private void updateMockView(){\n")               #插入并回车
lines.insert(len(lines)-1,"        String mock_switch = CPResourceUtil.getStringContent(\"mock_switch\");\n")           #插入并回车
lines.insert(len(lines)-1,"        if (\"1\".equals(mock_switch)) {\n")           #插入并回车
lines.insert(len(lines)-1,"            if(ivMockmark == null){\n")              #插入并回车
lines.insert(len(lines)-1,"                ivMockmark = new ImageView(this);\n")           #插入并回车
lines.insert(len(lines)-1,"                ivMockmark.setBackgroundResource(R.drawable.img_demo_watermark);\n")           #插入并回车
lines.insert(len(lines)-1,"                LinearLayout.LayoutParams layoutParamsImageMain = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);\n")           #插入并回车
lines.insert(len(lines)-1,"                ((ViewGroup) getWindow().getDecorView().findViewById(android.R.id.content)).addView(ivMockmark, layoutParamsImageMain);\n")           #插入并回车
lines.insert(len(lines)-1,"            }\n")           #插入并回车
lines.insert(len(lines)-1,"        }else{\n")           #插入并回车
lines.insert(len(lines)-1,"             if(ivMockmark != null){\n")           #插入并回车
lines.insert(len(lines)-1,"                ((ViewGroup) getWindow().getDecorView().findViewById(android.R.id.content)).removeView(ivMockmark);\n")           #插入并回车
lines.insert(len(lines)-1,"             }\n")           #插入并回车
lines.insert(len(lines)-1,"        }\n")           #插入并回车
lines.insert(len(lines)-1,"        int childCount = ((ViewGroup) getWindow().getDecorView().findViewById(android.R.id.content)).getChildCount();\n")           #插入并回车
lines.insert(len(lines)-1,"        for(int i=0; i<childCount-1; i++){\n")           #插入并回车
lines.insert(len(lines)-1,"            if(((ViewGroup) getWindow().getDecorView().findViewById(android.R.id.content)).getChildAt(i) instanceof ImageView) {\n")           #插入并回车
lines.insert(len(lines)-1,"               ImageView imageView = (ImageView) ((ViewGroup) getWindow().getDecorView().findViewById(android.R.id.content)).getChildAt(i);\n")           #插入并回车
lines.insert(len(lines)-1,"               ((ViewGroup) getWindow().getDecorView().findViewById(android.R.id.content)).removeView(imageView);\n")           #插入并回车
lines.insert(len(lines)-1,"            }\n")           #插入并回车
lines.insert(len(lines)-1,"        }\n")           #插入并回车
lines.insert(len(lines)-1,"    }\n")           #插入并回车

s=''.join(lines)
f=open(m_file,'w+', encoding='utf-8') #重新写入文件
f.write(s)
f.close()
del lines[:]                      #清空列表

print("---modify ParentActivity success---")

require File.expand_path('../read_ws_info',__FILE__)
require File.expand_path('../tchat_add_fb',__FILE__)
require File.expand_path('../Singleton',__FILE__)

src = ARGV[0].dup
native_path = ARGV[1].dup
target_project = ARGV[2].dup
if src == nil
    scr = ""
    puts "$ele_fail,-99,参数错误 无效的根路径$"
    return
end

if native_path == nil
    native_path = ""
    puts "$ele_fail,-99,参数错误 无效的本地路径$"
    return
end


if target_project == nil
    target_project = ""
    puts "waring,1,未配置操控工程,将采取全局设置"
end
puts "target_project"
puts target_project
puts "target_project end"

# puts "本地根路径="+src
# puts "Mock 添加源="+native_path
# puts "操控工程="+target_project

puts "info,1,正在读取工程"
reader = ReadWSInfo.new
all_info = reader.get_ws_info(src)

if all_info.count==0
    puts "$ele_fail,-1,读取工程信息失败$"
    return
end
puts "工程数量"
puts all_info.count
puts "9999999999999"

puts all_info
puts "9999999999999"

# puts all_info

scp_root_path = all_info["SCP"]["root"]  #根目录/Users/apple/Desktop/网银/IOS
# puts "根目录="+scp_root_path
scp_path = all_info["SCP"]["path"] #SCP根目录 /Users/apple/Desktop/网银/IOS/SCP_iOS_Trunk
# puts "SCP根目录全路径="+scp_path
scp_ws_path = all_info["SCP"]["ws_path"] #SCP wrokspace路径   /Users/apple/Desktop/网银/IOS/SCP_iOS_Trunk/TChatWorkSpace.xcworkspace
# puts "SCP xcworkspace 全路径="+scp_ws_path
scp_root_file = all_info["SCP"]["root_file"] #SCP根目录文件名 SCP_iOS_Trunk
# puts "SCP根目录="+scp_root_file
scp_main_project = all_info["SCP"]["main_project"]  
# puts "SCP 可执行工程="  
#{"MpaasTChat"=>{"path"=>"/Users/apple/Desktop/Git/SCP_iOS_Trunk/MpaasTChat/MpaasTChat.xcodeproj", "name"=>"MpaasTChat"}, "Bizmate"=>{"path"=>"/Users/apple/Desktop/Git/SCP_iOS_Trunk/TChat/Bizmate.xcodeproj", "name"=>"Bizmate"}}
# puts scp_main_project

if target_project != ""
    tmp = scp_main_project[target_project]
    if tmp == nil
        puts "$ele_fail,-101,[Case1]没有可以操控的工程"+target_project+"$"
        return
    end
end
scp_main_project_list = []
scp_main_project.each {|key,value|
    scp_main_project_list << value
}
# puts "SCP 可执行工程数组"
#{"path"=>"/Users/apple/Desktop/Git/SCP_iOS_Trunk/MpaasTChat/MpaasTChat.xcodeproj", "name"=>"MpaasTChat"}
#{"path"=>"/Users/apple/Desktop/Git/SCP_iOS_Trunk/TChat/Bizmate.xcodeproj", "name"=>"Bizmate"}
puts scp_main_project_list

if scp_main_project_list.count == 0
    puts "$ele_fail,-101,[Case2]没有可以操控的工程$"
    return
end

tchat_root_path = all_info["TChat"]["root"]     #根目录/Users/apple/Desktop/网银/IOS
# puts "根目录="+tchat_root_path
tchat_path = all_info["TChat"]["path"]          #TChat根目录 /Users/apple/Desktop/网银/IOS/TChat_iOS_Trunk
# puts "TChat根目录全路径="+tchat_path
tchat_ws_path = all_info["TChat"]["ws_path"]    #TChatwrokspace路径   /Users/apple/Desktop/网银/IOS/TChat_iOS_Trunk/TChatWorkSpace.xcworkspace
# puts "TChat xcworkspace 全路径="+tchat_ws_path
tchat_root_file = all_info["TChat"]["root_file"] #TChat根目录文件名 TChat_iOS_Trunk
# puts "TChat根目录="+tchat_root_file
tchat_main_project = all_info["TChat"]["main_project"]
# puts "TChat 可执行工程"  
# puts tchat_main_project
if target_project != ""
    tmp = tchat_main_project[target_project]
    if tmp == nil
        puts "$ele_fail,-102,没有可以操控的工程"+target_project+"$"
        return
    end
end
tchat_main_project_list = []
tchat_main_project.each {|key,value|
    tchat_main_project_list << value
}
# puts "TChat 可执行工程数组" 
# puts tchat_main_project_list
if tchat_main_project_list.count == 0
    puts "$ele_fail,-102,没有可以操控的工程$"
    return
end

# puts "info,1,工程信息读取完毕"
# 从native_path_mocksdk 拷贝到scp_root_file/MockCommunication

# puts "info,1,开始拷贝MockCommunication到Scp"
fcontrol = FileControl.new
is_Biz = 1
ssroot_config_file = fcontrol.searchPath(tchat_path,"SSRootApp+Config.m")
if ssroot_config_file.count>0
    is_Biz = 1
else
    is_Biz = 0
end
native_path_mocksdk = native_path+"/BZS/MockCommunication"  #/Users/apple/Desktop/Mock_Download/MockCommunication
native_relative_path_mocksdk = "MockCommunication/MockCommunication.xcodeproj"
native_path_replace = native_path+"/BZS/ReplaceFiles" #/Users/apple/Desktop/Mock_Download/ReplaceFiles
native_path_scp = native_path+"/BZS/SCP"  #/Users/apple/Desktop/Mock_Download/SCP

if is_Biz == 1
    native_path_mocksdk = native_path+"/BZS/MockCommunication"  #/Users/apple/Desktop/Mock_Download/MockCommunication
    native_relative_path_mocksdk = "MockCommunication/MockCommunication.xcodeproj"
    native_path_replace = native_path+"/BZS/ReplaceFiles" #/Users/apple/Desktop/Mock_Download/ReplaceFiles
    native_path_scp = native_path+"/BZS/SCP"  #/Users/apple/Desktop/Mock_Download/SCP
else
    native_path_mocksdk = native_path+"/YQT/MockCommunication"  #/Users/apple/Desktop/Mock_Download/MockCommunication
    native_relative_path_mocksdk = "MockCommunication/MockCommunication.xcodeproj"
    native_path_replace = native_path+"/YQT/ReplaceFiles" #/Users/apple/Desktop/Mock_Download/ReplaceFiles
    native_path_scp = native_path+"/YQT/SCP"  #/Users/apple/Desktop/Mock_Download/SCP
end
fcontrol.dir_rm(scp_path+'/'+'MockCommunication')
copyFils = File::basename(native_path_mocksdk)
copyFullPath = scp_path+'/'+copyFils
fcontrol.dir_rm(copyFullPath)
if File.exist?(native_path_mocksdk)
else
    puts "$ele_fail,-1 Mock工程不存在，未找到Mock替换工程本地路径$"
    return
end
fcontrol.dir_copy(native_path_mocksdk,scp_path)
fcontrol.dir_rm(copyFullPath+'/'+'.svn')
fcontrol.dir_rm(copyFullPath+'/'+'.git')
# puts "info,1,拷贝MockCommunication到Scp完毕"

# 将Mock sdk 添加到workspace

# puts "info,1,开始添加MockCommunication工程依赖到SCP workspace"

addFrameworkInstance = AddFramework.new
addFrameworkInstance.addProjectDependence(scp_ws_path,native_relative_path_mocksdk)

# puts "info,1,添加MockCommunication工程依赖到SCP workspace 完毕"

# puts "info,1,开始添加Framework & bundle 到SCP 主工程的依赖"

if target_project != ""
    dest = scp_main_project[target_project]["path"]
    if dest == ""
        puts "$ele_fail,-103,工程信息读取异常，SCP工程未找到对应的主工程路径$"
        return
    end
    addFrameworkInstance.addFrameworks(dest,"MockCommunication.framework","BUILT_PRODUCTS_DIR")
    addFrameworkInstance.addBundle(dest,"MockBundle.bundle","BUILT_PRODUCTS_DIR")
else
    for item in scp_main_project_list
        dest = item["path"]
        name = item["name"]
        addFrameworkInstance.addFrameworks(dest,"MockCommunication.framework","BUILT_PRODUCTS_DIR")
        addFrameworkInstance.addBundle(dest,"MockBundle.bundle","BUILT_PRODUCTS_DIR")
    end
end

# puts "info,1,添加Framework & bundle 到SCP 主工程的依赖完毕"


#拷贝 MockFramework 和bundle 到 SCP

# puts "info,1,开始拷贝 MockFramework & bundle 到TChat/TChat/SCP 目录"
tchat_scp_files = fcontrol.searchPathByTag(tchat_path,"SCP_MainUI.framework")

if tchat_scp_files.count == 0
    puts "$ele_fail,-108,工程信息读取异常，未找到TChatScp库存放路径$"
    return
end
tchat_scp_file = File.expand_path("..", tchat_scp_files[0])

puts tchat_scp_file

puts "mmmmmmmmmmm"
if File.directory?(tchat_scp_file)

else
    # fcontrol.makeDir(tchat_scp_file)
    puts "$ele_fail,-108,工程信息读取异常，未找到TChatScp库存放路径$"
    return
end

target_paths=fcontrol.readFiles(native_path_scp)
puts target_paths
for target_path in target_paths
    fcontrol.dir_copy(target_path,tchat_scp_file)
end
# puts "info,1,拷贝 MockFramework & bundle 到TChat/TChat/SCP 目录完毕"

#添加tchat 工程依赖
# puts "info,1,开始添加Framework & bundle 到TChat 主工程的依赖"

if target_project != ""
    dest = tchat_main_project[target_project]["path"]
    relative_path = fcontrol.getRelativePath(tchat_scp_file,dest)

    if dest == ""
        puts "$ele_fail,-104,工程信息读取异常，TChat工程未找到对应的主工程路径$"
        return
    end
    for target_path in target_paths
        fileName = File::basename(target_path);
        if fileName.include?(".framework")

            addFrameworkInstance.addFrameworks(dest,relative_path+fileName,"")
        end
        if fileName.include?(".bundle")
            addFrameworkInstance.addBundle(dest,relative_path+fileName,"")
        end
    end
else
    puts "kkkkkkkkkkkkk111111"

    for item in tchat_main_project_list
        dest = item["path"]
        puts "kkkkkkkkkkkkk"
        relative_path = fcontrol.getRelativePath(tchat_scp_file,dest)
        # puts dest
        for target_path in target_paths
            fileName = File::basename(target_path);
            if fileName.include?(".framework")
                addFrameworkInstance.addFrameworks(dest,relative_path+fileName,"")
            end
            if fileName.include?(".bundle")
                addFrameworkInstance.addBundle(dest,relative_path+fileName,"")
            end
        end
    end
end

# puts "info,1,添加Framework & bundle 到TChat 主工程的依赖完毕"

# SSRootApp+Config  加入Function注册
# puts "info,1,开始注册GetApiFakerFunction事件"
modify_fileName = fcontrol.searchPath(tchat_path,"SSRootApp+Config.m")
issert_buffer = "[[ProductInterfaceUtil sharedManager] registFunction:[[NSClassFromString(@\"GetApiFakerFunction\") alloc] init]];"

if modify_fileName.count == 0
    # puts "000000000"
    issert_buffer = "[[NSClassFromString(@\"GetApiFakerFunction\") alloc] init]"
    modify_fileName_oaplugin = fcontrol.searchPath(tchat_path,"OAPlugin+Mock.m")
    if modify_fileName_oaplugin.count==0
        if File.directory?(tchat_path+"/TChat/TChat/Mock")
            puts "目录存在"
            puts native_path_replace
            puts tchat_path+"/TChat/TChat/Mock"
        else
            puts "目录不存在"
            fcontrol.makeDir(tchat_path+"/TChat/TChat/Mock")
            # fcontrol.copy_dir_item(native_path_replace,tchat_path+"/TChat/TChat")
        end
        begin
            fcontrol.copy_dir_item(native_path_replace,tchat_path+"/TChat/TChat/Mock")
        rescue => exception
            puts "$ele_fail,-1"+exception+"$"
            return 
        end


        oaplugin_ext = fcontrol.readFiles(tchat_path+"/TChat/TChat/Mock")
        puts oaplugin_ext
        if oaplugin_ext.count == 0
            puts "$ele_fail,-1,您的银企通产品版本过低，没有包含OAPlugin+Custom.m，无法为您注册GetApiFakerFunction，请手动在OAPlugin.m中注册$"
            return
        end
        for item in oaplugin_ext 
            puts item
            oa_fileName = File::basename(item);
            puts oa_fileName
            for item2 in tchat_main_project_list
                dest = item2["path"]
                puts "hhhhhhhhhhhhhhhhhhh"
                # relative_path = fcontrol.getRelativePath(File.dirname(item),File::dirname(dest))
                # relative_path = fcontrol.getRelativePath(item,dest)
                relative_path = fcontrol.getRelativePath(File.dirname(item),dest)

                puts "relative_path"

                puts relative_path
                addFrameworkInstance.addGroupRef(dest,File::basename(item),"Mock",relative_path[0,relative_path.length-1],"")
            end

            for item3 in scp_main_project_list 
                dest = item3["path"]
                puts dest
                puts "iiiiiiiiiiiiiiiiii1"
                # relative_path = fcontrol.getRelativePath(File.dirname(item),File::dirname(dest))
                # relative_path = fcontrol.getRelativePath(item,dest)
                relative_path = fcontrol.getRelativePath(File.dirname(item),dest)
                puts "relative_path"
                puts relative_path
                puts relative_path[0,relative_path.length-1]
                puts "iiiiiiiiiiiiiiiiii2"

                addFrameworkInstance.addGroupRef(dest,File::basename(item),"Mock",relative_path[0,relative_path.length-1],"")

                # addFrameworkInstance.addGroupRef(dest,"Mock"+"/"+File::basename(item),"Mock","")
            end
            puts "----------"
        end
        # puts "$ele_fail,-1,您的银企通产品版本过低，没有包含OAPlugin+Custom.m，无法为您注册GetApiFakerFunction，请手动在OAPlugin.m中注册$"
        # return
    else
        puts "OAPlugin+Mock 已包含"
        # for item in modify_fileName_oaplugin
        #     # puts item
        #     bbb = File.open(item,'r+')
        #     # puts bbb.read()
        #     if bbb.include?("GetApiFakerFunction")
        #         puts "已包含注册事件"
        #     else
        #         allBuffer = ""
        #         puts item
        #         File.open(item,'r+').each_line do |line|
        #             # puts allBuffer
        #             if line.include?("nil") and line.include?("return")
        #                 allBuffer << "\t"
        #                 allBuffer << "return @["+issert_buffer+"];"
        #                 allBuffer << "\n"
        #                 next
        #             else
        #                 if line.include?("@[") and line.include?("return")
        #                     allBuffer << "\t"
        #                     allBuffer << "return @["+issert_buffer+","
        #                     next
        #                 end
        #             end
        #             allBuffer << line
    
        #         end
        #         if allBuffer.include?("GetApiFakerFunction")
        #             File.open(item,'w+'){|f|f << allBuffer}
        #         else
        #             puts "$ele_fail,-105, OAPlugin+Custom 修改失败，版本过低，请手动去OAPlugin中注册GetApiFakerFunction$"
        #         end

        #     end
        # end
    end
else
    # puts "11111111"
    if modify_fileName.count==0
        puts "$ele_fail,-1,您的伴正事产品版本过低，没有包含SSRootApp+Config.m，无法为您注册GetApiFakerFunction$"
        return
    end
    for item in modify_fileName
        # puts item
        bbb = File.open(item,'r+')
        if bbb.read().include?(issert_buffer)
            puts "已包含注册事件"
        else
            allBuffer = ""
            puts item
            File.open(item,'r+').each_line do |line|
                allBuffer << line
                # puts allBuffer
                if line.include?("getNetworkEnvConfigWithType:")
                    allBuffer << "\t"
                    allBuffer << issert_buffer
                    allBuffer << "\n"
                end
            end
            # puts allBuffer
            if allBuffer.include?("GetApiFakerFunction")
                File.open(item,'w+'){|f|f << allBuffer}
            else
                puts "$ele_fail,-105,SSRootApp+Config 修改失败，请手动设置$"
            end
            # File.open(item,'w+'){|f|f << allBuffer}
        end
    end
end
puts "info,1,注册GetApiFakerFunction事件完毕"





require File.expand_path('../filecontrol',__FILE__)
require File.expand_path('../read_ws_info',__FILE__)


src = ARGV[0].dup   #根目录 /Users/apple/Desktop/网银/IOS
puts src

if src == nil
    puts "$ele_fail,-99,参数错误 无效的根路径$"
    return
end

reader = ReadWSInfo.new
all_info = reader.get_ws_info(src)
if all_info.count==0
    puts "$ele_fail,-1,读取工程信息失败$"
    return
end
scp_path = all_info["SCP"]["path"] #SCP根目录 /Users/apple/Desktop/网银/IOS/SCP_iOS_Trunk

if scp_path == nil
    puts "$ele_fail,-1,读取工程信息失败,未找到SCPRoot$"
    return
end

if scp_path == ""
    puts "$ele_fail,-1,读取工程信息失败,未找到SCPRoot$"
    return
end
fcontrol = FileControl.new

if File.exist?(scp_path+"/MockCommunication")
else
    puts "$ele_fail,-1 创建工程失败,MockCommunication工程不存在$"
    return
end
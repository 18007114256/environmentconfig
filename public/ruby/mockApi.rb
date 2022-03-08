require File.expand_path('../read_ws_info',__FILE__)
require 'rexml/document'

src = ARGV[0].dup   #根目录 /Users/apple/Desktop/网银/IOS

mock_host_url = ARGV[1].dup  #url  10.1.30.2
mock_apis_str = ARGV[2].dup   #'message.bindDeliveryToken,user.getOrganizationInfo,user.getaaa'

if src == nil
    puts "$ele_fail,-99,参数错误 无效的根路径$"
    return
end

if mock_host_url == nil
    puts "$ele_fail,-99,参数错误 无效的Mock url$"
    return
end

if mock_apis_str == nil
    mock_apis_str = ""
    puts "$waring,1,参数错误 无效的Mock apis$"
end

env_value = ENV["HOME"]   
puts src
# puts mock_host_url
# puts mock_apis_str
mock_apis = mock_apis_str.split(",")
# puts mock_apis

# puts "info,1,开始读取工程配置"
reader = ReadWSInfo.new
all_info = reader.get_ws_info(src)
if all_info.count==0
    puts "$ele_fail,-1,读取工程信息失败$"
    return
end
scp_path = all_info["SCP"]["path"] #SCP根目录 /Users/apple/Desktop/网银/IOS/SCP_iOS_Trunk
# puts scp_path
scp_ws_path = all_info["SCP"]["ws_path"] #SCP wrokspace路径   /Users/apple/Desktop/网银/IOS/SCP_iOS_Trunk/TChatWorkSpace.xcworkspace
# puts scp_ws_path
scp_ws_name = File::basename(scp_ws_path,".xcworkspace");
# puts scp_ws_name

tchat_path = all_info["TChat"]["path"] #SCP根目录 /Users/apple/Desktop/网银/IOS/TChat_iOS_Trunk
# puts tchat_path

# puts "info,1,读取工程配置完毕"

fcontrol = FileControl.new

# puts "info,1,开始修改MockConfig.plist"

scp_modify_plist = fcontrol.searchPath(scp_path,"MockConfig.plist")
if scp_modify_plist.count==0
    puts "$ele_fail,-1,未找到MockConfig.plist,无法为您修改挡板配置文件$"
    return
end
# puts scp_modify_plist
for item in scp_modify_plist
    xmlfile = File.new(item)
    doc = REXML::Document.new(File.open(item))
    root = doc.root
    root.each_element(xpath = nil){|element|
        element.each_element(xpath = nil){|element1|
            element.delete_element(element1)
        }
        puts element
        if mock_host_url != ""
            doc_url = REXML::Document.new 
            element_url_key = doc_url.add_element('key')
            element_url_key.add_text("MockHostPath")
            element.add_element(element_url_key)
            element_url_value = doc_url.add_element('string')
            # element_url_value.add_text("http://"+mock_host_url+"/Mock")
            element_url_value.add_text(mock_host_url)
            element.add_element(element_url_value)
        end
        if mock_apis.count>0
            doc_api = REXML::Document.new 
            doc_api_key = doc_api.add_element('key')
            doc_api_key.add_text("MockCMDList")
            element.add_element(doc_api_key)
            doc_api_value = doc_api.add_element('array')
            element.add_element(doc_api_value)
            num = 0
            for api_item in mock_apis
                doc_api_value_item = doc_api.add_element('string')
                doc_api_value_item.add_text(api_item)
                doc_api_value.add_element(doc_api_value_item)
                num +=1
            end
        end 
    }
    # puts root
    # puts "-------"
    # puts doc
    File.open(item,'w+'){|f|f << doc}
end
# puts "info,1,修改MockConfig.plist完毕"
# 由于bundle中的plist文件不能被代码修改，需要编译工程并拷贝bundle到SCP
# puts "info,1,开始编译SCP MockCommunication工程"
build_src = env_value+"/Library/Developer/Xcode/DerivedData"
system 'rm -r -f '+build_src+'/'+scp_ws_name+'-*'
system 'xcodebuild -scheme '+'MockCommunication -workspace '+scp_ws_path+ ' -allowProvisioningUpdates -configuration Debug'
# puts "info,1,编译SCP MockCommunication工程完毕"
# puts "info,1,开始拷贝 MockFramework & bundle 到 TChat/SCP"
build_root_file = fcontrol.search_file_tag(build_src,scp_ws_name)
# puts "build_root_file="+build_root_file
mockBundle_path = build_src+"/"+build_root_file+"/Build/Products/Debug-iphoneos/MockBundle.bundle"
if File.directory?(mockBundle_path)
else
    puts "$ele_fail,MockBundle.bundle 不存在，您的工程可能存在编译问题,请手动编译工程$"
    return
end
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
fbdest = tchat_scp_file
fcontrol.dir_copy(mockBundle_path,fbdest)
puts "info,1,拷贝 MockFramework & bundle 到 TChat/SCP完毕"

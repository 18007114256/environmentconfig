require File.expand_path('../filecontrol',__FILE__)
require 'xcodeproj'

class ReadWSInfo
    def get_ws_info(path)
        puts "aaaaa"
        puts path
        all_info = {}
        filecontrol = FileControl.new;
        ws_path = path
        if ws_path == ""
            puts "根路径为空"
        end
        root_files = filecontrol.readFiles(ws_path)
        if root_files.count == 0
            puts "$ele_fail,-97,根目录下没有文件$"
            return all_info
        end
        target_files = []
        for item in root_files
            tmp = filecontrol.searchPathByTag(item,".xcworkspace")
            puts tmp.count
            if tmp.count>0
                target_files << item
            end
        end
        puts "==========="
        puts target_files
        puts "==========="
        scp_ws = {}
        tchat_ws = {}
        puts "aaaaa"
        root_files = target_files
        if root_files.count == 2
            targetFile1 = root_files[0];
            targetFile2 = root_files[1];
            targetFile1_files = filecontrol.readFiles(targetFile1)
            targetFile2_files = filecontrol.readFiles(targetFile2)
        
            #  判断哪个是scp 哪个是trunk
            scp = ""
            tchat = ""
        
            if targetFile1_files.count > targetFile2_files.count
                scp =  targetFile1
                tchat = targetFile2;
                scp_ws["root"] = ws_path
                scp_ws["count"] = targetFile1_files.count
                scp_ws["path"] = targetFile1
                scp_ws["ws_path"] = filecontrol.get_file_list(targetFile1,".xcworkspace",".xcodeproj")[0]
                scp_ws["root_file"] = File::basename(targetFile1)

                scp_sub_files =  filecontrol.readFiles(scp)
                puts scp_sub_files 
                scp_main_project = {}

                for subItem in scp_sub_files
                    if subItem.include?("BaiDuMapView") or subItem.include?("sm2Demo") or subItem.include?("CommunicationAdapter") or subItem.include?("ContactBaseLib")  or subItem.include?("DataBackupLib")
                        next
                    end
                    if subItem.include?("IDssBase") or subItem.include?("LoginControlLib") or subItem.include?("MockCommunication")
                        next
                    end
                    if subItem.include?("SCP_A") or subItem.include?("SCP_B")  or subItem.include?("SCP_C") or subItem.include?("SCP_D") or subItem.include?("SCP_F")
                        next
                    end
                    if subItem.include?("SCP_G") or subItem.include?("SCP_I") or subItem.include?("SCP_L")  or subItem.include?("SCP_M") or subItem.include?("SCP_N") or subItem.include?("SCP_P")
                        next
                    end
                    if subItem.include?("SCP_Q") or subItem.include?("SCP_T") or subItem.include?("SCP_U")  or subItem.include?("SCP_V") or subItem.include?("SCP_W") or subItem.include?("SCP_R")
                        next
                    end
                    if subItem.include?("sqlite3_toLib") or subItem.include?("Pods")
                        next
                    end
                    
                    sub_project = {}
                    
                    xcodeproj_path = filecontrol.get_file_list(subItem,".xcodeproj","")[0]
                    puts "=======00000"

                    puts subItem

                    puts "=======11111"
                    puts xcodeproj_path
                    puts "&&&&&"
                    if xcodeproj_path == nil and  subItem.include?(".xcodeproj")
                        xcodeproj_path = subItem
                    end
                    if xcodeproj_path != nil
                        puts "&&&&&1111111"

                        if xcodeproj_path.include?(".xcodeproj")
                            puts "&&&&&1111111333333"
                            project = Xcodeproj::Project.open(xcodeproj_path)
                            target = project.native_targets[0]
                            xc_build_configration = target.build_configurations[0]
                            puts  xc_build_configration
                            # puts xc_build_configration.buildSettings
                            appIcon = xc_build_configration.resolve_build_setting("ASSETCATALOG_COMPILER_APPICON_NAME",root_target = nil, previous_key = nil)

                            # puts appIcon + "appIcon"
                            if appIcon != nil
                                puts "&&&&&111111133333344444"

                                # puts xcodeproj_path
                                # puts appIcon
                                sub_project["path"] = xcodeproj_path
                                project_name = File::basename(xcodeproj_path,".xcodeproj");
                                sub_project["name"] = project_name
                                scp_main_project[project_name]=sub_project
                                # puts mian_project
                            end
                        end
                    end
                end
                scp_ws["main_project"] = scp_main_project
        
                tchat_ws["root"] = ws_path
                tchat_ws["count"] = targetFile2_files.count
                tchat_ws["path"] = targetFile2
                tchat_ws["ws_path"] = filecontrol.get_file_list(targetFile2,".xcworkspace",".xcodeproj")[0]
                tchat_ws["root_file"] = File::basename(targetFile2)

                tchat_sub_files =  filecontrol.readFiles(tchat)
                # puts scp_sub_files 
                tchat_main_project = {}
                for subItem in tchat_sub_files
                    sub_project = {}
                    xcodeproj_path = filecontrol.get_file_list(subItem,".xcodeproj","")[0]
                    # puts "======="
                    # puts xcodeproj_path
                    # puts "&&&&&"
                    if xcodeproj_path == nil and  subItem.include?(".xcodeproj")
                        xcodeproj_path = subItem
                    end
                    if xcodeproj_path != nil
                        if xcodeproj_path.include?(".xcodeproj")
                            project = Xcodeproj::Project.open(xcodeproj_path)
                            target = project.native_targets[0]
                            xc_build_configration = target.build_configurations[0]
                            appIcon = xc_build_configration.resolve_build_setting("ASSETCATALOG_COMPILER_APPICON_NAME",root_target = nil, previous_key = nil)
                            if appIcon != nil
                                # puts xcodeproj_path
                                # puts appIcon
                                sub_project["path"] = xcodeproj_path
                                project_name = File::basename(xcodeproj_path,".xcodeproj");
                                sub_project["name"] = project_name
                                tchat_main_project[project_name]=sub_project
                                # puts mian_project
                            end
                        end
                    end
                end
                tchat_ws["main_project"] = tchat_main_project
        
            else

                scp =  targetFile2
                tchat = targetFile1;
                tchat_ws["root"] = ws_path
                tchat_ws["count"] = targetFile1_files.count
                tchat_ws["path"] = targetFile1
                tchat_ws["ws_path"] = filecontrol.get_file_list(targetFile1,".xcworkspace",".xcodeproj")[0]
                tchat_ws["root_file"] = File::basename(targetFile1)

                tchat_sub_files =  filecontrol.readFiles(tchat)
                puts scp_sub_files 
                tchat_main_project = {}
                for subItem in tchat_sub_files
                    sub_project = {}
                    xcodeproj_path = filecontrol.get_file_list(subItem,".xcodeproj","")[0]
                    puts "=======222222"
                    # puts xcodeproj_path
                    # puts "&&&&&"
                    if xcodeproj_path == nil and  subItem.include?(".xcodeproj")
                        xcodeproj_path = subItem
                    end

                    puts "========181"
                    puts xcodeproj_path
                    puts subItem

                    if xcodeproj_path != nil

                        if xcodeproj_path.include?(".xcodeproj")
                            puts "========188"

                            project = Xcodeproj::Project.open(xcodeproj_path)
                            target = project.native_targets[0]
                            xc_build_configration = target.build_configurations[0]
                            appIcon = xc_build_configration.resolve_build_setting("ASSETCATALOG_COMPILER_APPICON_NAME",root_target = nil, previous_key = nil)
                            puts "========appIcon"

                            if appIcon != nil
                                # puts xcodeproj_path
                                # puts appIcon
                                sub_project["path"] = xcodeproj_path
                                project_name = File::basename(xcodeproj_path,".xcodeproj");
                                sub_project["name"] = project_name
                                tchat_main_project[project_name]=sub_project
                                # puts mian_project
                            end
                        end
                    end
                end
                tchat_ws["main_project"] = tchat_main_project
        
                scp_ws["root"] = ws_path
                scp_ws["count"] = targetFile2_files.count
                scp_ws["path"] = targetFile2
                scp_ws["ws_path"] = filecontrol.get_file_list(targetFile2,".xcworkspace",".xcodeproj")[0]
                scp_ws["root_file"] = File::basename(targetFile2)

                scp_sub_files =  filecontrol.readFiles(scp)
                # puts scp_sub_files 
                scp_main_project = {}
                for subItem in scp_sub_files
                    if subItem.include?("BaiDuMapView") or subItem.include?("sm2Demo") or subItem.include?("CommunicationAdapter") or subItem.include?("ContactBaseLib")  or subItem.include?("DataBackupLib")
                        next
                    end
                    if subItem.include?("IDssBase") or subItem.include?("LoginControlLib") or subItem.include?("MockCommunication")
                        next
                    end
                    if subItem.include?("SCP_A") or subItem.include?("SCP_B")  or subItem.include?("SCP_C") or subItem.include?("SCP_D") or subItem.include?("SCP_F")
                        next
                    end
                    if subItem.include?("SCP_G") or subItem.include?("SCP_I") or subItem.include?("SCP_L")  or subItem.include?("SCP_M") or subItem.include?("SCP_N") or subItem.include?("SCP_P")
                        next
                    end
                    if subItem.include?("SCP_Q") or subItem.include?("SCP_T") or subItem.include?("SCP_U")  or subItem.include?("SCP_V") or subItem.include?("SCP_W") or subItem.include?("SCP_R")
                        next
                    end
                    if subItem.include?("sqlite3_toLib") or subItem.include?("Pods")
                        next
                    end
                    if subItem.include?("SCP_S") or subItem.include?("EUserUI")
                        next
                    end

                    sub_project = {}
                    xcodeproj_path = filecontrol.get_file_list(subItem,".xcodeproj","")[0]
                    if xcodeproj_path == nil and  subItem.include?(".xcodeproj")
                        xcodeproj_path = subItem
                    end
                    if xcodeproj_path != nil
                        if xcodeproj_path.include?(".xcodeproj")
                            project = Xcodeproj::Project.open(xcodeproj_path)
                            target = project.native_targets[0]
                            xc_build_configration = target.build_configurations[0]
                            appIcon = xc_build_configration.resolve_build_setting("ASSETCATALOG_COMPILER_APPICON_NAME",root_target = nil, previous_key = nil)
                            if appIcon != nil
                                # puts xcodeproj_path
                                # puts appIcon
                                sub_project["path"] = xcodeproj_path
                                project_name = File::basename(xcodeproj_path,".xcodeproj");
                                sub_project["name"] = project_name
                                scp_main_project[project_name]=sub_project
                                # puts mian_project
                            end
                        end
                    end
                end
                scp_ws["main_project"] = scp_main_project
            end
        
            # 读取scp工程信息
            # puts scp_ws
            # puts tchat_ws

            all_info["SCP"]=scp_ws
            all_info["TChat"]=tchat_ws
            return all_info
        else
            puts "$ele_fail,-98,根目录xcodeproj文件过多,无法为您区分SCP工程和TChat工程,请删除SCP & TChat之外包含xcodeproj的目录$"
            return all_info
        end
    end

end



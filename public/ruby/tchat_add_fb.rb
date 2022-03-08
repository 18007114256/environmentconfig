require 'xcodeproj'

class AddFramework

    def addFrameworks(dest,path,sourcetree)
        puts "开始添加Framework"
        puts dest
        puts path
        # puts "sourcetree"
        puts sourcetree
        main_project_path = ""
        main_project_target = ""
        if dest.include?".xcodeproj"
            puts "路径 已包含 .xcodeproj"
            main_project_path = dest
            main_project_target = File::basename(dest,".xcodeproj")
        else
            main_project_path = dest+".xcodeproj"
            main_project_target = File::basename(dest,".xcodeproj")
        end
        # puts main_project_path
        # puts main_project_target

        add_tag = File::basename(path)
        project = Xcodeproj::Project.open(main_project_path)
        # puts "main_project_path"

        # puts main_project_path
        # puts project

        targetIndex = 0
        project.targets.each_with_index do |target, index|
            if target.name  == main_project_target
              targetIndex = index
              puts target
            end
          end
        puts targetIndex
        target = project.targets[targetIndex]
        fileRef = ""
        pro_groups = project.groups
        for pro_group in pro_groups
            for file in pro_group.files
                # puts dest
                # puts path
                # puts file
                if file.path[add_tag]
                    # puts file.path
                    fileRef = file
                end
                # puts file.path
            end
        end
        #添加xx.framework的引用
        puts " #添加xx.framework的引用"
        puts fileRef
        if fileRef == ""

            # puts "正在添加Framework"
            # puts fileRef
            file_ref = project.frameworks_group.new_file(path)
            # puts file_ref.path
            if sourcetree == ""
                #donothing
            else
                file_ref.set_source_tree(sourcetree)
            end
            # puts file_ref
            target.frameworks_build_phases.add_file_reference(file_ref) 
            project.save
        else
            puts "waring 您的工程已包含"+add_tag+",本地添加已忽略"
        end
    end
    def addBundle(dest,path,sourcetree)
        puts "开始添加Bundle"

        # puts dest
        # puts path
        # puts sourcetree
        main_project_path = ""
        main_project_target = ""
        if dest.include?".xcodeproj"
            puts "路径 已包含 .xcodeproj"
            main_project_path = dest
            main_project_target = File::basename(dest,".xcodeproj")
        else
            main_project_path = dest+".xcodeproj"
            main_project_target = File::basename(dest,".xcodeproj")
        end
        # puts main_project_path
        # puts main_project_target

        add_tag = File::basename(path)
        project = Xcodeproj::Project.open(main_project_path)
        targetIndex = 0
        project.targets.each_with_index do |target, index|
            if target.name  == main_project_target
              targetIndex = index
              puts target
            end
          end
        puts targetIndex
        target = project.targets[targetIndex]
        fileRef = ""
        pro_groups = project.groups
        for pro_group in pro_groups
            for file in pro_group.files
                # puts file
                if file.path[add_tag]
                    # puts file.path
                    fileRef = file
                end
                # puts file.path
            end
        end

        #添加xx.bundle的引用
        if fileRef == ""
            puts "正在添加bundle"

            # puts fileRef
            file_ref = project.frameworks_group.new_file(path)
            puts file_ref.path
            if sourcetree == ""
                #do nothing
            else
                # puts sourcetree
                file_ref.set_source_tree(sourcetree)
            end
            target.resources_build_phase.add_file_reference(file_ref)
            project.save
        else
            puts "waring 您的工程已包含"+add_tag+",本地添加已忽略"
        end
    end

    def addProjectDependence(ws_path,target_path)
        if ws_path.include?".xcworkspace"
            puts "参数 已包含 .xcworkspace"
        else
            ws_path = ws_path+".xcworkspace"
        end 
        if target_path.include?".xcodeproj"
            puts "参数 已包含 .xcodeproj"
        else
            target_path = target_path+".xcodeproj"
        end 
        # puts ws_path
        # puts target_path
        workspaceInstace =  Xcodeproj::Workspace.new_from_xcworkspace(ws_path)
        # 查找workspace 中是否已包含工程引用
        target_ref = ""
        for fielRef in workspaceInstace.file_references
            if fielRef.path[File::basename(target_path)]
                # puts fielRef.path
                target_ref = "has"
            end
        end
        # puts target_ref

        if target_ref == ""
            puts workspaceInstace.<<(target_path)
            workspaceInstace.save_as(ws_path)
        else
            puts "waring 您的工程已包含"+target_path+",本地添加已忽略"
        end
    end

    def addGroupRef(dest,path,groupName,groupPath,sourcetree)
        puts "开始添加文件引用"
        puts dest
        puts path
        # puts "sourcetree"
        puts sourcetree
        main_project_path = ""
        main_project_target = ""
        if dest.include?".xcodeproj"
            puts "路径 已包含 .xcodeproj"
            main_project_path = dest
            main_project_target = File::basename(dest,".xcodeproj")
        else
            main_project_path = dest+".xcodeproj"
            main_project_target = File::basename(dest,".xcodeproj")
        end
        # puts main_project_path
        # puts main_project_target

        add_tag = File::basename(path)
        project = Xcodeproj::Project.open(main_project_path)
        # puts "main_project_path"

        # puts main_project_path
        # puts project

        targetIndex = 0
        project.targets.each_with_index do |target, index|
            if target.name  == main_project_target
                puts target.name
                targetIndex = index
              puts target
            end
          end
        puts targetIndex
        target = project.targets[targetIndex]
        fileRef = ""
        puts main_project_target
        puts "$$$$$$$$"+File.join(main_project_target,'Mock')
        group = project.main_group.find_subpath(File.join(main_project_target,groupName), true)
        if groupPath != ""
            puts "设置groupPaht"
            puts groupPath
            group.set_path(groupPath)
        end
        puts "-----------1"
        puts dest
        puts group
        puts group.path
        puts "-----------2"
        group.set_source_tree('SOURCE_ROOT')
        if group.find_file_by_path(path)
            puts "已包含Mock"
        else
            file_ref = group.new_reference(path)
            target.add_file_references([file_ref])
            project.save
        end




        # pro_groups = project.groups
        # if pro_group.find_file_by_path(path)
        #     puts "已包含"+path
        # else
        #     pro_group.new_reference(path)
        #     project.save

        # end
        # for pro_group in pro_groups
        #     for file in pro_group.files
        #         # puts dest
        #         # puts path
        #         # puts file
        #         if file.path[add_tag]
        #             # puts file.path
        #             fileRef = file
        #         end
        #         puts file.path
        #     end
        # end
        # puts  "aaaaa"
        # puts fileRef
        # if fileRef == ""
        #     puts "正在添加bundle"

        #     # puts fileRef
        #     file_ref = pro_groups.frameworks_group.new_file(path)
        #     puts file_ref.path
        #     if sourcetree == ""
        #         #do nothing
        #     else
        #         # puts sourcetree
        #         file_ref.set_source_tree(sourcetree)
        #     end
        #     target.resources_build_phase.add_file_reference(file_ref)
        #     project.save
        # else
        #     puts "waring 您的工程已包含"+add_tag+",本地添加已忽略"
        # end
    end

    
    # def addFrameworksRef(dest,tag)
    #     main_project_target = File::basename(dest)
    #     puts main_project_target
    #     if dest.include?".xcodeproj"
    #         puts "路径 已包含 .xcodeproj"
    #     else
    #         dest=dest+".xcodeproj"
    #     end

    #     # 找到目标target 取第一个
    #     targetIndex = 0
    #     project.targets.each_with_index do |target, index|
    #         if target.name  == main_project_target
    #         targetIndex = index
    #         puts target
    #         end
    #     end
    #     puts targetIndex
    #     target = project.targets[targetIndex]
    #     #先判断framworks里面是否存在，然后找scp文件下是否存在
    #     # scp_group = project.frameworks_group
    #     # puts scp_group
    #     file_framework_ref = ""
    #     pro_groups = project.groups
    #     puts pro_groups
    #     for pro_group in pro_groups
    #         for file in pro_group.files
    #             puts file
    #             if file.path[tag]
    #                 puts file.path
    #                 file_framework_ref = file
    #             end
    #             puts file.path
    #         end
    #     end
    #     #添加xx.framework的引用
    #     if file_framework_ref == ""
    #         puts 'add framework' 
    #         puts file_framework_ref
    #         file_ref = project.frameworks_group.new_file(tag+".framework")
    #         puts file_ref.path
    #         file_ref.set_source_tree("BUILT_PRODUCTS_DIR")
    #         puts file_ref
    #         target.frameworks_build_phases.add_file_reference(file_ref) 
    #     end
    # end
end
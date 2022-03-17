# require File.expand_path('../searchfilepath',__FILE__)
require File.expand_path('../filecontrol',__FILE__)
require File.expand_path('../tchat_add_fb',__FILE__)

class ReplaceFile
    def addFileToProject(envSrc,src)
        filecontrol = FileControl.new
        fileName1 = "APPFileConfig"
        destFilePath = filecontrol.searchPath(src,fileName1)[0]
        repFiles = filecontrol.readFiles(envSrc)
        puts repFiles
    
        projectName = "SCP_MainUI.xcodeproj"
        projectFullPath = filecontrol.searchPath(src,projectName)[0]
        addFrameworkInstance = AddFramework.new
    
        repFiles.each do |fileItem|
            puts fileItem
    
            fileName = File::basename(fileItem)
            if fileName.include? ".se"
                puts destFilePath
                filecontrol.file_copy(fileItem,destFilePath)
                addFrameworkInstance.addGroupRef(projectFullPath,destFilePath + "/" + fileName,"","","<group>")
                puts "success"
            end
    
        end
    end
end



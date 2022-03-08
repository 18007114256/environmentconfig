# require File.expand_path('../searchfilepath',__FILE__)
require File.expand_path('../filecontrol',__FILE__)

# 替换工程中需要被替换的文件 内部根据文件名匹配，替换目标目录的所有同名文件
# 参数
# src 需要被替换的文件目录
# dest 拷贝到指定位置的目录 总目录
src = ARGV[0].dup
dest = ARGV[1].dup

puts src
puts dest


filecontrol = FileControl.new;
repFiles = filecontrol.readFiles(src)
puts repFiles

# searchFilePath =  SearchFilePath.new
repFiles.each do |fileItem|
    puts fileItem
    fileName = File::basename(fileItem)

    destFilePaths = filecontrol.searchPath(dest,fileName)

    puts destFilePaths

    destFilePaths.each do |fileItemDest| 
        puts fileItemDest
        filecontrol.dir_copy(fileItem,fileItemDest)
    end
end

# sfilePath = SearchFilePath.new

# replaceFile = Dir.
# afilePath = sfilePath.path("SSRootApp+Config.m")

# targetFilePath = sfilePath.searchPath(src,target)

# puts targetFilePath

# File.open(targetFilePath,"r").each_line do |line|
#     puts line
# end
# puts afilePath
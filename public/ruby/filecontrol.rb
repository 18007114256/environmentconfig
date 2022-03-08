require 'fileutils'
require 'find'

#  文件管理  
class FileControl
    @@ws_info={}
    # 从src 拷贝 到 dest
    def dir_copy(src,dest)
        FileUtils.cp_r(src,dest)
    end
    # 文件拷贝
    def file_copy(src,dest)
        # puts src
        # puts dest
        FileUtils.cp(src,dest)
    end

    def copy_dir_item(src,dest)
        repFiles = readFiles(src)
        puts "========="
        puts repFiles
        puts "========="

        repFiles.each do |fileItem|
            puts fileItem
            dir_copy(fileItem,dest)

            # fileName = File::basename(fileItem)
            # destFilePaths = searchPath(dest,fileName)
            # puts "=========222"

            # puts destFilePaths
            # puts "=========333"

            # destFilePaths.each do |fileItemDest| 
            #     puts fileItemDest
            # end
        end
    end

    def makeDir(src)
        FileUtils.mkdir_p(src)
    end

    def getRelativePath(pathA,pathB)
        puts pathA
        puts pathB
        arrayA = pathA.split("/")
        arrayB = pathB.split("/")
        puts arrayA
        puts arrayB
        puts arrayA.count
        puts arrayB.count

        count_a = arrayA.count-1
        count_b = arrayB.count-1

        cur = 0
        while cur <= count_a and cur <= count_b do
            if arrayA[cur] != arrayB[cur]
                break
            end
            cur += 1
        end
        puts cur
        puts arrayA[cur]
        puts arrayB[cur]

        tmp = ""
        m = cur
        while m < count_b do
            tmp += "../"
            m += 1
        end
        puts "++++++11"

        if tmp==""
            tmp = "./"
        end
        puts "++++++22"
        n = cur
        puts 
        while n <= count_a do
            puts arrayA[n]
            tmp += arrayA[n]+"/"
            n += 1
        end
        puts tmp
        puts "++++++"
        return tmp

        # i = count_b
        # for value in enumerable do
            
        # end

    end

    def dir_rm(src)
        if File.directory?(src)
            puts src
            FileUtils.rm_r(src)
        else
            puts "99999999999"
        end

    end

    def  readFiles(src)
        list=[]
        if File.directory?(src)
            Dir.foreach(src) do |filename|
                if filename != "." and filename != ".."
                    full_path =  src+"/"+filename
                    if filename.include?(".svn") or filename.include?(".git") or filename.include?(".DS_Store")
                    else
                        list << full_path
                    end
                end
                # puts filename
                # puts filename.path

            end
            return list
        else
            return list
        end
    end

    def search_file_tag(filepath,tag)
        latestFile = ""
        if File.directory?(filepath)
            # puts "Dirs:" + filepath
            Dir.foreach(filepath) do |filename|
            if filename != "." and filename != ".."
                if filename.include?tag
                    mtime = File::ctime(filepath+'/'+filename).to_i
                    mtimeNew = 0
                    if latestFile != ""
                        mtimeNew = File::ctime(filepath+'/'+latestFile).to_i
                    else
                        latestFile = filename
                        mtimeNew = File::ctime(filepath+'/'+latestFile).to_i
                    end
                    # puts mtime
                    # puts mtimeNew
    
                    if (mtimeNew < mtime)
                        latestFile = filename
                        # puts "latestFile:" + latestFile
                        # puts File::ctime(filepath+'/'+latestFile)
                        # puts File::ctime(filepath+'/'+latestFile).to_i
    
                    end
                    # puts "latestFile:" + latestFile
                    # puts File::ctime(filepath+'/'+filename).to_i
    
                end
            end
          end
          return latestFile
        else
            return latestFile
        end
    end

    def searchPath(src,fileName)
        # puts src
        list=[]
        Find.find(src) do |path|
            # puts File::basename(path)
            # puts path
            if File::basename(path) == fileName
                # puts path
                list << path
            end
        end
        return list
    end

    def searchPathByTag(src,tag)
        puts src
        list=[]
        Find.find(src) do |path|
            # puts File::basename(path)
            # puts path
            if File::basename(path).include?(tag)
                # puts path
                list << path
            end
        end
        return list
    end

    def get_file_list(path,tag,ignoreTag) 
        list=[] 
        if File.directory?(path)
            Dir.entries(path).each do |sub|         
                if sub != '.' && sub != '..'  
                  if File.directory?("#{path}/#{sub}")  
                      if ignoreTag == ""
                          if sub.include?(tag)
                              # ext = File.extname(sub)
                              # puts ext
                              # puts path+"/"+sub
                              list << path+"/"+sub
      
                          else
                              get_file_list("#{path}/#{sub}",tag,ignoreTag)  
                          end
                      else
                          if sub.include?(ignoreTag)
                              # do nothing
                          else
                              if sub.include?(tag)
                                  list << path+"/"+sub
                              else
                                  get_file_list("#{path}/#{sub}",tag,ignoreTag)  
                              end
                          end
                      end
      
                  else  
                      if sub.include?(tag)
                          list << path+"/"+sub
                      end
                  end  
                end  
              end  
        end

        return list
    end  

    def path(file)
        $LOADED_FEATURES.each{|path|
            return path if path.split('/').last == file
        } 
    end
end

#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-
require File.expand_path('../filecontrol',__FILE__)

src = ARGV[0].dup
fileName = "ProdcutionEnvConfig.m" #环境配置文件

filecontrol = FileControl.new;

filePaths = filecontrol.searchPath(src,fileName) #查找文件并返回目录列表

array = []
# 查找工程中现有的环境
IO.foreach(filePaths[0]) do |line|
     if line.include? "conType=="    
          array.push(line[line.rindex("=")+1,1])
     end
end

print string = array.join("-Env-")

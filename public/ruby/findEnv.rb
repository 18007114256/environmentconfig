#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-
require File.expand_path('../filecontrol',__FILE__)

src = ARGV[0].dup
# lastPath = "/TChat/TChat/ProdctionConfigEtc/ProdcutionEnvConfig.m"
fileName = "ProdcutionEnvConfig.m" #环境配置文件

filecontrol = FileControl.new;

filePaths = filecontrol.searchPath(src,fileName) #查找文件并返回目录列表

array = []
tempArr = []
# 查找工程中现有的环境
IO.foreach(filePaths[0]) do |line|
    line if line =~/setServerConfigEqual_/ 
    if line.index '(void)setServerConfigEqual_'
        array.push(line.reverse[2...3].reverse)
    else
        # puts ("error")
    end
end

for value in array do
    case value
    when '3'
        tempArr.push("伴正事开发环境")
    when '2'
         tempArr.push("伴正事黑盒")
    when '0'
         tempArr.push("伴正事沙盒")
    when '1'
         tempArr.push("伴正事生产")
    when '4'
         tempArr.push("伴正事阿里云生产环境（银行Sit环境）")
    when '5'
         tempArr.push("伴正事私有云沙盒环境 （银行Uat环境）")
    when '6'
         tempArr.push("伴正事私有云沙盒环境")
     else
         tempArr.push(value)
    end
 end

print string = array.join("-Env-")

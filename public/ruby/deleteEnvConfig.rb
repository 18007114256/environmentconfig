#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-
require File.expand_path('../filecontrol',__FILE__)
require File.expand_path('../tchat_add_fb',__FILE__)
require File.expand_path('../replacefile',__FILE__)
require 'xcodeproj'

src = ARGV[0].dup             #工程地址
envConfig = ARGV[1].dup       #环境名称

fileName = "ProdcutionEnvConfig.m" #环境配置文件

filecontrol = FileControl.new;

fullPath = filecontrol.searchPath(src,fileName) #查找文件并返回目录列表

arr = IO.readlines(fullPath[0])  #取出ProdcutionEnvConfig.m文件中的每一行并存入数组
lines = File.readlines(fullPath[0])   #取出ProdcutionEnvConfig.m文件中的每一行并存入数组

envMethod = "setServerConfigEqual_"+ envConfig.strip + "{"
###############################################------删除对应的配置信息------###############################################

i = 0     #定义一个数字作为要删除的行数初始下标
j = 0     #定义一个数字作为要删除的行数的最终下标

#遍历数组，根据传进来的需要删除的环境名获取需要删除的行数的初始和最终下标
for value in arr do
     if value.include? envMethod
          i = arr.index(value)
     end
     if i != 0 && j == 0 && (value.include? "(void)setServerConfigEqual_") && !(value.include? envMethod)
          j = arr.index(value)
     end
end
puts envMethod,i,j

$start = 1
#如果是最后一个环境，j等于数组的最大长度
if j == 0
    for value in arr do
        if (value.include? "(void)setNetworkConfig:(id)value") && i != 0
             j = arr.index(value)
        end
   end
end
if i == 0 && j == 0
    print "delete success"
    abort
end

#遍历需要修改的行数，并删除对应的行
begin
    lines.delete_at(i)
    $start +=1
end while i + $start < j

for value in arr do
    if (value.include? "if (conType==" + envConfig) && !(value.include? "else if")
        valueIndex = arr.index(value)
        type = arr[valueIndex + 2].chomp
        lines[valueIndex + 2] = "    if " + type[type.index("(")..type.length] << $/
        lines.delete(value)
    elsif (value.include? "else if (conType==" + envConfig)
        lines.delete(value)
    end
    if value.include? "setServerConfigEqual_" + envConfig
        lines.delete(value)
    end
end

File.open(fullPath[0], 'w') { |f| f.write(lines.join) }

puts "delete success!"




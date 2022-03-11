#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

src = ARGV[0].dup
# puts src
lastPath = "/TChat/TChat/ProdctionConfigEtc/ProdcutionEnvConfig.m"
array = []
IO.foreach(src + lastPath) do |line|
    line if line =~/setServerConfigEqual_/ #输出匹配到了'abc'的所在行 
    if line.index '(void)setServerConfigEqual_'
        array.push(line.reverse[2...3].reverse)
    else
        # puts ("error")
    end
end

tempArr = []

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

puts string = tempArr.join("-Env-")
# return string
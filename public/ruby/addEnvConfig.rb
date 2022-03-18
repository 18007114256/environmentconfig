#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-
require File.expand_path('../filecontrol',__FILE__)
require File.expand_path('../tchat_add_fb',__FILE__)
require File.expand_path('../replacefile',__FILE__)
require 'xcodeproj'

envSrc = ARGV[0].dup          #环境配置文件地址
src = ARGV[1].dup             #工程地址
envConfig = ARGV[2].dup       #环境名称

fileName = "ProdcutionEnvConfig.m" #环境配置文件

filecontrol = FileControl.new;

fullPath = filecontrol.searchPath(src,fileName) #查找文件并返回目录列表

arr = IO.readlines(fullPath[0])  #取出ProdcutionEnvConfig.m文件中的每一行并存入数组
lines = File.readlines(fullPath[0])   #取出ProdcutionEnvConfig.m文件中的每一行并存入数组

envMethod = "setServerConfigEqual_"+ envConfig.strip + "{"

secretFileValue = ""    #mstp se文件名
mstpPublicKey = ""      #mstp 加密公钥串
httpPublicKey = ""      #http加密公钥串
authServerUrl = ""      #域名端口   
secret = ""             #screct
realm = ""              #realm
resource = ""           ##idToken认证相关的clientId
configFileArray = Dir::entries(envSrc)  #所有配置文件名称

for fileName in configFileArray do
     if (fileName.include? ".se") || (fileName.include? ".pem")
          secretFileValue = (fileName.include? ".se") ? ('"' + fileName + '"') : ('"' + fileName.sub!("pem","se") + '"')
     end
     if fileName.include? "mstp.sinosun.com"
          mstpPublicKey = '"' + fileName + '"'
     end
     if fileName.include? "ts.sinosun.com"
          httpPublicKey = '"' + fileName + '"'
     end
     if fileName.include? ".txt"
          keyCloakConfigFile = fileName 
     end
     if fileName.include? ".yml"
          ymlConfigFile = fileName 
     end
end


#读取keyCloak配置文件中的参数
IO.foreach(envSrc + '/' + keyCloakConfigFile) do |line|
     if (line.include? "auth-server-url") && authServerUrl.empty?
          authServerUrl = line.strip[line.index(":")..line.length].strip.chop
     end
     if (line.include? "realm") && realm.empty?
          realm = line.strip[line.index(":")+1..line.length].strip.chop.chop
     end
     if (line.include? "resource") && resource.empty?
          resource = line.strip[line.index(":")..line.length].strip.chop
     end
     if (line.include? "secret") && secret.empty?
          secret = line.strip[line.index(":")..line.length].strip
     end
end

#读取yml文件中的配置项
tidValue = '' 							#AppTid
bsl_sm2_kid  = ''    				# BSL JWE 加密用的 kid，长度固定为 32 字符
bsl_sm2_public_key  = '' 			# BSL JWE SM2 公钥，长度固定为 128 字符。TODO：私有云的 BSL 公钥，需要配置到公有云，用于公有云内部服务访问私有云接口
bsl_sinosun_sm2_kid 	= ''		# 兆日公有云 BSL 网关的 kid
bsl_sinosun_sm2_public_key = ''	# 兆日公有云 BSL 网关的公钥
bplus_public_domain 	= ''		# 访问公有云BPlus（商云），使用的域名
sinots_publickeyfile	= ''		#安全键盘公钥加密串，软证书加密串
IO.foreach(envSrc + '/' + ymlConfigFile) do |line|
     if (line.include? "tid") && tidValue.empty?
          tidValue = '"' + line.strip[line.index(":")+1..line.length].strip + '"'    #Apptid
     end
     if line.include? "bsl_sm2_kid"
          bsl_sm2_kid = '"' + line.strip[line.index(":")+1..line.length].strip + '"'        #BSL JWE 加密用的 kid，长度固定为 32 字符
     end
     if line.include? "bsl_sm2_public_key"
          bsl_sm2_public_key = '"' + line.strip[line.index(":")+1..line.length].strip + '"'                #BSL JWE SM2 公钥，长度固定为 128 字符。TODO：私有云的 BSL 公钥，需要配置到公有云，用于公有云内部服务访问私有云接口
     end
     if line.include? "bsl_sinosun_sm2_kid"
          bsl_sinosun_sm2_kid = '"' + line.strip[line.index(":")+1..line.length].strip + '"'               #兆日公有云 BSL 网关的 kid
     end
     if line.include? "bsl_sinosun_sm2_public_key"
          bsl_sinosun_sm2_public_key = '"' + line.strip[line.index(":")+1..line.length].strip + '"'                #兆日公有云 BSL 网关的公钥
     end
     if line.include? "bplus_public_domain"
          bplus_public_domain = line.strip[line.index(":")+1..line.length].strip               #访问公有云BPlus（商云），使用的域名
     end
     if line.include? "sinots_publickeyfile"
          sinots_publickeyfile = '"' + line.strip[line.index(":")+1..line.length].strip + '"'               #安全键盘公钥加密串，软证书加密串
     end
end

#域名
serverHostValue = '"' + authServerUrl[authServerUrl.index(':')+3..authServerUrl.rindex(":")-1] + '"'
#端口
serverPortValue = '"' + authServerUrl[authServerUrl.rindex(':')+1..authServerUrl.rindex("/")-1] + '"'
#http备用域名
httpHostBackup = "[@[@" + serverHostValue + "]]"
#商旅相关地址
bplusServerAddr = '"' + bplus_public_domain[0..bplus_public_domain.rindex(":")-1] + '"'
#idToken认证相关的Authorization地址
privateAuthAddr = authServerUrl.chop + '/realms/' + realm + '/protocol/openid-connect/auth"'
#idToken认证相关的Token地址
privateTokenAddr = authServerUrl.chop + '/realms/' + realm + '/protocol/openid-connect/token"'
#idToken认证相关的clientId
privateClientIdAddr = resource
#idToken认证相关的clientSecret
privateSecretAddr = '"' + secret

#################################--------新增环境--------#################################
i = 0
j = 0
for value in arr do
    if value.include? "NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@\"auth_config\" ofType:@\"plist\"]]"
        i = arr.index(value)
    end
end

puts i,j

lines.insert(i-2,"    else if (conType==" + envConfig + ") {\n")
lines.insert(i-1,"        [self setServerConfigEqual_" + envConfig + "];\n")
lines.insert(i,"    }\n")
File.open(fullPath[0], 'w') { |f| f.write(lines.join) }
arr = IO.readlines(fullPath[0])
lines = File.readlines(fullPath[0])
for value in arr do
    if value.include? "(void)setNetworkConfig:(id)value"
        j = arr.index(value)
    end
end
#代码拼接
headStr = "    [self setNetworkConfig:@"
middleStr = " forKey:"
tailStr = "];"
k = 0
tempArr = IO.readlines("./setServerConfig.txt")
for value in tempArr do
    if value =~/setServerConfigEqual_/
        newParameter = "- (void)setServerConfigEqual_" + envConfig + "{"
        value = newParameter << $/ #将新的参数替换到对应的行中
    end
    if value =~/AppTid/
        newParameter = headStr + tidValue + middleStr + "AppTid" + tailStr #拼接新的参数
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   # if value =~/MstpPort/
   #      newParameter = headStr + mstpPortValue + middleStr + "MstpPort" + tailStr #mstp服务器端口
   #      value = newParameter << $/ #将新的参数替换到对应的行中
   # end
   # if value =~/MstpHost/
   #      newParameter = headStr + mstpHostValue + middleStr + "MstpHost" + tailStr #mstp服务器Host地址
   #      value = newParameter << $/ #将新的参数替换到对应的行中
   # end
   if value =~/PrivateServerPort/
        newParameter = headStr + serverPortValue + middleStr + "PrivateServerPort" + tailStr #http服务器端口
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/PrivateServerHost/
        newParameter = headStr + serverHostValue + middleStr + "PrivateServerHost" + tailStr #http服务器主机名
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/kEnvConfig_NetWorkConfig_EnvHTTPHostBackup/
        newParameter = headStr + httpHostBackup + middleStr + "kEnvConfig_NetWorkConfig_EnvHTTPHostBackup" + tailStr #业务服务器（TS）Host备份地址
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/MallServerAddr/
        newParameter = headStr + bplusServerAddr + middleStr + "MallServerAddr" + tailStr #商城Host地址
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/TravelServerAddr/
        newParameter = headStr + bplusServerAddr + middleStr + "TravelServerAddr" + tailStr #商旅Host地址
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/NetMeetingServerAddr/
        newParameter = headStr + bplusServerAddr + middleStr + "NetMeetingServerAddr" + tailStr #JTS会议Host地址
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   # if value =~/OfflineHost/
   #      newParameter = headStr + value + middleStr + "OfflineHost" + tailStr #mpaas离线包Host地址
   #      value = newParameter << $/ #将新的参数替换到对应的行中
   # end
   # if value =~/kEnvConfig_NetWorkConfig_EnvHTTPPathPrefix/
   #      newParameter = headStr + value + middleStr + "kEnvConfig_NetWorkConfig_EnvHTTPPathPrefix" + tailStr #http请求的网关地址，比如ssp-http，连接在http端口后面
   #      value = newParameter << $/ #将新的参数替换到对应的行中
   # end
   if value =~/kEnvConfig_NetWorkConfig_SoftCertificateVerSignPublickey/
        newParameter = headStr + sinots_publickeyfile + middleStr + "kEnvConfig_NetWorkConfig_SoftCertificateVerSignPublickey" + tailStr #软证书验签公钥
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/PrivateAuthAddr/
        newParameter = headStr + privateAuthAddr + middleStr + "PrivateAuthAddr" + tailStr #idToken认证相关的Authorization地址
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/PrivateTokenAddr/
        newParameter = headStr + privateTokenAddr + middleStr + "PrivateTokenAddr" + tailStr #idToken认证相关的Token地址
        # lines[i + $start - 1] = "" << $/
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/PrivateClientIdAddr/
        newParameter = headStr + privateClientIdAddr + middleStr + "PrivateClientIdAddr" + tailStr #idToken认证相关的clientId
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/PrivateSecretAddr/
        newParameter = headStr + privateSecretAddr + middleStr + "PrivateSecretAddr" + tailStr #idToken认证相关的clientSecret
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/MstpSecretFile/
        newParameter = headStr + secretFileValue + middleStr + "MstpSecretFile" + tailStr #mstp se文件名
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/kEncConfig_NetWorkConfig_EnvMSTPPublicKey/
        newParameter = headStr + mstpPublicKey + middleStr + "kEncConfig_NetWorkConfig_EnvMSTPPublicKey" + tailStr #mstp 加密公钥串
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/HttpSecretFile/
        newParameter = headStr + secretFileValue + middleStr + "HttpSecretFile" + tailStr #http se文件名
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/kEncConfig_NetWorkConfig_EnvHTTPPublicKey/
        newParameter = headStr + httpPublicKey + middleStr + "kEncConfig_NetWorkConfig_EnvHTTPPublicKey" + tailStr #http加密公钥串
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/JwePublicBslKid/
        newParameter = headStr + bsl_sinosun_sm2_kid + middleStr + "JwePublicBslKid" + tailStr #公有云 jwe 加密公钥ID
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/JwePublicBslKey/
        newParameter = headStr + bsl_sinosun_sm2_public_key + middleStr + "JwePublicBslKey" + tailStr #公有云 jwe 加密公钥串
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/JwePrivateBslKid/
        newParameter = headStr + bsl_sm2_kid + middleStr + "JwePrivateBslKid" + tailStr #私有云 jwe 加密公钥ID
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   if value =~/JwePrivateBslKey/
        newParameter = headStr + bsl_sm2_public_key + middleStr + "JwePrivateBslKey" + tailStr #私有云 jwe 加密公钥串
        value = newParameter << $/ #将新的参数替换到对应的行中
   end
   lines.insert(j - 1 + k,value)
   k += 1;
end
    
File.open(fullPath[0], 'w') { |f| f.write(lines.join) }


####################################----------se文件拷贝和添加引用--------####################################

addFileToProject = ReplaceFile.new
addFileToProject.addFileToProject(envSrc,src)

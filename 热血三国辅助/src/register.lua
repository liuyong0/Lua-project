logcat("load register")

全局_注册码数据 = ""   -- 记录注册码的数据
全局_访问令牌=""       -- 记录软件的访问令牌，此数据由服务器返回
全局_项目名称 = ""     -- 记录项目的名称
全局_云应用Token = ""  -- 记录访问云应用的token数据
全局_验证次数 = 1
全局_错误信息 = ""     -- 记录错误信息
全局_机器编码 = string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),3,3)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),10,10)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-1,-1)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-5,-5)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-9,-9)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-14,-14)
全局_上次验证时间 = 0
全局_注册码剩余时间 = -1   -- 记录注册码的剩余时间
全局_软件版本号 = ""  -- 记录软件的版本号，用于自动更新
-----------------------------------------------
function decodeURI(s)
	s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
	return s
end
function encodeURI(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end

function 数据初始化(name, token, regcode, ver)
	全局_项目名称 = name
	全局_云应用Token = token
	全局_注册码数据 = regcode
	全局_软件版本号 = ver
end

-- 通信接口
function connectBBY(arg)
	Json字符串 = json.encode(arg)
	logcat ("Json字符串:" .. Json字符串)
	Json字符串 = encodeURI(Json字符串)
	params = "token=" .. 全局_云应用Token .. "&funparams=" .. Json字符串
	strUrl = "http://get.baibaoyun.com/cloudapi/cloudappapi"
	strGet= strUrl .. "?" .. params
	返回值, state = net.get(strGet)
	logcat(返回值)
	logcat(type(返回值))
	
	if state == 200 then
		全局_错误信息 = ""
		return 返回值
	end
	
	for i = 1 , 5 do
		返回值, state = net.get(strGet)
		logcat(返回值)
		if state == 200 then
			全局_错误信息 = ""
			return 返回值
		end
		
		sleep(1000)
	end
	全局_错误信息 = 返回值
	return 返回值
end

-- 获取注册码的剩余时间
function 获取注册码的剩余时间()
	if 全局_上次验证时间 == 0 then
		全局_上次验证时间 = os.time()
	end
	
	local 间隔s = os.difftime(os.time(), 全局_上次验证时间)
	if 全局_注册码剩余时间 <=0 then		 --and 间隔s > 180 then
		local command2 = {flag="查询注册码时间",机器码=全局_机器编码,注册码=全局_注册码数据,访问令牌=全局_访问令牌,项目名称 = 全局_项目名称}
		返回值 = connectBBY(command2)
		
		logcat ("线程返回的内容：" .. 返回值)
		index = string.find(返回值, "失败")
		if index ~= nil then
			logcat("检测注册码脚本运行时间失败!原因：" .. 返回值)
			全局_错误信息 = 返回值
			local errorCode = 0
			if(nil ~= string.find(返回值, "注册码不正确")) then
				errorCode = -1000
			elseif(nil ~= string.find(返回值, "注册码已经冻结")) then
				errorCode = -1001
			elseif(nil ~= string.find(返回值, "注册码已过期")) then
				errorCode = -1002
			elseif(nil ~= string.find(返回值, "注册码只能在一个客户端使用")) then
				errorCode = -1003
			elseif(nil ~= string.find(返回值, "注册码已经解绑")) then
				errorCode = -1004
			elseif(nil ~= string.find(返回值, "非法机器登录的查询")) then
				errorCode = -1005
			elseif(nil ~= string.find(返回值, "非法用户")) then
				errorCode = -1006
			end
			
			return errorCode
		end
		
		if type(返回值) == "string" then
			time1 = tonumber(返回值)
			if time1 < 0 then
				toast ("检测注册码脚本已经脚本到期。。")
				全局_错误信息 = "脚本到期"
				return -1
			end
			
			local day = math.floor(返回值/1440)
			local hour = math.floor((返回值-day*1440)/60)
			toast ("剩余时间：" ..day.."天".. hour.."小时"..(返回值%60).. "分钟",5000)
			全局_注册码剩余时间 = time1
			全局_上次验证时间 = os.time()
			全局_错误信息 = ""
			return time1
		else
			logcat ("检测注册码脚本失败，返回内容为：" .. 返回值)
			local errorCode = 0
			-- 通信错误，可能是网络问题、并发数问题、服务器问题.具体错误信息，看errMsg后面的内容
			if((nil ~= string.find(返回值, "token为空")) or (nil ~= string.find(返回值, "token不正确"))) then
				errorCode = -2000
			elseif(nil ~= string.find(返回值, "云应用未运行")) then
				errorCode = -2001
			elseif(nil ~= string.find(返回值, "并发数已满")) then
				errorCode = -2002
			elseif(nil ~= string.find(返回值, "安全验证")) then
				errorCode = -2003
			elseif(nil ~= string.find(返回值, "请求的参数格式不正确")) then
				errorCode = -2004
			elseif(nil ~= string.find(返回值, "请求失败")) then
				errorCode = -2005
			elseif(nil ~= string.find(返回值, "其他未知错误")) then
				errorCode = -2006
			else
				errorCode = -2007
			end
			
			return errorCode
		end
		
	else
		local 间隔分1 = 间隔s / 60
		logcat("间隔分1=" .. 间隔分1)
		if(间隔分1 < 0) then
			全局_错误信息 = "脚本到期"
			return -1
		else
			全局_错误信息 = ""
			return math.floor(全局_注册码剩余时间 - 间隔分1)
		end
	end
	
end

-- 进行注册码的登录验证
function 验证注册码()
	local command = {flag="注册码登录", 机器码 = 全局_机器编码, 注册码 = 全局_注册码数据, 项目名称 = 全局_项目名称}
	返回值 = connectBBY(command)
	
	local index = string.find(返回值,"成功")
	if index == nil then
		toast ("登陆失败:，原因：" ..返回值)
		logcat ("登陆失败:，原因：" ..返回值)
		sleep(1000)
		return false
	end
	
	data = xutil.split(返回值, "|")
	if xutil.isTable(data) then
		全局_访问令牌 = data[3]
	end
	return true
end


-- 发送监控消息
function 发送监控消息(名称, 消息)
	local command = {flag="插入监控数据", 注册码=全局_注册码数据,规则名称=名称, 详情=消息}
	返回值 = connectBBY(command)
	if 返回值 == "成功" then
		logcat("发送监控消息成功")
		return true
	else
		logcat("发送监控消息失败")
		return false
	end
end




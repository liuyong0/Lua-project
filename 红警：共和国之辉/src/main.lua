--------------------------------------------------
-- 脚本名称: 红警：共和国之辉
-- 脚本描述: 自动升级建筑；自动寻矿。
--------------------------------------------------
bar.position(360,0)

全局_注册码数据 = ""   -- 记录注册码的数据
全局_访问令牌=""       -- 记录软件的访问令牌，此数据由服务器返回
全局_项目名称 = ""     -- 记录项目的名称
全局_云应用Token = ""  -- 记录访问云应用的token数据
全局_验证次数 = 1
全局_错误信息 = ""     -- 记录错误信息
全局_机器编码 = string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),3,3)..string.sub(string.gsub (security.md5(systeminfo.udid()),"%D",""),10,10)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-1,-1)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-5,-5)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-9,-9)..string.sub(string.gsub(security.md5(systeminfo.udid()),"%D",""),-14,-14)
全局_上次验证时间 = 0
全局_注册码剩余时间 = -1   -- 记录注册码的剩余时间
全局_软件版本号 = ""  -- 记录软件的版本号，用于自动更新
-----------------------------------------------

-------------------验证函数----------------------
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
	if 全局_注册码剩余时间 <=0 then		--and 间隔s > 180
		local command2 = {flag="查询注册码时间",机器码=全局_机器编码,注册码=全局_注册码数据,访问令牌=全局_访问令牌}
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
			
			logcat(errorCode)
			return errorCode
		end
		
		if type(返回值) == "string" then
			time1 = tonumber(返回值)
			logcat(time1)
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
			
			logcat(type(返回值))
			logcat(返回值)
			logcat(errorCode)
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
	logcat(返回值)
	
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
-----------------验证函数结束---------------

-----------------------功能函数--------------------
function 升级司令部()
	if iscolor(38,1252,0xFF0000,95) then	--切换至基地界面
	else
		repeat
			touch.click(38,1252)
			sleep(1500)
		until iscolor(38,1252,0xFF0000,95)
	end

	touch.swipe(600,400,100,400,500)	--屏幕拖到最右边，方便确定司令部位置
	sleep(500)
	touch.swipe(600,400,100,400,500)	--屏幕拖到最右边，方便确定司令部位置
	sleep(500)
	
	--if iscolor(416,253,0xD54E4A,95) then	--点击司令部
		touch.click(386,335)
		sleep(1000)
	--end
	
	if iscolor(601,921,0x203A53,95) then	--点击升级
		touch.click(600,920)
		sleep(1000)
	end
	
	touch.click(55,60)		--返回主界面
	sleep(1000)
end


--type:升级建筑类型：铁矿厂；铜矿厂；油井；水晶工厂；钛矿厂。
--返回值：
--true：可以休眠10分钟
function 升级建筑(type)
	if iscolor(38,1252,0x00FE12,95) then	--切换至野外界面
	else
		repeat
			touch.click(38,1252)
			sleep(500)
		until iscolor(38,1252,0x00FE12,95)
	end

	touch.swipe(100,400,600,400,500)	--屏幕拖到最左边
	sleep(500)
	touch.swipe(100,400,600,400,500)	--屏幕拖到最左边
	sleep(500)

	for all = 1,3 do	--屏幕移动
		for cont = 1,10 do
			if type == "铁矿厂" then					--根据类型找到建筑位置
				isFound,x,y = find.colors({
					0xE74A3E,
					{23,-42,0xD6D5D4},
					{-13,-17,0xDA4C40}},95,1,400,719,1100)
			elseif type == "铜矿厂" then
				isFound,x,y = find.colors({
					0xF5A802,
					{-1,13,0xF8C105},
					{8,-48,0xA8A8B6}},95,1,400,719,1100)
			elseif type == "油井" then
				isFound,x,y = find.colors({
					0x972619,
					{-12,-22,0xDE533C},
					{5,-78,0x7E8589}},95,1,400,719,1100)
			elseif type == "水晶工厂" then
				isFound,x,y = find.colors({
					0x3053C3,
					{-38,-63,0x80D9F5}},95,1,400,719,1100)
			elseif type == "钛矿厂" then
				isFound,x,y = find.colors({
					0xB426C0,
					{38,-18,0x9625A2},
					{-4,-42,0xC02DCE}},95,1,400,719,1100)
			end

			if isFound then
				touch.click(x,y)		--点击建筑
				sleep(1500)
				
				if iscolor(610,989,0x6D3F07,95) then
					touch.click(55,60)
					return true
				end
				
				if iscolor(619,981,0x155E01,95) then	--如果资源不够升级
					touch.click(55,60)					--返回主界面
					sleep(1500)
					return true
				end
				
				if iscolor(608,980,0x26405B,95) then	--点击升级
					touch.click(608,980)
					sleep(1000)
					
					if iscolor(642,548,0x825F05,95) then	--如果队列最大，返回true，退出循环
						touch.click(55,60)		--返回主界面
						sleep(1000)
						return true
					end
					
					touch.click(55,60)		--返回主界面
					sleep(1500)
					
					if type == "水晶工厂" then
						return true
					end
				end--if
			end--if
		end--cont
		
		if all == 1 then			--切换至中屏
			logcat("切换至中屏")
			touch.swipe(600,400,150,400,500)	--屏幕拖到最左边
			sleep(1000)
		elseif all == 2 then	--切换至右屏
			logcat("切换至右屏")
			touch.swipe(600,400,100,400,500)	--屏幕拖到最左边
			sleep(500)
			touch.swipe(600,400,100,400,500)	--屏幕拖到最左边
			sleep(1000)
		elseif all == 3 then
			return true
		end--if
		
	end--all
end
---------------------------功能函数结束---------------------

----------------------------UI界面-------------------------
ui.newLayout("main",360)

--ui.addTextView("hh","☞设置间隔时间：",14,ui.WRAP_CONTENT,ui.MATCH_PARENT)
--ui.addEditText("time",1000,ui.WRAP_CONTENT,ui.MATCH_PARENT)
--ui.addTextView("ii","秒",ui.WRAP_CONTENT,ui.MATCH_PARENT)

--ui.newRow("451")
ui.addTextView("efe","☞选择是否升级司令部：")
ui.addSpinner("slb",{"是", "否"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.newRow("iu")

ui.addTextView("iuo","☞设置升级野外建筑优先级：")
ui.newRow("uio")
ui.addTextView("poi","		第一优先升级：")
ui.addSpinner("first",{"铁矿厂", "铜矿厂","油井","水晶工厂","钛矿厂"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.newRow("qwe")
ui.addTextView("qe","		第二优先升级：")
ui.addSpinner("second",{"铁矿厂", "铜矿厂","油井","水晶工厂","钛矿厂"},2,ui.WRAP_CONTENT,ui.MATCH_PARENT)

ui.show("main")
-------------------------UI界面结束------------------------

--获取UI结果
ui.updateResult()
slb = ui.getResult("slb")
first = ui.getResult("first")
second = ui.getResult("second")
--m_time = ui.getResult("time")

-- 主函数
function m_main()
	while true do
		toast("开始执行",600)
		sleep(1000)
		if slb == "是" then
			toast("升级司令部",1000)
			升级司令部()
		end
		
		toast("开始升级"..first,600)
		sleep(1000)
		升级建筑(first)
		
		sleep(2000)
		
		toast("开始升级"..second,600)
		sleep(1000)
		升级建筑(second)

		--toast("等待中，"..m_time.."秒后开始执行",3000)
		--sleep(m_time*1000)
		toast("等待中，10秒后开始执行",3000)
		sleep(10000)
	end
end


-- 脚本入口
function main()
	-- 软件执行的第一时间调用这个方法，用来初始化重要数据
	数据初始化("幻想三国","77a762748d995273023b45483712b781","5E0C74A18A010FB111C6731E9E29B128","4.0.0.0")
	
	-- 进行注册码的登录验证
	if 验证注册码() == false then
		toast("注册码登录失败,原因："..全局_错误信息)
		xscript.stop()
	else
		-- 开启定时器进行注册码的时间验证操作。
		--setTrigger.timeLoop(600000, "获取注册码的剩余时间()")
	end
	
	m_main()
end

-- 此行无论如何保持最后一行
main()

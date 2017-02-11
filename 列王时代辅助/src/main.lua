--------------------------------------------------
-- 脚本名称: 列王辅助
-- 脚本版本: 1.5
-- 脚本作者: ly
-- 脚本描述: 多账号自动任务(果盘、九游)
--------------------------------------------------

--------------------基本信息获取-----------------------
width,height = systeminfo.deviceSize()
xx = width/720
yy = height/1280
logcat(width,height,xx,yy)
bar.position(270*xx,0)
path = xscript.scriptDir().."lwXscript.txt"
logcat(path)
ime.set("com.surcumference.xscript/.Xkbd")
----------------------获取结束-------------------------


-----------------------功能函数------------------------
------------激活码相关函数------------
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

-- 脚本入口
function main()
	ui.updateResult()
	local password = ui.getResult("bhu")
	if password ~=nil then
		if string.len(password) == 32 then
			xutil.writeToFile(路径, password)
		end
	end
	
	logcat(路径)
	if xutil.isFileExists(路径) then
		logcat(路径)
		file,err = io.open(路径,"rw")
		logcat(err)
		password = xutil.readFileAll(路径)
		io.close()
	end



	-- 软件执行的第一时间调用这个方法，用来初始化重要数据
	数据初始化("幻想三国","77a762748d995273023b45483712b781",password,"4.0.0.0")
	
	-- 进行注册码的登录验证
	if 验证注册码() == false then
		toast("注册码登录失败,原因："..全局_错误信息)
		xscript.stop()
	else
		-- 开启定时器进行注册码的时间验证操作。
		setTrigger.timeLoop(600000, "获取注册码的剩余时间()")
		setTrigger.timeLoop(50000, "judge()")
	end
	
	获取注册码的剩余时间()
	
	m_main()
end
-----------激活码相关函数结束--------

----------------主要函数---------------
function fuzhi()						--复制ID
	system.setClip(全局_机器编码)
	toast("ID复制成功")
end

function sm()			--使用说明
	ui.newLayout("shuoming",360)
	ui.setTitleText("shuoming","使用说明")
	ui.addTextView("uiu","使用须知：")
	ui.setTextColor("uiu",0xFF0000)
	ui.addTextView("aaa","1.此脚本暂时只适用于720*1280分辨率，320DPI。\n2.第一次使用请先点击“激活码注册”，然后复制ID交给宣传代理购买或试用。")
	ui.addTextView("bbb","3.获取激活码后，运行脚本，点击“输入账号”，将账号保存至文件，然后点击“继续”，在弹出的激活界面输入激活码完成验证。")
	ui.addTextView("yuy","脚本说明：")
	ui.setTextColor("yuy",0xFF0000)
	ui.addTextView("tyt","1.脚本运行前请先完全退出游戏。\n2.脚本运行过程中请勿触摸屏幕，以免干扰脚本运行。\n3.请保证兵营和战车工坊已建造，并处于新手教程默认位置，否则无法正常造兵造车。")
	ui.show("shuoming")
end

function input()				--账号写入文件
	ui.newLayout("login",360)
	ui.setTitleText("login","账号输入")
	ui.addButton("baocun","保存账号",80,40)
	ui.setOnClick("baocun","toFile()")
	ui.addTextView("shuomin","输入完毕后一定要点击保存账号")
	ui.newRow("000")
	for i=1,10 do
		ui.addEditText("账号"..i,"account"..i,150,40)
		ui.addEditText("密码"..i,"password"..i,150,40)
	end
	ui.show("login")
end

function toFile()
	ui.updateResult()
	local 路径1 = xscript.scriptDir().."账号密码.txt" 
	xutil.writeToFile(路径1)

	for j=1,10 do
		local 账号 = ui.getResult("账号"..j)
		local 密码 = ui.getResult("密码"..j)
		xutil.appendToFile(路径1, 账号, "\n", 密码,"\n")
		io.close()
	end
	toast("账号已保存")
end

--账号切换登录.  
--参数han:读取第几个账号
--返回值：1：成功登陆	0：已是最后一个账号
function accountSwitch(han)	
	local 路径1 = xscript.scriptDir().."账号密码.txt" 
	local flag = xutil.isFileExists(路径1)		--判断账号是否写入
	if flag then 
		io.open(路径,"rb")
	else
		toast("账号未写入文件，请先输入账号")
		xscript.stop()
	end

	nowrun = app.getFront()				--判断是否处于游戏界面
	if nowrun ~= apkname then
		app.start(apkname)
		if 游戏端 == "果盘版" then
			repeat
				sleep(1000)
				if goend then		--异常处理
					break
				end
			until iscolor(739*yy,495*xx,0xFF6000,98)
		elseif 游戏端 == "九游版" then
			repeat
				sleep(1000)
				if goend then		--异常处理
					break
				end
			until iscolor(553*yy,503*xx,0xFF8200,98)
			sleep(1000)
		end
	end

	account = xutil.readFileLine(路径1,han*2-1)	--读取账号密码
	password = xutil.readFileLine(路径1,han*2)
	logcat(account)
	logcat(password)	
	
	local ac		--用于判断输入账号是否成功
	local pc		--用于判断输入密码是否成功
	
	if 游戏端 == "果盘版" then
		if iscolor(852*yy,330*xx,0xFFFFFF,98) then		--输入账号
			touch.click(800*yy,195*xx)
			sleep(500)
			
			for k = 1,20 do
				key.backSpace()
			end
			
			sleep(500)
			if account ~= "account"..han then		--如果为默认账号，则一轮循环结束，重新开始
				ime.inputText(account)
				sleep(1000)
				ac = true
			else
				return 0
			end
		end
		
		if iscolor(846*yy,330*xx,0xFFFFFF,98) then		--输入密码
			touch.click(846*yy,330*xx)
			sleep(500)
			for k = 1,20 do
				key.backSpace()
			end
			
			sleep(500)
			if password ~= "password"..han then
				ime.inputText(password)
				sleep(1000)
				pc = true
			else
				return 0
			end
		end
		
		if ac then							--在输入完账号密码后点击登录
			if pc then
				if iscolor(739*yy,495*xx,0xFF6000,98) then
					touch.click(739*yy,495*xx)
					return 1
				end
			end
		end
	end
	
	if 游戏端 == "九游版" then
		if iscolor(514*yy,605*xx,0x9D9D9D,98) then	--切换到UC账号登录
			touch.click(514*yy,605*xx)
			sleep(500)
		end
		
		if iscolor(417*yy,604*xx,0xFF8400,98) then
			touch.click(417*yy,604*xx)
			sleep(500)
		end
		
		if iscolor(417*yy,604*xx,0xFFFFFF,95) then		--输入账号
			if iscolor(774*yy,269*xx,0xFFFFFF,98) then
				touch.click(774*yy,269*xx)
				sleep(500)
				for k = 1,20 do
					key.backSpace()
				end
				
				sleep(500)
				if account ~= "account"..han then		--如果为默认账号，则一轮循环结束，重新开始
					ime.inputText(account)
					sleep(1000)
					ac = true
				else
					return 0
				end
			end
			
			if iscolor(734*yy,356*xx,0xFFFFFF,98) then
				touch.click(734*yy,356*xx)
				sleep(500)
				for k = 1,20 do
					key.backSpace()
				end
			
			
				sleep(500)
				if password ~= "password"..han then		--如果为默认密码，则一轮循环结束，重新开始
					ime.inputText(password)
					sleep(1000)
					pc = true
				else
					return 0
				end
			end
		end
	
		if ac then							--在输入完账号密码后点击登录
			if pc then
				if iscolor(553*yy,503*xx,0xFF8400,98) then
					touch.click(553*yy,503*xx)
					return 1
				end
			end
		end
		
	end
	
	io.close()
end


function 自动签到()
	repeat
		if iscolor(1226*yy,305*xx,0x9F9F9F,95) then
			touch.click(1226*yy,305*xx)
			sleep(1000)
		elseif iscolor(787*yy,599*xx,0x214A00,95)	then
			touch.click(787*yy,599*xx)
			sleep(1000)
		end
		
		if goend then		--异常处理
			break
		end
	until iscolor(789*yy,597*xx,0x1B1B1B,95)
	
	sleep(1000)
	if iscolor(40*yy,38*xx,0xE6E6E6,95) then
		touch.click(40*yy,38*xx)
		sleep(1000)
	end
end

function 联盟探险()
	if iscolor(940*yy,647*xx,0xFDFDFD,95) then		--进入联盟探险界面
		touch.click(940*yy,647*xx)
		sleep(1000)
	elseif iscolor(1215*yy,683*xx,0xE6E6E6,95) then
		touch.click(1215*yy,683*xx)
		sleep(1000)
		if iscolor(940*yy,647*xx,0xFDFDFD,95) then
			touch.click(940*yy,647*xx)
			sleep(1000)
		end
	end
	
	repeat		--探险界面内操作
		if iscolor(463*yy,513*xx,0xE6E6E6,95) then
			touch.click(463*yy,513*xx)
			sleep(1000)
		elseif iscolor(92*yy,242*xx,0x000000,95) then
			touch.click(92*yy,242*xx)
			sleep(1000)
		elseif iscolor(1010*yy,230*xx,0x224C00,95) then
			touch.click(1010*yy,230*xx)
			sleep(1000)
		end

		if iscolor(696*yy,493*xx,0x214900,95) then
			touch.click(696*yy,493*xx)
			sleep(1000)
		end
		
		if goend then		--异常处理
			break
		end
	until iscolor(697*yy,407*xx,0x244C00,95)		--直到点了加速，出现确认使用金币

	sleep(1000)
	touch.click(40*yy,38*xx)
	sleep(1000)
	if iscolor(40*yy,38*xx,0xE6E6E6,95) then		--返回游戏界面
		touch.click(40*yy,38*xx)
		sleep(1000)
		touch.click(40*yy,38*xx)
		sleep(1000)
	end

end

function 自动遗迹()
	for i = 1,6 do 				--移动至画面左下角
		touch.swipe(400*yy,500*xx,400*yy,100*xx,500)
		sleep(300)
	end
	for i = 1,6 do
		touch.swipe(900*yy,600*xx,200*yy,600*xx,500)	--移动至画面右下角
		sleep(300)
	end

	touch.click(573*yy,155*xx)	--点击遗迹
	sleep(1000)
	
	repeat
		if iscolor(1041*yy,642*xx,0x1D4900,95) then	--点击“开始挑战”，“出战”
			touch.click(1041*yy,642*xx)
			sleep(1000)
			touch.click(1041*yy,642*xx)
			sleep(500)
		elseif iscolor(843*yy,503*xx,0x703F08,95) then	--胜利则继续
			touch.click(843*yy,503*xx)
			sleep(1000)
		elseif iscolor(1051*yy,678*xx,0x1A1A1A,95) then	--俘虏用完则退出
			touch.click(40*yy,38*xx)
			sleep(1000)
			break
		end
		
		if goend then		--异常处理
			break
		end
	until iscolor(726*yy,424*xx,0x214A00,95)		--直到战败
	
	sleep(1000)
	touch.click(40*yy,38*xx)
	sleep(1000)
	if iscolor(40*yy,38*xx,0xE6E6E6,95) then
		touch.click(40*yy,38*xx)
		sleep(1000)
	end
	
end

function 升级建筑()
	if iscolor(25*yy,620*xx,0xFFFFFF,95) then		--点左下角升级提示
		touch.click(25*yy,620*xx)
		sleep(1000)
	end
	
	--if iscolor(594*yy,598*xx,0xECDDBD,90) then		--点升级
		touch.click(593*yy,598*xx)
		sleep(1000)
	--end
	
	
	if iscolor(1228*yy,679*xx,0x532F08,95) then		--点建筑升级
		touch.click(1228*yy,679*xx)
		sleep(1000)
	elseif iscolor(1226*yy,680*xx,0x1A1A1A,95) then		--点建筑升级
		touch.click(40*yy,38*xx)
		sleep(1000)
	elseif iscolor(696*yy,410*xx,0x214A00,95) then		--如果是加速，点击退出
		touch.click(430*yy,200*xx)
		sleep(1000)
	end
	
	if iscolor(697*yy,409*xx,0x214A00,95) then		--如果资源不足，退出
		touch.click(40*yy,38*xx)
		sleep(1000)
		touch.click(40*yy,38*xx)
		sleep(1000)
	end

end

function 科技研究(类型)
	for i = 1,5 do 				--移动至画面左下角
		touch.swipe(635*yy,500*xx,635*yy,100*xx,500)
		sleep(400)
	end
	
	touch.down(300*yy,100*xx,0)		--上移确定车营位置
	touch.move(300*yy,600*xx,0)
	sleep(200)
	touch.up(0)
	sleep(400)

	touch.click(377*yy,250*xx)
	sleep(1000)
	
	if iscolor(725*yy,633*xx,0xE6E6E6,95) then
		touch.click(725*yy,633*xx)
		sleep(2000)
	else
		touch.click(713*yy,403*xx)
		return 0
	end
	
	logcat(类型)
	if 类型 == "经济" then
		
	elseif 类型 == "城防" then
		if iscolor(75*yy,243*xx,0x000000,95) then		--切换到城防界面
			touch.click(92*yy,243*xx)
			sleep(1000)
		end
			
	elseif 类型 == "战斗" then
		toast(类型)
		if iscolor(75*yy,325*xx,0x000000,95) then		--切换到战斗界面
			touch.click(92*yy,325*xx)
			sleep(1000)
		end
	else
		toast("esle")
	end


	for i = 1,5 do
		isFound,x,y,tb = find.colors({			--找到可升级图标
			0xFBB740,
			{0*yy,18*xx,0xFCB841},
			{8*yy,9*xx,0xFCB841}},95,155*yy,210*xx,380*yy,610*xx)
		if isFound then
			touch.click(x-20*yy,y-30*xx)
			sleep(1000)
			break
		else
			touch.swipe(900*yy,300*xx,630*yy,300*xx,500)
			sleep(500)
		end
		
		if goend then		--异常处理
			break
		end
	end	
	
	if iscolor(1214*yy,650*xx,0x532F08,95) then	--点“进行研究”
		touch.click(1214*yy,650*xx)
		sleep(1000)
		touch.click(40*yy,40*xx)
		sleep(1000)
	end
end

function resourcesCollecte()			--收集资源
	for i = 1,6 do 				--移动至画面左下角
		touch.swipe(400*yy,500*xx,400*yy,100*xx,500)
		sleep(300)
	end
	sleep(300)

	for j = 1,7 do				--开始收集资源
		repeat
			for a=1,9 do
				if goend then		--异常处理
					break
				end
				local flag5,x0,y = find.colors({
						0x6E7E7E,
						{4*yy,4*xx,0xE6E6E6},
						{-1*yy,32*xx,0x495055}},99,100*yy,125*xx,890*yy,650*xx)	--找到铁矿收获图标
				if flag5 then
					touch.click(x0,y)
					sleep(400)
					--flag1 = flase
				end
			end

			for b=1,9 do
				if goend then		--异常处理
					break
				end
				local flag2,x,y = find.colors({0x417320,{12*yy,0*xx,0x417320}},99,100*yy,125*xx,890*yy,650*xx)	--找到粮收获图标
				if flag2 then
					touch.click(x,y)
					sleep(400)
					--flag2 = flase
				end
			end

			for c=1,9 do
				if goend then		--异常处理
					break
				end
				local flag3,x,y = find.colors({0x754A20,{12*yy,0*xx,0x754A20}},99,100*yy,125*xx,890*yy,650*xx)	--找到木收获图标
				if flag3 then
					touch.click(x,y)
					sleep(400)
					--flag3 = flase
				end
			end
			
			if flag5 then			--判断是否收集完成
			else
				if flag2 then
				else
					if flag3 then
					else
						flag = true
					end
				end
			end
			
			if goend then		--异常处理
				break
			end
		until flag

		sleep(300)
		touch.swipe(700*yy,400*xx,300*yy,400*xx,300)
		sleep(500)
	end

	sleep(500)
	for k=1,3 do
		touch.down(600*yy,200*xx,1)
		sleep(100)
		touch.move(600*yy,460*xx,1)
		sleep(300)
		touch.up(1)
		sleep(500)
		
		local flag4,x,y = find.colors({0x4E7B1D,{12*yy,0*xx,0x4E7B1D}},99,100*yy,125*xx,1000*yy,650*xx)	--找到船上物资收获图标
		if flag4 then
			touch.click(x,y)
			sleep(500)
			if iscolor(686*yy,458*xx,0x204200,95) then
				touch.click(686*yy,458*xx)
				sleep(200)
			end
		end
	end
end


--函数功能：收步兵,造步兵
--参数说明：soldiersRank:造兵等级
--			0：默认等级
--			1~10：对应1~10级
function trianSoldiers1(soldiersRank)					
	for i = 1,5 do 				--移动至画面左下角
		touch.swipe(635*yy,500*xx,635*yy,100*xx,500)
		sleep(400)
	end

	sleep(300)

	touch.down(635*yy,100*xx,0)		--上移确定兵营位置
	touch.move(635*yy,500*xx,0)
	sleep(200)
	touch.up(0)
	sleep(400)

	touch.click(210*yy,390*xx)		--点击兵营(收兵或调出训练)
	sleep(1300)

	for j=1,2 do
		if iscolor(710*yy,642*xx,0xE6E6E6,98) then	--如果调出了训练，点击训练
			touch.click(710*yy,642*xx)
			sleep(1000)
		else
			touch.click(210*yy,390*xx)		--否则再次点击兵营
			sleep(1200)
		end
	end

	if soldiersRank ~= 0 then			--根据配置设置造兵等级
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)			--将等级调到1级
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(500)

		for k=1,soldiersRank-1 do				
			touch.click(110*yy,250*xx)
			sleep(300)
		end

		sleep(500)

		if iscolor(1200*yy,680*xx,0x131213,98) then	--如果设置等级超过可以造的等级，则为默认级别
			repeat
				touch.click(110*yy,550*xx)
				sleep(500)
				
				if goend then		--异常处理
					break
				end
			until (not iscolor(1200*yy,680*xx,0x131213,98))
			sleep(500)
		end
		
		sleep(500)
	end
	
		if iscolor(1200*yy,675*xx,0x764409,98) then	--如果可以训练，点击确认训练
			touch.click(1211*yy,676*xx)
			sleep(500)
		end

		if iscolor(1204*yy,681*xx,0x222222,98) then	--如果不能，点击粮食
			touch.click(880*yy,30*xx)
			sleep(500)
			
			local i = 0
			repeat
				
				local flag1,x1,y1 = find.color(0x4E2C04,98,847*yy,86,1039*yy,713*xx)	--找可用资源
				if flag1 then
					touch.click(x1,y1)
					sleep(500)
					
					local flag2,x2,y2 = find.color(0xE3BF96,98,500*yy,300*xx,800*yy,500*xx)	--找到使用资源的数量拖动条，拖动至最大
					if flag2 then 
						touch.swipe(x2,y2,800*yy,396*xx,300)
						sleep(500)
						touch.click(683*yy,518*xx)
						sleep(500)
					end
					
				else
					touch.swipe(600*yy,500*xx,600*yy,100*xx,300)		--下拉继续寻找
					sleep(500)
					i = i + 1
				end
				
				if i == 2 then
					touch.click(40*yy,220*xx)			--点击切换至木材
					sleep(500)
				elseif i == 4 then
					touch.click(40*yy,310*xx)			--点击切换至铁矿
					sleep(500)
				elseif i == 6 then
					touch.click(40*yy,390*xx)			--点击切换至晶石矿
					sleep(500)
				end
				
			until (i == 8)
			
			touch.click(40*yy,40*xx)
			sleep(500)
			
			if iscolor(1200*yy,675*xx,0x764409,98) then	--使用背包增加资源后，如果可以训练，点击确认训练
				touch.click(1211*yy,676*xx)
				sleep(500)
			elseif iscolor(1204*yy,681*xx,0x222222,98) then	--如果不能，点击退出，结束造兵
				touch.click(40*yy,40*xx)
				sleep(500)
			end
			
		end

end

function 自动骑兵(Rank)
	for i = 1,5 do 				--移动至画面左下角
		touch.swipe(635*yy,500*xx,635*yy,100*xx,500)
		sleep(400)
	end

	sleep(300)

	touch.down(635*yy,100*xx,0)		--上移确定车营位置
	touch.move(635*yy,500*xx,0)
	sleep(200)
	touch.up(0)
	sleep(400)

	touch.click(503*yy,166*xx)		--点击车营(收车或调出训练)
	sleep(1000)


	for j=1,2 do
		if iscolor(712*yy,641*xx,0xE6E6E6,98) then	--如果调出了训练，点击训练
			touch.click(712*yy,641*xx)
			sleep(500)
		else
			touch.click(680*yy,330*xx)		--否则再次点击车营
			sleep(1000)
		end
	end

	if Rank ~= 0 then			--根据配置设置造兵等级
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)		--将等级调到1级
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(500)

		for k=1,Rank-1 do
			touch.click(110*yy,250*xx)
			sleep(300)
		end

		sleep(500)

		if iscolor(1200*yy,680*xx,0x131213,98) then
			repeat
				touch.click(110*yy,550*xx)
				sleep(500)
				
				if goend then		--异常处理
					break
				end
			until (not iscolor(1200*yy,680*xx,0x131213,98))
			sleep(500)
		end
	
	end
	
	if iscolor(1200*yy,675*xx,0x764409,98) then	--如果可以训练，点击确认训练
		touch.click(1211*yy,676*xx)
		sleep(500)
	end

	if iscolor(1200*yy,675*xx,0x764409,98) then	--使用背包增加资源后，如果可以训练，点击确认训练
		touch.click(1211*yy,676*xx)
		sleep(500)
	elseif iscolor(1204*yy,681*xx,0x222222,98) then	--如果不能，点击退出，结束造车
		touch.click(40*yy,40*xx)
		sleep(500)
	end
end

function 自动弓兵(Rank)
	for i = 1,5 do 				--移动至画面左下角
		touch.swipe(635*yy,500*xx,635*yy,100,500)
		sleep(400)
	end

	sleep(300)

	touch.down(635*yy,100*xx,0)		--尝试上移，排除收资源干扰
	touch.move(635*yy,500*xx,0)
	sleep(200)
	touch.up(0)
	sleep(400)
	touch.down(635*yy,500*xx,0)		
	touch.move(635*yy,100*xx,0)
	sleep(200)
	touch.up(0)
	sleep(1000)

	touch.down(635*yy,100*xx,0)		--上移确定车营位置
	touch.move(635*yy,500*xx,0)
	sleep(200)
	touch.up(0)
	sleep(1000)
	touch.down(635*yy,100*xx,0)		--上移确定车营位置
	touch.move(635*yy,400*xx,0)
	sleep(200)
	touch.up(0)
	sleep(400)
	--touch.down(635*yy,100*xx,0)		--上移确定车营位置
	--touch.move(635*yy,400*xx,0)
	--sleep(200)
	--touch.up(0)
	--sleep(400)

	touch.click(766*yy,436*xx)		--点击车营(收车或调出训练)
	sleep(1000)


	for j=1,2 do
		if iscolor(706*yy,647*xx,0xE6E6E6,98) then	--如果调出了训练，点击训练
			touch.click(706*yy,647*xx)
			sleep(500)
		else
			touch.click(680*yy,330*xx)		--否则再次点击车营
			sleep(1000)
		end
	end

	if Rank ~= 0 then			--根据配置设置造兵等级
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)		--将等级调到1级
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(500)

		for k=1,Rank-1 do
			touch.click(110*yy,250*xx)
			sleep(300)
		end

		sleep(500)

		if iscolor(1200*yy,680*xx,0x131213,98) then
			repeat
				touch.click(110*yy,550*xx)
				sleep(500)
				
				if goend then		--异常处理
					break
				end
			until (not iscolor(1200*yy,680*xx,0x131213,98))
			sleep(500)
		end
	
	end
	
	if iscolor(1200*yy,675*xx,0x764409,98) then	--如果可以训练，点击确认训练
		touch.click(1211*yy,676*xx)
		sleep(500)
	end

	if iscolor(1200*yy,675*xx,0x764409,98) then	--使用背包增加资源后，如果可以训练，点击确认训练
		touch.click(1211*yy,676*xx)
		sleep(500)
	elseif iscolor(1204*yy,681*xx,0x222222,98) then	--如果不能，点击退出，结束造车
		touch.click(40*yy,40*xx)
		sleep(500)
	end
end


--函数功能：收车,造车
--参数说明：soldiersRank:造兵等级
--			0：默认等级
--			1~10：对应1~10级
function trianTank(tankRank)
	for i = 1,5 do 				--移动至画面左下角
		touch.swipe(635*yy,500*xx,635*yy,100*xx,500)
		sleep(400)
	end

	sleep(300)

	touch.down(635*yy,100*xx,0)		--上移确定车营位置
	touch.move(635*yy,500*xx,0)
	sleep(200)
	touch.up(0)
	sleep(400)

	touch.click(680*yy,330*xx)		--点击车营(收车或调出训练)
	sleep(1000)


	for j=1,2 do
		if iscolor(712*yy,641*xx,0xE6E6E6,98) then	--如果调出了训练，点击训练
			touch.click(712*yy,641*xx)
			sleep(500)
		else
			touch.click(680*yy,330*xx)		--否则再次点击车营
			sleep(1000)
		end
	end

	if tankRank ~= 0 then			--根据配置设置造兵等级
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)		--将等级调到1级
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(300)
		touch.swipe(95*yy,680*xx,95*yy,150*xx,200)
		sleep(500)

		for k=1,tankRank-1 do
			touch.click(110*yy,250*xx)
			sleep(300)
		end

		sleep(500)

		if iscolor(1200*yy,680*xx,0x131213,98) then
			repeat
				touch.click(110*yy,550*xx)
				sleep(500)
				
				if goend then		--异常处理
					break
				end
			until (not iscolor(1200*yy,680*xx,0x131213,98))
			sleep(500)
		end
	
	end
	
		if iscolor(1200*yy,675*xx,0x764409,98) then	--如果可以训练，点击确认训练
			touch.click(1211*yy,676*xx)
			sleep(500)
		end

		--[[if iscolor(1204,681,0x222222,98) then	--如果不能，点击粮食
			touch.click(880,30)
			sleep(500)
		
			local i = 0
			repeat
				local flag1,x1,y1 = find.color(0x4E2C04,98,847,86,1039,713)	--找可用资源
				if flag1 then
					touch.click(x1,y1)
					sleep(500)
					
					local flag2,x2,y2 = find.color(0xE3BF96,98,500,300,800,500)	--找到使用资源的数量拖动条，拖动至最大
					if flag2 then 
						touch.swipe(x2,y2,800,396,300)
						sleep(500)
						touch.click(683,518)
						sleep(500)
					end
					
				else
					touch.swipe(600,500,600,100,300)		--下拉继续寻找
					sleep(500)
					i = i + 1
				end
				
				if i == 2 then
					touch.click(40,220)			--点击切换至木材
					sleep(500)
				elseif i == 4 then
					touch.click(40,310)			--点击切换至铁矿
					sleep(500)
				elseif i == 6 then
					touch.click(40,390)			--点击切换至晶石矿
					sleep(500)
				end
			until (i == 8)
			
			touch.click(40,40)
			sleep(500)]]
			
			if iscolor(1200*yy,675*xx,0x764409,98) then	--使用背包增加资源后，如果可以训练，点击确认训练
				touch.click(1211*yy,676*xx)
				sleep(500)
			elseif iscolor(1204*yy,681*xx,0x222222,98) then	--如果不能，点击退出，结束造车
				touch.click(40*yy,40*xx)
				sleep(500)
			end
		--end	恢复使用背包增加资源功能后，恢复此end
	
end


-------出兵采集世界资源功能函数------
--函数功能：找到资源并点击
--参数说明：types:资源类型
--返回值：false:没找到
--		  true：找到
function m_find(types)
	local isFound
	if types=="木" then
		isFound,x,y = find.colors({
			0xBD6135,
			{-6*yy,14*xx,0xC16143},
			{-12*yy,-7*xx,0xC06446}},95,108*yy,97*xx,1051*yy,658*xx)
	elseif types == "粮" then
		isFound,x,y,tb = find.colors({0xE9A640,{5*yy,-2*xx,0xCD933E}},98,108*yy,97*xx,1051*yy,658*xx)
	elseif types == "铁" then
		isFound,x,y,tb = find.colors({
			0xC1BBA8,
			{1*yy,6*xx,0xBCC5BF},
			{1*yy,12*xx,0xE6DEDD}},96,108*yy,98*xx,1051*yy,658*xx)
	end
	if isFound then
		touch.click(x,y)
		return true
	end
	
	if types == "晶石" then
		isFound1,x1,y1,tb = find.colors({
			0xB48F6D,
			{4*yy,2*xx,0x9E7B59},
			{-9*yy,12*xx,0x665652},
			{0*yy,35*xx,0xBEBAB1}},97,108*yy,98*xx,1051*yy,658*xx)--晶石
		isFound2,x2,y2 = find.colors({
			0xAF563B,
			{-17*yy,60*xx,0xCCCCAC},
			{-10*yy,60*xx,0xBBC6B1}},96,108*yy,98*xx,1051*yy,658*xx)
			
		isFound3,x3,y3 = find.colors({
			0xBA6145,
			{-24*yy,50*xx,0x9C795D},
			{-26*yy,85*xx,0x949786}},96,108*yy,98*xx,1051*yy,658*xx)
		isFound4,x4,y4 = find.colors({
			0xA64F2A,
			{6*yy,29*xx,0x6E4B38},
			{-18*yy,87*xx,0xBBBAB3}},96,108*yy,98*xx,1051*yy,658*xx)
		if isFound1 then
			touch.click(x1,y1)
		elseif isFound2 then
			touch.click(x2-15*yy,y2+15*xx)
		elseif isFound3 then
			touch.click(x3,y3)
		elseif isFound4 then
			touch.click(x4,y4)
		end
	end
	
	if 	types == "随机" then
		isFound,x,y = find.colors({
			0xBD6135,
			{-6*yy,14*xx,0xC16143},
			{-12*yy,-7*xx,0xC06446}},95,108*yy,97*xx,1051*yy,658*xx)	--木
		if isFound then
			touch.click(x,y)
			sleep(500)
			return true
		end
		
		isFound,x,y,tb = find.colors({0xE9A640,{5*yy,-2*xx,0xCD933E}},98,108*yy,97*xx,1051*yy,658*xx)--粮
		if isFound then
			touch.click(x,y)
			sleep(500)
			return true
		end
		
		isFound,x,y,tb = find.colors({
			0xC1BBA8,
			{1*yy,6*xx,0xBCC5BF},
			{1*yy,12*xx,0xE6DEDD}},96,108*yy,97*xx,1051*yy,658*xx)--铁
		if isFound then
			touch.click(x,y)
			sleep(500)
			return true
		end
		
		isFound1,x1,y1,tb = find.colors({
			0xB48F6D,
			{4*yy,2*xx,0x9E7B59},
			{-9*yy,12*xx,0x665652},
			{0*yy,35*xx,0xBEBAB1}},97,108*yy,98*xx,1051*yy,658*xx)--晶石
		isFound2,x2,y2 = find.colors({
			0xAF563B,
			{-17*yy,60*xx,0xCCCCAC},
			{-10*yy,60*xx,0xBBC6B1}},96,108*yy,98*xx,1051*yy,658*xx)
			
		isFound3,x3,y3 = find.colors({
			0xBA6145,
			{-24*yy,50*xx,0x9C795D},
			{-26*yy,85*xx,0x949786}},96,108*yy,98*xx,1051*yy,658*xx)
		isFound4,x4,y4 = find.colors({
			0xA64F2A,
			{6*yy,29*xx,0x6E4B38},
			{-18*yy,87*xx,0xBBBAB3}},96,108*yy,98*xx,1051*yy,658*xx)
		if isFound1 then
			touch.click(x1,y1)
			sleep(500)
			return true
		elseif isFound2 then
			touch.click(x2-15*yy,y2+15*xx)
			sleep(500)
			return true
		elseif isFound3 then
			touch.click(x3,y3)
			sleep(500)
			return true
		elseif isFound4 then
			touch.click(x4,y4)
			sleep(500)
			return true
		end
	end
end



--函数功能：向左找资源
--参数说明：times:移动次数
--			types:资源类型
--返回值：false:没找到
--		  true：找到
function leftFind(times,types)
	for i = 1,times do
		if goend then		--异常处理
			break
		end
		
		sleep(1000)
		touch.down(300*yy,360*xx,1)
		sleep(200)
		touch.move(950*yy,360*xx,1)
		sleep(300)
		touch.up(1)
		sleep(500)
		local flag = m_find(types)
		if flag then
			return true
		end
	end
end

function rightFind(times,types)		--向右找资源
	for i = 1,times do
		if goend then		--异常处理
			break
		end
		
		sleep(1000)
		touch.down(950*yy,360*xx,1)
		sleep(200)
		touch.move(300*yy,360*xx,1)
		sleep(300)
		touch.up(1)
		sleep(500)
		local flag = m_find(types)
		if flag then
			return true
		end
	end
end

function upFind(times,types)		--向上找资源
	for i = 1,times do
		if goend then		--异常处理
			break
		end
		
		sleep(1000)
		touch.down(600*yy,200*xx,1)
		sleep(200)
		touch.move(600*yy,600*xx,1)
		sleep(300)
		touch.up(1)
		sleep(500)
		local flag = m_find(types)
		if flag then
			return true
		end
	end
end

function downFind(times,types)		--向下找资源

	for i = 1,times do
		if goend then		--异常处理
			break
		end
		
		sleep(1000)
		touch.down(600*yy,600*xx,1)
		sleep(200)
		touch.move(600*yy,200*xx,1)
		sleep(300)
		touch.up(1)
		sleep(500)
		local flag = m_find(types)
		if flag then
			return true
		end
	end
end
---------功能函数结束---------
--函数功能：出兵采集世界资源
--参数说明：types:资源类型
function worldResoures(types)
	if iscolor(1217*yy,57*xx,0xE9E9E9,95) then
		touch.click(1217*yy,57*xx)
		sleep(3000)
	end

	local ii = 1
	local flag0
	while true do
		if goend then		--异常处理
			break
		end
		
		if ii == 1 then
			m_find(types)
			sleep(1000)
		end
		if iscolor(594*yy,589*xx,0xE6E6E6,96) then	--点击‘占领’
			touch.click(594*yy,589*xx)
			sleep(500)
		end
		
			sleep(1000)
		if iscolor(594*yy,589*xx,0xE6E6E6,96) then	--点击‘占领’
			touch.click(594*yy,589*xx)
			sleep(500)
		end
		
		if iscolor(1164*yy,625*xx,0xFFFFFF,94) then	--点击‘部队出征’
			touch.click(1164*yy,625*xx)
			sleep(800)
			if iscolor(787*yy,395*xx,0x306600,94) then	--出征部队数量最大，点击返回
				touch.click(39*yy,37*xx)
				sleep(800)
			
				if iscolor(39*yy,37*xx,0xE6E6E6,94) then	--返回
					touch.click(39*yy,37*xx)
					sleep(800)
				end
				if iscolor(1213*yy,61*xx,0xE9E9E9,94) then	--回城
					touch.click(1213*yy,61*xx)
					sleep(500)
					break
				end
			end
			
			if iscolor(1238*yy,627*xx,0x2A2A2A,94) then
				if iscolor(39*yy,37*xx,0xE6E6E6,94) then	--返回
					touch.click(39*yy,37*xx)
					sleep(800)
				end
				if iscolor(1213*yy,61*xx,0xE9E9E9,94) then	--回城
					touch.click(1213*yy,61*xx)
					sleep(500)
					break
				end
			end
			
		elseif iscolor(1058*yy,648*xx,0x202020,95) then

			if iscolor(39*yy,37*xx,0xE6E6E6,94) then	--返回
				touch.click(39*yy,37*xx)
				sleep(800)
			end
			if iscolor(1213*yy,61*xx,0xE9E9E9,94) then	--回城
				touch.click(1213*yy,61*xx)
				sleep(500)
				break
			end
		end
		
		repeat								--循环直到找到资源
			if goend then		--异常处理
				break
			end
		
			flag0 = leftFind(ii,types)
			sleep(1000)
			if flag0 then
				break
			end	
			
			flag0 = upFind(ii,types)
			sleep(1000)
			if flag0 then
				break
			end	
			
			ii = ii + 1
			flag0 = rightFind(ii,types)
			sleep(1000)
			if flag0 then
				break
			end	
			
			flag0 = downFind(ii,types)
			sleep(1000)
			if flag0 then
				break
			end	

			ii = ii + 1
			
			if iscolor(665*yy,567*xx,0xAA6C0D,95) then
				touch.click(160*yy,515*xx)
				sleep(500)
			end			
			
		until ii > 12		--控制范围的话 ii = 圈数 x 2 + 1
		sleep(1000)
			
	end
end

function m_main()						--主体函数（在验证通过的情况下调用此函数）
	toast("脚本开始运行")
	ui.updateResult()
	轮数 = ui.getResult("lunshu")
	kjyj = ui.getResult("kjyj")
	科技类型 = ui.getResult("kjlx")
	lmtx = ui.getResult("lmtx")
	mfyj = ui.getResult("mfyj")
	zdzb = ui.getResult("zdzb")
	zdzc = ui.getResult("zdzc")
	zdqb = ui.getResult("zdqb")
	zdgb = ui.getResult("zdgb")
	cjzy = ui.getResult("cjzy")
	sjjz = ui.getResult("sjjz")
	游戏端 = ui.getResult("游戏端")
	
	if 游戏端 == "九游版" then
		apkname = "com.xianyugame.aok.uc" 
	elseif 游戏端 == "果盘版" then
		apkname = "com.xianyugame.aok.wdj.guopan"
	end
	
	soldiersRank = ui.getResult("bb")
	if soldiersRank == "默认" then
		soldiersRank = 0
	elseif soldiersRank == "Ⅰ级" then
		soldiersRank = 1
	elseif soldiersRank == "Ⅱ级" then
		soldiersRank = 2
	elseif soldiersRank == "Ⅲ级" then
		soldiersRank = 3
	elseif soldiersRank == "Ⅳ级" then
		soldiersRank = 4 
	elseif soldiersRank == "Ⅴ级" then
		soldiersRank = 5
	elseif soldiersRank == "Ⅵ级" then
		soldiersRank = 6
	elseif soldiersRank == "Ⅶ级" then
		soldiersRank = 7
	elseif soldiersRank == "Ⅷ级" then
		soldiersRank = 8
	elseif soldiersRank == "Ⅸ级" then
		soldiersRank = 9
	elseif soldiersRank == "Ⅹ级" then
		soldiersRank = 10
	end
	
	qbRank = ui.getResult("qb")
	if qbRank == "默认" then
		qbRank = 0
	elseif qbRank == "Ⅰ级" then
		qbRank = 1
	elseif qbRank == "Ⅱ级" then
		qbRank = 2
	elseif qbRank == "Ⅲ级" then
		qbRank = 3
	elseif qbRank == "Ⅳ级" then
		qbRank = 4 
	elseif qbRank == "Ⅴ级" then
		qbRank = 5
	elseif qbRank == "Ⅵ级" then
		qbRank = 6
	elseif qbRank == "Ⅶ级" then
		qbRank = 7
	elseif qbRank == "Ⅷ级" then
		qbRank = 8
	elseif qbRank == "Ⅸ级" then
		qbRank = 9
	elseif qbRank == "Ⅹ级" then
		qbRank = 10
	end
	
	gbRank = ui.getResult("gb")
	if gbRank == "默认" then
		gbRank = 0
	elseif gbRank == "Ⅰ级" then
		gbRank = 1
	elseif gbRank == "Ⅱ级" then
		gbRank = 2
	elseif gbRank == "Ⅲ级" then
		gbRank = 3
	elseif gbRank == "Ⅳ级" then
		gbRank = 4 
	elseif gbRank == "Ⅴ级" then
		gbRank = 5
	elseif gbRank == "Ⅵ级" then
		gbRank = 6
	elseif gbRank == "Ⅶ级" then
		gbRank = 7
	elseif gbRank == "Ⅷ级" then
		gbRank = 8
	elseif gbRank == "Ⅸ级" then
		gbRank = 9
	elseif gbRank == "Ⅹ级" then
		gbRank = 10
	end
		
	tankRank = ui.getResult("zc")
	if tankRank == "默认" then
		tankRank = 0
	elseif tankRank == "Ⅰ级" then
		tankRank = 1
	elseif tankRank == "Ⅱ级" then
		tankRank = 2
	elseif tankRank == "Ⅲ级" then
		tankRank = 3
	elseif tankRank == "Ⅳ级" then
		tankRank = 4 
	elseif tankRank == "Ⅴ级" then
		tankRank = 5
	elseif tankRank == "Ⅵ级" then
		tankRank = 6
	elseif tankRank == "Ⅶ级" then
		tankRank = 7
	elseif tankRank == "Ⅷ级" then
		tankRank = 8
	elseif tankRank == "Ⅸ级" then
		tankRank = 9
	elseif tankRank == "Ⅹ级" then
		tankRank = 10
	end
	
	types = ui.getResult("zy")
	
	
	路径1 = xscript.scriptDir().."账号密码.txt" 
	local flag00 = xutil.isFileExists(路径1)		--判断账号是否写入
	if flag00 then
		for lun = 1,轮数,1 do
			--timer = os.clock()
			for han = 1,10 do
				toast("开始第"..lun.."轮  第"..han.."个账号",1000)
				goend = false
				flagLongin = accountSwitch(han)
				logcat(flagLongin)
				if flagLongin == 1 then
				
				if not goend then		--异常处理
					repeat
						sleep(1000)
						if goend then	--如果卡主，跳出循环
							break
						end
					until iscolor(1216*yy,62*xx,0xE9E9E9,96)
				end
				
					if iscolor(909*yy,114*xx,0xD8D8D8,96) then 
						touch.click(160*yy,400*xx)
						sleep(500)
					end
					
					if iscolor(959*yy,525*xx,0xFFA300,96) then
						touch.click(959*yy,525*xx)
						sleep(500)
					end
					
				if not goend then		--异常处理
					toast("开始收集资源",800)
					resourcesCollecte()
					sleep(1000)
				end
				
				if not goend then		--异常处理
					toast("自动签到",800)
					sleep(1000)
					自动签到()
				end
				
				if not goend then		--异常处理
					if lmtx then
						toast("联盟探险",800)
						sleep(1000)
						联盟探险()
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if sjjz then
						toast("开始升级建筑",800)
						sleep(1000)
						升级建筑()
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if kjyj then
						toast("开始科技研究",800)
						sleep(1000)
						科技研究(科技类型)
					end
				end
				
				if not goend then		--异常处理
					if mfyj then
						toast("魔法遗迹",800)
						sleep(1000)
						自动遗迹()
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if zdzb then
						toast("开始造步兵",800)
						sleep(1000)
						trianSoldiers1(soldiersRank)
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if zdzc then
						toast("开始造战车",800)
						sleep(1000)
						trianTank(tankRank)
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if zdqb then
						toast("开始造骑兵",800)
						sleep(1000)
						自动骑兵(qbRank)
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if zdgb then
						toast("开始造弓兵",800)
						sleep(1000)
						自动弓兵(gbRank)
						--sleep(500)
					end
				end
				
				if not goend then		--异常处理
					if cjzy then
						toast("开始出兵采集世界资源",800)
						sleep(1000)
						worldResoures(types)
						sleep(3000)
					end
				end
					
					sleep(1000)
					toast("切换账号")
					app.stop(apkname)
					sleep(3000)
				
				end

			end
			
			--[[if (os.clock()-timer)<5 then
				app.stop("com.xianyugame.aok.wdj.guopan")
					sleep(5000)
					app.start("com.xianyugame.aok.wdj.guopan")
					sleep(7000)
					goend = false
			end]]
			
		end
		
	else
		toast("账号未写入文件，请先输入账号")
		input()
	end
end
--------------主要函数结束--------------

---------------------功能函数结束----------------------


-----------------------UI界面------------------------
function 激活码()
	ui.newLayout("激活码",360)
	ui.setTitleText("激活码","激活界面")

	ui.addButton("fuzhiid","复制ID",85,40)
	ui.setOnClick("fuzhiid","fuzhi()")
	ui.addTextView("id","您的设备ID:")
	ui.addTextView("imei","10"..全局_机器编码) 

	ui.newRow("a")
	--ui.addTextView("nji","输入激活码:",16,ui.WRAP_CONTENT,ui.WRAP_CONTENT)
	ui.addEditText("bhu", "点击此处输入激活码，已验证设备勿再输入",360,40)  

	ui.newRow("b")
	ui.addLine("c",320,2)

	ui.newRow("d")
	ui.addTextView("shuomin","辅助交流群：528194935\n作者QQ：1099042293",17)
	ui.setTextColor("shuomin",0x000000)
	ui.addLine("e",320,2)

	ui.newRow("f")

	ui.show("激活码")
end


ui.newLayout("main",360)

ui.addTextView("rqdt","☞注意：使用脚本前请先阅读使用说明",16)
ui.setTextColor("rqdt",0xFF0000)

ui.newRow("igbh")
ui.setTitleText("main","游戏配置")
ui.addButton("jhjm","激活码注册",108,40)		--激活界面
ui.setOnClick("jhjm","激活码()")

ui.addButton("zhsr","输入账号",108,40)		--账号输入界面
ui.setOnClick("zhsr","input()")

ui.addButton("sysm","使用说明",108,40)		--使用说明
ui.setOnClick("sysm","sm()")


ui.addLine("888",320,2)
ui.newRow("yhjvs")
ui.addTextView("489","☞选择游戏端类型：")
ui.addSpinner("游戏端",{ "九游版", "果盘版"},1,ui.WRAP_CONTENT,ui.WRAP_CONTENT)

ui.newRow("dfew")
ui.addTextView("564","☞所有账号循环 ")
ui.addEditText("lunshu","10",ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.addTextView("yug"," 轮")

ui.newRow("98978")
ui.addTextView("uiu","☞选择功能：")
ui.newRow("IPO")
ui.addCheckBox("kjyj", "科技研究",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.addCheckBox("lmtx", "联盟探险",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.addCheckBox("mfyj", "魔法遗迹",false, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.newRow("89456")
ui.addCheckBox("zdzb", "自动步兵",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.addCheckBox("zdzc", "自动造车",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.addCheckBox("cjzy", "采集资源",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.newRow("8784")
ui.addCheckBox("zdqb", "自动骑兵",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.addCheckBox("zdgb", "自动弓兵",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)
ui.addCheckBox("sjjz", "升级建筑",true, ui.WRAP_CONTENT, ui.WRAP_CONTENT)

ui.addLine("875",320,2)
ui.newRow("7874")
ui.addTextView("bbdj","☞请选择步兵等级：")
ui.addSpinner("bb",{"默认", "Ⅰ级", "Ⅱ级","Ⅲ级", "Ⅳ级","Ⅴ级","Ⅵ级","Ⅶ级","Ⅷ级","Ⅸ级","Ⅹ级"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.addTextView("bingsm","（默认为最高级）")
ui.newRow("jo")
ui.addTextView("qbdj","☞请选择骑兵等级：")
ui.addSpinner("qb",{"默认", "Ⅰ级", "Ⅱ级","Ⅲ级", "Ⅳ级","Ⅴ级","Ⅵ级","Ⅶ级","Ⅷ级","Ⅸ级","Ⅹ级"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.newRow("887")
ui.addTextView("gbdj","☞请选择弓兵等级：")
ui.addSpinner("gb",{"默认", "Ⅰ级", "Ⅱ级","Ⅲ级", "Ⅳ级","Ⅴ级","Ⅵ级","Ⅶ级","Ⅷ级","Ⅸ级","Ⅹ级"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.newRow("254")
ui.addTextView("che","☞请选择造车等级：")
ui.addSpinner("zc",{"默认", "Ⅰ级", "Ⅱ级","Ⅲ级", "Ⅳ级","Ⅴ级","Ⅵ级","Ⅶ级","Ⅷ级","Ⅸ级","Ⅹ级"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.addTextView("che","☞请选择科技研究类型：")
ui.addSpinner("kjlx",{"经济", "城防", "战斗"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)

ui.newRow("hiu")
ui.addTextView("che","☞请选择出兵采集资源类型：")
ui.addSpinner("zy",{"随机","木","粮","铁","晶石"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)

ui.show("main")
-----------------------UI结束------------------------



----------异常处理----------
function judge()
	if iscolor(640*yy,360*xx,colorbigan,95) then
		goend = true
		if goend == true then
			app.stop(apkname)
			sleep(5000)
			--goend = false
		end
		colorbigan = getcolor(640*yy,360*xx)
	else
		logcat("8")
	end
	
	colorbigan = getcolor(640*yy,360*xx)
	logcat(colorbigan)
	if colorbigan == -1 then
		sleep(1000)
		colorbigan = getcolor(640*yy,360*xx)
	end
end
----------异常处理结束------

colorbigan = 0xFF0000
goend = false
bigan = true


--此行务必保留最后一行
main()
--------------------------------------------------
-- 脚本名称: 自动任务
-- 脚本描述: 自动完成材料，剧情任务
--------------------------------------------------

bar.position(700,0)
toast("在游戏主界面点击播放按钮开始")
xscript.pause() 
autoscreencap(true)		--关闭自动截图
xscript.setCompatible(true)  --设置兼容模式截图

function fuzhi()						--复制ID
	system.setClip(systeminfo.imei())
	toast("ID复制成功")
end

function jihuocall()					--激活码输入
	ui.newLayout("jihuoma_ui")
	ui.setTitleText("jihuoma_ui","激活界面")
	ui.addTextView("03","输入激活码:")
	ui.addEditText("04","",200,40)
	ui.show("jihuoma_ui")
	ui.updateResult()
	激活码 = ui.getResult("04")
	路径 = xscript.scriptDir() .. "yitian.txt"
	xutil.writeToFile(路径, 激活码)
end

function st()							--停止脚本函数
		toast("试用结束，自动关闭游戏并停止脚本",3000)
		app.stop("com.cmge.pwrd.yttlj.android.tt.tdd.leshi")
		xscript.stop()
	end

function sy()							--试用函数
	ui.dismiss("jihuo")
	toast("开始试用")
	
	if ii > 10 then
		toast("试用结束，自动关闭游戏并停止脚本",3000)
		app.stop("com.cmge.pwrd.yttlj.android.tt.tdd.leshi")
		xscript.stop()
	end
end

-------------材料副本--------------
function clfb()
	while true do
		if iscolor(704,343,0xFFFFFF,95) then	--如果当前次数用尽，切换到下一材料副本
			touch.click(1004,343)
			sleep(1000)
		end
		
		if iscolor(683,345,0xFF0000,90) then	--如果总次数用尽，点击返回
			break;
		end
		
		if iscolor(945,647,0x7D5433,90)	then	--"进入"处颜色,点击“进入”
			touch.click(945,647)
			sleep(500)
		end
		
		zidong = iscolor(1236,363,0x908046,90)		--判断是否自动战斗
		if (zidong) then							--如果不是，点击自动战斗，并等待完成
			touch.click(1236,363)
			sleep(3000)
		elseif iscolor(1236,363,0xAB7814,90) then	--仍是自动战斗，延时等待
			sleep(10000)
		end

		fanpai = iscolor(1017,507,0x343D55,90)		--翻牌界面
		if (fanpai) then							--翻开第四张牌
			sleep(2000)
			touch.click(1017,507)
			sleep(2000)
			touch.click(1170,530)
			sleep(1000)
		end
		toast("材料副本中",300)

	end
end
-----------材料副本结束------------


-------------剧情副本--------------
function jqfb()
	while true do
		if iscolor(400,423,0x7D9EAF,90) then	--如果处于副本界面，点击进入任务
			touch.click(400,420)
			sleep(1000)
		end
		
		if iscolor(910,560,0x7E5534,90)	then	--"开始"处颜色,点击“开始”
			touch.click(910,560)
			sleep(1000)
		end
		
		if iscolor(259,640,0xFFF6E0,90) then		--打完一次后处于副本界面，点击返回主界面重新开始
			touch.click(400,420)
			sleep(1000)
			break;
		end

		zidong = iscolor(1236,363,0x908046,90)		--判断是否自动战斗
		if (zidong) then							--如果不是，点击自动战斗，并等待完成
			touch.click(1236,363)
			sleep(3000)
		elseif iscolor(1236,363,0xAB7814,90) then	--仍是自动战斗，延时等待
			sleep(10000)
		end

		fanpai = iscolor(1017,507,0x343D55,90)		--翻牌界面
		if (fanpai) then							--翻开第四张牌
			sleep(2000)
			touch.click(1017,507)
			sleep(3000)
			touch.click(1170,530)
			sleep(2000)
		end
		toast("剧情副本中",300)
	end
end
-----------剧情副本结束------------


-------------帮派任务--------------
function bprw()

end
-----------帮派任务结束------------



--------------主函数--------------
function main_()
	while true do
		huodong = iscolor(431,62,0xD9B795,90)	--活动颜色
		vip = iscolor(360,46,0x681D26,90)		--vip处颜色

		if huodong and vip then
			touch.click(500,40)					--点击“副本”
			toast("副本",100)
			sleep(1000)
			--screencap()
			--sleep(500)
		elseif iscolor(338,104,0xFAE3AB,85) then	--处于副本界面（"副本"处颜色）
			
			sleep(1000)
			--cailiao = iscolor(1063,400,0x5F7089,90)	--找到材料副本
			if iscolor(1063,400,0x5F7089,90) then		--找到材料副本
				touch.click(1063,400)
				sleep(1000)
			--elseif iscolor(1062,404,0xB2ECF4,90) then
				clfb()
				sleep(1000)
			end
			
		--[[find.colors({0x2CDA0E,
			{2,4,0x2CE50E},
			{-1,10,0x2CE30E},
			{186,7,0xE6CE63}},85,465,130,865,480)
			if cailaio then							--点击“参加”，开始材料副本
				toast("cialiao")
				touch.click(x+400,y)
				sleep(3000)
				clfb()
			end]]
			
			sleep(1000)
			--cailiao = iscolor(1063,400,0xB3EDF5,90)	--找到剧情副本
			if iscolor(1065,194,0x5F7089,90) then
				touch.click(1065,194)
				sleep(1000)
			--elseif iscolor(1064,191,0xB3EDF5,90) then
				jqfb()
				sleep(1000)
			end
			
		--[[sleep(1000)
			juqing,x,y = find.colors({				--找到“剧情副本”
			0xB9D0D4,
			{2,2,0x7B8383},
			{1,8,0xDBF9FF},
			{68,0,0xD5F1F7}},90,190,170,400,490)
			if juqing then 							--点击“参加”，开始剧情副本
				toast("juqing")
				touch.click(x+650,y)
				sleep(1000)
				jqfb()
			end]]
			
		--[[sleep(1000)
			bangpai,x,y = find.colors({			--找到帮派任务
			0xD3EFF5,
			{0,2,0x271E19},
			{0,3,0xC1D9DE},
			{3,5,0xDBF9FF},
			{77,6,0x281F1B}},90,190,170,400,490)
			if bangpai then						--点击“参加”，开始帮派任务
				toast("bangpai")
				touch.click(x+650,y)
				sleep(3000)
				bprw()
			end]]
			
		else
			toast("脚本正在运行",500)
		end
	end
end
------------主函数结束-------------

--------------------------------------------------激活码移植部分-------------------------------------------
function chongxin()						--重新注册
	local 路径 = xscript.scriptDir() .. "yitian.txt"
	os.remove(路径) 
	toast("已清空原注册数据，点击继续重新注册")
end	

function jihuocall()					--激活码输入界面
	ui.newLayout("jihuoma_ui")
	ui.setTitleText("jihuoma_ui","激活界面")
	ui.addTextView("01","输入激活码:")
	ui.newRow("02")
	ui.addEditText("03","",320,40)
	ui.show("jihuoma_ui")
	ui.updateResult()
	local 激活 = ui.getResult("03")
	if 激活 == "" then
		toast("请输入激活码")
	end
	local 路径 = xscript.scriptDir() .. "yitian.txt"
	xutil.writeToFile(路径, 激活)
	local m_long,m_date = jiemi(激活)
	xutil.appendToFile(路径,"\n",m_long,"\n",m_date)
end

function fuzhi()						--复制ID
	system.setClip(systeminfo.imei())
	toast("ID复制成功")
end


--对比函数，于生成的3个激活码（1天，30天，永久）对比
--参数：x：读取的激活码
--返回值：激活码错误：0   1天：1   30天：2   永久：3
function jihuoma(x)
	if x == nil then
		return 0
	else
		local IMEI = tonumber(string.sub(systeminfo.imei(),2,15))
		local TIME = tonumber(os.date("%Y%m%d%H",t))
		local password1 = IMEI + TIME*100 + 1*1000000000000		--10^12
		local password2 = IMEI + TIME*100 + 2*1000000000000
		local password3 = IMEI + TIME*100 + 3*1000000000000
		if x == security.base64enc(password1) then
			return 1
		elseif x == security.base64enc(password2) then
			return 2
		elseif x == security.base64enc(password3) then
			return 3
		else
			return 0
		end
	end
end


--验证函数
--参数：y：到期时间（秒）
--返回值：没过期：1    过期：0
function yanzhen(y)
	local 到期时间=y 	--获取目前时间戳
	toast("开始验证是否过期,请稍后")
	local 当前时间 = net.time()
	
	if 当前时间 == nil then 		
		toast("获取网络时间失败，脚本验证需要联网")
		sleep(3000)
		exit() 	--获取成功 	
	else 	--计算得出脚本剩余的秒数 		
		local	脚本剩余秒数=到期时间-当前时间 		--如果脚本剩余秒数小于0就是脚本到期了 		
		if 脚本剩余秒数<0 then
			return 0 			--脚本到期 		
		else 			
			toast("脚本到期剩余"..string.format("%d小时%d分",脚本剩余秒数/3600,(脚本剩余秒数%3600)/60)) 		
			return 1
		end 	
	end
end


--激活码解密函数
--参数：base64加密后的激活码
--返回值：m_long：时长    m_date:注册时间
function jiemi(激活码)
	if 激活码 == nil then
		return 0,0
	elseif 激活码 then
		if security.base64dec(激活码) == nil then
			toast("激活码不正确")
			return 0,0
		end
		local 数据 = tonumber(security.base64dec(激活码))
		local m_imei = tonumber(string.sub(systeminfo.imei(),2,15))
		local 结果 = 数据 - m_imei
		local m_long = math.floor(结果/1000000000000)
		local m_date = (结果%1000000000000)
		return m_long,m_date
	else
		toast("请输入激活码")
	end
end

-------------------UI开始------------------------
ui.newLayout("main","360")
ui.setTitleText("main","激活码界面")

ui.addButton("fuzhiid","复制ID",85,40)
ui.setOnClick("fuzhiid","fuzhi()")
ui.addTextView("id","您的设备ID:")
ui.addTextView("imei",systeminfo.imei()) 

ui.newRow("a")
ui.addButton("zhuce","重新注册",85,40)
ui.setOnClick("zhuce","chongxin()")
ui.addTextView("zcshuomin","会删除之前注册数据.谨慎点击")
ui.setTextColor("zhuce",0xffff00)

ui.newRow("b",320,5)
ui.addLine("c",320,2)

ui.newRow("d")
ui.addTextView("06","注意：\n1.此脚本只试用于720*1280分辨率。\n2.脚本联网验证可能需要3~10秒，请耐心等待。\n3.如果执行脚本出错，说明激活码不正确。")
ui.setTextColor("06",0xFF00FF)

ui.addLine("tv",320,2)
ui.newRow("d")
ui.addTextView("03","购买激活码请加QQ群:555370598")
ui.setTextColor("03",0x000000)
ui.newRow("c")
ui.addTextView("05","联系作者QQ：1099042293")
ui.setTextColor("05",0x000000)

ui.show("main")

-------------------UI结束----------------------


-------------------激活模块--------------------
ui.updateResult()
local 激活 = ui.getResult("03")


路径 = xscript.scriptDir() .. "yitian.txt"
file,errMsg = io.open(路径,"rw")
toast("脚本验证中，请确保互联网连接正常")

while true do
	file,errMsg = io.open(路径,"rw")
	logcat(路径)
	logcat(errMsg)
	if file then
		激活码 = xutil.readFileLine(路径,1) 
		flag = jihuoma(激活码)					--对比激活码
		logcat(flag)
		if flag~=0 then
			if flag~=nil then
				m_long = tonumber(xutil.readFileLine(路径,2))
				m_date = xutil.readFileLine(路径,3)
				if m_long == 2 then
					m_long =30
				elseif m_long == 3 then
					m_long =365
				end
				
				m_date_year = string.sub(m_date,1,4)
				m_date_mouth = tonumber(string.sub(m_date,5,6))
				m_date_mouth = (m_date_mouth + 10) - 10
				m_date_day = string.sub(m_date,7,8)
				m_date_hour = string.sub(m_date,9,10)
				secend = m_long*24*3600 + os.time({year=m_date_year,month=m_date_mouth,day=m_date_day,hour=m_date_hour})
				flag1 = yanzhen(secend)		--调用时间验证函数，判断是否过期
				
				if flag1==1 then
					file:close()
					main_()
				elseif flag1==0 then
					toast("脚本已过期，请重新购买")
					xscript.stop() 
				end
			else
				toast("激活码不正确，请重新输入")
				jihuocall()
			end
			
		else
			toast("激活码不正确，请重新输入")
			jihuocall()
		end
		
	else
		jihuocall()
	end
end
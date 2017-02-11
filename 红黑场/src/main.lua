--------------------------------------------------
-- 脚本名称: 红黑场
-- 脚本描述: 
--------------------------------------------------


---------------UI界面-------------------
ui.newLayout("main",360)
ui.setTitleText("main","设置")

ui.newRow("fe")
ui.addTextView("asd","☞押注方式：")
ui.addRadioGroup("rg", {'轮换', '跟押','随机','递增轮换','混合'},1)

ui.newRow("pop")
ui.addTextView("qwe","☞初始押注大小：")
ui.addSpinner("money",{"5千","1万", "2万","3万","4万","5万"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)

ui.show("main")
---------------UI结束------------------

toast("点击控制条上的播放按键运行")
xscript.pause()

toast("脚本开始运行",1500)
sleep(1000)

---------------功能函数----------------
--返回值：返回输赢状态
--1：赢
--0：输
function betting(color,money)
	local x_color
	local y_color
	if color == "红" then
		x_color = 470
		y_color = 520
	end
	if color == "黑" then
		x_color = 790
		y_color = 520
	end
	logcat(x_color,y_color)

	local y_money = 680
	local x_money_100 = 530
	local x_money_1000 = 675
	local x_money_1w = 820
	local x_money_10w = 965
	local x_money_100w = 1110
	
	local times_100w = math.floor(money/10000)
	money = money%10000
	local times_10w = math.floor(money/1000)
	money = money%1000
	local times_1w = math.floor(money/100)
	money = money%100
	local times_1000 = math.floor(money/10)
	money = money%10
	local times_100 = money
	logcat(times_100w,times_10w,times_1w,times_1000,times_100)
	
	repeat
		sleep(1000)
	until iscolor(876,15,0x705433,95)	--等到押注时间
	sleep(1500)
	
	if times_100w>0 then				--开始下注
		for i=1,times_100w,1 do
			if not iscolor(1064,697,0xFC5002,95) then
				touch.click(1064,697)
				sleep(300)
			end
			touch.click(x_color,y_color)
			sleep(200)
		end
	end
	if times_10w>0 then
		for i=1,times_10w,1 do
			if not iscolor(919,697,0xFC5002,95) then
				touch.click(919,697)
				sleep(300)
			end
			touch.click(x_color,y_color)
			sleep(200)
		end
	end
	if times_1w>0 then
		for i=1,times_1w,1 do
			if not iscolor(774,697,0xFC5002,95) then
				touch.click(774,697)
				sleep(300)
			end
			touch.click(x_color,y_color)
			sleep(200)
		end
	end
	if times_1000>0 then
		for i=1,times_1000,1 do
			if not iscolor(629,697,0xFC5002,95) then
				touch.click(629,697)
				sleep(300)
			end
			touch.click(x_color,y_color)
			sleep(200)
		end
	end
	if times_100>0 then
		for i=1,times_100,1 do
			if not iscolor(484,697,0xFC5002,95) then
				touch.click(484,697)
				sleep(300)
			end
			touch.click(x_color,y_color)
			sleep(200)
		end
	end
	
	repeat
		sleep(1000)
	until iscolor(889,10,0xFDFDFD,95)	--等到结算时间
	
	repeat
		if color == "红" then				--判断胜负
			if iscolor(481,504,0xE40400,95) then
				return 1
			end
		elseif color == "黑" then
			if iscolor(793,505,0xD80500,95) then
				return 1
			end
		end
		sleep(1000)
	until iscolor(870,15,0x1D2324,95)
	return 0
end


--断线重连
function reLink()
	if iscolor(746,472,0x42B5DE,98) then
		touch.click(746,472)
		sleep(1000)
	end
end


-- 脚本入口
function main()
	toast("脚本开始运行")
	
	ui.updateResult() 
	init_money = ui.getResult("money")
	押注方式 = ui.getResult("rg")
	logcat(init_money)
	--money换算比例100:1
	if init_money == "5千" then
		init_money = 50
	elseif init_money == "1万" then
		init_money = 100
	elseif init_money == "2万" then
		init_money = 200
	elseif init_money == "3万" then
		init_money = 300
	elseif init_money == "4万" then
		init_money = 400
	elseif init_money == "5万" then
		init_money = 500
	end
	
	
	setTrigger.timeLoop(50000, "reLink()")  	--断线处理
	
	if iscolor(1142,670,0xF7BC06,95) then		--进入红黑场
		touch.click(1070,370)
		sleep(1000)
	end
	repeat
		sleep(1000)
	until iscolor(876,15,0x705433,95)	--等到押注时间
	
	count = 0
	money = init_money
	if 押注方式 == '轮换' then
		while true do	--轮换下注
			if (count%2) == 0 then
				if betting("红",money) == 1 then
					money = init_money/2
				end
				repeat
					sleep(1000)
				until iscolor(876,15,0x705433,95)	--等到押注时间
				money = money * 2
				
				if betting("红",money) == 1 then
					money = init_money/2
				end
				repeat
					sleep(1000)
				until iscolor(876,15,0x705433,95)	--等到押注时间
				money = money * 2
				
				if betting("红",money) == 1 then
					money = init_money/2
				end
			else
				if betting("黑",money) == 1 then
					money = init_money/2
				end
				repeat
					sleep(1000)
				until iscolor(876,15,0x705433,95)	--等到押注时间
				money = money * 2
				
				if betting("黑",money) == 1 then
					money = init_money/2
				end
				repeat
					sleep(1000)
				until iscolor(876,15,0x705433,95)	--等到押注时间
				money = money * 2
				
				if betting("黑",money) == 1 then
					money = init_money/2
				end
			
			end
			
			logcat(count,money)
			money = money * 2
			count = count + 1
			logcat(money)
		end
		
	elseif 押注方式 == '跟押' then
		last = "红"
		while true do
			if betting(last,money) == 1 then
				money = init_money/2
			else
				if last == "红" then
					last = "黑"
				else
					last = "红"
				end
			end
			
			money = money * 2
			logcat(money)
		end
		
	elseif 押注方式 == '随机' then
		while true do
			math.randomseed(os.time())
			local m_times = math.random(1,100)
			if (m_times%2)==0 then
				last = "红"
			else 
				last = "黑"
			end
			
			if betting(last,money) == 1 then
				money = init_money/2
			end
			
			money = money * 2
			logcat(money)
		end
		
	elseif 押注方式 == '递增轮换' then
		last = "红"
		count = 1
		money = init_money/2
		while true do
			for i = 1,count,1 do
				money = money * 2
				if betting(last,money) == 1 then
					money = init_money/2
					count = 0
					last = "黑"
					break
				end
			end
			if last == "红" then
				last = "黑"
			else
				last = "红"
			end
			
			count = count + 1
			logcat(count,money)
		end
		
	--跟押3次，然后红2次，黑3次
	elseif 押注方式 == '混合' then
		last = "红"
		while true do
			for i=1,3 do	--跟押
				toast("跟押:第"..i.."次:"..last.."  "..(money/100).."万",5000)
				if betting(last,money) == 1 then
					money = init_money/2
				else
					if last == "红" then
						last = "黑"
					else
						last = "红"
					end
				end
				money = money * 2
				logcat(money)
			end
			for i=1,2 do	--红2次
				toast("固定押:第"..i.."次: 红  "..(money/100).."万",5000)
				if betting("红",money) == 1 then
					money = init_money/2
				end
				money = money * 2
				logcat(money)
			end
			for i=1,3 do	--黑3次
				toast("固定押:第"..i.."次: 黑  "..(money/100).."万",5000)
				if betting("黑",money) == 1 then
					money = init_money/2
					last = "黑"
				else
					last = "红"
				end
				money = money * 2
				logcat(money)
			end
		end
	end
	
end


-- 此行无论如何保持最后一行
main()





--------------------------------------------------
-- 脚本名称: 飞禽走兽V1.0
-- 脚本描述: 
--------------------------------------------------

---------------UI界面-------------------
ui.newLayout("main",360)
ui.setTitleText("main","设置")

ui.newRow("fe")
ui.addTextView("asd","☞押注方式：")
ui.addRadioGroup("rg", {'随机','固定'},1)

ui.newRow("pop")
ui.addTextView("qwe","☞初始押注大小：")
ui.addSpinner("money",{"1万","2万","5万","10万"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)

ui.newRow("5656")
ui.addLine("jhi",320,2)
ui.newRow("56656")
ui.addTextView("ded","模式说明：")
ui.newRow("79564")
ui.addTextView("sdc","①随机：随机选择压飞禽或走兽，赢了下注金额恢复初始值，输了翻倍。",16,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.newRow("8965")
ui.addTextView("gy","②固定：固定下注顺序，飞禽和走兽依次压1、3、2、4、5次。",16,ui.WRAP_CONTENT,ui.MATCH_PARENT)

ui.show("main")
---------------UI结束------------------

toast("点击控制条上的播放按键运行")
xscript.pause()

toast("脚本开始运行",1500)
sleep(1000)


---------------定义全局变量--------------
win_tb = {0xFEFCF1,{-6,-14,0xDA881B},{-17,-12,0xDE952F},{-23,-8,0xFFF7D9},
    {-23,-5,0xFEF8CB},{-23,-2,0xFBED98},{-23,3,0xC26F1D},{-27,8,0xFCEE8A},
	{-27,12,0xBF6B1A},{-18,23,0xA74F0F},{17,30,0xEDB634},{33,24,0xDD8519},
    {48,22,0xE6A326},{58,17,0xE09822},{19,9,0xF7DA5B},{9,12,0xF3BF32}}

y_money = 685
x_money_1000 = 290
x_money_10000 = 430
x_money_10w = 575
x_money_100w = 715
x_money_1000w = 870

--固定模式押注次数
fixed_times = {1,3,2,4,5}

---------------功能函数----------------
--返回值：返回输赢状态
--1：赢
--0：输
function betting(type,money)
	local type_x,type_y
	if type == "飞禽" then
		type_x = 460
		type_y = 340
	elseif type == "走兽" then
		type_x = 830
		type_y = 340
	end
	logcat(type_x,type_y)
	
	local times_1000w = math.floor(money/10000)
	money = money%10000
	local times_100w = math.floor(money/1000)
	money = money%1000
	local times_10w = math.floor(money/100)
	money = money%100
	local times_10000 = math.floor(money/10)
	money = money%10
	local times_1000 = money
	logcat(times_1000w,times_100w,times_10w,times_10000,times_1000)
	
	repeat
		sleep(1000)
	until iscolor(492,133,0xFBF5E1,99)	--等到押注时间
	sleep(1500)

	if times_1000w>0 then				--开始下注
		for i=1,times_1000w,1 do
			if not iscolor(x_money_1000w,y_money,0xF67B13,99) then
				touch.click(x_money_1000w,y_money)
				sleep(300)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_100w>0 then
		for i=1,times_100w,1 do
			if not iscolor(x_money_100w,y_money,0xF67B13,99) then
				touch.click(x_money_100w,y_money)
				sleep(300)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_10w>0 then
		for i=1,times_10w,1 do
			if not iscolor(x_money_10w,y_money,0xF67B13,99) then
				touch.click(x_money_10w,y_money)
				sleep(300)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_10000>0 then
		for i=1,times_10000,1 do
			if not iscolor(x_money_10000,y_money,0xF67B13,99) then
				touch.click(x_money_10000,y_money)
				sleep(300)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_1000>0 then
		for i=1,times_1000,1 do
			if not iscolor(x_money_1000,y_money,0xF67B13,99) then
				touch.click(x_money_1000,y_money)
				sleep(300)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	
	repeat
		sleep(1000)
	until not iscolor(492,133,0xFBF5E1,99)		--等到下注时间结束
	
	repeat
		if find.colors(win_tb,98,580,259,744,349) then
			return 1
		end
		sleep(1000)
	until iscolor(492,133,0xFBF5E1,99)		--等到结算结束，即下一把下注开始
	return 0
end



-- 脚本入口
function main()
	toast("脚本开始运行")
	
	ui.updateResult() 
	init_money = ui.getResult("money")
	押注方式 = ui.getResult("rg")
	if init_money == "1000" then
		init_money = 1
	elseif init_money == "1万" then
		init_money = 10
	elseif init_money == "2万" then
		init_money = 20
	elseif init_money == "5万" then
		init_money = 50
	elseif init_money == "10万" then
		init_money = 100
	elseif init_money == "100万" then
		init_money = 1000
	elseif init_money == "1000万" then
		init_money = 10000
	end
	logcat(init_money,押注方式)
	
	repeat
		sleep(1000)
	until iscolor(492,133,0xFBF5E1,99)	--等到押注时间
	
	money = init_money
	if 押注方式 == '随机' then
		while true do
			math.randomseed(os.time())
			local m_times = math.random(1,100)
			logcat(m_times)
			if (m_times%2)==0 then
				last = "飞禽"
			else 
				last = "走兽"
			end
			
			if betting(last,money) == 1 then
				money = init_money/2
			end
			
			money = money * 2
			logcat(money)
		end
	elseif 押注方式 == '固定' then
		local last = "飞禽"
		local count = 1
		money = init_money/2
		while true do
			for i=1,fixed_times[count],1 do
				money = money*2
				if betting(last,money) == 1 then
					money = init_money/2
					last = "走兽"
					count = 0
					break
				end
			end
			if last == "飞禽" then
				last = "走兽"
			else
				last = "飞禽"
			end
			
			count = count + 1
			logcat(count,money)
		end
	end	
end


-- 此行无论如何保持最后一行
main()

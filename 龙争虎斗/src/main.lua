--------------------------------------------------
-- 脚本名称: 龙争虎斗
-- 脚本描述: 
--------------------------------------------------

--------------------------------------------------
-- 脚本名称: 龙争虎斗
-- 脚本描述: 
--------------------------------------------------

---------------UI界面-------------------
ui.newLayout("main",360)
ui.setTitleText("main","设置")

ui.newRow("fe")
ui.addTextView("asd","☞押注方式：")
ui.addRadioGroup("ways", {'跟押'},1)

ui.newRow("pop")
ui.addTextView("qwe","☞初始押注大小：")
ui.addSpinner("money",{"2千","5千","1万","2万","3万","4万"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)

--[[ui.newRow("5656")
ui.addLine("jhi",320,2)
ui.newRow("56656")
ui.addTextView("ded","模式说明：")
ui.newRow("79564")
ui.addTextView("sdc","①随机：随机选择压飞禽或走兽，赢了下注金额恢复初始值，输了翻倍。",16,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.newRow("8965")
ui.addTextView("gy","②固定：固定下注顺序，飞禽和走兽依次压1、3、2、4、5次。",16,ui.WRAP_CONTENT,ui.MATCH_PARENT)
]]
ui.show("main")
---------------UI结束------------------

toast("点击控制条上的播放按键运行")
xscript.pause()

toast("脚本开始运行",1500)
sleep(1000)


---------------定义全局变量--------------
y_money = 693
x_money_1000 = 824
x_money_1w = 716
x_money_5w = 608
x_money_10w = 499
x_money_100w = 391
--0xF4F1EA
---------------功能函数----------------
--返回值：返回输赢状态
--1：赢
--0：输
function betting(type,money)
	local type_x,type_y
	if type == "左" then
		type_x = 468
		type_y = 225
	elseif type == "右" then
		type_x = 811
		type_y = 225
	end
	logcat("type:"..type,"money:"..money.."k")
	local m_money = money
	
	local times_100w = math.floor(money/1000)
	money = money%1000
	local times_10w = math.floor(money/100)
	money = money%100
	local times_5w = math.floor(money/50)
	money = money%50
	local times_1w = math.floor(money/10)
	money = money%10
	local times_1000 = money
	logcat(times_100w,times_10w,times_5w,times_1w,times_1000)
	
	repeat
		sleep(1000)
		logcat("loop")
	until iscolor(643,184,0xD87B15,98)	--等到押注时间
	toast("这把押："..last.."  "..m_money.." k!",5000)
	sleep(5000)
	
	if times_100w>0 then				--开始下注
		for i=1,times_100w,1 do
			if iscolor(x_money_100w,y_money,0xFFB308,99) then
				touch.click(x_money_100w,y_money-40)
				sleep(200)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_10w>0 then
		for i=1,times_10w,1 do
			if iscolor(x_money_10w,y_money,0x4FBB23,99) then
				touch.click(x_money_10w,y_money-40)
				sleep(200)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_5w>0 then
		for i=1,times_5w,1 do
			if iscolor(x_money_5w,y_money,0x2E89E7,99) then
				touch.click(x_money_5w,y_money-40)
				sleep(200)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_1w>0 then
		for i=1,times_1w,1 do
			if iscolor(x_money_1w,y_money,0xFFB50E,99) then
				touch.click(x_money_1w,y_money-40)
				sleep(200)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	if times_1000>0 then
		for i=1,times_1000,1 do
			if iscolor(x_money_1000,y_money,0xEA4F10,99) then
				touch.click(x_money_1000,y_money-40)
				sleep(200)
			end
			touch.click(type_x,type_y)
			sleep(200)
		end
	end
	
	repeat
		sleep(1000)
		logcat("loop")
	until not iscolor(643,184,0xD87B15,98)		--等到下注时间结束

	repeat
		if find.color(0x902F2C,100,500,237,519,260) then
			if type == "左" then
				logcat("win")
				return 1
			end
		elseif find.color(0x902F2C,100,746,245,778,281) then
			if type == "右" then
				logcat("win")
				return 1
			end
		end
		logcat("loop")
		sleep(100)
	until iscolor(643,184,0xD87B15,98)		--等到结算结束，即下一把下注开始
	logcat("loose")
	return 0
end



-- 脚本入口
function main()
	ui.updateResult()
	init_money = ui.getResult("money")
	押注方式 = ui.getResult("ways")
	if init_money == "2千" then
		init_money = 2
	elseif init_money == "5千" then
		init_money = 5
	elseif init_money == "1万" then
		init_money = 10
	elseif init_money == "2万" then
		init_money = 20
	elseif init_money == "3万" then
		init_money = 30
	elseif init_money == "4万" then
		init_money = 40
	end
	logcat("init_money:"..init_money.."k","押注方式:"..押注方式)
	
	
	repeat
		sleep(1000)
	until iscolor(643,184,0xD87B15,98)	--等到押注时间
	
	money = init_money
	if 押注方式 == '跟押' then
		last = "左"
		while true do
			if betting(last,money) == 1 then
				money = init_money/2
			else
				if last == "左" then
					last = "右"
				else
					last = "左"
				end
			end
			
			money = money * 2
			logcat("money："..money.."k")
		end
	end
	
	
	
end


-- 此行无论如何保持最后一行
main()

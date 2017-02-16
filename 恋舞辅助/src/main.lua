--------------------------------------------------
-- 脚本名称: 恋舞辅助
-- 脚本描述: 
--------------------------------------------------
w,h = systeminfo.deviceSize()
setscale(w/720,h/1280)



-----------------UI-------------------
ui.newLayout("main",320)
ui.setFullScreen("main")
ui.setTitleText("main","恋舞OL辅助配置")

ui.addTextView("a","☞设置速度延时： ",16,ui.WRAP_CONTENT,ui.WRAP_CONTENT)
ui.addEditText("time",10,30,ui.WRAP_CONTENT)
ui.addTextView("a"," 毫秒（0最快）",16,ui.WRAP_CONTENT,ui.WRAP_CONTENT)

ui.newRow("98")
ui.addLine("97",null,2)

ui.newRow("96")
ui.addTextView("ex","脚本说明：",16,ui.WRAP_CONTENT,ui.WRAP_CONTENT)
ui.setTextColor("ex",0xff0000)

ui.newRow("95")
ui.addTextView("ex1","1. 适用分辨率：720*1280、1080*1920、1440*2560(2k).",16,ui.WRAP_CONTENT,ui.WRAP_CONTENT)

ui.newRow("94")



ui.show("main")
ui.setFullScreen("main") 
---------------UI结束------------------
toast("请建好房间后点击播放",3000)
xscript.pause()

-- 脚本入口
function main()
	ui.updateResult()
	ui = ui.getData()
	
	local redButton = {x = 224,y = 625}
	local blueButton = {x = 1057,y = 628}
	--[[local tb_red = {0xF895C8,{-20,-14,0xFDAACC},{-20,15,0xFC96BF}}
	local tb_blue = {0x57CAF6,{-15,-14,0x53CEFF},{-14,15,0x2CE7F8}}]]
	local tb_blue = {
    0x3DE1FE,
    {-18,-5,0x3FD4FA},
    {-18,6,0x26E1F2}}
	local tb_red = {
    0xF693C6,
    {-18,-6,0xEC87A3},
    {-18,5,0xE887B8}}
	local tb_both = {0x6BCEF7,{-10,10,0x45C1E3},{-12,-11,0xEEA1E1}}
	local isRed,isBlue,isBoth
	while true do
		if iscolor(1196,683,0x00D5A4,95) then
			touch.click(1196,683)
			logcat("点击准备")
			sleep(3000)
		end
		if iscolor(638,479,0x2792FD,95) then
			touch.click(638,479)
			logcat("点击确定")
			sleep(3000)
		end
		if iscolor(1195,683,0xFC9126,95) then
			touch.click(1195,683)
			logcat("点击开始")
			sleep(3000)
		end
	
		autoscreencap (false)
		repeat
			screencap()  
			isRed = find.colors(tb_red,93,925,441,960,478)
			if isRed then
				touch.click(redButton.x,redButton.y)
				--sleep(10)
			end
			
			isBlue = find.colors(tb_blue,93,925,441,960,478)
			if isBlue then
				touch.click(blueButton.x,blueButton.y)
				--sleep(10)
			end
			
			isBoth = find.colors(tb_both,93,925,441,960,478)
			if isBoth then
				touch.click(blueButton.x,blueButton.y,1)
				touch.click(redButton.x,redButton.y)
				--sleep(10)
			end
			sleep(ui.time)
			if iscolor(1220,36,0xF10A65,97)	then
				logcat("break")
				break
			end
			--logcat("running")
			--logcat(isRed,isBlue,isBoth)
		until iscolor(1186,34,0xF40668,96)
		autoscreencap (true)
		sleep(2000)
		if iscolor(1186,34,0xF40668,96) then
			touch.click(1186,34)
			logcat("点击返回")
			sleep(3000)
		end
	end
end


-- 此行无论如何保持最后一行
main()
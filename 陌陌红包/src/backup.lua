--[[------------------------------------------------
-- 脚本名称: 陌陌红包
-- 脚本描述: 
--------------------------------------------------

-------------------UI---------------------
ui.newLayout("main")
ui.setTitleText("main","设置")

ui.newRow("456")
ui.addTextView("io","刷新速度：")
ui.addEditText("time","05")
ui.addTextView("xx","（输入大于0的数 , 1最快）")

ui.setFullScreen("main")
ui.show("main")

toast("打开陌陌后点击播放",3000)
sleep(1000)
xscript.pause()


-- 脚本入口
function main()
	ui.updateResult()
	UI = ui.getData() 
	
	--[[app = "com.immomo.momo"

	logcat(str)
	if app ~= str then
		app.start(app)
		sleep(2500)
	end
	
	if not iscolor(52,917,0x00C0FF,95) then	--调到附近
		touch.click(52,917)
		sleep(2000)
	end
	repeat	--调出红包入口
		touch.swipe(290,329,302,640)
		sleep(1000)
	until find.color("0xC8180B", 95, 0,111,541,252)
	
	tb_快去抢 = {0xFFE17F,{0,-2,0xFF0000},{0,18,0xEA0000},{-14,-4,0xF4CC6F},
    {-16,22,0xE90000},{15,27,0xFFDB7C},{-18,-21,0xFFE17F},{18,-21,0xFFE380},
    {17,-18,0xFD0000},{19,-17,0xFFD87A},{14,-4,0xF4D473}}
	
	repeat	--进入刷红包界面
		isFound,x,y = find.colors(tb_快去抢, 95,443,256,537,358)
		sleep(1000)
	until isFound
	touch.click(x,y)
	sleep(1000)]]
	tb_抢红包 = {
    0xE84239,
    {0,3,0xFCE97A},
    {0,5,0xE94B3C},
    {0,8,0xFCE97A},
    {0,11,0xEA5B42},
    {5,11,0xFCE97A},
    {13,11,0xE84239},
    {15,11,0xFCE97A},
    {14,8,0xE8453A},
    {14,6,0xFCE97A}}
	tb_关注财神 = {
    0xE8483B,
    {0,1,0xFCE97A},
    {3,6,0xFCE97A},
    {3,7,0xE84239},
    {0,20,0xFCE97A},
    {-4,20,0xF6BB67},
    {-5,20,0xE84239},
    {-17,20,0xFAD873},
    {-17,19,0xE84239},
    {-16,2,0xFADA74}}
	tb_红包主页 = {
    0xE8473B,
    {0,-2,0xFCE97A},
    {-1,-9,0xEB5B42},
    {0,-17,0xE84239},
    {-8,-18,0xFBE177},
    {-8,-17,0xE84239},
    {-17,-17,0xF9CF6F},
    {-14,-9,0xE84239},
    {-16,-4,0xFCE97A},
    {-15,-2,0xFCE97A}}
	tb_领 = {0x380D00,{-60,-40,0xFFD77D},{41,42,0xFBD872},{43,-47,0xF9D879},{-46,50,0xFBD779},
		{-16,32,0x380D04},{-33,-30,0x370E00},{26,-38,0x3A1000}}
	while true do
		isFound2,x2,y2 = find.colors(tb_抢红包, 90, 394,389, 517,945)
		if not isFound2 then
			isFound3,x3,y3 = find.colors(tb_关注财神, 95,59,708, 508,944) 
			if not isFound3 then
				isFound4,x4,y4 = find.colors(tb_领,95,179,494,354,675)
				if not isFound4 then
					isFound5 = find.colors(tb_红包主页,95,259,289,536,492)
				end
			end
		end
		logcat(isFound2,isFound3,isFound4,isFound5)
		if isFound2 then
			touch.click(x2,y2)
			logcat(x2,y2)
			sleep(100)
			logcat("抢红包")
		elseif isFound3 then
			touch.swipe(290,329,302,640)
			sleep(500)
			logcat("关注财神")
		elseif isFound4 then
			--xscript.pause()
			touch.click(x4+50,y4+50)
			sleep(1500)
			logcat("领")
			key.back()
			sleep(500)
		elseif isFound5 then
			logcat("红包主页")
			key.back()
		end
		sleep(UI.time*100)
	end
	
end]]
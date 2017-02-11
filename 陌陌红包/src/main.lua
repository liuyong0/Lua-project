--------------------------------------------------
-- 脚本名称: 陌陌红包
-- 脚本描述: 适用机型：vivo Y51,720*1280(DPI320),1080*1280(DPI480)
--------------------------------------------------
w,h = systeminfo.deviceSize()  
logcat(w,h)

-------------------UI---------------------
ui.newLayout("main")
ui.setTitleText("main","设置")

--ui.newRow("89")
--ui.addTextView("ui","请输入口令：")
--ui.addEditText("key","点击此处输入口令")

ui.newRow("456")
ui.addTextView("io","刷新速度：")
ui.addEditText("time","05")
ui.addTextView("xx","（输入大于0的数 , 1最快）")

ui.newRow("785")
ui.addLine("89",500,1)
ui.newRow("2132")

ui.addTextView("auther","脚本所有者：红苹果")
ui.newRow("1124")
ui.addTextView("qq","QQ：1982152689")

ui.setFullScreen("main")
ui.show("main")

----------------UI结束----------------------
--vivo Y51/540*960
function vivoY51()
	while true do		
		if find.color(0xFCE97A, 98, 436,526, 501,557) then
			touch.click(467,542)
			sleep(100)
			logcat("抢红包")
		elseif iscolor(269,677,0xD81B17,98) then
			touch.swipe(290,329,302,640)
			sleep(500)
			logcat("关注财神")
		elseif find.color(0x391000,95,224,540,310,627) then
			touch.click(266,586)
			sleep(2000)
			logcat("领")
			key.back()
			sleep(500)
		elseif iscolor(314,761,0xF5F5F5,100) then
			key.back()
			logcat("红包主页")
		end
		sleep(UI.time*100)
	end
end

--720*1280,DPI320
function main720()
	while true do
		if find.color(0x390E00,90,304,727,412,835) then
			touch.click(348,810)
			sleep(100)
			touch.click(348,810)
			sleep(1500)
			logcat("领")
			key.back()
			sleep(400)
		elseif find.color(0xFCE97A, 98,586,710, 659,742) then
			touch.click(629,723)
			sleep(100)
			logcat("抢红包")
		elseif iscolor(441,829,0xBE231E,98) then
			touch.swipe(290,329,302,640)
			sleep(300)
			logcat("关注财神")
		elseif iscolor(465,1006,0xFFFFFF,99) then
			key.back()
			logcat("红包主页")
		end
		if  find.color(0x390E00,90,304,727,412,835) then
			touch.click(348,810)
			sleep(100)
			touch.click(348,810)
			sleep(1500)
			logcat("领")
			key.back()
			sleep(400)
		end
		sleep(UI.time*100)
	end
end



-- 脚本入口
function main()
	ui.updateResult()
	UI = ui.getData() 
	
	--[[if UI.key ~= "1314" then
		toast("口令错误!")
		sleep(1000)
		xscript.stop()
	end]]
	
	toast("打开陌陌后点击播放",3000)
	sleep(500)
	xscript.pause()
	
	--vivo Y51
	if w == 540 then
		if h ==960 then
			vivoY51()
		end
	end
	
	if w == 720 then
		if h == 1280 then
			main720()
		end
	end
	
	if w == 1080 then
		if h == 1920 then
			setscale(1.5, 1.5)  
			main720()
		end
	end
	
end


-- 此行无论如何保持最后一行
main()

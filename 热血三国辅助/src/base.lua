logcat("load base")



--找NPC并点击
function leftFind(times,tb_type1,tb_type2,怪等级min,怪等级max)
	local tb_未开放 = {0x0F7598,{-6,0,0xFCFEFE},{-28,-107,0x061211},
					{-28,-116,0xF5F5F5},{-28,-119,0x051010}}
	for i = 1,times do
		logcat("leftFind",times)
		sleep(1000)
		touch.down(100,360,1)
		sleep(200)
		touch.move(650,360,1)
		sleep(300)
		touch.up(1)
		touch.click(650,360)
		touch.up()
		if find.colors(tb_未开放,90,269,593,448,757) then
			touch.click(361,727)
			sleep(750)
			touch.click(657,829)
			sleep(1000)
		end
		if clickNPC(tb_type1,tb_type2,怪等级min,怪等级max) then
			return true
		end
	end
	return false
end

function upFind(times,tb_type1,tb_type2,怪等级min,怪等级max)
	local tb_未开放 = {0x0F7598,{-6,0,0xFCFEFE},{-28,-107,0x061211},
					{-28,-116,0xF5F5F5},{-28,-119,0x051010}}
	for i = 1,times do
		logcat("upFind",times)
		sleep(1000)
		touch.down(360,1000,1)
		sleep(200)
		touch.move(360,250,1)
		sleep(300)
		touch.up(1)
		touch.click(360,250)
		touch.up()
		if find.colors(tb_未开放,90,269,593,448,757) then
			touch.click(361,727)
			sleep(750)
			touch.click(657,829)
			sleep(1000)
		end
		if clickNPC(tb_type1,tb_type2,怪等级min,怪等级max) then
			return true
		end
	end
	return false
end

function rightFind(times,tb_type1,tb_type2,怪等级min,怪等级max)
	local tb_未开放 = {0x0F7598,{-6,0,0xFCFEFE},{-28,-107,0x061211},
					{-28,-116,0xF5F5F5},{-28,-119,0x051010}}
	for i = 1,times do
		logcat("rightFind",times)
		sleep(1000)
		touch.down(650,360,1)
		sleep(200)
		touch.move(100,360,1)
		sleep(300)
		touch.up(1)
		touch.click(100,360)
		touch.up()
		if find.colors(tb_未开放,90,269,593,448,757) then
			touch.click(361,727)
			sleep(750)
			touch.click(657,829)
			sleep(1000)
		end
		if clickNPC(tb_type1,tb_type2,怪等级min,怪等级max) then
			return true
		end
	end
	return false
end

function downFind(times,tb_type1,tb_type2,怪等级min,怪等级max)
	local tb_未开放 = {0x0F7598,{-6,0,0xFCFEFE},{-28,-107,0x061211},
					{-28,-116,0xF5F5F5},{-28,-119,0x051010}}
	for i = 1,times do
		logcat("downFind",times)
		sleep(1000)
		touch.down(360,250,1)
		sleep(200)
		touch.move(360,1000,1)
		sleep(300)
		touch.up(1)
		touch.click(360,1000)
		touch.up()
		if find.colors(tb_未开放,90,269,593,448,757) then
			touch.click(361,727)
			sleep(750)
			touch.click(657,829)
			sleep(1000)
		end
		if clickNPC(tb_type1,tb_type2,怪等级min,怪等级max) then
			return true
		end
	end
	return false
end


--进攻NPC
--返回值：true：成功，false:无可出征的将领或派出失败
function attackNPC()
	local tb_进攻 = {0xF0F9FA,{3,0,0x3CABC2},{3,14,0x0E7397},{1,14,0xB2D2DE}}
	local tb_出征 = {0xE7F3F7,{0,-2,0x1C9DC5},{7,2,0xF8FBFC},{5,9,0x1B93BA},
					{10,13,0xF9FAFB},{0,16,0x1C98BF},{0,12,0xFEFFFF},{-9,13,0xFFFFFF},
					{-4,9,0x1B8FB3},{-7,2,0xD4E2E8}}
	local tb_将领出击 = {0xEEF9FA,{0,-2,0x57BFD1},{7,3,0xF1F9FB},{9,3,0x4BB0C7},
					{-7,3,0xDFF1F5},{-8,3,0x62BCCE},{8,8,0xCAE6ED},{11,8,0x1F94B1},
					{-8,8,0xCAE6ED},{-10,8,0x309CB7},{0,16,0xDCEBF0},{0,19,0x0C6D92},
					{-2,14,0x1581A3},{2,14,0x1581A3}}
	local tb_确定 = {0xF9FDFD,{0,-3,0x5AC5D5},{9,4,0xF2FAFB},{9,6,0x269EB9},
					{9,18,0xE7F1F5},{11,18,0x10789A},{2,15,0x2489A9},{0,12,0xF5FAFB},
					{2,9,0x2D9BB6},{0,4,0x45B0C6}}

	if find.colors(tb_进攻,95,426,859,481,890) then
		touch.click(454,875)
		logcat("进攻")
		sleep(1000)
	else
		return false
	end
	
	find.setResult(4)
	local is_出征,x,y,tb = find.colors(tb_出征,90,108,414,148,900)
	find.setResult(1)
	if is_出征 then
		for i=2,#tb do
			touch.click(tb[i].x+100,tb[i].y)
			sleep(1000)
			logcat("选择出征将领")
		end
	else
		logcat("无可出征的将领")
		toast("无可出征的将领")
		if iscolor(287,986,0x8E3636,95) then
			touch.click(287,986)
			sleep(1000)
			logcat("取消")
		end
		return false
	end
	
	if find.colors(tb_将领出击,90,406,964,513,1001) then	
		touch.click(455,983)
		sleep(1000)
		logcat("将领出击")
	end
	
	if iscolor(292,711,0x8E3636,98) then
		if iscolor(423,711,0x1A8BAA,98) then
			touch.click(482,709)
			sleep(1000)
			logcat("确定出征")
			return true
		end
	end
end


--点击指定等级的NPC
function clickNPC(tb_type1,tb_type2,怪等级min,怪等级max)
	logcat("怪等级:"..怪等级min,怪等级max)
	if 怪等级min<10 then
		find.setResult(5)  
		local is_type,x,y,tb = find.colors(tb_type1[1],70,9,89,612,1046)
		logcat(is_type,x,y)
		if is_type then
			for j=怪等级min,9 do
				for i=1,#tb do
					if ocrClass(tb_type1,tb[i].x,tb[i].y) == j then
						if find.colors({0xB1FFA0,{1,0,0x9FFF8F}},95,tb[i].x-90,tb[i].y-130,tb[i].x+105,tb[i].y+50) then
							logcat("已派将")
							return false
						end
						touch.click(tb[i].x,tb[i].y)
						sleep(100)
						touch.click(tb[i].x,tb[i].y)
						logcat("点击NPC")
						sleep(1000)
						return true
					end
				end
			end
		end
	end
	
	if 怪等级max>=10 then
		local is_type,x,y,tb = find.colors(tb_type2[1],70,9,89,612,1046)
		find.setResult(1) 
		logcat(is_type,x,y)
		if is_type then
			for j=10,怪等级max do
				for i=1,#tb do
					if ocrClass(tb_type2,tb[i].x,tb[i].y) == j then
						if find.colors({0xB1FFA0,{1,0,0x9FFF8F}},95,tb[i].x-90,tb[i].y-130,tb[i].x+105,tb[i].y+50) then
							logcat("已派将")
							return false
						end
						touch.click(tb[i].x,tb[i].y)
						sleep(100)
						touch.click(tb[i].x,tb[i].y)
						logcat("点击NPC")
						sleep(1000)
						return true
					end
				end
			end
		end
	end
	
	return false
end


--识别怪的等级
--返回怪等级
function ocrClass(tb_type,x,y)
	local 字典路径 = xscript.scriptDir()
	--logcat(xscript.scriptDir())
	--logcat(xscript.scriptPath())
	local 字典语言 = "eng"
	local 配置	 = {["tessedit_char_whitelist"] = "1234567890",
					["tessedit_char_blacklist"] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"}
	local text = ocr.screen(x+tb_type[2],y+tb_type[3],x+tb_type[4],y+tb_type[5],字典路径,字典语言,配置)
	logcat("识别结果[" .. text .."]")
	return tonumber(text)
end


--复制机器码
function fuzhi()						--复制ID
	system.setClip(全局_机器编码)
	toast("ID复制成功")
end






logcat("load function")
require("base")

function 刷怪(怪等级min,怪等级max)
	logcat("怪等级:"..怪等级min,怪等级max)
	local tb_我的城池 = {0x7BCE8B,{-5,18,0x11502A},{30,31,0x88D995},
						{-5,62,0x070A0D},{-5,66,0x03060A},{-5,64,0xCDC59A}}
	local tb_世界 = {0x560E0C,{-61,9,0xF2A73F},{-42,7,0xF0D54B},{29,-1,0xFEE85C},{49,8,0xF9B73D}}
	local tb_内城 = {0x0F1016,{-55,2,0xE7963E},{-34,2,0x7F8594},{32,1,0x737986},{55,1,0xEE9F3A}}
	local tb_流寇1 = {{0xBFBFBF,{1,2,0x0B170A},{-4,0,0x010301},{22,-13,0xEFEFEF},{21,-8,0xCBCDCB},{24,-10,0x030703},
					{24,-6,0x010301},{20,1,0xE5E6E5},{22,3,0x010101},{25,1,0xE8E8E8},
					{27,2,0x0A0C09},{30,2,0xCDCECD},{32,3,0x030303},{37,3,0x000100},
					{36,1,0xD9DAD9},{36,-5,0x020302},{35,-7,0xE3E3E3},{36,-10,0x000000},
					{35,-12,0xEDEDED},{30,-14,0xC8CAC8}},2,-16,16,4}
	local tb_流寇2 = {{0xAFB0AF,{1,2,0x0B170A},{-4,0,0x010301},{32,-13,0xE2E2E2},{35,-10,0x040403},{32,-8,0xF6F6F5},
					{35,-6,0x010301},{31,1,0xECECEB},{33,3,0x010100},{41,2,0xD7D9D6},
					{45,2,0xD6D6D6},{48,3,0x010201},{48,-10,0x020401},{46,-12,0xCCCECA},
					{41,-10,0x0A0A09},{40,-14,0xC3C6C0}},3,-15,24,4}
	
	
	
	--进入世界界面
	if find.colors(tb_世界,90,299,1168,424,1272) then
		touch.click(361,1218)
		logcat("进入世界界面")
		repeat
			sleep(500)
		until find.colors(tb_内城,90,297,1167,421,1273)
		
		--定位到我的城池
		if find.colors(tb_我的城池,90,612,780,701,873) then
			touch.click(660,827)
			sleep(1000)
			logcat("我的城池")
		end
	end
	
	sleep(1000)
	local flag
	local count = 1
	for i=1,4 do
		--点击流寇
		if i==1 then
			if clickNPC(tb_流寇1,tb_流寇2,怪等级min,怪等级max) then
				sleep(500)
				if attackNPC() == false then
					toast("无可派出将领")
					logcat("无可派出将领--刷怪函数")
					break
				end
			end
		end
		
		repeat
			flag = leftFind(count,tb_流寇1,tb_流寇2,怪等级min,怪等级max)
			if flag then
				break
			end
			sleep(500)
			
			flag = upFind(count,tb_流寇1,tb_流寇2,怪等级min,怪等级max)
			if flag then
				break
			end
			sleep(500)
		
			count = count + 1
	
			flag = rightFind(count,tb_流寇1,tb_流寇2,怪等级min,怪等级max)
			if flag then
				break
			end
			sleep(500)
			
			flag = downFind(count,tb_流寇1,tb_流寇2,怪等级min,怪等级max)
			if flag then
				break
			end
			sleep(500)
			
			count = count + 1
		until count>12
		sleep(1000)
		
		if attackNPC() == false then
			logcat("无流寇可打--刷怪函数")
			break
		end
		
	end
	
	if find.colors(tb_内城,95,297,1167,421,1273) then
		touch.click(361,1218)
		logcat("进入内城界面")
	end
end









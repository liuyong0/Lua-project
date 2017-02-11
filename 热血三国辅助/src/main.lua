--------------------------------------------------
-- 脚本名称: 热血三国辅助
-- 脚本描述: 
--------------------------------------------------
w,h = systeminfo.deviceSize()  
if w~=720 then
	toast("分辨率不适用!")
	xscript.stop()
end

require("function")
require("register")
require("base")
local 路径 = xscript.scriptDir().."password.txt" 


toast("请在游戏内城界面点击播放",3000)
xscript.pause()

---------------------UI界面----------------------
function 激活码()
	ui.newLayout("激活码",360)
	ui.setTitleText("激活码","激活界面")

	ui.addButton("fuzhiid","复制ID",85,40)
	ui.setOnClick("fuzhiid","fuzhi()")
	ui.addTextView("id","您的设备ID:")
	ui.addTextView("imei","10"..全局_机器编码) 

	ui.newRow("a")
	--ui.addTextView("nji","输入激活码:",16,ui.WRAP_CONTENT,ui.WRAP_CONTENT)
	ui.addEditText("password", "点击此处输入激活码，已验证设备勿再输入",360,40)  

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
ui.setTitleText("main","辅助配置")

ui.newRow("001")
ui.addButton("jhjm","激活码注册",120,35)		--激活界面
ui.setOnClick("jhjm","激活码()")
ui.addTextView("id00","您的设备ID：")
ui.addTextView("imei","10"..全局_机器编码) 

ui.newRow("12354")
ui.addLine("999")

ui.newRow("784")
ui.addTextView("time0","☞设置运行间隔时间： ")
ui.addEditText("time","100",ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.addTextView("time1"," 秒")

ui.newRow("45")
ui.addCheckBox("刷流寇","☞选择刷流寇的等级：",true)
--ui.addTextView("poi","☞选择刷流寇的等级：")
ui.addSpinner("流寇等级min",{"5", "6","7", "8","9","10","11","12","13","14","15"},1,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.addTextView("-"," ~ ")
ui.addSpinner("流寇等级max",{"5", "6","7", "8","9","10","11","12","13","14","15"},5,ui.WRAP_CONTENT,ui.MATCH_PARENT)
ui.addTextView("po","（不勾选则不启用该功能）")

ui.newRow("99")

ui.setFullScreen("main")  
ui.show("main")
--------------------UI结束------------------------





-- 脚本入口
function main()
	tb_ui = ui.getData()
	
	------------------------网络验证----------------------------
	toast("网络验证中，请稍后",3000)
	local password = tb_ui.password
	if password ~=nil then
		if string.len(password) == 32 then
			xutil.writeToFile(路径, password)
		end
	end
	
	if xutil.isFileExists(路径) then
		logcat(路径)
		file,err = io.open(路径,"rw")
		logcat(err)
		password = xutil.readFileAll(路径)
		io.close()
	end
	if password == nil then
		toast("请输入激活码",3000)
		xscript.stop()  
	end
	
	--B407BE04AF53BC6ECF12994CA1F7F291
	-- 软件执行的第一时间调用这个方法，用来初始化重要数据
	数据初始化("幻想三国","77a762748d995273023b45483712b781",password,"2.0.0.0")
	
	-- 进行注册码的登录验证
	if 验证注册码() == false then
		toast("注册码登录失败,原因："..全局_错误信息)
		xscript.stop()
	else
		-- 开启定时器进行注册码的时间验证操作。
		setTrigger.timeLoop(180000, "获取注册码的剩余时间()")
	end
	获取注册码的剩余时间()
	-------------------------验证结束----------------------------
	
	logcat(tb_ui.time)
	while true do
		if tb_ui.刷流寇 == true then
			logcat(tb_ui.流寇等级min,tb_ui.流寇等级max)
			刷怪(tonumber(tb_ui.流寇等级min),tonumber(tb_ui.流寇等级max))
		end
		toast(tb_ui.time.."秒后开始下一次派将",3000)
		sleep(tb_ui.time*1000)
	end
end


-- 此行无论如何保持最后一行
main()

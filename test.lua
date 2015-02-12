--ショートカットをpeerstplayerに似せたlua

--ボリューム関係
initialvolume = 11			--初期ボリューム
volume = 5				--マウスホイールの変更量
ctrlvolume = 3				--control押しながらの時
shiftvolume = 1				--shift押しながらの時

--ステータス表示
statusbar = 1				--ステータスバー（の代わりのタイトルバー）のオンオフ（うまく動かない）
showcontainertype = 1			--ビデオコーデックかコンテナ表示（未表示は未実装）
showwindowsize = 1			--表示動画サイズを表示（未表示は未実装）
showsoucesize = 1			--動画の元のサイズを表示（未実装）
showfps = 1				--fps表示（未表示は未実装）
showbitrate = 1				--ビットレート表示（1秒間にdemuxerが処理した量?）（未表示は未実装）
showcachesize = 1			--キャッシュサイズを表示（未表示は未実装）

--スクリーンショット関係
sstype = "jpg"				--「"png"」又は「"jpg"」
jpgquality = 90				--jpgの時の画質。0-100
sssize = 1				--ソースサイズ「1」か表示windowサイズ「0」か
ssfolder = "d:\\a b\\" 			--保存場所。区切りは｢\\｣で両端の"と最後の\\は必須




orgwidth , orgheight = 0,0
mp.set_property("options/volume", initialvolume )
function errorproof(case)
	local hantei = nil
--	print(case)
	if case == "path" then
		if string.find(mp.get_property("path"),"/stream/".. string.rep("%x", 32)) ~= nil then
		hantei = 1
		else hantei = 0
		end
	elseif case == "start" then
		if mp.get_property_number("playlist-count")  < 2 then
		hantei = 1
		else hantei = 0
		end
	elseif case == "playing" then
		if 	mp.get_property("estimated-vf-fps") ~= nil 
			or mp.get_property("playback-time") ~= nil
		then
		hantei = 1
		else hantei = 0
		end
	end
	return hantei 
end
function initialize()
	if errorproof("path") == 1 then
		print("initialize")
		vrate,arate,srate = 0,0,0
		--動画サイズ取得
		orgwidth  = mp.get_property("width")
		if orgwidth == nil then orgwidth = 0 end
		currentwidth = orgwidth
		orgheight = mp.get_property("height")
		if orgheight == nil then orgheight = 0 end
	--	currentheight = orgheight
--		orgwidth,orgheight = 0,0
--		fps = "0.0"
		--fps取得
		if mp.get_property_number("fps") == nil then fps = 0
		else fps = mp.get_property_number("fps")
		end
		fps = string.format("%4.1f", fps)
		--ビデオコーデック取得
--		vcodec = mp.get_property("video-codec")
		if mp.get_property("track-list/0/type") == "video" then
			vcodec = mp.get_property("track-list/0/codec")
		else	vcodec = mp.get_property("track-list/1/codec")
		end
		ttype = vcodec
		--コンテナ取得
--		ttype = mp.get_property("file-format")
		if	ttype == nil then ttype = "[0]"
		else	ttype = "["..ttype.."]"
		end

--		if statusbar == 1 then
--			if mp.get_property("border") == "no" then mp.commandv("cycle" , "border")
--			end
--		elseif mp.get_property("border") == "yes" then mp.commandv("cycle" , "border")
--		end
--		print(mp.get_property("border"))
--		print(mp.get_property("options/border"))
		mp.set_property("loop", "inf")
	else print("notpecapath")
	end	
end
mp.register_event("file-loaded", initialize)


local timer = mp.get_time()
function reconnectlua ()
	  if mp.get_property_bool("core-idle") then
    if mp.get_time() - timer >= 20 then
      timer = mp.get_time()
      mp.osd_message("reconnect",3)
      print("reconnect")
      mp.commandv("playlist_next")
    end
  else
    timer = mp.get_time()
  end
end

mp.add_periodic_timer(1, (function ()
	if errorproof("playing") == 1 and errorproof("path") == 1
	then
		tmediatitle = mp.get_property("media-title")
		ttime = mp.get_property_osd("playback-time")
		--ビットレート取得
		if
			vrate ~= mp.get_property("packet-video-bitrate")
		then
			vrate = mp.get_property("packet-video-bitrate")
			arate = mp.get_property("packet-audio-bitrate")
			trate = vrate + arate
		else
			trate = vrate + arate
		end
		if srate == nil then srate = 0 end 
		if srate == 0 then 
			srate = mp.get_property("stream-pos")
			trate = srate /1024 * 8
		else
			trate = (mp.get_property("stream-pos") - srate) /1024 * 8
			srate = mp.get_property("stream-pos")
		end
		trate = string.format("%4dk ", trate)
		--キャッシュ取得
		tcache = string.format("%03d" , mp.get_property("cache-used", 0))
		--fps取得
--		if errorproof("playing") == 1 then
--			if fps == nil then fps = string.format("%4.1f", mp.get_property("fps"))
--			elseif fps == "1000.0" then fps = "vfr"
--			elseif fps == "0.0" then string.format("%4.1f", mp.get_property("fps"))
--			end
--		else fps = "0.0"
--		end
		currentfps = mp.get_property("estimated-vf-fps")
		if currentfps == nil then currentfps = 0 end
		tfps = string.format("%4.1f", currentfps).."/"..fps
		--ボリューム取得
		local vol = mp.get_property("volume")
--		if vol == nil then vol = 0
--		end
		tvol =  string.format(" vol:%d", vol)
		if
			mp.get_property_bool("mute") then tvol = " vol:-" 
		end
		--解像度取得
--		if orgwidth == 0 and mp.get_property("width") ~= nil then orgwidth = mp.get_property("width") end
--		if orgheight == 0 and mp.get_property("height") ~= nil then orgheight  = mp.get_property("height") end
		tcurrentsize = ""--string.format("%d",currentwidth).."x"..string.format("%d",currentheight).." "
		torgsize = string.format("%d",orgwidth).."x"..string.format("%d",orgheight)..""
		--まとめてタイトルバーに表示
		tbarlist = ttype .. tmediatitle .." ("..torgsize..""..tcurrentsize.." " ..trate.."".. tfps ..") c:".. tcache .."KB".. " ".. ttime .. tvol
		mp.set_property("options/title", tbarlist )

	else 
		if errorproof("path") == 1 then reconnectlua () end
	end
end))

--再生スピードでキャッシュ量調整（重くなるかも）
function autospeed(name, value)
	if 	value > 1000 then
		mp.set_property("speed", 1.05)
	elseif 	value < 500 then
		mp.set_property("speed", 1.00)
	elseif	value < 100 then
		mp.set_property("speed", 0.95)
	end
end
mp.observe_property("cache-used", "number", autospeed)

function mutewhenminimize(name, value)
if value == true then
mp.set_property("screen", 32)
end
end
mp.observe_property("mute", "bool", mutewhenminimize)

function test()
	print(mp.get_property("video-params/w"))
	print(mp.get_property("time-pos"))
	print(mp.get_property("fps"))
	print(mp.get_property("speed"))
end
mp.add_key_binding("KP9", "test" , test)

--画面サイズ変更用
function changewindowsize(newwidth , newheight , kurobuti)
	mp.set_property("vf","dsize=" .. math.floor(newwidth) ..":".. math.floor(newheight) ..":".. kurobuti .."::0")
	mp.set_property_number("window-scale" , 1)
	currentwidth = mp.get_property("dwidth")
	currentheight = mp.get_property("dheight")
	mp.set_property("vf","dsize=".. orgwidth .. ":" .. orgheight)
end

--URL取得と分割
function getpath()
    local fullpath = mp.get_property("path")
    local id = {string.find(fullpath,"/stream/(%x*)")}
    local a = {}
    for i in string.gmatch(fullpath, "[^/]+") do
      table.insert(a, i)
    end
    return fullpath,a[2],id[3]
end

--スクリーンショット
function screenshot()
	if errorproof("playing") == 1 then
		mp.set_property("options/screenshot-format", sstype )
		mp.set_property("options/screenshot-jpeg-quality", jpgquality )
		mp.set_property("options/screenshot-template", ssfolder .."%{media-title}_%tX_%n")
		if sssize == 0 then sssize = "window" 
		else sssize = "video"
		end
		mp.commandv("screenshot" , sssize )
		mp.osd_message("screenshot")
	end
end
mp.add_key_binding("p", "screenshot", screenshot)

--ボリューム上げる
function gainvolume()
	mp.commandv("add", "volume", volume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Up", "gainvolume", gainvolume)
mp.add_key_binding("MOUSE_BTN3", "gainvolume_wheel", gainvolume)

function cgainvolume()
	mp.commandv("add", "volume", ctrlvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Ctrl+MOUSE_BTN3", "cgainvolume_wheel", cgainvolume)

function sgainvolume()
	mp.commandv("add", "volume", shiftvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Shift+Up", "sgainvolume", sgainvolume)
mp.add_key_binding("Shift+MOUSE_BTN3", "sgainvolume_wheel", sgainvolume)

--ボリューム下げる
function reducevolume()
	mp.commandv("add", "volume", -1 * volume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Down", "reducevolume", reducevolume)
mp.add_key_binding("MOUSE_BTN4", "reducevolume_wheel", reducevolume)

function creducevolume()
	mp.commandv("add", "volume", -1 * ctrlvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Ctrl+MOUSE_BTN4", "creducevolume_wheel", creducevolume)

function sreducevolume()
	mp.commandv("add", "volume", -1 * shiftvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Shift+Down", "sreducevolume", sreducevolume)
mp.add_key_binding("Shift+MOUSE_BTN4", "sreducevolume_wheel", sreducevolume)

--音声を左のみに
function panleft()
	if mp.get_property_number("audio-channels") == 1 then
	mp.set_property("af", "pan=2:[ 1 , 0 ]")
	else mp.set_property("af", "channels=2:[ 1-0 , 1-0 ]")
	end
end
mp.add_key_binding("Ctrl+Left", "panleft", panleft)

--音声を右のみに
function panright()
	if mp.get_property_number("audio-channels") == 1 then
	mp.set_property("af", "pan=2:[ 1 , 1 ]") end
	mp.set_property("af", "channels=2:[ 0-1 , 0-1 ]")
end
mp.add_key_binding("Ctrl+Right", "panright", panright)

--音声を中央（モノラル）に
function pancenter()
	mp.set_property("af", "pan=1:[ 1 , 1 ]")
end
mp.add_key_binding("Ctrl+Up", "pancenter", pancenter)

--音声を普通のステレオに
function panrestore()
	mp.set_property("af", "channels=2")
end
mp.add_key_binding("Ctrl+Down", "panrestore", panrestore)

--フルスクリーン
function fullscreen()
	mp.commandv("cycle" , "fullscreen")
end
mp.add_key_binding("Alt+Enter", "fullscreen", fullscreen)

--終了
function exit()
	mp.commandv("quit")
end
mp.add_key_binding("Esc", "exit", exit)

--ステータスバーの代わり
function titlebar()
	mp.commandv("cycle" , "border")
end
mp.add_key_binding("Enter", "titlebar", titlebar)

--最前面表示切り替え
function ontop()
	mp.commandv("cycle", "ontop")
	if mp.get_property_bool("ontop")
	then mp.osd_message("ontop")
	else mp.osd_message("ontop_off")
	end
end
mp.add_key_binding("t", "ontop", ontop)

--リレー再接続
function bump()
	if errorproof("path") == 1 then
	local streampath,localhost,streamid = getpath()
	mp.commandv("playlist_clear")
	mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
	mp.commandv("playlist_next")
	mp.osd_message("bump",3)
	end
end
mp.add_key_binding("Alt+b", "bump" , bump)

--リレー切断
function stop()
	if errorproof("path") == 1 then
	local streampath,localhost,streamid = getpath()
	mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=stop&id=".. streamid)
	end
end
mp.add_key_binding("Alt+x", "stop" , stop)

--ここからwindowサイズ変更
function to50per()
	local targetsize = 0.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("1", "50%", to50per)

function to75per()
	local targetsize = 0.75
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("2", "75%", to75per)

function to100per()
	local targetsize = 1
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("3", "100%", to100per)

function to150per()
	local targetsize = 1.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("4", "150%", to150per)

function to200per()
	local targetsize = 2
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("5", "200%", to200per)

function to250per()
	local targetsize = 2.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("6", "250%", to250per)

function to300per()
	local targetsize = 3
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("7", "300%", to300per)

function to25per()
	local targetsize = 0.25
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("8", "25%", to25per)

function to160x120()
	local targetsize = {160 , 120}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+1", "160x120", to160x120)

function to320x240()
	local targetsize = {320 , 240}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+2", "320x240", to320x240)

function to480x360()
	local targetsize = {480 , 360}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+3", "480x360", to480x360)

function to640x480()
	local targetsize = {640 , 480}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+4", "640x480", to640x480)

function to800x600()
	local targetsize = {800 , 600}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+5", "800x600", to800x600)

function to1280x960()
	local targetsize = {1280 , 960}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+6", "1280x960", to1280x960)

function to1600x1200()
	local targetsize = {1600 , 1200}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+7", "1600x1200", to1600x1200)

function to1920x1440()
	local targetsize = {1920 , 1440}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+8", "1920x1440", to1920x1440)

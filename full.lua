--ショートカットをpeerstplayerに似せたlua

--初期設定
--ボリューム関係
initialvolume = 11			--初期ボリューム
volume = 5				--マウスホイールの変更量
ctrlvolume = 3				--control押しながらの時
shiftvolume = 1				--shift押しながらの時

--ステータス表示
statusbar = 0				--ステータスバー（の代わりのタイトルバー）のオンオフ（うまく動かない）
showcontainertype = 1			--ビデオコーデックかコンテナ表示（未表示は未実装）
showwindowsize = 1			--表示動画サイズを表示（未表示は未実装）
showsoucesize = 1			--動画の元のサイズを表示（未表示は未実装）
showfps = 1				--fps表示（未表示は未実装）
showbitrate = 1				--大体のビットレート表示（未表示は未実装）
showcachesize = 1			--キャッシュサイズを表示（未表示は未実装）

--スクリーンショット関係
sstype = "jpg"				--「"png"」又は「"jpg"」
jpgquality = 90				--jpgの時の画質。0-100
sssize = 1				--ソースサイズ「1」か表示windowサイズ「0」か
ssfolder = "d:\\a b\\" 			--保存場所。区切りは｢\\｣で最後の\\がないとファイル名に化けます

--その他
icursorhide = 1				--マウスカーソルを自動的に隠す。2はフルスクリーンのみ隠す
iontop = 1				--最前面表示（うまく動かない）
recordfolder = "d:\\a b\\"		--録画フォルダ


--キーバインド				--（）内はデフォルト
--音関係
kvolup = "Up"				--ボリュームアップ（↑キー）
kvoldown = "Down"			--ボリュームダウン（↓キー）
kvolup_wheel = "MOUSE_BTN3"		--ボリュームアップ2つめ（ホイール↑）
kvoldown_wheel = "MOUSE_BTN4"		--ボリュームダウン2つめ（ホイール↓）
kvolup2 = "Ctrl+MOUSE_BTN3"		--中ボリュームアップ（ctrl押しながらホイール↑）
kvoldown2 = "Ctrl+MOUSE_BTN4"		--中ボリュームダウン（ctrl押しながらホイール↓）
kvolup3 = "Shift+MOUSE_BTN3"		--小ボリュームアップ（shift押しながらホイール↑）
kvoldown3 = "Shift+MOUSE_BTN4"		--小ボリュームダウン（shift押しながらホイール↓）
kpanleft = "Ctrl+Left"			--音声を左のみに（ctrl押しながら←）
kpanright = "Ctrl+Right"		--音声を右のみに（ctrl押しながら→）
kpancenter = "Ctrl+Up"			--音声をモノラルに（ctrl押しながら↑）
kpanstereo = "Ctrl+Down"		--音声を普通のステレオに（ctrl押しながら↓）
kmute = "MOUSE_BTN1"			--ミュート（マウス中クリック）

--プレイヤーの状態
--kminimize = "未実装"
kfullscreen = "Alt+Enter"		--フルスクリーン（alt押しながらenter）
kstatusbar = "Enter"			--タイトルバー表示非表示（enter）
--kminmute = "未実装"
kexit = "Esc"				--終了（escape）
kontop = "t"				--最前面表示（t）

--リレー操作
kstop = "Alt+x"				--リレー切断（alt押しながらx）
kbump = "Alt+b"				--リレー再接続（alt押しながらb）

--スクリーンショット
kscreenshot = "p"			--スクリーンショットキー（p）
krecord = "r"				--録画開始と終了（r）


--ウィンドウサイズ変更
--ウィンドウサイズ基準
k160x120 = "Alt+1"
k320x240 = "Alt+2"
k480x360 = "Alt+3"
k640x480 = "Alt+4"
k800x600 = "Alt+5"
k1280x960 = "Alt+6"
k1600x1200 = "Alt+7"
k1920x1440 = "Alt+8"
--動画サイズ基準
k50 = "1"
k75 = "2"
k100 = "3"
k150 = "4"
k200 = "5"
k250 = "6"
k300 = "7"
k25 = "8"



orgwidth , orgheight = 0,0
mp.set_property("options/volume", initialvolume )
tbarlist = mp.get_property("options/title")
if icursorhide == 1 then mp.set_property("options/cursor-autohide" , "3000" )
elseif icorsorhide == 2 then mp.set_property("options/cursor-autohide-fs-only" , 3000 )
end
	if statusbar == 1 then
		if mp.get_property("options/border") == "no" then mp.set_property("options/border", "yes")
		end
	elseif mp.get_property("options/border") == "yes" then mp.set_property("options/border", "no")
	end
print(mp.get_property("options/cursor-autohide"))
print(mp.get_property("options/border"))
print(mp.get_property("options/ontop"))


function errorproof(case)
	local hantei = nil
--	print(case)
	if 	case == "path" then
		if string.find(mp.get_property("path"),"/stream/".. string.rep("%x", 32)) then
		hantei = 1
		else hantei = 0
		end
	elseif	case == "firststart" then
		if mp.get_property_number("playlist-count")  < 3 then
		hantei = 1
		else hantei = 0
		end
	elseif	case == "playing" then
		if 	mp.get_property("estimated-vf-fps")
			or mp.get_property("playback-time") 
			or mp.get_property_number("demuxer-cache-duration")
		then
		hantei = 1
		else hantei = 0
		end
	elseif	case == "videoonly" then
		if 	not mp.get_property("aid") then
			hantei = 1
			else hantei = 0
		end
	elseif case == "errordata" then
		if	mp.get_property("track-list/2/codec") then
			hantei = 1
			else hantei = 0
		end
	elseif	not mp.get_property(case) then
		hantei = 1
	end
	return	hantei 
end

function errordata()
--		mp.commandv("playlist-next", "force")
--	bump()
	refresh()
		print("errordata")
end

function datacheck(bool)
	if	bool and errorproof("errordata") == 1 then
		print(bool)
		refresh()
	end
end
mp.observe_property("core-idle", "bool", datacheck)

function avsync(value)
--	if	value > 1 then
--		mp.commandv("drop_buffers")
--	end
print(value)
end
--mp.observe_property("avsync", "number", avsync)

function cacheerror(value)
local a = mp.get_property_number("demuxer-cache-duration")
	if a ~= nil and a > 3 then
--		mp.commandv("drop_buffers")
		mp.commandv("playlist_next", "force")
	end
end
--mp.observe_property("demuxer-cache-duration", "number", cacheerror)

function timer()
--	reconnectlua()
	if 	errorproof("playing") == 1 and errorproof("firststart") == 0 then
		if errorproof("errordata") == 0 then
			mp.add_timeout(0.1, getstatus)
			mp.set_property("options/title", tbarlist )
--			mp.add_timeout(0.8, getstatus)
		else	errordata()
		end
	else 
		print("buffer?")
	end
end

--キャッシュ取得
function getcache()
	local cache
	if 	mp.get_property("paused-for-cache") == "no" and mp.get_property("cache-used") ~= nil then
		cache = mp.get_property_number("cache-used", 0)
	else
		print("getcachefail")
		cache = 0
	end
	
	if cache == nil then cache = 0
	end
	return cache
end

function getstreampos()
	streampos = mp.get_property("stream-pos")
end

--ビットレート取得
function getbitrate()
--	local vrate,arate,brate,srate
	if vrate == nil then vrate = 0
	end
	
	if	vrate ~= mp.get_property("packet-video-bitrate") then
		if	errorproof("\"packet-video-bitrate\"") == 1 then
			vrate = mp.get_property("packet-video-bitrate")
		else	vrate = 0
		end
		if	errorproof("\"packet-audio-bitrate\"") == 1 then
			arate = mp.get_property("packet-audio-bitrate")
		else	arate = 0
		end
		if	vrate == nil then vrate = 0
		end
		if	arate == nil then arate = 0
		end
		brate = vrate + arate
	else
		brate = vrate + arate
	end
print("keyflame")
	if 	not srate then srate = 0
	end 
	
	mp.add_timeout(0.1,getstreampos)
	if	streampos == nil then srate = 0
	else
		if 	srate == 0 then 
			srate = streampos
			brate = srate /1024 * 8
		else
			brate = ((brate + streampos - srate) /1024 * 8)/2
			srate = streampos
		end
	end
print(streampos)
	if brate == nil then brate = 0
	end
	
	return brate
end

--現在fps取得
function getfps()
	local fps = mp.get_property("estimated-vf-fps")
--	if not fps then fps = "0.0"
--	end
	
--	fps = mp.get_property("estimated-vf-fps")
	if not fps then fps = 0
	end
	
--	if fps == nil then fps = 0
--	end
	
	return fps
end

--ボリューム取得
function getvolume()
	local vol = mp.get_property("volume")
	if errorproof("videoonly") == 1 or vol == nil then vol = 0
	end
	
	return vol
end

--解像度取得
function getresolution(tateyoko)
	if	tateyoko == "tate" then tateyoko = mp.get_property("osd-height")
		else tateyoko = mp.get_property("osd-width")
	end
--	local currentwidth , currentheight = mp.get_property("osd-width"), mp.get_property("osd-height")
	if not tateyoko then tateyoko = 0
	end

	return tateyoko
end

function getstatus()
--	if ttime ~= mp.get_property_osd("playback-time") then
	ttime = mp.get_property_osd("playback-time")
	--キャッシュ取得
--	cache = mp.get_property_number("cache-used", 0)
--	mp.add_timeout(0.01 , getcache)
--	if not cache then cache = 0
--	end
--		print("timerstart")
	local cache = getcache()
	local tcache = string.format("c:%03dKB" , cache)
	autospeed("",cache)
--print("timer2")
	local trate = string.format("%4dk ", getbitrate())
--print("bitrate")
	local tfps = string.format("%4.1f", getfps()).."/"..fps
--print("fps")
	local tvol =  string.format(" vol:%d", getvolume())
--print("getvol")
--	local trec , tbarlist
	if	mp.get_property_bool("mute") then tvol = " vol:-" 
	end
--	local currentwidth,currentheight = getresolution()
	local currentsize = string.format("%d",getresolution("yoko")).."x"..string.format("%d",getresolution("tate"))
	if 	currentsize == orgsize then tsize = currentsize
		else	tsize = orgsize..">"..currentsize.." "
	end
--print("timer4")
	--まとめてタイトルバーに表示
	local trec = ""
	if 	recording ~= nil and recording == 1 then trec = "rec"
	else	trec = ""
	end
	tbarlist = trec..ttype .. tmediatitle .." ("..tsize.." " ..trate.."".. tfps ..") ".. tcache .. " ".. ttime .. tvol
--	print("timerend")
--	mp.add_timeout(0.5, on)
--	return tbarlist

end

--ファイル情報取得とタイマースタート
function initialize()
	if errorproof("errordata") == 1 and errorproof("playing") == 1 then errordata()
	else
	if errorproof("path") == 1 then
		print("initialize")
		vrate,arate,srate,brate = 0,0,0,0
		tmediatitle = mp.get_property("media-title")
		--動画サイズ取得
		orgwidth  = mp.get_property("width")
		if not orgwidth then orgwidth = 0
		end
		orgheight = mp.get_property("height")
		if not orgheight then orgheight = 0
		end
		orgsize = string.format("%d",orgwidth).."x"..string.format("%d",orgheight)
		--fps取得
		fps = mp.get_property_number("fps")
		if 	not fps then fps = "0.0"
			elseif fps == 1000 then fps = "vfr"
			else fps = string.format("%4.1f", fps)
		end
		--ビデオコーデック取得
--		vcodec = mp.get_property("video-codec")
		if mp.get_property("track-list/0/type") == "video" then
			vcodec = mp.get_property("track-list/0/codec")
		else	vcodec = mp.get_property("track-list/1/codec")
		end
		ttype = vcodec
		--コンテナ取得
--		ttype = mp.get_property("file-format")
		if	not ttype then ttype = "[0]"
		else	ttype = "["..ttype.."]"
		end
		mp.set_property("loop", "inf")
		if errorproof("firststart") == 1 then
			local streampath,localhost,streamid = getpath()
			mp.commandv("playlist_clear")
			for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
			mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
			if  recording ~= 1 then mp.add_periodic_timer(1, timer)
			end
		end
	else print("notpecapath")
	end	
	end
end
mp.register_event("file-loaded", initialize)

--reconnect.luaとりあえずそのまま持ってきた
local rtimer = mp.get_time()
--function reconnectlua ()
mp.add_periodic_timer(1, (function()
if errorproof("path") == 1 then
	  if mp.get_property_bool("core-idle") then
    if mp.get_time() - rtimer >= 20 then
      rtimer = mp.get_time()
      mp.osd_message("reconnect",3)
      print("reconnect")
      mp.commandv("playlist_next")
    end
  else
    rtimer = mp.get_time()
  end
end
end))


--キャッシュ量を再生スピードで調整
function autospeed(name, value)
	if errorproof("playing") == 1 and errorproof("\"cache-used\"") == 1 
	and brate ~= nil and value ~= nil and errorproof("\"demuxer-cache-duration\"") ==1 then
		local demuxbuffer = mp.get_property_number("demuxer-cache-duration")
		local kbytepersecond = brate / 8
		if	kbytepersecond == 0 then kbytepersecond = 10
		end
		local max = kbytepersecond * 10
		local min = kbytepersecond * 0.1
		local normal1 = kbytepersecond * 1
		local normal2 = kbytepersecond * 2		
		if 	value > normal1 and value < normal2 then
			mp.set_property("speed", 1.00)
		elseif	value < min and demuxbuffer <= 1.2 then
			mp.set_property("speed", 0.99)
		elseif value > max then
			mp.set_property("speed", 1.01)
		elseif mp.get_property_number("speed") <= 0.99 and value > normal1 then
			mp.set_property("speed", 1.00)
		elseif mp.get_property_number("speed") >= 1.01 and value < normal2 then
			mp.set_property("speed", 1.00)
		end
	end
end
--mp.observe_property("cache-used", "number", autospeed)


function test()
	print(mp.get_property("osd-width"))
	print(mp.get_property("time-pos"))
	print(mp.get_property("fps"))
	print(mp.get_property("speed"))
	print(mp.get_property("demuxer-cache-duration"))
	print(errorproof("\"cache-used\""))
	print(gettime("hour"))

end
mp.add_key_binding("KP9", "test" , test)

--mp.add_timeout(0.5 , test)

function gettime(type)
	local time = os.date("*t")
	
	if 	type == "y" then time = time["year"]
	elseif	type == "m" then time = time["month"]
	elseif	type == "d" then time = time["day"]
	elseif	type == "h" then time = time["hour"]
	elseif	type == "m" then time = time["min"]
	elseif	type == "s" then time = time["sec"]
	end
	return time
end

function refresh()
	if	errorproof("path") == 1 then
		local streampath,localhost,streamid = getpath()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	end
end

function record()
	if	errorproof("path") == 1 and errorproof("playing") == 1 then
		if	recording == nil or recording == 0 then
			local date = gettime("y")..gettime("m")..gettime("d").."_"..gettime("h")..gettime("m")..gettime("s")
			refresh()
			mp.set_property("stream-capture", recordfolder..mp.get_property("media-title").."_"..date.."."..mp.get_property("file-format"))
			mp.osd_message("record_start",3)
			recording = 1
			print(mp.get_property("playlist-count"))
		else	mp.set_property("stream-capture" , "" )
			mp.osd_message("record_end",3)
			recording = 0
		end
	end
end
mp.add_key_binding(krecord,"record" , record)
	

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
mp.add_key_binding(kscreenshot, "screenshot", screenshot)

--ボリューム上げる
function gainvolume()
	mp.commandv("add", "volume", volume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding(kvolup, "gainvolume", gainvolume)
mp.add_key_binding(kvolup_wheel, "gainvolume_wheel", gainvolume)

function cgainvolume()
	mp.commandv("add", "volume", ctrlvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding(kvolup2, "cgainvolume_wheel", cgainvolume)

function sgainvolume()
	mp.commandv("add", "volume", shiftvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Shift+Up", "sgainvolume", sgainvolume)
mp.add_key_binding(kvolup3, "sgainvolume_wheel", sgainvolume)

--ボリューム下げる
function reducevolume()
	mp.commandv("add", "volume", -1 * volume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding(kvoldown, "reducevolume", reducevolume)
mp.add_key_binding(kvoldown_wheel, "reducevolume_wheel", reducevolume)

function creducevolume()
	mp.commandv("add", "volume", -1 * ctrlvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding(kvoldown2, "creducevolume_wheel", creducevolume)

function sreducevolume()
	mp.commandv("add", "volume", -1 * shiftvolume)
	mp.osd_message(string.format("volume:%d",mp.get_property("volume",1)))
end
mp.add_key_binding("Shift+Down", "sreducevolume", sreducevolume)
mp.add_key_binding(kvoldown3, "sreducevolume_wheel", sreducevolume)

--ミュート
function mute()
	mp.commandv("cycle", "mute")
	if mp.get_property("mute") == "yes" then
		mp.osd_message("mute")
	else	mp.osd_message("mute_off")
	end
end
mp.add_key_binding( kmute, "mute", mute)

--音声を左のみに
function panleft()
	if mp.get_property_number("audio-channels") == 1 then
	mp.set_property("af", "pan=2:[ 1 , 0 ]")
	else mp.set_property("af", "channels=2:[ 1-0 , 1-0 ]")
	end
end
mp.add_key_binding(kpanleft, "panleft", panleft)

--音声を右のみに
function panright()
	if mp.get_property_number("audio-channels") == 1 then
	mp.set_property("af", "pan=2:[ 1 , 1 ]") 
	end
	mp.set_property("af", "channels=2:[ 0-1 , 0-1 ]")
end
mp.add_key_binding(kpanright, "panright", panright)

--音声を中央（モノラル）に
function pancenter()
	mp.set_property("af", "pan=1:[ 1 , 1 ]")
end
mp.add_key_binding(kpancenter, "pancenter", pancenter)

--音声を普通のステレオに
function panrestore()
	mp.set_property("af", "channels=2")
end
mp.add_key_binding(kpanstereo, "panrestore", panrestore)

--フルスクリーン
function fullscreen()
	mp.commandv("cycle" , "fullscreen")
end
mp.add_key_binding(kfullscreen, "fullscreen", fullscreen)

--終了
function exit()
	mp.commandv("quit")
end
mp.add_key_binding(kexit, "exit", exit)

--ステータスバーの代わり
function titlebar()
	mp.commandv("cycle" , "border")
end
mp.add_key_binding(kstatusbar, "titlebar", titlebar)

--最前面表示切り替え
function ontop()
	mp.commandv("cycle", "ontop")
	if mp.get_property_bool("ontop")
	then mp.osd_message("ontop")
	else mp.osd_message("ontop_off")
	end
end
mp.add_key_binding(kontop, "ontop", ontop)

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
mp.add_key_binding(kbump, "bump" , bump)

--リレー切断
function stop()
	if errorproof("path") == 1 then
	local streampath,localhost,streamid = getpath()
	mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=stop&id=".. streamid)
	end
end
mp.add_key_binding(kstop, "stop" , stop)

--ここからwindowサイズ変更
function to50per()
	local targetsize = 0.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding(k50, "50%", to50per)

function to75per()
	local targetsize = 0.75
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding(k75, "75%", to75per)

function to100per()
	local targetsize = 1
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding( k100, "100%", to100per)

function to150per()
	local targetsize = 1.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding( k150, "150%", to150per)

function to200per()
	local targetsize = 2
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding( k200, "200%", to200per)

function to250per()
	local targetsize = 2.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding( k250, "250%", to250per)

function to300per()
	local targetsize = 3
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding( k300, "300%", to300per)

function to25per()
	local targetsize = 0.25
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding( k25, "25%", to25per)

function to160x120()
	local targetsize = {160 , 120}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k160x120, "160x120", to160x120)

function to320x240()
	local targetsize = {320 , 240}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k320x240, "320x240", to320x240)

function to480x360()
	local targetsize = {480 , 360}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k480x360, "480x360", to480x360)

function to640x480()
	local targetsize = {640 , 480}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k640x480, "640x480", to640x480)

function to800x600()
	local targetsize = {800 , 600}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k800x600, "800x600", to800x600)

function to1280x960()
	local targetsize = {1280 , 960}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k1280x960, "1280x960", to1280x960)

function to1600x1200()
	local targetsize = {1600 , 1200}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k1600x1200, "1600x1200", to1600x1200)

function to1920x1440()
	local targetsize = {1920 , 1440}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding( k1920x1440, "1920x1440", to1920x1440)

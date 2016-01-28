local m={
--タイトルバー用情報取得タイマーのlua。0で非表示または無効になります

--ステータス表示とか
showtype = 1,				--ビデオコーデック「1」かコンテナ表示「2」
showsize = 3,				--解像度を表示。「2」は今のサイズのみ、「3」はソースサイズのみ表示
showbitrate = 1,			--キーフレーム間のビットレート表示。
showfps = 1,				--fps表示。「2」は今のfpsのみ、「3」は動画で設定されたfpsのみ表示
showcache = 1,				--大体のバッファサイズを表示。「2」でdemux+cacheの正確な表示
showplaytime = 1,			--再生時間（たまに総配信時間）を表示
showprotocol = 0,			--flvの時にhttpかrtmpかを表示
enablertmp = 0,				--flvの時に、「1」は初めはrtmpで再生する。「2」ですべてrtmpで再生する
enableautospeed = 1,			--キャッシュ量の自動調整。「2」でたまったときだけ調整、「0」で無効


--表示切り替え用キーバインド
ktype = 	"ctrl+1",
ksize =		"ctrl+2",
kbitrate = 	"ctrl+3",
kfps = 		"ctrl+4",
kcache = 	"ctrl+5",
kplaytime = 	"ctrl+6",
kprotocol = 	"ctrl+0",



--ここからスクリプトの処理コード
--module("timer", package.seeall)
}
local fps = 0
local orgsize = "0x0"
local tmediatitle = ""
local ttype = ""

function errorproof(case)
	if 	case == "path" then
		if string.find(mp.get_property("path"),"/stream/".. string.rep("%x", 32)) then
			return true
		end
	elseif	case == "firststart" then
		if mp.get_property_number("playlist-count")  < 3 then
		return true
		end
	elseif	case == "playing" then
		if 	mp.get_property("estimated-vf-fps")
			and mp.get_property("playback-time") 
			and mp.get_property_number("demuxer-cache-duration") then
			return true
		end
	elseif	case == "videoonly" then
		if 	not mp.get_property("aid") then
			return true
		end
	end
end

function avsync(name,value)
	if	value ~= nil and math.abs(value) > 2 then
		if	math.abs(value) > 100 then
			mp.commandv("drop_buffers")
			print("avsync:"..value)
--			bump()
--			addplaylist()
--			addbumpurl()
			--mp.osd_message("wrong relay bump",3)
		else	print("outofsync: "..value)
			mp.commandv("drop_buffers")
		end
	end
end
mp.observe_property("avsync", "number", avsync)

function ct(name,value)
	if	value ~= nil and math.abs(value) > 2 then
--		mp.commandv("playlist_next")
		mp.commandv("drop_buffers")
		print("outofct: "..value)
	end
end
mp.observe_property("total-avsync-change", "number", ct)

function getstreampos()
	local streampos
	print("1")
	streampos = mp.get_property("stream-pos", 0)
	print(streampos)
	if 	streampos == 0 then
		print("get_streampos_fail")
	end
	return streampos
end
mp.add_key_binding("*", "test3",getstreampos)
--ビットレート取得
function getbitrate()
	--キーフレーム間のビットレートを計測する方法
	local pvrate = mp.get_property("packet-video-bitrate", 0)
	local parate = mp.get_property("packet-audio-bitrate", 0)

	if	vrate ~= pvrate then
		vrate = pvrate
		arate = parate
		brate = vrate + arate
	else
		brate = vrate + arate
	end
	--ストリームのデータ量からビットレートを計算する方法
	--こっちの方法にするとmp.get_proprety("stream-pos")のところで他のスクリプトも巻き込んで反応がなくなることがあります。
--	local streampos = getstreampos()
--		if 	srate == nil or srate == 0 then 
--			srate = streampos
--			brate = srate /1024 * 8
--		else
--			--mkv以外きちんと1秒平均とれないようだから2で割ってみた
--			brate = (brate + (streampos - srate) /1024 * 8)/2
--			srate = streampos
--		end
	return brate
end

--キャッシュ取得
function getcache()
	local cache,demux,sec
	cache = mp.get_property_number("cache-used", 0)
	demux = mp.get_property_number("demuxer-cache-duration", 0)
	if	mp.get_property_number("packet-video-bitrate", 0) >= 0 then
		sec = cache/(getbitrate() /8 ) + demux
	else	sec = 0
	end
	return cache,demux,sec
end

--解像度取得
function getresolution(tateyoko)
	if	tateyoko == "tate" then tateyoko = mp.get_property("osd-height", 0)
		elseif tateyoko == "tateyoko" then 
			tateyoko = string.format("%d",getresolution("yoko")).."x"..string.format("%d",getresolution("tate"))
		else	tateyoko = mp.get_property("osd-width", 0)
	end
	return tateyoko
end

--ステータス集めて渡す
function getstatus()
	local currentsize,cache,demux,sec,size,rate
	local t = {}
	--録画チェック
	t.rec = mp.get_property("stream-capture","")
	if 	t.rec ~= "" then t.rec = "rec"
	end

	--ビデオコーデック取得
	if	m.showtype == 1 then
		if 	mp.get_property("track-list/0/type") == "video" then
			t.type = mp.get_property("track-list/0/codec")
		else	t.type = mp.get_property("track-list/1/codec")
		end
	elseif	m.showtype == 2 then t.type = mp.get_property("file-format")
	end
	if	not t.type or m.showtype == 0 then t.type = ""
	else	t.type = "["..t.type.."]"
	end

	
	if	m.showsize == 0 then size = ""
	else
		if	m.showsize == 3 then
			size = orgsize
		elseif m.showsize == 2 then size = getresolution("tateyoko")
		else	if 	getresolution("tateyoko") ~= orgsize then 
				size = orgsize.."->"..getresolution("tateyoko")
			else	size = orgsize
			end
		end
	end
	
	if	m.showbitrate == 0 then	rate = ""
	else	rate = string.format("%4dk", getbitrate())
	end
	if	m.showfps == 3 then t.fps = fps
	elseif	m.showfps == 0 then t.fps = ""
	elseif	m.showfps == 1 then t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0)).."/"..fps
	else	t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0))
	end
	
	--うまく並べる方法がわからないから全通りごり押し
	if	string.len(size..rate..t.fps) == 0 then t.info = " "
	else
		if	size ~= "" then				
			if	rate ~= "" then				
				if	t.fps ~= "" then			
					t.info = " ("..size.." "..rate.." "..t.fps..") "	--1.1.1
				else	t.info = " ("..size.." "..rate..") "			--1.1.0
				end
			else	if	t.fps ~= "" then
					t.info = " ("..size.." "..t.fps..") "			--1.0.1
				else	t.info = " ("..size..") "				--1.0.0	
				end
			end
		elseif	rate ~= "" then						
			if	t.fps ~= "" then
				t.info = " ("..rate.." "..t.fps..") "				--0.1.1
			else	t.info = " ("..rate..") "					--0.1.0
			end
		else	if	t.fps ~= "" then
				t.info = " ("..t.fps..") "					--0.0.1
			end
		end
	end	
	
	if	m.showplaytime ~= 1 then t.time = ""
	else	t.time = mp.get_property_osd("playback-time", 0)
	end
	if	mp.get_property_bool("core-idle") then
		t.time = "buffering"
	end
	--search判定できるかと思ったけどこれじゃできない
	if	mp.get_property_bool("idle") then
		t.time = "search"
	end
	
	cache,demux,sec = getcache()	
	if	m.enableautospeed ~= 0 then autospeed(sec)
	end
	
	if	sec ~= sec or getbitrate() == 0 then sec = "-"
	else	sec = string.format("%3.1fs",sec)
	end
	if	m.showcache == 0 then t.cache = ""
	elseif	m.showcache == 1 then t.cache = sec
	elseif	m.showcache == 2 then t.cache = string.format("%3.1fs+%03dKB",demux,cache)
	end

	if	mp.get_property_bool("mute") then t.vol = " vol:-" 
	else	t.vol =  string.format(" vol:%d", mp.get_property("volume", 0))
	end
	
	if m.showprotocol == 1 then
		if string.find(getpath(),"rtmp://") and mp.get_property("file-format","") == "flv" then
			t.protocol = "rtmp"
		elseif mp.get_property("file-format","") == "flv" then	t.protocol = "http"
		else t.protocol = ""
		end
	else	t.protocol = ""
	end

	
	--まとめてタイトルバーに表示
	t.barlist = t.rec..t.protocol..t.type .. tmediatitle .. t.info .. t.cache .. " ".. t.time .. t.vol
	return t.barlist
end

local loadlist = false
function setplaylist()
	if 	errorproof("path") and loadlist == false then
		if	mp.get_property("file-format","") == "flv"
		then
			mp.commandv("playlist_clear")		
			if	m.enablertmp == 1	then
				mp.add_timeout(0.1, function()
					addplaylist("rtmp",1)
					mp.commandv("playlist_next","force")
					mp.commandv("playlist_clear")
					addplaylist("http",3)
					addbumpurl()
				end)
				loadlist = true
			elseif	m.enablertmp == 2	then
				mp.add_timeout(0.1, function()
					addplaylist("rtmp",1)
					mp.commandv("playlist_next","force")
					mp.commandv("playlist_clear")
					addplaylist("rtmp",3)
					addbumpurl()
				end)
				loadlist = true
			else
				mp.add_timeout(0.1, function()
					addplaylist("http",1)
					mp.commandv("playlist_next","force")
					mp.commandv("playlist_clear")
					addplaylist("http",3)
					addbumpurl()
				end)
				loadlist = true			
			end
			
		elseif mp.get_property("file-format","") == "asf" then
			mp.add_timeout(0.1, (function()
				addplaylist("mms",1)
				mp.commandv("playlist_next","force")
				mp.commandv("playlist_clear")
				addplaylist("mms",3)
				addbumpurl()
			end))
			loadlist = true
		else

			mp.add_timeout(0.1, (function()

				addplaylist("http",1)
				mp.commandv("playlist_next","force")
				mp.commandv("playlist_clear")
				addplaylist("http",3)
				addbumpurl()
			end))
			loadlist = true
				
		end
	elseif errorproof("path") and mp.get_property_number("playlist-count") >= 6 then
		resetplaylist()
	end
end
function resetplaylist()
	loadlist = false
	setplaylist()
end
mp.register_event("file-loaded", setplaylist)
--mp.register_event("start-file", setplaylist)




function manualrtmp()
	mp.add_timeout(0.5, (function()
		mp.commandv("playlist_clear")
		addplaylist("rtmp",1)
		mp.commandv("playlist_next","force")
		mp.commandv("playlist_clear")
		addplaylist("http",3)
		addbumpurl()
	end))
	loadlist = true
end
mp.add_key_binding("KP9", "manualrtmp" , manualrtmp)


--ファイル情報取得
function getinfo()
	if 	errorproof("path") then
		--ch名をmedia-titleにする
		if	string.find(mp.get_property("media-title"), string.rep("%x", 32)) then
			tmediatitle = mp.get_property("options/title")
			mp.set_property("options/force-media-title",tmediatitle)
		else	tmediatitle = mp.get_property("media-title")
		end
		--動画サイズ取得
		orgwidth  = mp.get_property("width", 0)
		orgheight = mp.get_property("height", 0)
		orgsize = string.format("%d",orgwidth).."x"..string.format("%d",orgheight)
		--fps取得
		fps = mp.get_property_number("fps", 0)
		if 	fps == 1000 then fps = "vfr"
			--mp.add_timeout(1, (function()
			--	fps = mp.get_property("fps",0)
			--	fps = string.format("%3.1f", fps)
			--	end))
		else	fps = string.format("%3.1f", fps)
		end
--		--ビデオコーデック取得
--		if	showtype == 1 then
--			if 	mp.get_property("track-list/0/type") == "video" then
--				ttype = mp.get_property("track-list/0/codec")
--			else	ttype = mp.get_property("track-list/1/codec")
--			end
--		elseif	showtype == 2 then ttype = mp.get_property("file-format")
--		end
--		if	not ttype or showtype == 0 then ttype = ""
--		else	ttype = "["..ttype.."]"
--		end
	else print("notpecapath")
	end
end
mp.register_event("file-loaded", getinfo)


--キャッシュ量を再生スピードで調整
function autospeed(demuxbuffer)
	if errorproof("playing") and brate ~= nil  and mp.get_property_number("packet-video-bitrate", 0) > 1 then
	
		local high = 10			--10秒キャッシュが貯まったら早送り開始
		local low = 1.2			--demuxされた分が1.2秒以下になったら遅くする
		local normal1 = 2			--遅くして2秒分たまったら普通の速度に戻す
		local normal2 = 3			--早くして3秒分になったら普通の速度に戻す	
		local lowspeed = 0.95			--遅くしたときの再生速度
		local highspeed = 1.01 		--速くしたときの再生速度
		
		if	m.enableautospeed == 2 then lowspeed = 1
		end
		if 	demuxbuffer > normal1 and demuxbuffer < normal2 then
			mp.set_property("speed", 1.00)
		elseif	demuxbuffer < low then
			mp.set_property("speed", lowspeed)
		elseif demuxbuffer > high then
			mp.set_property("speed", highspeed)
		elseif mp.get_property_number("speed") <= lowspeed and demuxbuffer > normal1 then
			mp.set_property("speed", 1.00)
		elseif mp.get_property_number("speed") >= highspeed and demuxbuffer < normal2 then
			mp.set_property("speed", 1.00)
		end
	else	mp.set_property("speed", 1.00)
	end

end

function test()
--	mp.set_property("stream-pos" , 0 )
--	print(mp.get_property("stream-capture"))
	print(mp.get_property("time-pos"))
--	print(mp.get_property("fps"))
--	print(mp.get_property("speed"))
--	print(mp.get_property("playback-time"))
	print(mp.get_property("time-start"))
--	print(mp.get_property("window-minimized"))
	print(os.getenv("USERPROFILE").."\\pictures\\")
--	print(os.execute("intWindowStyle"))
--	if mp.get_property_number("packet-video-bitrate") then print("true")
--	else	print("false")
--	end
--	print(mp.get_property("track-list/2/codec"))
--a = {mp.get_osd_resolution()}
--print(mp.get_property("monitorpixelaspect"))
--print(mp.get_property("video-aspect"))
--print(mp.get_property("options/osc"))
--print(mp.get_property("playlist"))
--print(loadlist)
--mp.set_property("vf","scale=".. 800 .. ":" .. -3)-- ..":1:1")
--mp.set_property_number("window-scale" , 1)
--mp.set_property("vf","clr")
--print(mp.get_property_number("video-bitrate"))
local f = io.open("test.txt", "r")
local a=io.open("testwrite.txt","w+")
for line in f:lines() do
	
	a:write(line)
end


f:close()

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
end
mp.add_key_binding("KP8", "test" , test)



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

function addplaylist(protocol,times)
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		repeat mp.commandv("loadfile", protocol .. "://" .. localhost .. "/stream/" .. streamid , "append")
			times = times - 1
		until 	times == 0
	end
end

function addbumpurl()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	end
end		

function bumpt()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("playlist_clear")
		addbumpurl()
		mp.commandv("playlist_next","force")
		mp.osd_message("bump",3)
	end
end

--リレーそのままで開き直す
function refresh()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		resetplaylist()
	end
end
mp.add_key_binding("KP7","refresh",refresh)

--タイマーと最初に止まったままだった時の処理
local count = 0
mp.add_periodic_timer(1, (function()
--function timer()
	if	errorproof("path") then
		if 	not errorproof("firststart") then
			mp.set_property("options/title", getstatus() )
			bumpcount()
		else 			
			count = count + 1
			if	count >= 21 then mp.set_property("loop", "yes")
				bumpt()
				count = 0
			end		
		end
--	else	
	end
end))

--早めに再開できるようにと、再生と停止を繰り返すときの処理
function bumpcount()
	if	mp.get_property_bool("core-idle") and not mp.get_property_bool("pause") then
		count = count + 10
		print("count+10 count:"..count)
		if	count >= 100 then
			mp.commandv("playlist-next")
			count = count - 50
			print("skip count-50 count:"..count)
		elseif	math.mod(math.floor(count/10),2) == 0 then
--			mp.commandv("drop-buffers")
			mp.commandv("playlist-next")
			mp.commandv("playlist-prev")
		end

	else
		if	count > 0 then
			count = count - 1
--			print("count-1 count:"..count)
		end
	end
end

local maxstatus = {
	type = 2,
	size = 3,
	bitrate = 1,
	fps = 3,
	cache = 2,
	playtime = 1,
	protocol = 1
}

local cyclestatus = {
	type = function() m.showtype = m.showtype + 1; if m.showtype > maxstatus.type then m.showtype = 0 end;end,
	size = function() m.showsize = m.showsize + 1; if m.showsize > maxstatus.size then m.showsize = 0 end;end,
	bitrate = function() m.showbitrate = m.showbitrate + 1; if m.showbitrate > maxstatus.bitrate then m.showbitrate = 0 end;end,
	fps = function() m.showfps = m.showfps + 1; if m.showfps > maxstatus.fps then m.showfps = 0 end;end,
	cache = function() m.showcache = m.showcache + 1; if m.showcache > maxstatus.cache then m.showcache = 0 end;end,
	playtime = function() m.showplaytime = m.showplaytime + 1; if m.showplaytime > maxstatus.playtime then m.showplaytime = 0 end;end,
	protocol = function() m.showprotocol = m.showprotocol + 1; if m.showprotocol > maxstatus.protocol then m.showprotocol = 0 end;end
}

mp.add_key_binding( m.ktype,"cycleshowtype",cyclestatus.type)
mp.add_key_binding( m.ksize,"cycleshowsize",cyclestatus.size )
mp.add_key_binding( m.kbitrate,"cycleshowbitrate",cyclestatus.bitrate)
mp.add_key_binding( m.kfps,"cycleshowfps",cyclestatus.fps)
mp.add_key_binding( m.kcache,"cycleshowcache",cyclestatus.cache)
mp.add_key_binding( m.kplaytime,"cycleshowplaytime",cyclestatus.playtime)
mp.add_key_binding( m.kprotocol,"cycleshowprotocol",cyclestatus.protocol)

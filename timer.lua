--タイトルバー用情報取得タイマーのlua。0で非表示または無効になります

--ステータス表示とか
showtype = 1				--ビデオコーデック「1」かコンテナ表示「2」
showsize = 3				--解像度を表示。「2」は今のサイズのみ、「3」はソースサイズのみ表示
showbitrate = 1				--キーフレーム間のビットレート表示。キーフレーム2枚来るまで小さい値になります
showfps = 1				--fps表示。「2」は今のfpsのみ、「3」は動画で設定されたfpsのみ表示
showcache = 1				--大体のバッファサイズを表示。「2」でdemux+cacheの正確な表示
showplaytime = 1			--再生時間（たまに総配信時間）を表示
showprotocol = 0			--flvの時にhttpかrtmpかを表示
enablertmp = 0				--flvの時に、「1」は初めはrtmpで再生する。「2」ですべてrtmpで再生する
enableautospeed = 2			--キャッシュ量の自動調整。「2」でたまったときだけ調整、「0」で無効




--ここからスクリプトの処理コード
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
		mp.commandv("playlist_next") 
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
	local cache,demuxed,sec
	cache = mp.get_property_number("cache-used", 0)
	demuxed = mp.get_property_number("demuxer-cache-duration", 0)
	if	mp.get_property_number("packet-video-bitrate", 0) >= 0 then
		sec = cache/(getbitrate() /8 ) + demuxed
	else	sec = 0
	end
	if	sec ~= sec or getbitrate() == 0 then sec = "-"
	else	sec = string.format("%3.1fs",sec)
	end

	return cache,demuxed,sec
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
	local currentsize,cache,demuxed,sec,size,rate
	local t = {}
	--録画チェック
	t.rec = mp.get_property("stream-capture","")
	if 	t.rec ~= "" then t.rec = "rec"
	end
	
	if	not showsize or showsize > 3 then size = ""
	else
		if	showsize == 3 then
			size = orgsize
		elseif showsize == 2 then size = getresolution("tateyoko")
		else	if 	getresolution("tateyoko") ~= orgsize then 
				size = orgsize.."->"..getresolution("tateyoko")
			else	size = orgsize
			end
		end
	end
	
	if	showbitrate == 0 then	rate = ""
	else	rate = string.format("%4dk", getbitrate())
	end
	if	showfps == 3 then t.fps = fps
	elseif	showfps == 0 then t.fps = ""
	elseif	showfps == 1 then t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0)).."/"..fps
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
	
	if	showplaytime ~= 1 then t.time = ""
	else	t.time = mp.get_property_osd("playback-time", 0)
	end
	if	mp.get_property_bool("core-idle") then
		t.time = "buffering"
	end
	if	mp.get_property_bool("idle") then
		t.time = "search"
	end
	
	cache,demuxed,sec = getcache()
	if	showcache == 0 then t.cache = ""
	elseif	showcache == 1 then t.cache = sec
	elseif	showcache == 2 then t.cache = string.format("%3.1fs+%03dKB",demuxed,cache)
	end
	
	--キャッシュ自動調整するときの判定はautospeed関数でする
	if	enableautospeed ~= 0 then autospeed("",cache)
	end
	
	if	mp.get_property_bool("mute") then t.vol = " vol:-" 
	else	t.vol =  string.format(" vol:%d", mp.get_property("volume", 0))
	end
	
	local rtmp = getpath()
	if showprotocol == 1 then
		if string.find(rtmp,"rtmp://") and mp.get_property("file-format","") == "flv" then
			t.protocol = "rtmp"
		elseif mp.get_property("file-format","") == "flv" then	t.protocol = "http"
		else t.protocol = ""
		end
	else	t.protocol = ""
	end

	
	--まとめてタイトルバーに表示
	t.barlist = t.rec..t.protocol..ttype .. tmediatitle .. t.info .. t.cache .. " ".. t.time .. t.vol
	return t.barlist
end

rtmpplaying = false
function rtmp()
	if 	errorproof("path") then
		local fullpath,localhost,streamid = getpath()
		if	mp.get_property("file-format","") == "flv"
			and
			string.find(fullpath,"http://") and rtmpplaying == false
		then
			if	enablertmp == 1	then
				mp.add_timeout(0.5, (function()
					mp.commandv("playlist_clear")
					addplaylist("rtmp",1)
					mp.commandv("playlist_next","force")
					mp.commandv("playlist_clear")
					addplaylist("http",3)
					addbumpurl()
				end))
				rtmpplaying = true
			elseif	enablertmp == 2	then
				mp.add_timeout(0.5, (function()
					mp.commandv("playlist_clear")
					addplaylist("rtmp",1)
					mp.commandv("playlist_next","force")
					mp.commandv("playlist_clear")
					addplaylist("rtmp",3)
					addbumpurl()
				end))
				rtmpplaying = false
			end
			
			
		--elseif string.find(fullpath,"rtmp://") then
		--	mp.commandv("playlist_clear")
		--	mp.commandv("loadfile" , "http://".. localhost .. "/stream/".. streamid,"append")
		--	mp.commandv("playlist_next","force")
		--	mp.commandv("playlist_clear")
		--	for i = 0 , 2 do mp.commandv("loadfile" , "http://".. localhost .. "/stream/".. streamid,"append") end
		--	addbumpurl()
		
		end
	end
	print(rtmpplaying)
end
mp.register_event("file-loaded", rtmp)
function manualrtmp()
	mp.add_timeout(0.5, (function()
		mp.commandv("playlist_clear")
		addplaylist("rtmp",1)
		mp.commandv("playlist_next","force")
		mp.commandv("playlist_clear")
		addplaylist("http",3)
		addbumpurl()
	end))
	rtmpplaying = true
end
mp.add_key_binding("KP9", "manualrtmp" , manualrtmp)


--ファイル情報取得
fps = 0
orgsize = "0x0"
tmediatitle = ""
ttype = ""
function inittimer()
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
		--ビデオコーデック取得
		if	showtype == 1 then
			if 	mp.get_property("track-list/0/type") == "video" then
				ttype = mp.get_property("track-list/0/codec")
			else	ttype = mp.get_property("track-list/1/codec")
			end
		elseif	showtype == 2 then ttype = mp.get_property("file-format")
		end
		if	not ttype or showtype == 0 then ttype = ""
		else	ttype = "["..ttype.."]"
		end
	else print("notpecapath")
	end
end
mp.register_event("file-loaded", inittimer)


--キャッシュ量を再生スピードで調整
function autospeed(name, value)
	if errorproof("playing") and brate ~= nil  and mp.get_property_number("packet-video-bitrate", 0) > 1 then
		local demuxbuffer = mp.get_property_number("demuxer-cache-duration", 0)
		local kbps = brate / 8
		if	kbps == 0 then kbps = 10
		end
		local high = kbps * 15			--2秒+今のレート換算15秒相当分キャッシュが貯まったら早送り開始
		local lowdemuxed = 1.2			--demuxされた分が1.2秒以下になって↓のキャッシュ以下になったら遅くする
		local low = kbps * 0.1			--↑を満たして0.1秒相当分以下のキャッシュになったら遅くする
		local normal1 = kbps * 1		--遅くしてから2秒+1秒相当分たまったら普通の速度に戻す
		local normal2 = kbps * 2		--早くしてから2秒+2秒相当分になったら普通の速度に戻す	
		local lowspeed = 0.99			--遅くしたときの再生速度
		local highspeed = 1.01 			--速くしたときの再生速度
		if	enableautospeed == 2 then lowspeed = 1
		end
		if 	value+demuxbuffer*brate/8 > normal1+brate*2/8 and value+demuxbuffer*brate/8 < normal2+brate*2/8 then
			mp.set_property("speed", 1.00)
		elseif	value+demuxbuffer*brate/8 < low+brate*2/8 then--and demuxbuffer <= lowdemuxed then
			mp.set_property("speed", lowspeed)
		elseif value+demuxbuffer*brate/8 > high+brate*2/8 then
			mp.set_property("speed", highspeed)
		elseif mp.get_property_number("speed") <= lowspeed and value+demuxbuffer*brate/8 > normal1+brate*2/8 then
			mp.set_property("speed", 1.00)
		elseif mp.get_property_number("speed") >= highspeed and value+demuxbuffer*brate/8 < normal2+brate*2/8 then
			mp.set_property("speed", 1.00)
		end
	else	mp.set_property("speed", 1.00)
	end

end

function test()
--	mp.set_property("stream-pos" , 0 )
--	print(mp.get_property("stream-capture"))
--	print(mp.get_property("time-pos"))
--	print(mp.get_property("fps"))
--	print(mp.get_property("speed"))
--	print(mp.get_property("playback-time"))
--	print(mp.get_property("time-pos"))
--	print(errorproof("\"cache-used\""))
--	print(mp.get_property("time-start"))
--	print(mp.get_property("window-minimized"))
--	print(os.getenv("USERPROFILE").."\\my pictures\\")
--	print(os.execute("intWindowStyle"))
--	if mp.get_property_number("packet-video-bitrate") then print("true")
--	else	print("false")
--	end
--	print(mp.get_property("track-list/2/codec"))
a = {mp.get_osd_resolution()}
print(mp.get_property("monitorpixelaspect"))
print(mp.get_property("video-aspect"))
print(mp.get_property("options/osc"))
print(mp.get_property("playlist"))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
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

function bump()
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
		addplaylist("http",3)
		addbumpurl()
	end
end
mp.add_key_binding("KP7","refresh",refresh)

--タイマーと最初に止まったままだった時の処理
count = 0
mp.add_periodic_timer(1, (function()
--function timer()
	if	errorproof("path") then
		if 	not errorproof("firststart") then
			mp.set_property("options/title", getstatus() )
		else 			
			count = count + 1
			if	count >= 21 then mp.set_property("loop", "yes")
				bump()
				count = 0
			end		
		end
--	else	
	end
end))

function cycleshowtype()
	if showtype == 1 then showtype = 2
	elseif showtype == 2 then showtype = 0
	else showtype = 1
	end
end
mp.add_key_binding("ctrl+1","cycleshowtype",cycleshowtype)

function cycleshowsize()
	if showsize == 1 then showsize = 2
	elseif showsize == 2 then showsize = 3
	elseif showsize == 3 then showsize = 0
	else showsize = 1
	end
end
mp.add_key_binding("ctrl+2","cycleshowsize",cycleshowsize)

function cycleshowbitrate()
	if showbitrate == 1 then showbitrate = 0
	else showbitrate = 1
	end
end
mp.add_key_binding("ctrl+3","cycleshowbitrate",cycleshowbitrate)

function cycleshowfps()
	if showfps == 1 then showfps = 2
	elseif showfps == 2 then showfps = 3
	elseif showfps == 3 then showfps = 0
	else showfps = 1
	end
end
mp.add_key_binding("ctrl+4","cycleshowfps",cycleshowfps)

function cycleshowcache()
	if showcache == 1 then showcache = 2
	elseif showcache == 2 then showcache = 0
	else showcache = 1
	end
end
mp.add_key_binding("ctrl+5","cycleshowcache",cycleshowcache)

function cycleshowplaytime()
	if showplaytime == 1 then showplaytime = 0
	else showplaytime = 1
	end
end
mp.add_key_binding("ctrl+6","cycleshowplaytime",cycleshowplaytime)

function cycleshowprotocol()
	if showprotocol == 1 then showprotocol = 0
	else showprotocol = 1
	end
end
mp.add_key_binding("ctrl+0","cycleshowprotocol",cycleshowprotocol)

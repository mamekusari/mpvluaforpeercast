--タイトルバー用タイマーのlua

--ステータス表示
showtype = 1				--ビデオコーデック「1」かコンテナ表示「2」
showsize = 3				--解像度を表示。「2」は今のサイズのみ、「3」はソースサイズのみ表示
showfps = 1				--fps表示。「2」は今のfpsのみ、「3」は動画で設定されたfpsのみ表示
showbitrate = 1				--キーフレーム間のビットレート表示
showcache = 2				--キャッシュサイズを表示
enableautospeed = 1			--キャッシュ量の自動調整「2」でたまったときだけ調整




function errorproof(case)
	local hantei
--	print(case)
	if 	case == "path" then
		if string.find(mp.get_property("path"),"/stream/".. string.rep("%x", 32)) then
		hantei = 1
		end
	elseif	case == "firststart" then
		if mp.get_property_number("playlist-count")  < 3 then
		hantei = 1
		end
	elseif	case == "playing" then
		if 	mp.get_property("estimated-vf-fps")
			and mp.get_property("playback-time") 
			and mp.get_property_number("demuxer-cache-duration")
		then
		hantei = 1
		end
	elseif	case == "videoonly" then
		if 	not mp.get_property("aid") then
			hantei = 1
		end
	elseif case == "errordata" then
		if	mp.get_property("track-list/2/codec") then
			hantei = 1
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
	if	bool and errorproof("errordata") then
		print(bool)
		refresh()
		print("datacheckrun:refresh")
	end
	print("datacheckrun")
end
mp.observe_property("core-idle", "bool", datacheck)

function avsync(value)
	local avsync = mp.get_property_number("avsync")
	local ct = mp.get_property_number("total-avsync-change")
	if	ct == nil then ct,avsync = 0,0
	end
	if	ct == nil or ct > 2 or ct < -2 then
		mp.commandv("drop_buffers") 
--		mp.commandv("playlist-next")
		print("outofct: "..ct)	
	
	elseif	avsync == nil or avsync > 2 or avsync < -2 then
		mp.commandv("drop_buffers")
--		mp.commandv("playlist-next")
		print("outofsync: "..avsync)
	end
	
--		mp.commandv("drop_buffers")

end
mp.observe_property("avsync", "number", avsync)

function cacheerror(value)
local a = mp.get_property_number("demuxer-cache-duration")
	if a ~= nil and a > 3 then
--		mp.commandv("drop_buffers")
		mp.commandv("playlist_next", "force")
	end
end
--mp.observe_property("demuxer-cache-duration", "number", cacheerror)


function getstreampos()
	if	not errorproof("errordata") then
		streampos = mp.get_property("stream-pos")
		if streampos == nil then
			print("get_streampos_fail")
			refresh()
		end
	else	mp.set_property("stream-pos" , 0 )
		refresh()
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

--ビットレート取得
function getbitrate()
--	local vrate,arate,brate,srate
	--キーフレーム間のビットレートを計測する方法
	local pvrate = mp.get_property("packet-video-bitrate")
	local parate = mp.get_property("packet-audio-bitrate")
	if vrate == nil then vrate = 0
	end
	
	if	vrate ~= pvrate then
		if	pvrate ~= nil then
			vrate = pvrate
		else	vrate = 0
		end
		if	parate ~= nil then
			arate = parate
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
--print("keyflame")
--	if 	not srate then srate = 0
--	end 
	--ストリームのデータ量からビットレートを計算する方法
--	mp.add_timeout(0.1,getstreampos)
--	if	streampos == nil then srate = 0
--	else
--		if 	srate == 0 then 
--			srate = streampos
--			brate = srate /1024 * 8
--		else
			--mkv以外きちんと1秒平均とれないようだから2秒で割ってみた
--			brate = (brate + (streampos - srate) /1024 * 8)/2
--			srate = streampos
--		end
--	end
--print(streampos)
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
	if errorproof("videoonly") or vol == nil then vol = 0
	end
	
	return vol
end

--解像度取得
function getresolution(tateyoko)
	if	tateyoko == "tate" then tateyoko = mp.get_property("osd-height")
		elseif tateyoko == "tateyoko" then 
			tateyoko = string.format("%d",getresolution("yoko")).."x"..string.format("%d",getresolution("tate"))
		else	tateyoko = mp.get_property("osd-width")
	end
--	local currentwidth , currentheight = mp.get_property("osd-width"), mp.get_property("osd-height")
	if not tateyoko then tateyoko = 0
	end

	return tateyoko
end

function getstatus()
--	if ttime ~= mp.get_property_osd("playback-time") then
	local currentsize,cache,size,rate,tfps
	local trec,tinfo,tcache,ttime,tvol
	
	trec = mp.get_property("stream-capture")
	if 	trec ~= "" then trec = "rec"
	else	trec = ""
	end
	if	showsize == 0 then size = ""
	else
		if	showsize == 3 then
			size = orgsize
		elseif showsize == 2 then size = getresolution("tateyoko")
		else	if 	getresolution("tateyoko") ~= orgsize then 
				size = orgsize..">"..getresolution("tateyoko")
			end
		end	
	
	end
	
	if	showbitrate == 0 then	rate = ""
	else	rate = string.format("%4dk", getbitrate())
	end
	if	showfps == 3 then tfps = fps
	elseif	showfps == 0 then tfps = ""
	elseif	showfps == 1 then tfps = string.format("%3.1f", getfps()).."/"..fps
	else	tfps = string.format("%3.1f", getfps())
	end
	
	--うまく並べる方法がわからないから全通りごり押し
	if	string.len(size..rate..tfps) == 0 then tinfo = " "
	else
		if	size ~= "" then				
			if	rate ~= "" then				
				if	tfps ~= "" then			
					tinfo = " ("..size.." "..rate.." "..tfps..") "	--1.1.1
				else	tinfo = " ("..size.." "..rate..") "		--1.1.0
				end
			else	if	tfps ~= "" then
					tinfo = " ("..size.." "..tfps..") "		--1.0.1
				else	tinfo = " ("..size..") "			--1.0.0	
				end
			end
		elseif	rate ~= "" then						
			if	tfps ~= "" then
				tinfo = " ("..rate.." "..tfps..") "			--0.1.1
			else	tinfo = " ("..rate..") "				--0.1.0
			end
		else	if	tfps ~= "" then
				tinfo = " ("..tfps..") "				--0.0.1
			end
		end
	end	
	
	ttime = mp.get_property_osd("playback-time")
	cache = getcache()
	if	showcache == 0 then tcache = ""
	elseif	showcache == 1 then tcache = string.format("c:%03dKB" , cache)
	else	tcache = string.format("%3.1fs+%03dKB",mp.get_property("demuxer-cache-duration"),cache)
	end
	if	enableautospeed ~= 0 then autospeed("",cache)
	end
	tvol =  string.format(" vol:%d", getvolume())


	if	mp.get_property_bool("mute") then tvol = " vol:-" 
	end

	--録画チェック
	
	--まとめてタイトルバーに表示
	tbarlist = trec..ttype .. tmediatitle .. tinfo .. tcache .. " ".. ttime .. tvol
--	print("timerend")
--	mp.add_timeout(0.5, on)
--	return tbarlist

end


--ファイル情報取得とタイマースタート
function inittimer()
	if errorproof("errordata") and errorproof("playing") then errordata()
	else
	if errorproof("path") then
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
		mp.set_property("loop", "inf")
		if errorproof("firststart") then
--			if  recording ~= 1 then mp.add_periodic_timer(1, timer)
--			end
		end
	else print("notpecapath")
	end	
	end
end
mp.register_event("file-loaded", inittimer)


--キャッシュ量を再生スピードで調整
function autospeed(name, value)
	if errorproof("playing") --and  errorproof("\"cache-used\"") == 1 
	and brate ~= nil and value ~= nil and mp.get_property_number("packet-video-bitrate") > 1 then
		local demuxbuffer = mp.get_property_number("demuxer-cache-duration")
		if demuxbuffer == nil then demuxbuffer = 0
		end
		local kbytepersecond = brate / 8
		if	kbytepersecond == 0 then kbytepersecond = 10
		end
		local max = kbytepersecond * 15	--2秒+今のレート換算15秒相当分キャッシュが貯まったら早送り開始
		local min = kbytepersecond * 0.1	--1.2秒と0.1秒相当分以下のキャッシュになったら遅くする
		local normal1 = kbytepersecond * 1	--遅くしてから2秒+1秒相当分たまったら普通の速度に戻す
		local normal2 = kbytepersecond * 2	--早くしてから2秒+2秒相当分になったら普通の速度に戻す	
		local lowspeed = 0.99			--遅くしたときの再生速度
		local highspeed = 1.01 		--速くしたときの再生速度
		if	enableautospeed == 2 then lowspeed = 1
		end
		if 	value > normal1 and value < normal2 then
			mp.set_property("speed", 1.00)
		elseif	value < min and demuxbuffer <= 1.2 then
			mp.set_property("speed", lowspeed)
		elseif value > max then
			mp.set_property("speed", highspeed)
		elseif mp.get_property_number("speed") <= lowspeed and value > normal1 then
			mp.set_property("speed", 1.00)
		elseif mp.get_property_number("speed") >= highspeed and value < normal2 then
			mp.set_property("speed", 1.00)
		end
	end
end
--mp.observe_property("cache-used", "number", autospeed)


function test()
--	mp.set_property("stream-pos" , 0 )
--	print(mp.get_property("stream-capture"))
--	print(mp.get_property("time-pos"))
--	print(mp.get_property("fps"))
--	print(mp.get_property("speed"))
	print(mp.get_property("demuxer-cache-duration"))
	print(mp.get_property("packet-video-bitrate"))
--	print(errorproof("\"cache-used\""))
	print(mp.get_property("stream-pos"))
	print(mp.get_property("window-minimized"))
	print(os.getenv("USERPROFILE").."\\my pictures\\")
--	print(os.execute("intWindowStyle"))
--	os.execute("telnet localhost 7146")
--	os.execute("telnet GET / HTTP/1.1")
--	print(os.execute("telnet Host: localhost"))
	if not errorproof("videoonly") then print("true")
	else	print("false")
	end

end
mp.add_key_binding("KP8", "test" , test)

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

function refresh()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	end
end
mp.add_key_binding("KP7","refresh",refresh)


mp.add_periodic_timer(1, (function()
--function timer()
--	reconnectlua()
	if 	errorproof("playing") and not errorproof("firststart") then
		if not errorproof("errordata") then
			mp.add_timeout(0.1, getstatus)
			if not tbarlist then tbarlist = mp.get_property("media-title")
			end
			mp.set_property("options/title", tbarlist )
--			mp.add_timeout(0.8, getstatus)
		else	errordata()
		end
	else 
		print("buffer?")
	end
end))


--mp.add_periodic_timer(1, (function()
--	if not count then count = 0
--	end
--	count = count + 1
--	print(count)
--end))

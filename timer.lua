--タイトルバー用タイマーのlua
--今のところ非表示にはできません

--ステータス表示
showcontainertype = 1			--ビデオコーデック「1」かコンテナ表示「2」（未表示は未実装）
showwindowsize = 1			--表示動画サイズを表示（未表示は未実装）
showsoucesize = 1			--動画の元のサイズを表示（未表示は未実装）
showfps = 1				--fps表示（未表示は未実装）
showbitrate = 1				--大体のビットレート表示（未表示は未実装）
showcachesize = 1			--キャッシュサイズを表示（未表示は未実装）
enableautospeed = 1			--キャッシュ量の自動調整「2」でたまったときだけ調整（の予定）




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
			and mp.get_property("playback-time") 
			and mp.get_property_number("demuxer-cache-duration")
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
	refresh()
		print("errordata")
end

function datacheck(bool)
	if	bool and errorproof("errordata") == 1 then
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
		print("ct-error :"..ct)	
	
	elseif	avsync == nil or avsync > 2 or avsync < -2 then
		mp.commandv("drop_buffers")
		print("avsync-error :"..avsync)
	end
end
mp.observe_property("avsync", "number", avsync)

function cacheerror(value)
local a = mp.get_property_number("demuxer-cache-duration")
	if a ~= nil and a > 3 then
		mp.commandv("playlist_next", "force")
	end
end
--mp.observe_property("demuxer-cache-duration", "number", cacheerror)


function getstreampos()
	if	errorproof("errordata") == 0 then
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
		--print("getcachefail")
		cache = 0
	end
	
	if cache == nil then cache = 0
	end
	return cache
end

--ビットレート取得
function getbitrate()
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
	if 	not srate then srate = 0
	end 
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
	if not fps then fps = 0
	end
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
	if not tateyoko then tateyoko = 0
	end
	return tateyoko
end

function getstatus()
--	if ttime ~= mp.get_property_osd("playback-time") then
	local ttime = mp.get_property_osd("playback-time")
	--キャッシュ取得
--	cache = mp.get_property_number("cache-used", 0)
--	mp.add_timeout(0.01 , getcache)
--	if not cache then cache = 0
--	end
--		print("timerstart")
--	local cache = getcache()
	local tcache = string.format("c:%03dKB" , (getcache()))
	autospeed("",getcache())
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
	--録画チェック
	local trec = mp.get_property("stream-capture")
	if 	trec ~= "" then trec = "rec"
	else	trec = ""
	end
	--まとめてタイトルバーに表示
	tbarlist = trec..ttype .. tmediatitle .." ("..tsize.." " ..trate.."".. tfps ..") ".. tcache .. " ".. ttime .. tvol
--	print("timerend")
--	mp.add_timeout(0.5, on)
--	return tbarlist

end

--ファイル情報取得とタイマースタート
function inittimer()
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
		if 	mp.get_property("track-list/0/type") == "video" then
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
	if errorproof("playing") == 1 --and  errorproof("\"cache-used\"") == 1 
	and brate ~= nil and value ~= nil and mp.get_property_number("packet-video-bitrate") > 1 then
		local demuxbuffer = mp.get_property_number("demuxer-cache-duration")
		if demuxbuffer == nil then demuxbuffer = 0
		end
		local kbytepersecond = brate / 8
		if	kbytepersecond == 0 then kbytepersecond = 10
		end
		local max = kbytepersecond * 15	--2秒+今のレート換算15秒分キャッシュが貯まったら早送り開始
		local min = kbytepersecond * 0.1	--1.2秒と0.1秒分以下のキャッシュになったら遅くする
		local normal1 = kbytepersecond * 1	--遅くしてから2秒+1秒分たまったら普通の速度に戻す
		local normal2 = kbytepersecond * 2	--早くしてから2秒+2秒分になったら普通の速度に戻す	
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

end
--mp.add_key_binding("KP8", "test" , test)

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
	if	errorproof("path") == 1 then
		local streampath,localhost,streamid = getpath()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	end
end
mp.add_key_binding("KP7","refresh",refresh)

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
--mp.add_key_binding(krecord,"record" , record)

mp.add_periodic_timer(1, (function()
--function timer()
--	reconnectlua()
	if 	errorproof("playing") == 1 and errorproof("firststart") == 0 then
		if errorproof("errordata") == 0 then
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

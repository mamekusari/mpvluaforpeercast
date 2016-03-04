local m={
--タイトルバー用情報取得タイマーのlua。0で非表示または無効になります

--ステータス表示とか
showtype = 1,				--ビデオコーデック「1」かコンテナ表示「2」。「3」で音声コーデック
showsize = 3,				--解像度を表示。「2」は今のサイズのみ、「3」はソースサイズのみ表示
showbitrate = 1,			--キーフレーム間のビットレート表示。
showfps = 1,				--fps表示。「2」は今のfpsのみ、「3」は動画で設定されたfpsのみ表示
showcache = 1,				--大体のバッファサイズを表示。「2」でdemux+cacheの正確な表示
showplaytime = 1,			--再生時間（たまに総配信時間）を表示
showprotocol = 0,			--flvの時にhttpかrtmpかを表示
enablertmp = 0,				--flvの時に、「1」は初めはrtmpで再生する。「2」ですべてrtmpで再生する
enableautospeed = 2,			--キャッシュ量の自動調整。「2」でたまったときだけ調整、「0」で無効
enableothers = 1,			--peercast以外でこのスクリプトを適用するか


--表示切り替え用キーバインド
ktype = 	"ctrl+1",
ksize =		"ctrl+2",
kbitrate = 	"ctrl+3",
kfps = 		"ctrl+4",
kcache = 	"ctrl+5",
kplaytime = 	"ctrl+6",
kprotocol =	"ctrl+9",
kautospeed = 	"ctrl+0",


--ここからスクリプトの処理コード
}
local s = {
	offsetsec = 50,			--何秒で1秒分のバッファを相殺するか(50秒)
	recsec = 4,			--数値の秒ごとにプレイヤーを再接続する(4秒)
	incpossec = 10,			--数値の秒分以上になるとプレイリストを1つ送る(10秒)
	decpossec = -5,			--プレイリストを送った後にこの秒数分のカウントを減らす(5秒分)
	
	playlistcount = 4,		--プレイリストの数で、この次にbumpがくる(4つ)
	
	limitavsync = 0.5,		--音ズレを何秒まで許容するか(0.5秒)
	limitct = 2,			--音ズレ修正量を何秒まで許容するか(2秒)
	
	high = 10,   			--これ以上バッファが貯まったら早送り開始(10秒)
	low = 1.2,   			--これ以下になったら遅くする(1.2秒)
	normal1 = 2,			--遅くして2秒分たまったら普通の速度に戻す(2秒)
	normal2 = 3,			--早くして3秒分になったら普通の速度に戻す(3秒)
	lowspeed = 0.95,	 	--遅くしたときの再生速度(0.95倍)
	highspeed = 1.10,   		--速くしたときの再生速度(1.10倍)
	persec = 0.01,			--バッファの秒数にこれをかけた分を足す(+0.01)
	maxspeed = 2,			--速度の上限(2倍)

}

local videoinfo = {
	fps = 0,
	width = 0,
	height = 0,
	size = "0x0",
	title = "",
	type = "",
	codec = {}
}

local currentinfo ={
	fps = 0,
	width = 0,
	height = 0,
	bitrate = 0,
	title = "",
	type = "",
	vcodec = "",
	acodec = ""
}

local pecainfo = {
	stream = "/stream/".. string.rep("%x", 32),
	pls = "/pls/".. string.rep("%x", 32),
	
}

local t = {
	fps = 0,
	width = 0,
	height = 0,
	size = "0x0",
	title = "",
	type = "",
	vol = 0
}

local fps = 0
--local videoinfo.size = "0x0"
t.mediatitle = ""
local ttype = ""

playlist = {
	geturl = function(protocol)
			local streampath,localhost,streamid = get.path()
			if	not protocol then protocol = "http" 
			end
			return protocol .. "://" .. localhost .. "/stream/" .. streamid
		end,
	addurl = function(protocol,times)
			if	errorproof("path") then
				local streampath,localhost,streamid = get.path()
				repeat mp.commandv("loadfile", playlist.geturl(protocol) , "append")
				if	not times then times = 1
				end
					times = times - 1
				until 	times == 0
			end
		end,
	addplay = function(protocol)
			mp.commandv("playlist-clear")
			mp.commandv("loadfile", playlist.geturl(protocol) ,"append")
			mp.commandv("playlist-next")
		end,
	set = function(protocol1,times,protocol2)
			playlist.addplay(protocol1)
			mp.commandv("playlist-clear")
			if	protocol2 then
				playlist.addurl(protocol2,times-1)
			else
				playlist.addurl(protocol1,times-1)
			end
			bump.addurl()
		end
		
}		

bump = {
	geturl = function()
			local streampath,localhost,streamid = get.path()
			return "http://".. localhost .. "/admin?cmd=bump&id=".. streamid
		end,
	addurl = function()
			mp.commandv("loadfile", bump.geturl(), "append")
		end,
	t = function()
			mp.commandv("playlist-clear")
			mp.commandv("loadfile", bump.geturl(), "append")
			mp.commandv("playlist-next")
			mp.osd_message("bump")
		end
}

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
	if	value ~= nil and math.abs(value) > s.limitavsync then
--		if	math.abs(value) > 100 then
			mp.commandv("drop_buffers")
			print("avsync:"..value)
--			bump()
--			addplaylist()
--			addbumpurl()
			--mp.osd_message("wrong relay bump",3)
--		else	print("outofsync: "..value)
--			mp.commandv("drop_buffers")
--		end
--		mp.set_property_number("playlist-pos", mp.get_property_number("playlist-pos",0))
--		mp.commandv("seek","1")
	end
end
mp.observe_property("avsync", "number", avsync)

function ct(name,value)
	if	value ~= nil and math.abs(value) > s.limitct then
--		mp.commandv("playlist_next")
--		mp.set_property_number("playlist-pos", mp.get_property_number("playlist-pos",0))
		mp.commandv("drop_buffers")
		print("outofct: "..value)
	end
end
mp.observe_property("total-avsync-change", "number", ct)

get = {
	--URL取得と分割
	path = function()
	    local fullpath = mp.get_property("path","")
		if	string.find(fullpath,"admin?cmd=") then
			local pos = mp.get_property_number("playlist-pos")
			if	pos >= 1 then
				fullpath = mp.get_property("playlist/".. pos-1 .."/filename")
			else
				fullpath = mp.get_property("playlist/".. pos+1 .."/filename")
			end
		end
	    local id = {string.find(fullpath,"/stream/(%x*)")}
	    local a = {}
			for i in string.gmatch(fullpath, "[^/]+") do
			table.insert(a, i)
			end
	--	else	return "","",""
	--	end
	    return fullpath,a[2],id[3]
	end,

	--mp.get_property("stream-pos")は不安定らしいからこれは使えない
	streampos = function ()
		local streampos
		print("1")
		streampos = mp.get_property("stream-pos", 0)
		print(streampos)
		if 	streampos == 0 then
			print("get_streampos_fail")
		end
		return streampos
	end,

	--ビットレート取得
	bitrate = function()
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
	--	local streampos = get.streampos()
	--		if 	srate == nil or srate == 0 then 
	--			srate = streampos
	--			brate = srate /1024 * 8
	--		else
	--			--mkv以外きちんと1秒平均とれないようだから2で割ってみた
	--			brate = (brate + (streampos - srate) /1024 * 8)/2
	--			srate = streampos
	--		end
		return brate
	end,

	--キャッシュ取得
	cache = function()
		local cache,demux,sec
		cache = mp.get_property_number("cache-used", 0)
		demux = mp.get_property_number("demuxer-cache-duration", 0)
		if	mp.get_property_number("packet-video-bitrate", 0) >= 0 then
			sec = cache/(get.bitrate() /8 ) + demux
		else	sec = 0
		end
		return cache,demux,sec
	end,

	--解像度取得
	resolution = function(tateyoko)
		if	tateyoko == "tate" then tateyoko = mp.get_property("osd-height", 0)
		elseif tateyoko == "tateyoko" then 
			tateyoko = string.format("%d",get.resolution("yoko")).."x"..string.format("%d",get.resolution("tate"))
	--		elseif	type(tateyoko) == "string" then
	--			tateyoko = string.format("%d", videoinfo.width).."x"..string.format("%d", videoinfo.height)
		else	tateyoko = mp.get_property("osd-width", 0)
		end
		return tateyoko
	end,

	codec = function(type)
		local count = mp.get_property_number("track-list/count",0)
		local i = 0
		repeat videoinfo.codec[i+1] = mp.get_property("track-list/"..i.."/codec")
			i = i + 1
		until	videoinfo.codec[i] == nil
		
		if	count == 0 then--not videoinfo.codec[1] then
			return ""
		elseif	count == 1 then --not videoinfo.codec[2] then
			if	mp.get_property("track-list/0/type","") == "video" then
				currentinfo.vcodec = videoinfo.codec[1]
				currentinfo.acodec = "none"
			else	currentinfo.acodec = videoinfo.codec[1]
				currentinfo.vcodec = "none"
			end
		elseif	count == 2 then--not videoinfo.codec[3] then
			if	mp.get_property("track-list/0/type","") == "video" then
				currentinfo.vcodec = videoinfo.codec[1]
				currentinfo.acodec = videoinfo.codec[2]
			else	currentinfo.vcodec = videoinfo.codec[2]
				currentinfo.acodec = videoinfo.codec[1]
			end
		end
		
		if	type == "video" then
			return currentinfo.vcodec
		else	return currentinfo.acodec
		end
	end

}

tset = function(case)
	--録画チェック
	if	case == "rec"	then
		t.rec = mp.get_property("stream-capture","")
		if 	t.rec ~= "" then t.rec = "rec"
		end
	--ビデオコーデック取得
	elseif	case == "codec"	then
		local video,audio,container
		if	m.showtype ~= 0 then
			video = get.codec("video")
			audio = get.codec("audio")
			container = mp.get_property("file-format","")
			if	m.showtype == 1 then
				t.type = "["..video.."]"
			elseif	m.showtype == 2 then t.type = "["..container.."]"
			elseif	m.showtype == 3 then t.type = "["..audio.."]"
			end
		else	t.type = ""
		end
--		return	t.type
	--解像度
	elseif	case == "size"	then
		local size
		if	m.showsize == 0 then size = ""
		else
			if	m.showsize == 3 then
				size = videoinfo.size
			elseif m.showsize == 2 then size = get.resolution("tateyoko")
			else	if 	get.resolution("tateyoko") ~= videoinfo.size then 
					size = videoinfo.size.."->"..get.resolution("tateyoko")
				else	size = videoinfo.size
				end
			end
		end
		return	size
	--ビットレート
	elseif	case == "bitrate"	then
		local rate
		if	m.showbitrate == 0 then	rate = ""
		else	rate = string.format("%4dk", get.bitrate())
		end
		return	rate
	--fps
	elseif	case == "fps"	then
		if	m.showfps == 3 then t.fps = videoinfo.fps
		elseif	m.showfps == 0 then t.fps = ""
		elseif	m.showfps == 1 then t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0)).."/"..videoinfo.fps
		else	t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0))
		end
--		return	t.fps
	elseif	case == "sort"	then
	--うまく並べる方法がわからないから全通りごり押し
		local rate = tset("bitrate")
		local size = tset("size")
		tset("fps")
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
--		return	t.info
	--再生時間
	elseif	case == "playtime"	then
		if	m.showplaytime ~= 1 then t.time = ""
		else	t.time = mp.get_property_osd("playback-time", 0)
		end
		if	mp.get_property_bool("core-idle") and not mp.get_property_bool("pause") then
			t.time = "buffering"
		elseif	mp.get_property_bool("pause") then
			t.time = "pause"
		end
		--search判定できるかと思ったけどこれじゃできない
		if	mp.get_property_bool("idle") then
			t.time = "search"
		end
--		return	t.time
	--キャッシュ
	elseif	case == "cache"	then
		local cache,demux,sec = get.cache()
		if	sec ~= sec or get.bitrate() == 0 then sec = "-"
		else	sec = string.format("%3.1fs",sec)
		end
		if	m.showcache == 0 then t.cache = ""
		elseif	m.showcache == 1 then t.cache = sec
		elseif	m.showcache == 2 then t.cache = string.format("%3.1fs+%03dKB",demux,cache)
		end
--		return	t.cache
	--音量
	elseif	case == "volume"	then
		if	mp.get_property_bool("mute") then t.vol = " vol:-" 
		else	t.vol =  string.format(" vol:%d", mp.get_property("volume", 0))
		end
--		return	t.vol
	--プロトコル
	elseif	case == "protocol"	then
		if m.showprotocol == 1 then
			if string.find(get.path(),"rtmp://") and mp.get_property("file-format","") == "flv" then
				t.protocol = "rtmp"
			elseif mp.get_property("file-format","") == "flv" then	t.protocol = "http"
			else t.protocol = ""
			end
		else	t.protocol = ""
		end
--		return	t.protocol
	--再生速度
	elseif	case == "speed"	then
		if	mp.get_property_number("speed",0) ~= 1 then
			t.speed = string.format(" x%3.2f",mp.get_property_number("speed"))
			else
			t.speed = ""
		end
--		return	t.speed
	--まとめてタイトルバーに表示
	elseif	case == "display" then
		tset("rec")
		tset("protocol")
		tset("codec")
		tset("speed")
		tset("sort")
		tset("cache")
		tset("playtime")
		tset("volume")
		t.barlist = (
			t.rec..
			t.protocol..
			t.type ..
			t.mediatitle..
			t.speed ..
			t.info ..
			t.cache ..
			" "..
			t.time ..
			t.vol
			)
		return t.barlist
	end
end

local loadlist = false
function setplaylist()
	if 	errorproof("path") and loadlist == false then
		if	mp.get_property("file-format","") == "flv"
		then
			mp.commandv("playlist_clear")		
			if	m.enablertmp == 1	then
				mp.add_timeout(0.1, function()
					playlist.set("rtmp",s.playlistcount,"http")
				end)
				loadlist = true
			elseif	m.enablertmp == 2	then
				mp.add_timeout(0.1, function()
					playlist.set("rtmp",s.playlistcount)
				end)
				loadlist = true
			else
				mp.add_timeout(0.1, function()
					playlist.set("http",s.playlistcount)
				end)
				loadlist = true			
			end
			
		elseif mp.get_property("file-format","") == "asf" then
			mp.add_timeout(0.1, (function()
				playlist.set("mmsh",s.playlistcount)
			end))
			loadlist = true
		else

			mp.add_timeout(0.1, (function()
				playlist.set("http",s.playlistcount)
			end))
			loadlist = true
				
		end
	elseif errorproof("path") and mp.get_property_number("playlist-count") > s.playlistcount + 1 then
		resetplaylist()
	end
end
function resetplaylist()
	loadlist = false
	setplaylist()
end
mp.register_event("file-loaded", setplaylist)
--mp.register_event("start-file", setplaylist)

function wmapro()
	if	currentinfo.acodec == "wmapro" or get.codec("audio") == "wmapro" then
		--mp.set_property_number("options/mc",0.0001)
		s.limitct = 100000
		s.limitavsync = 2
	end
end
mp.register_event("playback-restart",wmapro)


function manualrtmp()
	loadlist = false
--	mp.add_timeout(0.1, function()
		playlist.set("rtmp",s.playlistcount,"http")
--	end)
	loadlist = true
end
mp.add_key_binding("KP9", "manualrtmp" , manualrtmp)

getorginfo = {
	title = function()
		if	errorproof("path") then
			if	string.find(mp.get_property("media-title",""), string.rep("%x", 32)) then
				t.mediatitle = mp.get_property("options/title")
				mp.set_property("options/force-media-title",t.mediatitle)
			else	t.mediatitle = mp.get_property("media-title","")
			end
		else	t.mediatitle = mp.get_property("media-title","")
		end
	end,
	
	resolution = function()
		videoinfo.width  = mp.get_property("width", 0)
		videoinfo.height = mp.get_property("height", 0)
		videoinfo.size = string.format("%d",videoinfo.width).."x"..string.format("%d",videoinfo.height)
	end,
	
	fps = function()
		if 	mp.get_property_number("fps",0) == 1000 then videoinfo.fps = "vfr"
		else	videoinfo.fps = string.format("%3.1f", mp.get_property_number("fps",0))
		end
	end,

	start = function()
		getorginfo.title()
		getorginfo.resolution()
		getorginfo.fps()
	end
}

mp.register_event("file-loaded", getorginfo.start)




--キャッシュ量を再生スピードで調整
function autospeed()
	if errorproof("playing")
	and brate ~= nil  
	and mp.get_property_number("packet-video-bitrate", 0) > 1
	and m.enableautospeed ~= 0
	then
	local a,b,buffer = get.cache()

		local curspd
		if	m.enableautospeed == 2 then s.lowspeed = 1
		end
		if	s.highspeed+s.persec*buffer < s.maxspeed then
			curspd = s.highspeed+s.persec*buffer
			else
			curspd = s.maxspeed
		end
		
		if 	buffer > s.normal1 and buffer < s.normal2 then
			mp.set_property("speed", 1.00)
		elseif	buffer < s.low then
			mp.set_property("speed", s.lowspeed)
		elseif buffer > s.high then
			mp.set_property("speed", curspd)
		elseif mp.get_property_number("speed") <= s.lowspeed and buffer > s.normal1 then
			mp.set_property("speed", 1.00)
		elseif mp.get_property_number("speed") >= s.highspeed and buffer < s.normal2 then
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
--	mp.commandv("seek","1")
--	print(mp.get_property("window-minimized"))
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
--mp.commandv("playlist_pos", mp.get_property("playlist_pos"))
--mp.set_property_number("playlist-pos",mp.get_property_number("playlist-pos",0))
--print(mp.get_property_number("playlist-pos"))
--print(mp.get_property_number("video-bitrate"))
--mp.osd_message(mp.get_property("path"),5)
--mp.osd_message(mp.get_property("path"),5)
print(mp.get_property("playlist/0/filename"))
--local f = io.open("test.txt", "r")
--local a=io.open("testwrite.txt","w+")
--for line in f:lines() do
--	
--	a:write(line)
--end


--f:close()

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
end
mp.add_key_binding("KP8", "test" , test)


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
	if	errorproof("path") or m.enableothers == 1 then
		if 	not errorproof("firststart") or not errorproof("path") then
			autospeed()
			mp.set_property("options/title", tset("display") )
			bumpcount();--mp.osd_message("others")
		else 			
			count = count + 1
			if	errorproof("path") and count >= 21 then
				mp.set_property("loop", "yes")
				bump.t()
--				playlist.addurl()
				resetplaylist()
				count = 0
			end		
		end
--	else	
	end
end))

--早めに再開できるようにと、再生と停止を繰り返すときの処理
function bumpcount()
	local pos = mp.get_property_number("playlist-pos",0)
	local inccount = 10					--止まった時に1秒ごとに増える数
	local reccount = s.recsec * inccount
	local incposseccount = s.incpossec * inccount
	local decposcount = -1 * math.abs(s.decpossec) * inccount
	local deccount = -1 * inccount / s.offsetsec
	
	count = (math.modf(count*1000))/1000

	if	mp.get_property_bool("core-idle") and not mp.get_property_bool("pause") then

		count = count + inccount
--		print("count+"..inccount.." count:"..count)
		--if	count >= 200 then
		--	bump.t()
		--	resetplaylist()
		--	count = count - 200
		if	math.fmod(math.floor(count/10),math.floor(incposseccount/10)) == 0 then --count >= 100 then
			mp.commandv("playlist-next")
			count = count + decposcount
			print("current pos:".. pos + 1 .."  count"..decposcount.." count:"..count)
		elseif	math.fmod(math.floor(count/10),math.floor(reccount/10)) == 0 then
			mp.set_property_number("playlist-pos",pos)
			print "reconnect"
		end
		
	else
		if	count > 0 then
			count = count + deccount
--			print("count"..deccount.." count:"..count)
		else	count = 0
		end
	end
--print("end:"..count)
end

local maxvalue = {
	type = 3,
	size = 3,
	bitrate = 1,
	fps = 3,
	cache = 2,
	playtime = 1,
	autospeed = 2,
	protocol = 1
}
function sv(value)
	mp.osd_message(string.format("%1d",value))
end
local cyclevalue = {
	type = function() m.showtype = m.showtype + 1; if m.showtype > maxvalue.type then m.showtype = 0 ;sv(m.showtype)end;end,
	size = function() m.showsize = m.showsize + 1; if m.showsize > maxvalue.size then m.showsize = 0 end;end,
	bitrate = function() m.showbitrate = m.showbitrate + 1; if m.showbitrate > maxvalue.bitrate then m.showbitrate = 0 end;end,
	fps = function() m.showfps = m.showfps + 1; if m.showfps > maxvalue.fps then m.showfps = 0 end;end,
	cache = function() m.showcache = m.showcache + 1; if m.showcache > maxvalue.cache then m.showcache = 0 end;end,
	playtime = function() m.showplaytime = m.showplaytime + 1; if m.showplaytime > maxvalue.playtime then m.showplaytime = 0 end;end,
	autospeed = function() m.autospeed = m.autospeed + 1; if m.autospeed > maxvalue.autospeed then m.autospeed = 0 ;sv(m.autospeed)end;end,
	protocol = function() m.showprotocol = m.showprotocol + 1; if m.showprotocol > maxvalue.protocol then m.showprotocol = 0 end;end
}

mp.add_key_binding( m.ktype,"cycleshowtype",cyclevalue.type)
mp.add_key_binding( m.ksize,"cycleshowsize",cyclevalue.size )
mp.add_key_binding( m.kbitrate,"cycleshowbitrate",cyclevalue.bitrate)
mp.add_key_binding( m.kfps,"cycleshowfps",cyclevalue.fps)
mp.add_key_binding( m.kcache,"cycleshowcache",cyclevalue.cache)
mp.add_key_binding( m.kplaytime,"cycleshowplaytime",cyclevalue.playtime)
mp.add_key_binding( m.kautospeed,"cycleautospeed",cyclevalue.autospeed)
mp.add_key_binding( m.kprotocol,"cycleshowprotocol",cyclevalue.protocol)

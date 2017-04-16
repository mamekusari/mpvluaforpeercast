require("mlpsettings")

getinfo = {
	function(case)
		if case == "" then
		end
	end
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
	size = 0,
	bitrate = 0,
	title = "",
	type = "",
	vcodec = "",
	acodec = ""
}

pecainfo = {
	ipandport = "",
	id = "",
	stream = "",
	pls = "",
	protocol = ""
	
}

local t = {
	fps = 0,
	width = 0,
	height = 0,
	size = "0x0",
	title = "",
	type = "",
	vol = 0,
	mediatitle = ""
}


mp.set_property("options/softvol", "yes" )
mp.set_property("options/volume-max", mlpsettings.s.maxvolume )
mp.set_property("options/softvol-max", mlpsettings.s.maxvolume )
mp.set_property("options/volume", mlpsettings.s.ivolume )
mp.set_property("options/cursor-autohide" , "3000" )
mp.set_property("options/cursor-autohide-fs-only", "no" )		--いったんnoにしないと動かなかった
if mlpsettings.s.icursorhide == 0 then mp.set_property("options/cursor-autohide" , "no" )
elseif mlpsettings.s.icursorhide == 2 then mp.set_property("options/cursor-autohide-fs-only", "yes" )
end
if mlpsettings.s.isnapwindow == 1 then mp.set_property_bool("options/snap-window", true)
else mp.set_property_bool("options/snap-window", false)
end

function getsavdir(name)
	local userdir,savdir = os.getenv("USERPROFILE")
	if 	string.find(userdir," and ") then
		savdir = userdir.."\\My "..name.."\\"
	elseif	string.find(userdir,"Users") then
		savdir = userdir.."\\"..name.."\\"
	else	savdir = ""
	end
	return savdir
end

mp.set_property("options/screenshot-format", mlpsettings.s.sstype )
mp.set_property("options/screenshot-jpeg-quality", mlpsettings.s.jpgquality )
if mlpsettings.s.sssize == 0 then mlpsettings.s.sssize = "window" 
else mlpsettings.s.sssize = "video"
end
if	mlpsettings.s.ssdir == "" then
	mlpsettings.s.ssdir = getsavdir("Pictures")
elseif	string.sub(ssdir,string.len(s.ssdir)) ~= "\\" then
	mlpsettings.s.ssdir = mlpsettings.s.ssdir.."\\"
end
mp.set_property("options/screenshot-template", mlpsettings.s.ssdir.."%{media-title}_%tY%tm%td_%tH%tM%tS_%n")

function delay(sec,command1,command2,command3)
	mp.add_timeout(sec,function()mp.commandv(command1,command2,command3)end)
end

local apply = false
function applysettings()
	--はじめの設定を適用する
	if	errorproof("firststart") and errorproof("path") and not apply then
		local osc = mp.get_property("options/osc")
		local fontsize = mp.get_property("options/osd-font-size")
		if 	mlpsettings.s.iosc == 1 then
			if	osc == "no" then
				mp.commandv("script_message","osc-visibility","cycle")
			elseif	osc == "always" then
				mp.commandv("script_message","osc-visibility","cycle")
				delay(0.1,"script_message","osc-visibility","cycle")
			end
			mp.set_property("osc","yes")
		elseif	mlpsettings.s.iosc == 2 then 
			if	osc == "yes" then
			mp.commandv("script_message","osc-visibility","cycle")
			elseif	osc == "no" then
			mp.commandv("script_message","osc-visibility","cycle")
			delay(0.1,"script_message","osc-visibility","cycle")
			end
			mp.set_property("osc","yes")
		else	
			if	osc == "yes" then
			mp.commandv("script_message","osc-visibility","cycle")
			delay(0.1,"script_message","osc-visibility","cycle")
			elseif	osc == "always" then
			mp.commandv("script_message","osc-visibility","cycle")
			end
			mp.set_property("osc","no")
		end
		mp.set_property_number("options/osd-font-size",fontsize)
		if	mlpsettings.s.istatusbar == 1 and mp.get_property("border") == "no" then
			delay(0.1,"cycle","border")
		elseif	mlpsettings.s.istatusbar == 0 and mp.get_property("border") == "yes" then
			delay(0.1,"cycle","border")
		end
		if	mlpsettings.s.iontop == 1 and mp.get_property("ontop") == "no" then
			delay(0.1,"cycle","ontop")
		elseif	mlpsettings.s.iontop == 0 and mp.get_property("ontop") == "yes" then
			delay(0.1,"cycle","ontop")
		end
		if	mlpsettings.s.iosd == 0 then
			mp.set_property("options/osd-font-size","1")
		else	mp.set_property("options/osd-font-size", fontsize)
		end
		mp.set_property("loop","yes")
		mp.set_property_number("options/demuxer-readahead-secs", 20)
		mp.set_property_bool("rebase-start-time", false)
		mp.set_property_bool("taskbar-progress", false)
		apply = true
	end
end
mp.register_event("start-file",applysettings)

function beginningmute()
	if	errorproof("path") and not mp.get_property_bool("mute",true) then
	mp.set_property("mute","yes")
	mp.add_timeout(4,function()mp.set_property("mute","no")end)
	end
end
mp.register_event("file-loaded",beginningmute)










local playlist = {}
playlist = {
	geturl = function(protocol)
			local streampath,localhost,streamid = get.path()
			if	not protocol then protocol = "http" 
			end
			pecainfo.ipandport = localhost
			pecainfo.id = streamid
			pecainfo.stream = localhost .. "/stream/" .. streamid
			pecainfo.pls = localhost .. "/pls/" .. streamid
			pecainfo.protocol = protocol
			return protocol .. "://" .. localhost .. "/stream/" .. streamid
		end,
	addurl = function(protocol,times)
			if	errorproof("path") then
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
	pos = function()
		local playlistcount = mp.get_property_number("playlist-count",0)
		local bumpurl
		local i = 0
		repeat bumpurl = string.find(mp.get_property("playlist/".. i .."/filename",""), "/admin??cmd=bump")
			i = i + 1
			until bumpurl  or playlistcount < i
		if	playlistcount < i then
			i = false
		end
		return i,playlistcount,mp.get_property_number("playlist-pos",0)+1 --1から数える
	end,
	t = function()
		local bumppos,playlistcount,currentpos = bump.pos()
		if	bumppos then
			if	bumppos > currentpos then
				for i = currentpos , bumppos - 1 do
					mp.commandv("playlist-next")
				end
			else
				for i = bumppos , playlistcount - currentpos + bumppos + 1 do
					mp.commandv("playlist-next")
				end
			end
		else
			mp.commandv("loadfile", bump.geturl(), "append")
			mp.commandv("playlist-next")
		end
		count = 0
		mp.osd_message("bump",3)
	end
}

function errorproof(case)
	if 	case == "path" then
		if string.find(mp.get_property("path",""),"/stream/".. string.rep("%x", 32)) then
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
	if	value ~= nil and math.abs(value) > mlpsettings.s.limitavsync then
			mp.commandv("drop_buffers")
			print("avsync:"..value)
	end
end
mp.observe_property("avsync", "number", avsync)

function ct(name,value)
	if	value ~= nil and math.abs(value) > mlpsettings.s.limitct then
		mp.commandv("playlist_next")
		print("outofct: "..value)
	end
end
mp.observe_property("total-avsync-change", "number", ct)


get = {
	--URL取得と分割
	path = function()
	    local fullpath = mp.get_property("playlist/0/filename","")
		if	string.find(fullpath,"admin??cmd=") then
			local pos = mp.get_property_number("playlist-pos",0)
			if	pos >= 1 then
				fullpath = mp.get_property("playlist/".. pos-1 .."/filename","")
			else
				fullpath = mp.get_property("playlist/".. pos+1 .."/filename","")
			end
		end
	    local id = {string.find(fullpath,"/stream/(%x*)")}
	    local a = {}
			for i in string.gmatch(fullpath, "[^/]+") do
			table.insert(a, i)
			end
	    return fullpath,a[2],id[3]
	end,

	--mp.get_property("stream-pos")は不安定らしいからこれは使えない
	streampos = function ()
		local streampos
	--	print("1")
		streampos = mp.get_property("stream-pos", 0)
	--	print(streampos)
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
		if	currentinfo.acodec == "wmapro" then
			demux = mp.get_property_number("demuxer-cache-duration", 0)	--wmaproの時にはこっちで
		else	demux = mp.get_property("demuxer-cache-time",0) - mp.get_property("playback-time",0)
		end
		if	mp.get_property_number("packet-video-bitrate", 0) >= 0 then
			sec = cache/(get.bitrate() /8 ) + demux
		else	sec = 0
		end
		if	not mp.get_property("cache-used") then
			cache = false
		end
		return cache,demux,sec
	end,

	--解像度取得
	resolution = function(tateyoko)
		currentinfo.width = string.format("%d", mp.get_property_number("osd-width", 0) )
		currentinfo.height = string.format("%d", mp.get_property_number("osd-height", 0) )
		currentinfo.size = currentinfo.width .. "x" .. currentinfo.height
		if	tateyoko == "tate" then 
			tateyoko =  currentinfo.height
		elseif tateyoko == "tateyoko" then
			tateyoko = currentinfo.size
		else	tateyoko = currentinfo.width
		end
		return tateyoko
	end,

	codec = function(type)
		local count = mp.get_property_number("track-list/count",0)
		local i = 0
		repeat videoinfo.codec[i+1] = mp.get_property("track-list/"..i.."/codec")
			i = i + 1
		until	videoinfo.codec[i] == nil
		
		if	count == 0 then
			return "none"
		elseif	count == 1 then
			if	mp.get_property("track-list/0/type","") == "video" then
				currentinfo.vcodec = videoinfo.codec[1]
				currentinfo.acodec = "none"
			else	currentinfo.acodec = videoinfo.codec[1]
				currentinfo.vcodec = "none"
			end
		elseif	count == 2 then
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

local tset = {}
tset = function(case)
	--ビデオコーデック取得
	if	case == "codec"	then
		local video,audio,container
		if	mlpsettings.s.showtype ~= 0 then
			video = get.codec("video")
			audio = get.codec("audio")
			container = mp.get_property("file-format","")
			if	mlpsettings.s.showtype == 1 then
				t.type = "["..video.."]"
			elseif	mlpsettings.s.showtype == 2 then t.type = "["..container.."]"
			elseif	mlpsettings.s.showtype == 3 then t.type = "["..audio.."]"
			end
		else	t.type = ""
		end
	--解像度
	elseif	case == "size"	then
		local size
		if	mlpsettings.s.showsize == 0 then size = ""
		else
			if	mlpsettings.s.showsize == 3 then
				size = videoinfo.size
			elseif mlpsettings.s.showsize == 2 then size = get.resolution("tateyoko")
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
		if	mlpsettings.s.showbitrate == 0 then	rate = ""
		else	rate = string.format("%4dk", get.bitrate())
		end
		return	rate
	--fps
	elseif	case == "fps"	then
		if	mlpsettings.s.showfps == 3 then t.fps = videoinfo.fps
		elseif	mlpsettings.s.showfps == 0 then t.fps = ""
		elseif	mlpsettings.s.showfps == 1 then t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0)).."/"..videoinfo.fps
		else	t.fps = string.format("%3.1f", mp.get_property("estimated-vf-fps", 0))
		end
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
	--再生時間
	elseif	case == "playtime"	then
		if	mlpsettings.s.showplaytime ~= 1 then t.time = ""
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
	--キャッシュ
	elseif	case == "cache"	then
		local cache,demux,sec = get.cache()
		if	sec ~= sec or get.bitrate() == 0 then sec = "-"
		else	sec = string.format("%3.1fs",sec)
		end
		if	mlpsettings.s.showcache == 0 or not cache then t.cache = ""
		elseif	mlpsettings.s.showcache == 1 then t.cache = sec
		elseif	mlpsettings.s.showcache == 2 then t.cache = string.format("%3.1fs+%03dKB",demux,cache)
		end
	--音量
	elseif	case == "volume"	then
		if	mp.get_property_bool("mute") then t.vol = " vol:-" 
		else	t.vol =  string.format(" vol:%d", mp.get_property("volume", 0))
		end
	--プロトコル
	elseif	case == "protocol"	then
		if mlpsettings.s.showprotocol == 1 then
			if string.find(get.path(),"rtmp://") and mp.get_property("file-format","") == "flv" then
				t.protocol = "rtmp"
			elseif mp.get_property("file-format","") == "flv" then	t.protocol = "http"
			else t.protocol = ""
			end
		else	t.protocol = ""
		end
	--再生速度
	elseif	case == "speed"	then
		if	mp.get_property_number("speed",0) ~= 1 then
			t.speed = string.format(" x%3.2f",mp.get_property_number("speed"))
		else
			t.speed = ""
		end
	--まとめてタイトルバーに表示
	elseif	case == "display" then
		tset("protocol")
		tset("codec")
		tset("speed")
		tset("sort")
		tset("cache")
		tset("playtime")
		tset("volume")
		t.barlist = (
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
			if	mlpsettings.s.enablertmp == 1	then
				mp.add_timeout(0.1, function()
					playlist.set("rtmp",mlpsettings.s.playlistcount,"http")
				end)
				loadlist = true
			elseif	mlpsettings.s.enablertmp == 2	then
				mp.add_timeout(0.1, function()
					playlist.set("rtmp",mlpsettings.s.playlistcount)
				end)
				loadlist = true
			else
				mp.add_timeout(0.1, function()
					playlist.set("http",mlpsettings.s.playlistcount)
				end)
				loadlist = true
			end
			
		elseif mp.get_property("file-format","") == "asf" then
			mp.add_timeout(0.1, (function()
				playlist.set("mmsh",mlpsettings.s.playlistcount)
			end))
			loadlist = true
		else
			mp.add_timeout(0.1, (function()
				playlist.set("http",mlpsettings.s.playlistcount)
			end))
			loadlist = true
		end
	elseif errorproof("path") and mp.get_property_number("playlist-count") > mlpsettings.s.playlistcount + 1 then
		resetplaylist()
	end
end
function resetplaylist()
	loadlist = false
	setplaylist()
end
mp.register_event("file-loaded", setplaylist)

function wmapro()
	if	currentinfo.acodec == "wmapro" or get.codec("audio") == "wmapro" or
		currentinfo.acodec == "wmav2" or get.codec("audio") == "wmav2" then
		if currentinfo.acodec == "wmapro" or get.codec("audio") == "wmapro" then 
			mp.set_property("options/video-sync", "display-resample")
		end
		mlpsettings.s.limitct = 100000
		mlpsettings.s.limitavsync = 100
	end
end
mp.register_event("playback-restart",wmapro)


function manualrtmp()
	loadlist = false
		playlist.set("rtmp",mlpsettings.s.playlistcount,"http")
	loadlist = true
end
--mp.add_key_binding("KP9", "manualrtmp" , manualrtmp)

getorginfo = {
	title = function()
		local mediatitle = mp.get_property("media-title","no media title")
		local title = mp.get_property("options/title","no title")
		if	string.find(mediatitle, string.rep("%x", 32))
			and	(string.find(title,"no title") or string.find(title,"No file"))
		then
			t.mediatitle = "no title"
			mp.set_property("media-title",t.mediatitle)
		elseif	string.find(mediatitle, string.rep("%x", 32)) then
			t.mediatitle = title
			mp.set_property("media-title",t.mediatitle)
		else	t.mediatitle = mediatitle
		end
	end,
	
	resolution = function()
		videoinfo.width  = mp.get_property("width", 0)
		videoinfo.height = mp.get_property("height", 0)
		videoinfo.size = string.format("%d",videoinfo.width).."x"..string.format("%d",videoinfo.height)
	end,
	
	fps = function()
		if 	mp.get_property_number("container-fps",0) == 1000 then videoinfo.fps = "vfr"
		else	videoinfo.fps = string.format("%3.1f", mp.get_property_number("container-fps",0))
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
	and brate  
	and mp.get_property_number("packet-video-bitrate", 0) > 1
	and mlpsettings.s.enableautospeed ~= 0
	and mp.get_property("cache-used")
	then
		local buffer = select(select("#",get.cache()),get.cache())

		local curspd
		if	mlpsettings.s.enableautospeed == 2 then mlpsettings.s.lowspeed = 1
		end
		if	mlpsettings.s.highspeed+mlpsettings.s.persec*buffer < mlpsettings.s.maxspeed then
			curspd = mlpsettings.s.highspeed+mlpsettings.s.persec*buffer
		else
			curspd = mlpsettings.s.maxspeed
		end
		
		if 	buffer > mlpsettings.s.normal1 and buffer < mlpsettings.s.normal2 then
			mp.set_property("speed", 1.00)
		elseif	buffer < mlpsettings.s.low then
			mp.set_property("speed", mlpsettings.s.lowspeed)
		elseif buffer > mlpsettings.s.high then
			mp.set_property("speed", curspd)
		elseif mp.get_property_number("speed") <= mlpsettings.s.lowspeed and buffer > mlpsettings.s.normal1 then
			mp.set_property("speed", 1.00)
		elseif mp.get_property_number("speed") >= mlpsettings.s.highspeed and buffer < mlpsettings.s.normal2 then
			mp.set_property("speed", 1.00)
		end
	else	mp.set_property("speed", 1.00)
	end

end

--リレーそのままで開き直す
function refresh()
	if	errorproof("path") then
		local streampath,localhost,streamid = get.path()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		resetplaylist()
	end
end
mp.add_key_binding("KP7","refresh",refresh)

--タイマーと最初に止まったままだった時の処理
local count = 0
mp.add_periodic_timer(1, (function()
	if	errorproof("path") or mlpsettings.s.enableothers == 1 then
		if 	not errorproof("firststart") or not errorproof("path") then
			autospeed()
			mp.set_property("options/title", tset("display") )
			if	errorproof("path") then
				reconnectcount()
			end
			countplaytime = mp.get_property_number("playback-time",-1)
			countcache = (select(3, get.cache()))
		else
			count = count + 1
			print ("count: " .. count)
			if	errorproof("path") and count >= 21 then
				mp.set_property("loop", "yes")
				mp.commandv("stop")
				mp.commandv("loadfile", mp.get_property("path"))
				resetplaylist()
				count = 0
			end
		end
	end
end))

--早めに再開できるようにと、再生と停止を繰り返すときの処理
local countcache , countplaytime = 0,0
function reconnectcount()
	local pos = mp.get_property_number("playlist-pos",0)
	local cntpersec = 10					--止まった時に1秒ごとに増える数
	local reccount = mlpsettings.s.recsec * cntpersec
	local incposseccount = mlpsettings.s.incpossec * cntpersec
	local inccount = math.abs(mlpsettings.s.incsec) * cntpersec
	local deccount = -1 * cntpersec / mlpsettings.s.offsetsec
	local bumpcount = mlpsettings.s.bumpsec * cntpersec
	if	mp.get_property_bool("core-idle") and not mp.get_property_bool("pause")
	then

		count = count + cntpersec
		count = (math.modf(count*1000))/1000
		if	count >= bumpcount then
			bump.t()
			count = count - bumpcount / 2
		elseif	math.fmod(math.floor(count/10),math.floor(incposseccount/10)) == 0 then
			mp.commandv("playlist-next")
			count = count + inccount
			print("current pos:".. pos + 2 .."  count+"..inccount.." count:"..count)
		elseif	math.fmod(math.floor(count/10),math.floor(reccount/10)) == 0 then
			mp.set_property_number("playlist-pos",pos)
			print ("reconnect".." count:"..count)
		end
		
	else
		if	count > 0 then
			count = count + deccount
		else	count = 0
		end
	end
end

local test = {}
test.new = function(name,value,max)
	local obj = {}
	obj.name = name
	obj.value = value
	obj.max = max
	obj.cyclevalue = function(self)
		self.value = self.value + 1
		if	self.value > self.max then
			self.value = 0
		end
		value = self.value
		print(value)
	end
	return obj
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
function t1()
	for	i , ver in pairs(maxvalue) do
	print(ver)
	end
end
mp.add_key_binding("KP1","testest",t1)
function sv(value)
	mp.osd_message(string.format("%1d",value))
end
local cyclevalue = {
	type = function() mlpsettings.s.showtype = mlpsettings.s.showtype + 1; if mlpsettings.s.showtype > maxvalue.type then mlpsettings.s.showtype = 0 end;end,
	size = function() mlpsettings.s.showsize = mlpsettings.s.showsize + 1; if mlpsettings.s.showsize > maxvalue.size then mlpsettings.s.showsize = 0 end;end,
	bitrate = function() mlpsettings.s.showbitrate = mlpsettings.s.showbitrate + 1; if mlpsettings.s.showbitrate > maxvalue.bitrate then mlpsettings.s.showbitrate = 0 end;end,
	fps = function() mlpsettings.s.showfps = mlpsettings.s.showfps + 1; if mlpsettings.s.showfps > maxvalue.fps then mlpsettings.s.showfps = 0 end;end,
	cache = function() mlpsettings.s.showcache = mlpsettings.s.showcache + 1; if mlpsettings.s.showcache > maxvalue.cache then mlpsettings.s.showcache = 0 end;end,
	playtime = function() mlpsettings.s.showplaytime = mlpsettings.s.showplaytime + 1; if mlpsettings.s.showplaytime > maxvalue.playtime then mlpsettings.s.showplaytime = 0 end;end,
	autospeed = function() mlpsettings.s.enableautospeed = mlpsettings.s.enableautospeed + 1; if mlpsettings.s.enableautospeed > maxvalue.autospeed then mlpsettings.s.enableautospeed = 0 end;end,
	protocol = function() mlpsettings.s.showprotocol = mlpsettings.s.showprotocol + 1; if mlpsettings.s.showprotocol > maxvalue.protocol then mlpsettings.s.showprotocol = 0 end;end
}

mp.add_key_binding( mlpsettings.s.ktype,"cycleshowtype",cyclevalue.type)
mp.add_key_binding( mlpsettings.s.ksize,"cycleshowsize",cyclevalue.size )
mp.add_key_binding( mlpsettings.s.kbitrate,"cycleshowbitrate",cyclevalue.bitrate)
mp.add_key_binding( mlpsettings.s.kfps,"cycleshowfps",cyclevalue.fps)
mp.add_key_binding( mlpsettings.s.kcache,"cycleshowcache",cyclevalue.cache)
mp.add_key_binding( mlpsettings.s.kplaytime,"cycleshowplaytime",cyclevalue.playtime)
mp.add_key_binding( mlpsettings.s.kautospeed,"cycleautospeed",cyclevalue.autospeed)
mp.add_key_binding( mlpsettings.s.kprotocol,"cycleshowprotocol",cyclevalue.protocol)

--osc切り替え
function osc()
	mp.commandv("script_message", "osc-visibility","cycle")
end
mp.add_forced_key_binding(  mlpsettings.s.kosc, "osc", osc)

--スクリーンショット
function screenshot()
	if 	errorproof("playing") then
		if	  mlpsettings.s.sssubdir == 1 then
			  mlpsettings.s.ssdir =   mlpsettings.s.ssdir ..mp.get_property("media-title").."\\"
			os.execute("mkdir ".."\""..  mlpsettings.s.ssdir.."\"")
			mp.set_property("options/screenshot-template",   mlpsettings.s.ssdir.."%{media-title}_%tY%tm%td_%tH%tM%tS_%n")
			  mlpsettings.s.sssubdir = 0
		end
		mp.commandv("screenshot" ,   mlpsettings.s.sssize )
		mp.osd_message("screenshot")
	end
end
mp.add_key_binding(  mlpsettings.s.kscreenshot, "screenshot", screenshot)

function volmessage()
	local vol = mp.get_property("volume")
	if	not vol then vol = "volume:-"
	else	vol = string.format("volume:%d", vol)
	end
	if	mp.get_property_bool("mute") then vol = vol .. "(mute)"
	end
	mp.osd_message(vol)
end


--ボリューム上げる
function gainvolume()
	mp.commandv("add", "volume",   mlpsettings.s.volume)
	volmessage()
end
mp.add_key_binding(  mlpsettings.s.kvolup, "gainvolume", gainvolume)
mp.add_key_binding(  mlpsettings.s.kvolup_wheel, "gainvolume_wheel", gainvolume)

function cgainvolume()
	mp.commandv("add", "volume",   mlpsettings.s.ctrlvolume)
	volmessage()
end
mp.add_key_binding(  mlpsettings.s.kvolup2, "cgainvolume_wheel", cgainvolume)

function sgainvolume()
	mp.commandv("add", "volume",   mlpsettings.s.shiftvolume)
	volmessage()
end
mp.add_key_binding("Shift+Up", "sgainvolume", sgainvolume)
mp.add_key_binding( mlpsettings.s.kvolup3, "sgainvolume_wheel", sgainvolume)

--ボリューム下げる
function reducevolume()
	mp.commandv("add", "volume", -1 *   mlpsettings.s.volume)
	volmessage()
end
mp.add_key_binding( mlpsettings.s.kvoldown, "reducevolume", reducevolume)
mp.add_key_binding( mlpsettings.s.kvoldown_wheel, "reducevolume_wheel", reducevolume)

function creducevolume()
	mp.commandv("add", "volume", -1 *   mlpsettings.s.ctrlvolume)
	volmessage()
end
mp.add_key_binding( mlpsettings.s.kvoldown2, "creducevolume_wheel", creducevolume)

function sreducevolume()
	mp.commandv("add", "volume", -1 *   mlpsettings.s.shiftvolume)
	volmessage()
end
mp.add_key_binding("Shift+Down", "sreducevolume", reducevolume)
mp.add_key_binding( mlpsettings.s.kvoldown3, "sreducevolume_wheel", sreducevolume)

--ミュート
function mute()
	if	errorproof("playing")	then
		mp.commandv("cycle", "mute")
		if 	mp.get_property_bool("mute") then
			mp.osd_message("mute")
		else	mp.osd_message("mute off")
		end
	end
end
mp.add_key_binding(  mlpsettings.s.kmute, "mute", mute)

--音声を左のみに
function panleft()
	if 	mp.get_property_number("audio-channels",0) == 1 then
		mp.set_property("af", "pan=2:[ 1 , 0 ]")
	else 	mp.set_property("af", "channels=2:[ 1-0 , 1-0 ]")
	end
	mp.osd_message("pan left")
end
mp.add_key_binding( mlpsettings.s.kpanleft, "panleft", panleft)

--音声を右のみに
function panright()
	if	mp.get_property_number("audio-channels",0) == 1 then
		mp.set_property("af", "pan=2:[ 1 , 1 ]") 
	end
	mp.set_property("af", "channels=2:[ 0-1 , 0-1 ]")
	mp.osd_message("pan right")
end
mp.add_key_binding( mlpsettings.s.kpanright, "panright", panright)

--音声を中央（モノラル）に
function pancenter()
	mp.set_property("af", "pan=1:[ 1 , 1 ]")
	mp.osd_message("mono")
end
mp.add_key_binding( mlpsettings.s.kpancenter, "pancenter", pancenter)

--音声を普通のステレオに
function panrestore()
	mp.set_property("af", "channels=2")
	mp.osd_message("stereo")
end
mp.add_key_binding( mlpsettings.s.kpanstereo, "panrestore", panrestore)

--フルスクリーン
function fullscreen()
	mp.commandv("cycle" , "fullscreen")
end
mp.add_key_binding( mlpsettings.s.kfullscreen, "fullscreen", fullscreen)
mp.add_key_binding( mlpsettings.s.kfullscreen2, "fullscreen2", fullscreen)

--終了
function exit()
	mp.commandv("quit")
end
mp.add_key_binding( mlpsettings.s.kexit, "exit", exit)

--ステータスバーの代わり
function titlebar()
	mp.commandv("cycle" , "border")
end
mp.add_key_binding( mlpsettings.s.kstatusbar, "titlebar", titlebar)

--最前面表示切り替え
function ontop()
	mp.commandv("cycle", "ontop")
	if	mp.get_property_bool("ontop")	then
		mp.osd_message("ontop")
	else 	mp.osd_message("ontop off")
	end
end
mp.add_key_binding(  mlpsettings.s.kontop, "ontop", ontop)

--bump
mp.add_key_binding( mlpsettings.s.kbump, "bump" , bump.t)
mp.add_key_binding( mlpsettings.s.kbump2, "bump2" , bump.t)

--リレー切断
function stop()
	if 	errorproof("path") then
		local streampath,localhost,streamid = get.path()
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=stop&id=".. streamid)
	end
end
mp.add_key_binding( mlpsettings.s.kstop, "stop" , stop)


--ここからwindowサイズ変更

function changewindowsize(newwidth , newheight , kurobuti)
	local width, height , ratio = videoinfo.width , videoinfo.height
	if	width >= height then ratio = 1 / (width / newwidth)
	else	ratio = 1 / (height / newheight)
	end
	mp.set_property_number("window-scale" , ratio)
end


local videosize = {
	to160 = {160,120},
	to320 = {320,240},
	to480 = {480,360},
	to640 = {640,480},
	to800 = {800,600},
	to1280 = {1280,960},
	to1600 = {1600,1200},
	to1920 = {1920,1440}
}

function to50per()
	mp.set_property_number("window-scale", 0.5)
end
mp.add_key_binding( mlpsettings.s.k50, "50%", to50per)

function to75per()
	mp.set_property_number("window-scale", 0.75)
end
mp.add_key_binding( mlpsettings.s.k75, "75%", to75per)

function to100per()
	mp.set_property_number("window-scale", 1)
end
mp.add_key_binding(  mlpsettings.s.k100, "100%", to100per)

function to150per()
	mp.set_property_number("window-scale", 1.5)
end
mp.add_key_binding(  mlpsettings.s.k150, "150%", to150per)

function to200per()
	mp.set_property_number("window-scale", 2)
end
mp.add_key_binding(  mlpsettings.s.k200, "200%", to200per)

function to250per()
	mp.set_property_number("window-scale", 2.5)
end
mp.add_key_binding(  mlpsettings.s.k250, "250%", to250per)

function to300per()
	mp.set_property_number("window-scale", 3)
end
mp.add_key_binding(  mlpsettings.s.k300, "300%", to300per)

function to25per()
	mp.set_property_number("window-scale", 0.25)
end
mp.add_key_binding(  mlpsettings.s.k25, "25%", to25per)

function to160x120()
	changewindowsize(videosize.to160[1] , videosize.to160[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k160x120, "160x120", to160x120)

function to320x240()
	changewindowsize(videosize.to320[1] , videosize.to320[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k320x240, "320x240", to320x240)

function to480x360()
	changewindowsize(videosize.to480[1] , videosize.to480[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k480x360, "480x360", to480x360)

function to640x480()
	changewindowsize(videosize.to640[1] , videosize.to640[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k640x480, "640x480", to640x480)

function to800x600()
	changewindowsize(videosize.to800[1] , videosize.to800[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k800x600, "800x600", to800x600)

function to1280x960()
	changewindowsize(videosize.to1280[1] , videosize.to1280[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k1280x960, "1280x960", to1280x960)

function to1600x1200()
	changewindowsize(videosize.to1600[1] , videosize.to1600[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k1600x1200, "1600x1200", to1600x1200)

function to1920x1440()
	changewindowsize(videosize.to1920[1] , videosize.to1920[2] , true)
end
mp.add_key_binding(  mlpsettings.s.k1920x1440, "1920x1440", to1920x1440)

local fs,oldwidth,oldheight,panx
function minimize()
	local targetsize = {160 , 90}
	if	mp.get_property_number("video-pan-x") ~= -1 then
		panx = mp.get_property_number("video-pan-x" , 0)
		mp.set_property_number("video-pan-x" , -1)
		oldwidth = get.resolution("yoko")
		oldheight = get.resolution("tate")
		if	mp.get_property("fullscreen") == "yes" then
			fs = true
			fullscreen()
			mp.add_timeout(0.10, (function()
				oldwidth = get.resolution("yoko")
				oldheight = get.resolution("tate")
				end))
			mp.add_timeout(0.15, (function()changewindowsize(targetsize[1] , targetsize[2] , -1)
			end))
		else
			changewindowsize(targetsize[1] , targetsize[2] , -1)
			mp.set_property_number("video-pan-x" , -1)
		end
	else
		mp.set_property_number("video-pan-x" , panx)
		if	fs then
			changewindowsize(oldwidth , oldheight , -1)
			fullscreen()
			fs = false
		else
			changewindowsize(oldwidth , oldheight , 2)
		end
	end
end
mp.add_key_binding(  mlpsettings.s.kminimize , "minimize", minimize)

local ismute = false
function minmute()
	if	mp.get_property_number("video-pan-x") == 0 then
		ismute = mp.get_property_bool("mute",false)
		mp.set_property_bool("mute" , true)
	else	mp.set_property_bool("mute" , ismute)
	end
	minimize()
end
mp.add_key_binding(  mlpsettings.s.kminmute , "minmute", minmute)

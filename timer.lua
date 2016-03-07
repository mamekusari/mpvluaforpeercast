local m={
--�^�C�g���o�[�p���擾�^�C�}�[��lua�B0�Ŕ�\���܂��͖����ɂȂ�܂�

--�X�e�[�^�X�\���Ƃ�
showtype = 3,				--�r�f�I�R�[�f�b�N�u1�v���R���e�i�\���u2�v�B�u3�v�ŉ����R�[�f�b�N
showsize = 3,				--�𑜓x��\���B�u2�v�͍��̃T�C�Y�̂݁A�u3�v�̓\�[�X�T�C�Y�̂ݕ\��
showbitrate = 1,			--�L�[�t���[���Ԃ̃r�b�g���[�g�\���B
showfps = 1,				--fps�\���B�u2�v�͍���fps�̂݁A�u3�v�͓���Őݒ肳�ꂽfps�̂ݕ\��
showcache = 1,				--��̂̃o�b�t�@�T�C�Y��\���B�u2�v��demux+cache�̐��m�ȕ\��
showplaytime = 1,			--�Đ����ԁi���܂ɑ��z�M���ԁj��\��
showprotocol = 0,			--flv�̎���http��rtmp����\��
enablertmp = 0,				--flv�̎��ɁA�u1�v�͏��߂�rtmp�ōĐ�����B�u2�v�ł��ׂ�rtmp�ōĐ�����
enableautospeed = 1,			--�L���b�V���ʂ̎��������B�u2�v�ł��܂����Ƃ����������A�u0�v�Ŗ���
enableothers = 1,			--peercast�ȊO�ł��̃X�N���v�g��K�p���邩


--�\���؂�ւ��p�L�[�o�C���h
ktype = 	"ctrl+1",
ksize =		"ctrl+2",
kbitrate = 	"ctrl+3",
kfps = 		"ctrl+4",
kcache = 	"ctrl+5",
kplaytime = 	"ctrl+6",
kprotocol =	"ctrl+9",
kautospeed = 	"ctrl+0",


--��������X�N���v�g�̏����R�[�h
}
local s = {
	offsetsec = 50,			--���b��1�b���̃o�b�t�@�𑊎E���邩(50�b)
	recsec = 4,			--���l�̕b���ƂɃv���C���[���Đڑ�����(4�b)
	incpossec = 10,			--���l�̕b���ƂɃv���C���X�g��1����(10�b)
	decpossec = 5,			--�v���C���X�g�𑗂�����ɂ��̕b�����ǉ�����(5�b��)
	bumpsec = 40,			--����ȏソ�܂�ƃ����[���Đڑ�����(40�b)
	
	playlistcount = 4,		--�v���C���X�g�̐��ŁA���̎���bump������(4��)
	
	limitavsync = 0.5,		--���Y�������b�܂ŋ��e���邩(0.5�b)
	limitct = 2,			--���Y���C���ʂ����b�܂ŋ��e���邩(2�b)
	
	high = 10,   			--����ȏ�o�b�t�@�����܂����瑁����J�n(10�b)
	low = 1.2,   			--����ȉ��ɂȂ�����x������(1.2�b)
	normal1 = 2,			--�x������2�b�����܂����畁�ʂ̑��x�ɖ߂�(2�b)
	normal2 = 3,			--��������3�b���ɂȂ����畁�ʂ̑��x�ɖ߂�(3�b)
	lowspeed = 0.95,	 	--�x�������Ƃ��̍Đ����x(0.95�{)
	highspeed = 1.10,   		--���������Ƃ��̍Đ����x(1.10�{)
	persec = 0.01,			--�o�b�t�@�̕b���ɂ�������������𑫂�(+0.01)
	maxspeed = 2,			--���x�̏��(2�{)

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
			--	local streampath,localhost,streamid = get.path()
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
		repeat bumpurl = string.find(mp.get_property("playlist/".. i .."/filename"), "/admin??cmd=bump")
			i = i + 1
			until bumpurl  or playlistcount < i
		if	playlistcount < i then
			i = "no bump url"
		end
		return i,playlistcount,mp.get_property_number("playlist-pos",0)+1 --1���琔����
		
	end,
	t = function()
		local bumppos,playlistcount,currentpos = bump.pos()
		if	bumppos > currentpos then
			for i = currentpos , bumppos - 1 do
				mp.commandv("playlist-next")
			--	print(i)
			end
		else
			for i = bumppos , playlistcount - currentpos + bumppos + 1 do
				mp.commandv("playlist-next")
			--	print(i)
			end
		end
		mp.osd_message("bump",3)

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
	--URL�擾�ƕ���
	path = function()
	    local fullpath = mp.get_property("playlist/0/filename","")
		if	string.find(fullpath,"admin??cmd=") then
			local pos = mp.get_property_number("playlist-pos",0)
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
	    return fullpath,a[2],id[3]
	end,

	--mp.get_property("stream-pos")�͕s����炵�����炱��͎g���Ȃ�
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

	--�r�b�g���[�g�擾
	bitrate = function()
		--�L�[�t���[���Ԃ̃r�b�g���[�g���v��������@
		local pvrate = mp.get_property("packet-video-bitrate", 0)
		local parate = mp.get_property("packet-audio-bitrate", 0)

		if	vrate ~= pvrate then
			vrate = pvrate
			arate = parate
			brate = vrate + arate
		else
			brate = vrate + arate
		end
		--�X�g���[���̃f�[�^�ʂ���r�b�g���[�g���v�Z������@
	--	local streampos = get.streampos()
	--		if 	srate == nil or srate == 0 then 
	--			srate = streampos
	--			brate = srate /1024 * 8
	--		else
	--			--mkv�ȊO�������1�b���ςƂ�Ȃ��悤������2�Ŋ����Ă݂�
	--			brate = (brate + (streampos - srate) /1024 * 8)/2
	--			srate = streampos
	--		end
		return brate
	end,

	--�L���b�V���擾
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

	--�𑜓x�擾
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
	--�r�f�I�R�[�f�b�N�擾
	if	case == "codec"	then
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
	--�𑜓x
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
	--�r�b�g���[�g
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
	--���܂����ׂ���@���킩��Ȃ�����S�ʂ育�艟��
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
	--�Đ�����
	elseif	case == "playtime"	then
		if	m.showplaytime ~= 1 then t.time = ""
		else	t.time = mp.get_property_osd("playback-time", 0)
		end
		if	mp.get_property_bool("core-idle") and not mp.get_property_bool("pause") then
			t.time = "buffering"
		elseif	mp.get_property_bool("pause") then
			t.time = "pause"
		end
		--search����ł��邩�Ǝv�������ǂ��ꂶ��ł��Ȃ�
		if	mp.get_property_bool("idle") then
			t.time = "search"
		end
--		return	t.time
	--�L���b�V��
	elseif	case == "cache"	then
		local cache,demux,sec = get.cache()
		if	sec ~= sec or get.bitrate() == 0 then sec = "-"
		else	sec = string.format("%3.1fs",sec)
		end
		if	m.showcache == 0 or cache+demux == 0 then t.cache = ""
		elseif	m.showcache == 1 then t.cache = sec
		elseif	m.showcache == 2 then t.cache = string.format("%3.1fs+%03dKB",demux,cache)
		end
--		return	t.cache
	--����
	elseif	case == "volume"	then
		if	mp.get_property_bool("mute") then t.vol = " vol:-" 
		else	t.vol =  string.format(" vol:%d", mp.get_property("volume", 0))
		end
--		return	t.vol
	--�v���g�R��
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
	--�Đ����x
	elseif	case == "speed"	then
		if	mp.get_property_number("speed",0) ~= 1 then
			t.speed = string.format(" x%3.2f",mp.get_property_number("speed"))
			else
			t.speed = ""
		end
--		return	t.speed
	--�܂Ƃ߂ă^�C�g���o�[�ɕ\��
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
		s.limitavsync = 100
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
	--print(mp.get_property("media-title","nomediatitle").. " | " ..mp.get_property("options/title","notitle"))
		if	errorproof("path") then
			local mediatitle = mp.get_property("media-title","no media title")
			local title = mp.get_property("options/title","no title")
			if	string.find(mediatitle, string.rep("%x", 32))
			and	(string.find(title,"no title") or string.find(title,"No file"))
			then
				t.mediatitle = "no title"
				mp.set_property("options/force-media-title",t.mediatitle)
			--	print "1"
			elseif	string.find(mediatitle, string.rep("%x", 32)) then
				t.mediatitle = mp.get_property("options/title","no title")
				mp.set_property("options/force-media-title",t.mediatitle)
			--	print "2"
			else	t.mediatitle = mp.get_property("media-title","no title")
			--	print "3"
			end
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




--�L���b�V���ʂ��Đ��X�s�[�h�Œ���
function autospeed()
	if errorproof("playing")
	and brate ~= nil  
	and mp.get_property_number("packet-video-bitrate", 0) > 1
	and m.enableautospeed ~= 0
	and not string.find(mp.get_property_number("cache","none"),"none")
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
--print(bump.pos())
--	mp.set_property("stream-pos" , 0 )
--	print(mp.get_property("stream-capture"))
--	print(mp.get_property("time-pos"))
--	print(mp.get_property("fps"))
--	print(mp.get_property("speed"))
--	print(mp.get_property("playback-time"))
--	print(mp.get_property("time-start"))
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
--print(mp.get_property_number("cache-used","none"))
--print(mp.get_property_number("cache","cache"))
--print(mp.get_property_number("cache-duration","duration"))
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
--print(mp.get_property("playlist/0/filename"))
--local f = io.open("test.txt", "r")
--local a=io.open("testwrite.txt","w+")
--for line in f:lines() do
--	
--	a:write(line)
--end


--f:close()
--bump.t()
--mp.add_timeout(5,resetplaylist())
end
mp.add_key_binding("KP8", "test" , test)


--�����[���̂܂܂ŊJ������
function refresh()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		resetplaylist()
	end
end
mp.add_key_binding("KP7","refresh",refresh)

--�^�C�}�[�ƍŏ��Ɏ~�܂����܂܂��������̏���
local count = 0
mp.add_periodic_timer(1, (function()
--function timer()
	if	errorproof("path") or m.enableothers == 1 then
		if 	not errorproof("firststart") or not errorproof("path") then
			autospeed()
			mp.set_property("options/title", tset("display") )
			if errorproof("path") then reconnect()
			end
		else 			
			count = count + 1
			if	errorproof("path") and count >= 21 then
				mp.set_property("loop", "yes")
--				playlist.addurl()
				resetplaylist()
				bump.t()
				count = 0
			end		
		end
--	else	
	end
end))

--���߂ɍĊJ�ł���悤�ɂƁA�Đ��ƒ�~���J��Ԃ��Ƃ��̏���
function reconnect()
	local pos = mp.get_property_number("playlist-pos",0)
	local inccount = 10					--�~�܂�������1�b���Ƃɑ����鐔
	local reccount = s.recsec * inccount
	local incposseccount = s.incpossec * inccount
	local decposcount = math.abs(s.decpossec) * inccount
	local deccount = -1 * inccount / s.offsetsec
	local bumpcount = s.bumpsec * inccount
	
	count = (math.modf(count*1000))/1000

	if	mp.get_property_bool("core-idle") and not mp.get_property_bool("pause") then

		count = count + inccount
--		print("count+"..inccount.." count:"..count)
		if	count >= bumpcount then
			bump.t()
		--	resetplaylist()
			count = 0
		elseif	math.fmod(math.floor(count/10),math.floor(incposseccount/10)) == 0 then --count >= 100 then
			mp.commandv("playlist-next")
			count = count + decposcount
			print("current pos:".. pos + 2 .."  count"..decposcount.." count:"..count)
		elseif	math.fmod(math.floor(count/10),math.floor(reccount/10)) == 0 then
			mp.set_property_number("playlist-pos",pos)
			print ("reconnect".." count:"..count)
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

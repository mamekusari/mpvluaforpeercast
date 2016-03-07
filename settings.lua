local s={
--キーバインドは「T」だとshift+tで「t」で単体のtになります。「shift+t」の指定もできます
--mpvのデフォルトは無効になっていないのでたとえばqを押すとプレイヤーが終了します


--初期設定
--ボリューム関係				--下の方にあるキー割り当てを変えたらホイールとかcontrolとかはそのキーに変わります
ivolume = 50,				--初期ボリューム
maxvolume = 130,			--ボリュームの最大値。130で大体100の2倍の音量になります
volume = 5,				--マウスホイールの変更量
ctrlvolume = 3,				--control押しながらの時
shiftvolume = 1,			--shift押しながらの時

--スクリーンショット関係
sstype = "bmp",				--「"png"」又は「"jpg"」
jpgquality = 90,			--jpgの時の画質。0-100
sssize = 1,				--ソースサイズ「1」か表示windowサイズ「0」か
ssdir = "",	 			--保存場所。フォルダの区切りは｢\\｣。「""」でマイピクチャになります
sssubdir = 0,				--「1」でチャンネル名でサブフォルダを作る。「0」でつくらない

--その他					--保存フォルダ以外は0で無効になります
istatusbar = 1,				--ステータスバー（の代わりのタイトルバー）
icursorhide = 2,			--マウスカーソルを自動的に隠す「1」。「2」はフルスクリーンのみ隠す
iontop = 0,				--最前面表示
iosc = 0,				--オンスクリーンコントローラー。「2」で常に表示
iosd = 1,				--osdの表示


--キーバインド				--（）内はデフォルト
--音関係
kvolup = "Up",				--ボリュームアップ（↑キー）
kvoldown = "Down",			--ボリュームダウン（↓キー）
kvolup_wheel = "MOUSE_BTN3",		--ボリュームアップ2つめ（ホイール↑）
kvoldown_wheel = "MOUSE_BTN4",		--ボリュームダウン2つめ（ホイール↓）
kvolup2 = "Ctrl+MOUSE_BTN3",		--中ボリュームアップ（ctrl押しながらホイール↑）
kvoldown2 = "Ctrl+MOUSE_BTN4",		--中ボリュームダウン（ctrl押しながらホイール↓）
kvolup3 = "Shift+MOUSE_BTN3",		--小ボリュームアップ（shift押しながらホイール↑）
kvoldown3 = "Shift+MOUSE_BTN4",		--小ボリュームダウン（shift押しながらホイール↓）
kpanleft = "Ctrl+Left",			--音声を左のみに（ctrl押しながら←）
kpanright = "Ctrl+Right",		--音声を右のみに（ctrl押しながら→）
kpancenter = "Ctrl+Up",			--音声をモノラルに（ctrl押しながら↑）
kpanstereo = "Ctrl+Down",		--音声を普通のステレオに（ctrl押しながら↓）
kmute = "MOUSE_BTN1",			--ミュート（マウス中クリック）

--プレイヤーの状態
kminimize = "PGUP",			--最小化のようなもの（pageup）
kfullscreen = "Alt+Enter",		--フルスクリーン（alt押しながらenter）
kfullscreen2 = "MOUSE_BTN0_DBL",	--フルスクリーン2つめ（左ダブルクリック）
kstatusbar = "Enter",			--タイトルバー表示非表示（enter）
kminmute = "PGDWN",			--最小化のようなものと同時にミュート（pagedown）
kexit = "Esc",				--終了（escape）
kontop = "t",				--最前面表示（t）
kosc = "Ins",				--oscオンオフ（insert）

--リレー操作
kstop = "Alt+x",			--リレー切断（alt押しながらx）
kbump = "Alt+b",			--リレー再接続（alt押しながらb）
kbump2 = "z",				--リレー再接続2つめ（z）

--スクリーンショットとか
kscreenshot = "p",			--スクリーンショットキー（p）


--ウィンドウサイズ変更
--ウィンドウサイズ基準
k160x120 = "Alt+1",
k320x240 = "Alt+2",
k480x360 = "Alt+3",
k640x480 = "Alt+4",
k800x600 = "Alt+5",
k1280x960 = "Alt+6",
k1600x1200 = "Alt+7",
k1920x1440 = "Alt+8",
--動画サイズ基準
k50 = "1",
k75 = "2",
k100 = "3",
k150 = "4",
k200 = "5",
k250 = "6",
k300 = "7",
k25 = "8",






--ここからスクリプトの処理コード
}

mp.set_property("options/softvol", "yes" )
mp.set_property("options/softvol-max", s.maxvolume )
mp.set_property("options/volume", s.ivolume )
mp.set_property("options/cursor-autohide" , "3000" )
mp.set_property("options/cursor-autohide-fs-only", "no" )
if s.icursorhide == 0 then mp.set_property("options/cursor-autohide" , "no" )
elseif s.icursorhide == 2 then mp.set_property("options/cursor-autohide-fs-only", "yes" )
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

mp.set_property("options/screenshot-format", s.sstype )
mp.set_property("options/screenshot-jpeg-quality", s.jpgquality )
if s.sssize == 0 then s.sssize = "window" 
else s.sssize = "video"
end
if	s.ssdir == "" then
	s.ssdir = getsavdir("Pictures")
elseif	string.sub(ssdir,string.len(s.ssdir)) ~= "\\" then
	s.ssdir = s.ssdir.."\\"
end
mp.set_property("options/screenshot-template", s.ssdir.."%{media-title}_%tY%tm%td_%tH%tM%tS_%n")

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


--ファイル情報取得
local orgwidth,orgheight,orgsize
function getorgsize()
		--動画サイズ取得
		orgwidth  = mp.get_property("width", 0)
		orgheight = mp.get_property("height", 0)
		orgsize = string.format("%d",orgwidth).."x"..string.format("%d",orgheight)

end
mp.register_event("file-loaded", getorgsize)

function delay(sec,command1,command2,command3)
	mp.add_timeout(sec,function()mp.commandv(command1,command2,command3)end)
end

function applysettings()
		--はじめの設定を適用する
		if	errorproof("firststart") and errorproof("path") then
			local osc = mp.get_property("options/osc")
			if 	s.iosc == 1 then
				if	osc == "no" then
					mp.commandv("script_message","osc-visibility","cycle")
				elseif	osc == "always" then
					mp.commandv("script_message","osc-visibility","cycle")
					delay(0.1,"script_message","osc-visibility","cycle")
				end
			elseif	s.iosc == 2 then 
				if	osc == "yes" then
				mp.commandv("script_message","osc-visibility","cycle")
				elseif	osc == "no" then
				mp.commandv("script_message","osc-visibility","cycle")
				delay(0.1,"script_message","osc-visibility","cycle")
				end
			else	
				if	osc == "yes" then
				mp.commandv("script_message","osc-visibility","cycle")
				delay(0.1,"script_message","osc-visibility","cycle")
				elseif	osc == "always" then
				mp.commandv("script_message","osc-visibility","cycle")
				end
			end
			if	s.istatusbar == 1 and mp.get_property("border") == "no" then
				delay(0.1,"cycle","border")
			elseif	s.istatusbar == 0 and mp.get_property("border") == "yes" then
				delay(0.1,"cycle","border")
			end
			if	s.iontop == 1 and mp.get_property("ontop") == "no" then
				delay(0.1,"cycle","ontop")				
			elseif	s.iontop == 0 and mp.get_property("ontop") == "yes" then
				delay(0.1,"cycle","ontop")
			end
			if	s.iosd == 0 then
				--mp.set_property("osd-level","0")
				mp.set_property("options/osd-font-size","1")
				print(mp.get_property("osd-level"))
			end
			mp.set_property("loop","yes")
			mp.set_property("options/force-window", "immediate")
			mp.set_property_number("options/demuxer-readahead-secs", 20)
			print("apply")
		end
end
mp.register_event("start-file",applysettings)

function initialmute()
	if	errorproof("path") and not mp.get_property_bool("mute",true) then
	mp.set_property("mute","yes")
	mp.add_timeout(4,function()mp.set_property("mute","no");print("start")end)
	print("run")
	end
end
mp.register_event("file-loaded",initialmute)

function refresh()
	if	errorproof("path") then
		mp.set_property_number("playlist-pos", mp.get_property_number("playlist-pos",0))
--		local streampath,localhost,streamid = getpath()
--		mp.commandv("stop")
--		mp.commandv("loadfile", streampath)
--		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
--		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	end
end

--画面サイズ変更用
function changewindowsize(newwidth , newheight , kurobuti)
	mp.set_property("vf","scale=" .. math.floor(newwidth) ..":"..math.floor(newheight) )
	mp.set_property_number("window-scale" , 1)
	mp.set_property("vf","dsize=".. orgwidth .. ":".. orgheight)
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

--osc切り替え
function osc()
	mp.commandv("script_message", "osc-visibility","cycle")
end
mp.add_forced_key_binding(s.kosc, "osc", osc)

--スクリーンショット
function screenshot()
	if 	errorproof("playing") then
		if	s.sssubdir == 1 then
--			io.open(s.ssdir.."%{media-title}\\","w")
			s.ssdir = s.ssdir ..mp.get_property("media-title").."\\"
			os.execute("mkdir ".."\""..s.ssdir.."\"")
			mp.set_property("options/screenshot-template", s.ssdir.."%{media-title}_%tY%tm%td_%tH%tM%tS_%n")
			s.sssubdir = 0
		end
		mp.commandv("screenshot" , s.sssize )
		mp.osd_message("screenshot")
	end
end
mp.add_key_binding(s.kscreenshot, "screenshot", screenshot)

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
	mp.commandv("add", "volume", s.volume)
	volmessage()
end
mp.add_key_binding(s.kvolup, "gainvolume", gainvolume)
mp.add_key_binding(s.kvolup_wheel, "gainvolume_wheel", gainvolume)

function cgainvolume()
	mp.commandv("add", "volume", s.ctrlvolume)
	volmessage()
end
mp.add_key_binding(s.kvolup2, "cgainvolume_wheel", cgainvolume)

function sgainvolume()
	mp.commandv("add", "volume", s.shiftvolume)
	volmessage()
end
mp.add_key_binding("Shift+Up", "sgainvolume", sgainvolume)
mp.add_key_binding(s.kvolup3, "sgainvolume_wheel", sgainvolume)

--ボリューム下げる
function reducevolume()
	mp.commandv("add", "volume", -1 * s.volume)
	volmessage()
end
mp.add_key_binding(s.kvoldown, "reducevolume", reducevolume)
mp.add_key_binding(s.kvoldown_wheel, "reducevolume_wheel", reducevolume)

function creducevolume()
	mp.commandv("add", "volume", -1 * s.ctrlvolume)
	volmessage()
end
mp.add_key_binding(s.kvoldown2, "creducevolume_wheel", creducevolume)

function sreducevolume()
	mp.commandv("add", "volume", -1 * s.shiftvolume)
	volmessage()
end
mp.add_key_binding("Shift+Down", "sreducevolume", sreducevolume)
mp.add_key_binding(s.kvoldown3, "sreducevolume_wheel", sreducevolume)

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
mp.add_key_binding( s.kmute, "mute", mute)

--音声を左のみに
function panleft()
	if 	mp.get_property_number("audio-channels",0) == 1 then
		mp.set_property("af", "pan=2:[ 1 , 0 ]")
	else 	mp.set_property("af", "channels=2:[ 1-0 , 1-0 ]")
	end
	mp.osd_message("pan left")
end
mp.add_key_binding(s.kpanleft, "panleft", panleft)

--音声を右のみに
function panright()
	if	mp.get_property_number("audio-channels",0) == 1 then
		mp.set_property("af", "pan=2:[ 1 , 1 ]") 
	end
	mp.set_property("af", "channels=2:[ 0-1 , 0-1 ]")
	mp.osd_message("pan right")
end
mp.add_key_binding(s.kpanright, "panright", panright)

--音声を中央（モノラル）に
function pancenter()
	mp.set_property("af", "pan=1:[ 1 , 1 ]")
	mp.osd_message("mono")
end
mp.add_key_binding(s.kpancenter, "pancenter", pancenter)

--音声を普通のステレオに
function panrestore()
	mp.set_property("af", "channels=2")
	mp.osd_message("stereo")
end
mp.add_key_binding(s.kpanstereo, "panrestore", panrestore)

--フルスクリーン
function fullscreen()
	mp.commandv("cycle" , "fullscreen")
end
mp.add_key_binding(s.kfullscreen, "fullscreen", fullscreen)
mp.add_key_binding(s.kfullscreen2, "fullscreen2", fullscreen)

--終了
function exit()
	mp.commandv("quit")
end
mp.add_key_binding(s.kexit, "exit", exit)

--ステータスバーの代わり
function titlebar()
	mp.commandv("cycle" , "border")
end
mp.add_key_binding(s.kstatusbar, "titlebar", titlebar)

--最前面表示切り替え
function ontop()
	mp.commandv("cycle", "ontop")
	if	mp.get_property_bool("ontop")	then
		mp.osd_message("ontop")
	else 	mp.osd_message("ontop off")
	end
end
mp.add_key_binding(s.kontop, "ontop", ontop)

--リレー再接続
function bump()
	if	errorproof("path") and bumpt == nil then
		local streampath,localhost,streamid = getpath()
		mp.commandv("playlist_clear")
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append")
		end
		mp.commandv("playlist_next","force")
		mp.osd_message("bump",3)
		print("1")
	elseif	bumpt then
		bumpt()
		loadlist = false
		resetplaylist()
		print("2")
	end
end
mp.add_key_binding(s.kbump, "bump" , bump)
mp.add_key_binding(s.kbump2, "bump2" , bump)

--リレー切断
function stop()
	if 	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=stop&id=".. streamid)
	end
end
mp.add_key_binding(s.kstop, "stop" , stop)

--ここからwindowサイズ変更

videosize = {
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
	local targetsize = 0.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding(s.k50, "50%", to50per)

function to75per()
	local targetsize = 0.75
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding(s.k75, "75%", to75per)

function to100per()
	local targetsize = 1
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding( s.k100, "100%", to100per)

function to150per()
	local targetsize = 1.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding( s.k150, "150%", to150per)

function to200per()
	local targetsize = 2
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding( s.k200, "200%", to200per)

function to250per()
	local targetsize = 2.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding( s.k250, "250%", to250per)

function to300per()
	local targetsize = 3
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding( s.k300, "300%", to300per)

function to25per()
	local targetsize = 0.25
	changewindowsize(orgwidth * targetsize , orgheight * targetsize)
end
mp.add_key_binding( s.k25, "25%", to25per)

function to160x120()
	changewindowsize(videosize.to160[1] , videosize.to160[2])
end
mp.add_key_binding( s.k160x120, "160x120", to160x120)

function to320x240()
	changewindowsize(videosize.to320[1] , videosize.to320[2])
end
mp.add_key_binding( s.k320x240, "320x240", to320x240)

function to480x360()
	changewindowsize(videosize.to480[1] , videosize.to480[2])
end
mp.add_key_binding( s.k480x360, "480x360", to480x360)

function to640x480()
	changewindowsize(videosize.to640[1] , videosize.to640[2])
end
mp.add_key_binding( s.k640x480, "640x480", to640x480)

function to800x600()
	changewindowsize(videosize.to800[1] , videosize.to800[2])
end
mp.add_key_binding( s.k800x600, "800x600", to800x600)

function to1280x960()
	changewindowsize(videosize.to1280[1] , videosize.to1280[2])
end
mp.add_key_binding( s.k1280x960, "1280x960", to1280x960)

function to1600x1200()
	changewindowsize(videosize.to1600[1] , videosize.to1600[2])
end
mp.add_key_binding( s.k1600x1200, "1600x1200", to1600x1200)

function to1920x1440()
	changewindowsize(videosize.to1920[1] , videosize.to1920[2])
end
mp.add_key_binding( s.k1920x1440, "1920x1440", to1920x1440)

local fs
function minimize()
	local targetsize = {16 , 12}
	if	mp.get_property_number("osd-height", 0) >= 40 then
		if	mp.get_property("fullscreen") == "yes" then
			fs = true
			fullscreen()
			mp.add_timeout(0.10, (function()oldwidth, oldheight = mp.get_screen_size()end))
			mp.add_timeout(0.15, (function()changewindowsize(targetsize[1] , targetsize[2] , -1)end))
		else
			oldwidth, oldheight = mp.get_screen_size()
			changewindowsize(targetsize[1] , targetsize[2] , -1)
		end
	else	if	fs then
			changewindowsize(oldwidth , oldheight , -1)
			fullscreen()
			fs = false
		else
			changewindowsize(oldwidth , oldheight , 2)
		end
	end
end
mp.add_key_binding( s.kminimize , "minimize", minimize)

function minmute()
	if	mp.get_property_number("osd-height", 0) > 40  then
		muted = mp.get_property("mute","no")
		mp.set_property("mute" , "yes")
	else	mp.set_property("mute" , muted)
	end
	minimize()
end
mp.add_key_binding( s.kminmute , "minmute", minmute)

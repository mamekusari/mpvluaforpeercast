--キーバインドは「T」だとshift+tで「t」で単体のtになります
--mpvのデフォルトは無効になっていないのでたとえばqを押すとプレイヤーが終了します


--初期設定
--ボリューム関係
ivolume = 13				--初期ボリューム。0-100
volume = 5				--マウスホイールの変更量
ctrlvolume = 3				--control押しながらの時
shiftvolume = 1				--shift押しながらの時

--スクリーンショット関係
sstype = "jpg"				--「"png"」又は「"jpg"」
jpgquality = 90				--jpgの時の画質。0-100
sssize = 1				--ソースサイズ「1」か表示windowサイズ「0」か
ssfolder = "d:\\a b\\"	 		--保存場所。フォルダの区切りは｢\\｣で最後の\\がないとファイル名に化けます。「""」でmpv.exeのフォルダになります

--その他
istatusbar = 1				--ステータスバー（の代わりのタイトルバー）のオンオフ（うまく動かない）
icursorhide = 2				--マウスカーソルを自動的に隠す。「2」はフルスクリーンのみ隠す
iontop = 0				--最前面表示（うまく動かない?）
iosc = 0				--オンスクリーンコントローラーのオンオフ
recordfolder = "d:\\a b\\"		--録画フォルダ。よく壊れたファイルができます


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
kminimize = "+"				--最小化のようなもの（+）
kfullscreen = "Alt+Enter"		--フルスクリーン（alt押しながらenter）
kfullscreen2 = "MOUSE_BTN0_DBL"		--フルスクリーン2つめ（左ダブルクリック）
kstatusbar = "Enter"			--タイトルバー表示非表示（enter）
kminmute = "-"				--最小化のようなものと同時にミュート（-）
kexit = "Esc"				--終了（escape）
kontop = "t"				--最前面表示（t）
kosc = "Ins"				--oscオンオフ（insert）

--リレー操作
kstop = "Alt+x"				--リレー切断（alt押しながらx）
kbump = "Alt+b"				--リレー再接続（alt押しながらb）

--スクリーンショットとか
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




--ここからスクリプトの処理コード
mp.set_property("options/volume", ivolume )
mp.set_property("options/cursor-autohide" , "3000" )
mp.set_property("options/cursor-autohide-fs-only", "no" )
if icursorhide == 0 then mp.set_property("options/cursor-autohide" , "no" )
elseif icursorhide == 2 then mp.set_property("options/cursor-autohide-fs-only", "yes" )
end
mp.set_property("options/screenshot-format", sstype )
mp.set_property("options/screenshot-jpeg-quality", jpgquality )
mp.set_property("options/screenshot-template", ssfolder .."%{media-title}_%ty%tm%td_%tH%tM%tS_%n")
if sssize == 0 then sssize = "window" 
else sssize = "video"
end

function errorproof(case)
	local hantei
	if 	case == "path" then
		if string.find(mp.get_property("path"),"/stream/".. string.rep("%x", 32)) then
			hantei = true
		end
	elseif	case == "firststart" then
		if mp.get_property_number("playlist-count")  < 3 then
			hantei = true
		end
	elseif	case == "playing" then
		if 	mp.get_property("estimated-vf-fps")
			and mp.get_property("playback-time") 
			and mp.get_property_number("demuxer-cache-duration")
			then
			hantei = true
		end
	elseif	case == "videoonly" then
		if 	not mp.get_property("aid") then
			hantei = true
		end
	elseif	not mp.get_property(case) then
		hantei = true
	end
	return	hantei 
end

--ファイル情報取得
function initialize()
	if errorproof("path") then
		--動画サイズ取得
		orgwidth  = mp.get_property("width", 0)
		orgheight = mp.get_property("height", 0)
		orgsize = string.format("%d",orgwidth).."x"..string.format("%d",orgheight)
		--はじめの設定を適用する
		if	errorproof("firststart") then
			if 	iosc == 1 then mp.commandv("script_message", "enable-osc")
			else	mp.commandv("script_message", "disable-osc")
			end
			if	istatusbar == 1 and mp.get_property("border") == "no" then
				mp.commandv("cycle", "border")
			elseif	istatusbar == 0 and mp.get_property("border") == "yes" then
				mp.commandv("cycle", "border")
			end
			if	iontop == 1 and mp.get_property("ontop") == "no" then
				mp.commandv("cycle", "ontop")
			elseif	iontop == 0 and mp.get_property("ontop") == "yes" then
				mp.commandv("cycle", "ontop")
			end
		end
		mp.set_property("loop", "inf")
	else print("notpecapath")
	end
end
mp.register_event("file-loaded", initialize)

function refresh()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("stop")
		mp.commandv("loadfile", streampath)
		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append") end
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
	end
end

function record()
	if	errorproof("path") and errorproof("playing") then
		if	mp.get_property("stream-capture") == "" then
			local date = os.date("%y%m%d_%H%M%S")
			refresh()
			mp.set_property("stream-capture", recordfolder..mp.get_property("media-title").."_"..date.."."..mp.get_property("file-format"))
			mp.osd_message("record_start",3)
		else	mp.set_property("stream-capture" , "" )
			mp.osd_message("record_end",3)
		end
	end
end
mp.add_key_binding(krecord,"record" , record)
	

--画面サイズ変更用
function changewindowsize(newwidth , newheight , kurobuti)
	mp.set_property("vf","dsize=" .. math.floor(newwidth) ..":".. math.floor(newheight) ..":".. kurobuti .."::0")
	mp.set_property_number("window-scale" , 1)
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

--osc切り替え
function osc()
	if 	iosc == 1 then
		mp.commandv("script_message", "disable-osc")
		iosc = 0
	else	mp.commandv("script_message", "enable-osc")
		iosc = 1
	end
end
mp.add_forced_key_binding(kosc, "osc", osc)

--スクリーンショット
function screenshot()
	if 	errorproof("playing") then
		mp.commandv("screenshot" , sssize )
		mp.osd_message("screenshot")
	end
end
mp.add_key_binding(kscreenshot, "screenshot", screenshot)

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
	mp.commandv("add", "volume", volume)
	volmessage()
end
mp.add_key_binding(kvolup, "gainvolume", gainvolume)
mp.add_key_binding(kvolup_wheel, "gainvolume_wheel", gainvolume)

function cgainvolume()
	mp.commandv("add", "volume", ctrlvolume)
	volmessage()
end
mp.add_key_binding(kvolup2, "cgainvolume_wheel", cgainvolume)

function sgainvolume()
	mp.commandv("add", "volume", shiftvolume)
	volmessage()
end
mp.add_key_binding("Shift+Up", "sgainvolume", sgainvolume)
mp.add_key_binding(kvolup3, "sgainvolume_wheel", sgainvolume)

--ボリューム下げる
function reducevolume()
	mp.commandv("add", "volume", -1 * volume)
	volmessage()
end
mp.add_key_binding(kvoldown, "reducevolume", reducevolume)
mp.add_key_binding(kvoldown_wheel, "reducevolume_wheel", reducevolume)

function creducevolume()
	mp.commandv("add", "volume", -1 * ctrlvolume)
	volmessage()
end
mp.add_key_binding(kvoldown2, "creducevolume_wheel", creducevolume)

function sreducevolume()
	mp.commandv("add", "volume", -1 * shiftvolume)
	volmessage()
end
mp.add_key_binding("Shift+Down", "sreducevolume", sreducevolume)
mp.add_key_binding(kvoldown3, "sreducevolume_wheel", sreducevolume)

--ミュート
function mute()
	if	errorproof("playing")	then
		mp.commandv("cycle", "mute")
		if 	mp.get_property_bool("mute") then
			mp.osd_message("mute")
		else	mp.osd_message("mute_off")
		end
	end
end
mp.add_key_binding( kmute, "mute", mute)

--音声を左のみに
function panleft()
	if 	mp.get_property_number("audio-channels",0) == 1 then
		mp.set_property("af", "pan=2:[ 1 , 0 ]")
	else 	mp.set_property("af", "channels=2:[ 1-0 , 1-0 ]")
	end
	mp.osd_message("pan_left")
end
mp.add_key_binding(kpanleft, "panleft", panleft)

--音声を右のみに
function panright()
	if	mp.get_property_number("audio-channels",0) == 1 then
		mp.set_property("af", "pan=2:[ 1 , 1 ]") 
	end
	mp.set_property("af", "channels=2:[ 0-1 , 0-1 ]")
	mp.osd_message("pan_right")
end
mp.add_key_binding(kpanright, "panright", panright)

--音声を中央（モノラル）に
function pancenter()
	mp.set_property("af", "pan=1:[ 1 , 1 ]")
	mp.osd_message("mono")
end
mp.add_key_binding(kpancenter, "pancenter", pancenter)

--音声を普通のステレオに
function panrestore()
	mp.set_property("af", "channels=2")
	mp.osd_message("stereo")
end
mp.add_key_binding(kpanstereo, "panrestore", panrestore)

--フルスクリーン
function fullscreen()
	mp.commandv("cycle" , "fullscreen")
end
mp.add_key_binding(kfullscreen, "fullscreen", fullscreen)
mp.add_key_binding(kfullscreen2, "fullscreen2", fullscreen)

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
	if	mp.get_property_bool("ontop")	then
		mp.osd_message("ontop")
	else 	mp.osd_message("ontop_off")
	end
end
mp.add_key_binding(kontop, "ontop", ontop)

--リレー再接続
function bump()
	if	errorproof("path") then
		local streampath,localhost,streamid = getpath()
		mp.commandv("playlist_clear")
		mp.commandv("loadfile" , "http://".. localhost .. "/admin?cmd=bump&id=".. streamid,"append")
		for i = 0 , 2 do mp.commandv("loadfile", streampath , "append")
		end
		mp.commandv("playlist_next")
		mp.osd_message("bump",3)
	end
end
mp.add_key_binding(kbump, "bump" , bump)

--リレー切断
function stop()
	if 	errorproof("path") then
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

function minimize()
	local targetsize = {16 , 12}
	if	mp.get_property_number("osd-height", 0) >= 40 then
		if	mp.get_property("fullscreen") == "yes" then
			fullscreened = true
			fullscreen()
			mp.add_timeout(0.10, (function()oldwidth, oldheight = mp.get_screen_size()end))
			mp.add_timeout(0.15, (function()changewindowsize(targetsize[1] , targetsize[2] , -1)end))
		else
			oldwidth, oldheight = mp.get_screen_size()
			changewindowsize(targetsize[1] , targetsize[2] , -1)
		end
	else	if	fullscreened then
			changewindowsize(oldwidth , oldheight , -1)
			fullscreen()
			fullscreened = false
		else
			changewindowsize(oldwidth , oldheight , 2)
		end
	end
end
mp.add_key_binding( kminimize , "minimize", minimize)

function minmute()
	if	mp.get_property_number("osd-height", 0) > 40  then
		muted = mp.get_property("mute","no")
		mp.set_property("mute" , "yes")
	else	mp.set_property("mute" , muted)
	end
	minimize()
end
mp.add_key_binding( kminmute , "minmute", minmute)

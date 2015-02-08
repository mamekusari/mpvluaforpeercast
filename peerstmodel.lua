--ショートカットをpeerstplayerに似せたlua

function startup()

--ボリューム関係
initialvolume = 11			--初期ボリューム
volume = 5					--マウスホイールの変更量
ctrlvolume = 3				--control押しながらの時
shiftvolume = 1				--shift押しながらの時

--ステータス表示
statusbar = 1				--ステータスバー（の代わりのタイトルバー）のオンオフ
showwindowsize = 1			--表示動画サイズを表示
showsoucesize = 1			--動画の元のサイズを表示
showfps = 1					--fps表示
showbitrate = 1				--ビットレート表示

--スクリーンショット関係
sstype = "jpg"				--「"png"」又は「"jpg"」
jpgquality = 0				--jpgの時の画質。0-100
sssize = 1					--ソースサイズ「1」か表示windowサイズ「0」か
ssfolder = "d:\\a b\\" 		--保存場所。区切りは｢\\｣で両端のダブルクォーテーションと最後の\\は必須

	orgwidth = mp.get_property("width")
	orgheight = mp.get_property("height")
	if mp.get_property("fps") == nil then fps = 0
	else fps = mp.get_property("fps")
	end
	fps = string.format("%6.1f", fps)
	if statusbar == 1 then
		if mp.get_property("border") == "no" then mp.commandv("cycle" , "border")
		end
	elseif mp.get_property("border") == "yes" then mp.commandv("cycle" , "border")
	end
	print(mp.get_property("border"))
	mp.set_property("options/border", "yes")
	print(mp.get_property("options/border"))
	mp.set_property("options/volume", initialvolume )
	
end
mp.register_event("file-loaded", startup)

mp.add_periodic_timer(1, (function()
--	if (mp.get_property_bool("core-idle")) ~= "no" then
	if mp.get_property("playback-time") ~= nil then
		tmediatitle = mp.get_property("media-title")
		ttime = mp.get_property_osd("playback-time")			--stream-pos	--length  --playback-time
		tcache = string.format("%03d" , mp.get_property("cache-used", 0))
		if fps == nil then tfps = 0 
		end
		ttype = mp.get_property("file-format")
		if ttype == nil then ttype = "0"
		end
		local vol = mp.get_property("volume")
		if vol == nil then vol = "0" 
		end
		tvol =  string.format("%d", vol)
		if mp.get_property_bool("mute") then tvol = "mute" 
		end
		tbarlist = ttype .." ".. tmediatitle .." (".. fps ..") c:".. tcache .."KB".. "   ".. ttime .." vol:" .. tvol
		mp.set_property("options/title", tbarlist )
--	mp.set_property("options/window-minimized","yes")
--	aaa = mp.get_property("window-minimized")
--	print(aaa)
	end
end))

--画面サイズ変更用関数
function changewindowsize(newwidth , newheight , kurobuti)
	mp.set_property("vf","dsize=" .. math.floor(newwidth) ..":".. math.floor(newheight) ..":".. kurobuti .."::0")
	mp.set_property_number("window-scale" , 1)
	mp.set_property("vf","dsize=".. orgwidth .. ":" .. orgheight)
end

--スクリーンショット
function screenshot()
	mp.set_property("options/screenshot-format", sstype )
	mp.set_property("options/screenshot-jpeg-quality", jpgquality )
	mp.set_property("options/screenshot-template", ssfolder .."%{media-title}_%tX_%n")
	if sssize == 0 then sssize = "window" 
	else sssize = "video"
	end
	mp.commandv("screenshot" , sssize )
	print(ssfolder)
	print("\""..ssfolder .."%{media-title}_%tX_%n".."\"")
end
mp.add_key_binding("p", "screenshot", screenshot)

--ボリューム上げる
function gainvolume()
	mp.commandv("add", "volume", volume)
	mp.osd_message(mp.get_property("volume",1))
end
mp.add_key_binding("Up", "gainvolume", gainvolume)
mp.add_key_binding("MOUSE_BTN3", "gainvolume_wheel", gainvolume)

function cgainvolume()
	mp.commandv("add", "volume", ctrlvolume)
	mp.osd_message(mp.get_property("volume",1))
end
mp.add_key_binding("Ctrl+MOUSE_BTN3", "cgainvolume_wheel", cgainvolume)

function sgainvolume()
	mp.commandv("add", "volume", shiftvolume)
	mp.osd_message(mp.get_property("volume",1))
end
mp.add_key_binding("Shift+Up", "sgainvolume", sgainvolume)
mp.add_key_binding("Shift+MOUSE_BTN3", "sgainvolume_wheel", sgainvolume)

--ボリューム下げる
function reducevolume()
	mp.commandv("add", "volume", -1 * volume)
	mp.osd_message(mp.get_property("volume",1))
end
mp.add_key_binding("Down", "reducevolume", reducevolume)
mp.add_key_binding("MOUSE_BTN4", "reducevolume_wheel", reducevolume)

function creducevolume()
	mp.commandv("add", "volume", -1 * ctrlvolume)
	mp.osd_message(mp.get_property("volume",1))
end
mp.add_key_binding("Ctrl+MOUSE_BTN4", "creducevolume_wheel", creducevolume)

function sreducevolume()
	mp.commandv("add", "volume", -1 * shiftvolume)
	mp.osd_message(mp.get_property("volume",1))
end
mp.add_key_binding("Shift+Down", "sreducevolume", sreducevolume)
mp.add_key_binding("Shift+MOUSE_BTN4", "sreducevolume_wheel", sreducevolume)

--音声を左のみに
function panleft()
	if mp.get_property_number("audio-channels") == 1 then
	mp.set_property("af", "pan=2:[ 1 , 0 ]")
	else mp.set_property("af", "channels=2:[ 1-0 , 1-0 ]")
	end
end
mp.add_key_binding("Ctrl+Left", "panleft", panleft)

--音声を右のみに
function panright()
	if mp.get_property_number("audio-channels") == 1 then
	mp.set_property("af", "pan=2:[ 1 , 1 ]") end
	mp.set_property("af", "channels=2:[ 0-1 , 0-1 ]")
end
mp.add_key_binding("Ctrl+Right", "panright", panright)

--音声を中央（モノラル）に
function pancenter()
	mp.set_property("af", "pan=1:[ 1 , 1 ]")
end
mp.add_key_binding("Ctrl+Up", "pancenter", pancenter)

--音声を普通のステレオに
function panrestore()
	mp.set_property("af", "channels=2")
end
mp.add_key_binding("Ctrl+Down", "panrestore", panrestore)

--フルスクリーン
function fullscreen()
	mp.commandv("cycle" , "fullscreen")
end
mp.add_key_binding("Alt+Enter", "fullscreen", fullscreen)

--終了
function exit()
	mp.commandv("quit")
end
mp.add_key_binding("Esc", "exit", exit)

--ステータスバーの代わり
function titlebar()
	mp.commandv("cycle" , "border")
end
mp.add_key_binding("Enter", "titlebar", titlebar)

--最前面表示切り替え
function ontop()
	mp.commandv("cycle", "ontop")
	if mp.get_property_bool("ontop")
	then mp.osd_message("ontop")
	else mp.osd_message("ontop_off")
	end
end
mp.add_key_binding("t", "ontop", ontop)

--リレー再接続
--function reconnect_bump
	--require("reconnect")
	--lobal bump = require("reconnect")--bump_handler
	--bump_handler
--end
--mp.add_key_binding("Alt+x", "bumpp" , reconnect_bump)		--reconnect

--ここからwindowサイズ変更
function to50per()
	local targetsize = 0.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("1", "50%", to50per)

function to75per()
	local targetsize = 0.75
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("2", "75%", to75per)

function to100per()
	local targetsize = 1
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("3", "100%", to100per)

function to150per()
	local targetsize = 1.5
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("4", "150%", to150per)

function to200per()
	local targetsize = 2
	changewindowsize(orgwidth * targetsize , orgheight * targetsize , 2)
end
mp.add_key_binding("5", "200%", to200per)

function to160x120()
	local targetsize = {160 , 120}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+1", "160x120", to160x120)

function to320x240()
	local targetsize = {320 , 240}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+2", "320x240", to320x240)

function to480x360()
	local targetsize = {480 , 360}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+3", "480x360", to480x360)

function to640x480()
	local targetsize = {640 , 480}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+4", "640x480", to640x480)

function to800x600()
	local targetsize = {800 , 600}
	changewindowsize(targetsize[1] , targetsize[2] , -1)
end
mp.add_key_binding("Alt+5", "800x600", to800x600)

module("mlpsettings", package.seeall)
s={
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
sstype = "jpg",				--「"png"」又は「"jpg"」
jpgquality = 90,			--jpgの時の画質。0-100
sssize = 1,				--ソースサイズ「1」か表示windowサイズ「0」か
ssdir = "",	 			--保存場所。フルパスでフォルダの区切りは｢\\｣。「""」でマイピクチャになります
sssubdir = 0,				--「1」でチャンネル名でサブフォルダを作る。「0」でつくらない

--その他					--保存フォルダ以外は0で無効になります
istatusbar = 1,				--ステータスバー（の代わりのタイトルバー）
icursorhide = 2,			--マウスカーソルを自動的に隠す「1」。「2」はフルスクリーンのみ隠す
iontop = 0,				--最前面表示
iosc = 0,				--オンスクリーンコントローラー。「2」で常に表示
iosd = 1,				--osdの表示
isnapwindow = 0,			--ウィンドウスナップ


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
kminmute = "pgdwn",			--最小化のようなものと同時にミュート（pagedown）
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



--タイトルバー用情報取得タイマー。0で非表示または無効になります
showtype = 1,				--ビデオコーデック「1」かコンテナ表示「2」。「3」で音声コーデック
showsize = 3,				--解像度を表示。「2」は今のサイズのみ、「3」はソースサイズのみ表示
showbitrate = 1,			--キーフレーム間のビットレート表示。
showfps = 1,				--fps表示。「2」は今のfpsのみ、「3」は動画で設定されたfpsのみ表示
showcache = 1,				--大体のバッファサイズを表示。「2」でdemux+cacheの正確な表示
showplaytime = 1,			--再生時間を表示
showprotocol = 0,			--flvの時にhttpかrtmpかを表示

enablertmp = 0,				--flvの時に、「1」は初めはrtmpで再生する。「2」ですべてrtmpで再生する
enableautospeed = 1,			--キャッシュ量の自動調整。「2」でたまったときだけ調整、「0」で無効
enableothers = 0,			--peercast以外で動画情報を表示するか


--表示切り替え用キーバインド
ktype = 	"ctrl+alt+1",
ksize =		"ctrl+alt+2",
kbitrate = 	"ctrl+alt+3",
kfps = 		"ctrl+alt+4",
kcache = 	"ctrl+alt+5",
kplaytime = 	"ctrl+alt+6",
kprotocol =	"ctrl+alt+9",
kautospeed = 	"ctrl+alt+0",



--プレイヤーの挙動の設定。桁を変えたりマイナスにしたりするとおかしくなると思います。

limitavsync = 1,		--音ズレを何秒まで許容するか(1秒)
limitct = 2,			--音ズレ修正量を何秒まで許容するか(2秒)

--キャッシュが貯まりすぎ、少なすぎの時の再生速度の設定（enableautospeedが有効なとき）
high = 15,   			--これ以上キャッシュが貯まったら早送り開始(15秒)
low = 1.2,   			--これ以下になったら遅くする(1.2秒)
normal1 = 2,			--遅くして2秒分たまったら普通の速度に戻す(2秒)
normal2 = 3,			--早くして3秒分になったら普通の速度に戻す(3秒)
lowspeed = 0.95,	 	--遅くしたときの再生速度(0.95倍)
highspeed = 1.10,   		--速くしたときの再生速度(1.10倍)
persec = 0.01,			--キャッシュの秒数にこれをかけた分速くする(+0.01)
maxspeed = 2,			--速度の上限(2倍)

--再生が不安定なときの設定
offsetsec = 50,			--何秒で1秒分のバッファを相殺するか(50秒)
recsec = 4,			--数値の秒ごとにプレイヤーを再接続する(4秒)
incpossec = 10,			--数値の秒ごとにプレイリストを1つ送る(10秒)
incsec = 5,			--プレイリストを送った後にこの秒数分追加する(5秒分)
bumpsec = 40,			--これ以上たまるとリレーを再接続する(40秒)

playlistcount = 4,		--プレイリストの数で、この次にbumpがくる(4つ)

}

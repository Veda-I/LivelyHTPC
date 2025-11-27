[Variables]

; -- General --
IconCount=11
VisibleIcons=5
IconSize=220
IconSpacing=50
StartPosition=2
MainColor=255,125,253
SelectColor=252,255,125
ClockScale=1
ClockFormat24H=1
Language=French

; -- Icons (max:20) --
Icon.1.Name=Canal
Icon.1.Action=C:\Program Files\Mozilla Firefox\firefox.exe canalplus.com --kiosk
Icon.2.Name=Kodi
Icon.2.Action=C:\Program Files\Kodi\kodi.exe
Icon.3.Name=Youtube
Icon.3.Action=C:\Program Files\Google\Chrome\Application\chrome.exe youtube.com/tv --kiosk --disable-session-crashed-bubble --user-agent="Mozilla/5.0 (Linux; Tizen 2.3; SmartHub; SMART-TV; SmartTV; U; Maple2012) AppleWebKit/538.1+ (KHTML, like Gecko) TV Safari/538.1+"
Icon.4.Name=TF1
Icon.4.Action=C:\Program Files\Mozilla Firefox\firefox.exe tf1.fr/tf1/direct --kiosk
Icon.5.Name=Firefox
Icon.5.Action=C:\Program Files\Mozilla Firefox\firefox.exe lemediaen442.fr
Icon.6.Name=Deezer
Icon.6.Action=C:\Program Files\Mozilla Firefox\firefox.exe deezer.com/fr --kiosk
Icon.7.Name=X
Icon.7.Action=C:\Program Files\Mozilla Firefox\firefox.exe x.com/home --kiosk
Icon.8.Name=Playnite
Icon.8.Action=C:\Users\Veda\AppData\Local\Playnite\Playnite.FullscreenApp.exe
Icon.9.Name=Steam
Icon.9.Action=C:\Jeux\Steam\steam.exe steam://open/bigpicture
Icon.10.Name=Restart
Icon.10.Action=shutdown /r /t 0
Icon.11.Name=Shutdown
Icon.11.Action=shutdown /s /t 0

; -- Music (max:10, playlists or music files, not folder) --
Music.Playlist.Count=7
Music.Playlist.1=C:\Users\Veda\Music\Playlists\Various.m3u8
Music.Playlist.2=C:\Users\Veda\Music\Beverly Hills Cop II\02. Harold Faltermeyer - Bogomil Oil Well Jog , Bogomil Gets Shot.flac
Music.Playlist.3=C:\Users\Veda\Music\Dance\Outback Snakes - No Trouble in my Life.mp3
Music.Playlist.4=C:\Users\Veda\Music\Space-Motion-Lose-Myself.mp3
Music.Playlist.5=C:\Users\Veda\Music\Andrea Bocelli - Nessun dorma.mp3
Music.Playlist.6=C:\Users\Veda\Music\Jerry Goldsmith - The Mission.mp3
Music.Playlist.7=C:\Users\Veda\Music\Mike Candys - Flexin.mp3
Music.Playlist.8=C:\Users\Veda\Music\Last of Us\Chris Rondinella - Take on Me.mp3
Music.Playlist.9=C:\Users\Veda\Music\F1\01 - F1.mp3
Music.Playlist.10=C:\Users\Veda\Music\Justice\Hyperdrama\Neverender.mp3

; -- Animation (choice: None (S:0) , Linear (S:30), EaseOutQuad(S:0.08), EaseOutExpo (S:0.04), EaseOutExpoFast (S:0.008)) --
Animation.Mode=EaseOutQuad
Animation.Speed=0.08

; -- Sound --
StartSound=0
NavigationSound=1

; -- Vizualizer --
VizualizerOnNav=0

; -- Firefox Addon --
Addon.KeyboardSurfing=1

; -- Dev --
Debug=0

#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Path ---
RightSound := "@Resources\Sounds\Right.wav"
LeftSound := "@Resources\Sounds\Left.wav"
UpSound := "@Resources\Sounds\Left.wav"
DownSound := "@Resources\Sounds\Right.wav"
SelectSound := "@Resources\Sounds\Select.wav"
HomeSound := "@Resources\Sounds\Home.wav"
BackSound := "@Resources\Sounds\Back.wav"
ClickSound := "@Resources\Sounds\Click.wav"
OnSound := "@Resources\Sounds\On.wav"
OffSound := "@Resources\Sounds\Off.wav"
EnterSound := "@Resources\Sounds\Enter.wav"
ConfigPath := "@Resources\Variables.inc"
LockPath := "@Resources\Lua\Lock.ini"
StatePath := "@Resources\Player\State.ini"
RainPath := A_AppData "\Rainmeter\Rainmeter.ini"

; --- Config ---
Rainmeter := GetRainmeter()
IconCount := Min(IntRead(ConfigPath, "Variables", "IconCount", 4),20)
MusicCount := Min(IntRead(ConfigPath, "Variables", "Music.Playlist.Count", 0),10)
FocusIndex := IntRead(ConfigPath, "Variables", "StartPosition", 2)
NavigationSound := IntRead(ConfigPath, "Variables", "NavigationSound", 1)
StartSound := IntRead(ConfigPath, "Variables", "StartSound", 1)
VizualizerOnNav := IntRead(ConfigPath, "Variables", "VizualizerOnNav", 1)
KeyboardSurfing := IntRead(ConfigPath, "Variables", "Addon.KeyboardSurfing", 0)
Debug := IntRead(ConfigPath, "Variables", "Debug", 0)

; -- Icons
Icons := []
Loop IconCount {
    Index := A_Index
    Icons.Push({Name: IniRead(ConfigPath, "Variables", "Icon." . Index . ".Name"), Action: IniRead(ConfigPath, "Variables", "Icon." . Index . ".Action"), Position: Index})
}

; -- Musics
PositionToMusic := Map()
Musics := []
Loop MusicCount {
    Index := A_Index
	Pos := Floor((10 - MusicCount)/2) + Index
	Uri := IniRead(ConfigPath, "Variables", "Music.Playlist." . Index)
	PositionToMusic[Pos] := Uri
    Musics.Push({Track: Uri, Position: Pos})
}
RepeatTint:= Map(0, "#Color#", 1, "#MainColor#", 2, "#MainColor#")

; --- State ---
DesktopActive := true
LastActionTime := 0
ActionCooldown := 200
TVApp := false
Playing := false
PlayInit := false
VerPos := 0
PlayerPos := 0
RepeatValue := 0
PlaylistPos := 0
Player := 0
LaunchedApp := ""
NavSkin := "LivelyHTPC"
PlayerSkin := "LivelyHTPC\Player"
PlaylistSkin := "LivelyHTPC\Playlist"
VisualizerSkin := "LivelyHTPC\Visualizer"
PlayerLoaded := isLoaded(PlayerSkin)
PlaylistLoaded := isLoaded(PlaylistSkin) && MusicCount != 0
VisualizerLoaded := isLoaded(VisualizerSkin) 

; ----------------------------------------------------

; --- Init ---
Init() {
	global StartSound
	ForceShellFocus()
	Visualizer("Hide",1)
	if (StartSound)
		SoundPerform(["@Resources\Sounds\Start-1.wav", "@Resources\Sounds\Start-2.wav"][Random(1,2)])
}

; --- Visualizer ---
Visualizer(action, type) {
	if (VisualizerLoaded && !VizualizerOnNav && type = 1) {
		Bang(action, VisualizerSkin)
	}
}

; --- Playlist ---
Playlist(action, type) {
	if (PlaylistLoaded && type = 1) {
		Bang(action, PlaylistSkin)
	}
}


; --- Logging ---
Log(message) {
	global Debug
    if (Debug)
        FileAppend(formattedTime := FormatTime(A_Now, "dd/MM/yyyy HH:mm:ss") " - " message "`n", "Debug.log")
}

; --- Integer Read ---
IntRead(configPath, section, key, default) {
    val := IniRead(configPath, section, key, default)
    if (val = "")
        return default
    return Integer(val)
}

; --- Sound ---
SoundPerform(wav) {
	if (NavigationSound)
		SoundPlay(wav)
}

; --- Skin Load ---
isLoaded(skin) {
    return IntRead(RainPath, skin, "Active", 0) != 0
}

; --- Rainmeter ---
GetRainmeter() {
    for proc in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name='Rainmeter.exe'") {
        return proc.ExecutablePath
    }
    return "C:\Program Files\Rainmeter\Rainmeter.exe"
}

; --- Process Monitoring ---
MonitorProcessClosure(pid, processName) {
	Log("Monitoring " . processName . " (pid:" . pid . ")")           
    ; -- checks process every 200 ms
	checkClosure := CheckProcessClosure.Bind(pid, processName)
    SetTimer(checkClosure, 200)
}

; --- Check Process ---
CheckProcessClosure(pid, processName) {
    if (!ProcessExist(pid)) {
        ; -- stop timer
		Display("Show",HomeSound)
        SetTimer(,0)
        Log("Monitoring closed") 
    }
}

; --- Force Shell Focus ---
ForceShellFocus() {
	WinActivate("ahk_class Progman")
}

; --- Check Skin Lock ---
CanNotify() {
    global LockPath
    maxAttempts := 10
    attempt := 1
    while (attempt <= maxAttempts) {
        try {
            updateComplete := IniRead(LockPath, "Variables", "UpdateComplete", 0)
            if (updateComplete = "1") {
                return true
            }
            Sleep(50)
            attempt += 1
        } catch as e {
            Log("CanNotify Error: " . e.Message)
            return false
        }
    }
    Log("CanNotify: Timeout (a:" . maxAttempts . ")")
    return false
}

; --- Bang Skin ---
Bang(command, target) {
    global Rainmeter
    if (!CanNotify()) {
        Log("Bang: Skipped")
        return
    }
    try {
        Run('"' . Rainmeter . '" !' . command . ' ' . target . '', , "Hide")
    } catch as e {
        Log("Bang Error: " . e.Message)
    }
}

; --- Hide/Show Skins --- 
Display(action,sound) {
    global DesktopActive, TVApp, VerPos
    try {
		if (!DesktopActive && action = "Show") {
			; -- show skin
			TVApp := false
			ForceShellFocus()
			DesktopActive := true
			VerPos := 0
			SoundPerform(sound)
			Sleep(200)
			Bang(action . "FadeGroup", "LivelyHTPC")
			Visualizer(action,2)
			Playlist(action,2)
			Log("Display: " . action . " Skin")
		} else if (DesktopActive && action = "Hide") {
			; -- hide skin
			DesktopActive := false
			VerPos := 0
			SoundPerform(sound)
			Sleep(200)
			Bang(action . "FadeGroup", "LivelyHTPC")
			Visualizer(action,2)
			Playlist(action,1)
			Log("Display: " . action . " Skin")
		} else {
			Log("Display: Needless (" . action . ")")
		}
    } catch as e {
        Log("Display Error: " . e.Message)
    }	
}

; --- Notify Skin ---
Notify() {
    global FocusIndex, NavSkin
	Bang("SetVariable FocusIndex " . FocusIndex, NavSkin)
}

; --- Check Cooldown ---
CanPerformAction() {
    global LastActionTime, ActionCooldown
    currentTime := A_TickCount
    if (currentTime - LastActionTime < ActionCooldown) {
        Log("Action blocked (cooldown)")
        return false
    }
    LastActionTime := currentTime
    return true
}

; --- Monitoring Player ---
HidePlayer() {
	global Player
    static counter := 0
	static pop := 0
    if (pop = 2 || counter > 100) {  ; -- max 5s
        SetTimer(, 0)
		Log("Player | Stop timer (" . pop . "|" . counter . ")")
		pop := 0
        return
    }
    counter++
	Player := WinExist("ahk_class ApplicationFrameWindow")
	if (Player) {
		WinSetTransparent(0, Player)
		WinHide(Player)
		pop += 1
        Log("Player invisible (pop=" . pop . ")")
	}
}

; --- Play Player ---
Play(track) {
    Log("Launching Music: " . track)
	Visualizer("Show",1)
    try {
        SetTimer(HidePlayer, 50)  ; -- freq : 50ms
		Run('explorer.exe "' . track . '"', , "Hide") 	
    } catch as e {
        Log("Play Error: " . e.Message)
    }
}

; --- Stop Player ---
Stop() {
	global Player
	Visualizer("Hide",1)
	if (Player) {
		WinClose(Player)
		Log("Player closed (" . Player . ")")
	} else {
		Log("Player not found (" . Player . ")")
	}
}

; --- Player Navigation ---
PlayerNavigation(order) {
	global PlayerPos, RepeatValue, RepeatTint
	switch PlayerPos {
	case -1: 
		Bang('SetOption MeterPlayPause ImageTint "#Color#"', PlayerSkin)
		Bang('SetOption MeterPrev ImageTint "#SelectColor#"', PlayerSkin)
	case 0: 
		if (order = "Left") {
			Bang('SetOption MeterNext ImageTint "#Color#"', PlayerSkin)
			Bang('SetOption MeterPlayPause ImageTint "#SelectColor#"', PlayerSkin)
		} else {
			Bang('SetOption MeterPrev ImageTint "#Color#"', PlayerSkin)
			Bang('SetOption MeterPlayPause ImageTint "#SelectColor#"', PlayerSkin)
		}
	case 1: 
		if (order = "Left") {
			Bang('SetOption MeterRepeat ImageTint "' . RepeatTint[RepeatValue] . '"', PlayerSkin)
			Bang('SetOption MeterNext ImageTint "#SelectColor#"', PlayerSkin)
		} else {
			Bang('SetOption MeterPlayPause ImageTint "#Color#"', PlayerSkin)
			Bang('SetOption MeterNext ImageTint "#SelectColor#"', PlayerSkin)
		}
	case 2: 
		Bang('SetOption MeterNext ImageTint "#Color#"', PlayerSkin)
		Bang('SetOption MeterRepeat ImageTint "#SelectColor#"', PlayerSkin)
	}
}

; --- Player Action ---
PlayerAction() {
	global PlayerPos, RepeatValue
	switch PlayerPos {
	case -1: 
		Bang('CommandMeasure MeasurePlayPause "Previous"', PlayerSkin)
		Bang('SetOption MeterPrev ImageTint "#MainColor#"', PlayerSkin)
		sleep(500)
		Bang('SetOption MeterPrev ImageTint "#SelectColor#"', PlayerSkin)
	case 0: 
		Bang('CommandMeasure MeasurePlayPause "PlayPause"', PlayerSkin)
		Bang('SetOption MeterPlayPause ImageTint "#MainColor#"', PlayerSkin)
		sleep(500)
		Bang('SetOption MeterPlayPause ImageTint "#SelectColor#"', PlayerSkin)
	case 1: 
		Bang('CommandMeasure MeasurePlayPause "Next"', PlayerSkin)
		Bang('SetOption MeterNext ImageTint "#MainColor#"', PlayerSkin)
		sleep(500)
		Bang('SetOption MeterNext ImageTint "#SelectColor#"', PlayerSkin)
	case 2: 
		Bang('CommandMeasure MeasurePlayPause "Repeat"', PlayerSkin)
		sleep(100)
		Bang('UpdateMeasure MeasureSyncRepeat', PlayerSkin) 
		sleep(100)
		RepeatValue := IntRead(StatePath, "Variables", "RepeatValue", 0)
		switch RepeatValue {
			case 0:
				Bang('SetOption MeterRepeat ImageTint "#Color#"', PlayerSkin)
				Bang('SetOption MeterRepeat ImageName "#@#Icons\Music\repeat.png"', PlayerSkin)
			case 1:
				Bang('SetOption MeterRepeat ImageTint "#MainColor#"', PlayerSkin)
				Bang('SetOption MeterRepeat ImageName "#@#Icons\Music\repeatone.png"', PlayerSkin)
			case 2:
				Bang('SetOption MeterRepeat ImageTint "#MainColor#"', PlayerSkin)
				Bang('SetOption MeterRepeat ImageName "#@#Icons\Music\repeat.png"', PlayerSkin)
		}
	}
}


; *** Init ***
Init()


; ----------------------------------------------------


; --- Bar Hotkeys ---
#HotIf DesktopActive && VerPos = 0

; --- Right Arrow ---
Right:: {
    global FocusIndex, IconCount, RightSound
    if (CanPerformAction() && FocusIndex < IconCount) {
        SoundPerform(RightSound)
        FocusIndex += 1
        Notify()
    }
    Log("Button Right (f:" . FocusIndex . ")")
}

; --- Left Arrow ---
Left:: {
    global FocusIndex, LeftSound
    if (CanPerformAction() && FocusIndex > 1) {
        SoundPerform(LeftSound)
		FocusIndex -= 1
        Notify()
    }
    Log("Button Left (f:" . FocusIndex . ")")
}

; --- Enter Button ---
Enter:: {
    global FocusIndex, Icons, SelectSound, LaunchedApp, TVApp
    for icon in Icons {
        if (icon.Position = FocusIndex) {
            try {
                Log("Launching " . icon.Name)

                if (icon.Name = "Shutdown" || icon.Name = "Restart") {
					Run(icon.Action, , "Hide", &pid_temp)
					break
				} else if (icon.Name = "Steam") {
					Run(icon.Action, , "Hide", &pid_temp)
				} else {
					Run(icon.Action, , , &pid_temp)
				}

                ; -- extract process name
                processName := ""
                if (RegExMatch(icon.Action, "([^\\]+?\.exe)", &m))
                    processName := m[1]

                LaunchedApp := processName	
				
				; -- check TVApp
				if InStr(icon.Action, "youtube.com/tv") {
					TVApp := true
				}

                ; -- wait logic : wait 10s for real window --
                maxWait := 100
                found := false

                Loop maxWait {
                    if WinExist("ahk_exe " . processName) {
                        found := true
                        break
                    }
                    Sleep(100)
                }

                if (found) {
                    real_pid := WinGetPID("ahk_exe " . processName)
                    Log("Process " . processName . " (pid:" . real_pid . ")")
                } else {
                    real_pid := pid_temp
                    Log("Process " . processName . " (pid:" . real_pid . "|fallback)")
                }
                ; -- wait logic (end) --

                ; -- Monitoring
                MonitorProcessClosure(real_pid, processName)
				
				; -- hide skin
				Display("Hide",SelectSound) 
				
				timer := A_TickCount

				; -- wait window visible (max 10s)
				if !WinWaitActive("ahk_exe " . processName, , 10) {
					WinActivate("ahk_exe " . processName)
					timer := A_TickCount - timer
					Log("Window " . processName . " forced (" . timer . "ms)")
				} else {
					timer := A_TickCount - timer
					Log("Window " . processName . " activated (" . timer . "ms)")
				}

            } catch as e {
                Log("Enter Error: " . e.Message)
            }
            break
        }
    }
}

#HotIf

; --- Nav Hotkeys | Player ---
#HotIf DesktopActive && PlayerLoaded && Playing && VerPos = 0

Up:: {
	global VerPos, PlayerPos
	VerPos := 1
	PlayerPos := 0
	Bang('SetTransparency 200', NavSkin)
    SoundPerform(ClickSound)
	Bang('SetOption MeterPlayPause ImageTint "#SelectColor#"', PlayerSkin)
	return
}

#HotIf

; --- Nav Hotkeys | Playlist ---
#HotIf DesktopActive && PlaylistLoaded && VerPos = 0

Down:: {
	global VerPos
	VerPos := -1
    SoundPerform(ClickSound)
	Bang('SetTransparency 200', NavSkin)
	if (Playing) {
		Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\stop.png"', PlaylistSkin)
	} else {
		Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\start.png"', PlaylistSkin)
	}
	Bang('SetOption MeterStartStop ImageTint "#SelectColor#"', PlaylistSkin)
	Playlist("ShowFade", 1)
	return
}

#HotIf

; --- Player Hotkeys ---
#HotIf DesktopActive && PlayerLoaded && Playing && VerPos = 1

Down:: {
	global VerPos, PlayerPos
	VerPos := 0
	PlayerPos := 0
	Bang('SetTransparency 255', NavSkin)
	Bang('SetOption MeterPrev ImageTint "#Color#"', PlayerSkin)
	Bang('SetOption MeterPlayPause ImageTint "#Color#"', PlayerSkin)
	Bang('SetOption MeterNext ImageTint "#Color#"', PlayerSkin)
	Bang('SetOption MeterRepeat ImageTint "' . RepeatTint[RepeatValue] . '"', PlayerSkin)
    SoundPerform(ClickSound)
	return
}

Enter:: {
    SoundPerform(EnterSound)
	PlayerAction()
	return
}

Left:: {
	global PlayerPos
	if (PlayerPos > -1) {
		SoundPerform(ClickSound)
		PlayerPos -= 1
		PlayerNavigation("Left")
	}
	return
}

Right:: {
	global PlayerPos
	if (PlayerPos < 2) {
		SoundPerform(ClickSound)
		PlayerPos += 1
		PlayerNavigation("Right")
	}
	return
}

#HotIf

; --- Playlist Hotkeys ---
#HotIf DesktopActive && PlaylistLoaded && VerPos = -1

Up:: {
	global VerPos, PlaylistPos, PlayInit
	VerPos := 0
	PlaylistPos := 0
	PlayInit := false
    SoundPerform(ClickSound)
	for music in Musics {
		meter := "MeterMusic" . music.Position
		Bang('SetOption ' . meter . ' ImageTint "#Color#"', PlaylistSkin)
		Bang('HideMeter ' . meter, PlaylistSkin)	
	}

	Bang('SetTransparency 255', NavSkin)
	Playlist("HideFade", 1)
	return
}

Enter:: {
	global VerPos, PlaylistPos, Playing, PlayInit
	if (PlaylistPos = 0) {
		if (Playing) {
			SoundPerform(OffSound)
			VerPos := 0
			Stop()
			Bang('SetOption MeterStartStop ImageTint "#MainColor#"', PlaylistSkin)
			Sleep(500)
			Playing := false
			PlayInit := false
			Bang('SetTransparency 255', NavSkin)
			Playlist("HideFade", 1)
			Sleep(500)
			Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\start.png"', PlaylistSkin)
		} else {
			SoundPerform(OnSound)
			Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\idle.png"', PlaylistSkin)
			for music in Musics {
				meter := "MeterMusic" . music.Position
				Bang('ShowMeter ' . meter, PlaylistSkin)	
			}
			PlayInit := true
		}
	} else {
		SoundPerform(EnterSound)
		index := (PlaylistPos > 0) ? (PlaylistPos + 5) : PlaylistPos + 6
		meter := "MeterMusic" . index
		Bang('SetOption ' . meter . ' ImageTint "#MainColor#"', PlaylistSkin)
		Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\stop.png"', PlaylistSkin)
		Sleep(200)
		Bang('SetOption MeterStartStop ImageTint "#MainColor#"', PlaylistSkin)
		Play(PositionToMusic[index])
		Sleep(1000)
		for music in Musics {
			meter := "MeterMusic" . music.Position
			Bang('SetOption ' . meter . ' ImageTint "#Color#"', PlaylistSkin)
			Bang('HideMeter ' . meter, PlaylistSkin)	
		}
		Playing := true
		VerPos := 0
		PlaylistPos := 0
		Bang('SetTransparency 255', NavSkin)
		Playlist("HideFade", 1)
	}
	return
}

#HotIf

; --- Playlist Hotkeys ---
#HotIf DesktopActive && PlaylistLoaded && VerPos = -1 && PlayInit

Left:: {
	global PlaylistPos
	if (-PlaylistPos < Ceil(MusicCount/2) && !Playing) {
		SoundPerform(ClickSound)
		next := (PlaylistPos > 0) ? (PlaylistPos + 4) : (PlaylistPos < 0 ? PlaylistPos + 5 : 5)
		prev := (PlaylistPos < 0) ? (PlaylistPos + 6) : (PlaylistPos > 0 ? PlaylistPos + 5 : 0)
		nextMeter := ""
		prevMeter := ""
		if (next = 5 && prev != 0) {
			nextMeter := "MeterStartStop"
		} else {
			nextMeter := "MeterMusic" . next	
		}
		if (prev = 0) {
			prevMeter := "MeterStartStop"
		} else {
			prevMeter := "MeterMusic" . prev	
		}
		Bang('SetOption ' . prevMeter . ' ImageTint "#Color#"', PlaylistSkin)
		Bang('SetOption ' . nextMeter . ' ImageTint "#SelectColor#"', PlaylistSkin)
		PlaylistPos -= 1
	}
	return
}

Right:: {
	global PlaylistPos
	if (PlaylistPos < Floor(MusicCount/2) && !Playing) {
		SoundPerform(ClickSound)
		next := (PlaylistPos < 0) ? (PlaylistPos + 7) : (PlaylistPos > 0 ? PlaylistPos + 6 : 6)
		prev := (PlaylistPos < 0) ? (PlaylistPos + 6) : (PlaylistPos > 0 ? PlaylistPos + 5 : 0)
		nextMeter := ""
		prevMeter := ""
		if (next = 6 && prev != 0) {
			nextMeter := "MeterStartStop"
		} else {
			nextMeter := "MeterMusic" . next	
		}
		if (prev = 0) {
			prevMeter := "MeterStartStop"
		} else {
			prevMeter := "MeterMusic" . prev		
		}
		Bang('SetOption ' . prevMeter . ' ImageTint "#Color#"', PlaylistSkin)
		Bang('SetOption ' . nextMeter . ' ImageTint "#SelectColor#"', PlaylistSkin)
		PlaylistPos += 1
	}
	return
}

#HotIf

; --- No Desktop Hotkeys ---
#HotIf !DesktopActive

; --- Browser_Home Button ---
F10::
Browser_Home::
{
    global LaunchedApp
    Log("Button Browser_Home (hard kill)")

    if (LaunchedApp = "") {
        Log("No app launched")
        return
    } else {
		allowedProcesses := ["firefox.exe", "chrome.exe", "kodi.exe", "steam.exe", "Playnite.FullscreenApp.exe"]
		; -- check if allowed process
		isAllowed := false
		for proc in allowedProcesses {
			if (proc = LaunchedApp) {
				isAllowed := true
				break
			}
		}
		if isAllowed {
			Display("Show",HomeSound)
			pid := ProcessExist(LaunchedApp)
			if (!pid) {
				Log(LaunchedApp " no longer exists")
				LaunchedApp := ""
				return
			}
			ProcessClose(pid)
			Log(LaunchedApp " closed")
			LaunchedApp := ""		
		}
	}
}

#HotIf

; --- Firefox Hotkeys | Related to Keyboard Surfing extension ---
; ---
; --- Remote Control --- 
; --- 	- Possible actions : Left, Right, Up, Down, Enter, Browser_Home, Browser_Back, AppsKey, Volume_Up, Volume_Down
; --- 	- Shortcuts : Browser_Home : Alt + Home | Browser_Back : Alt + Left | AppsKey : Shift + F10
; ---
#HotIf !DesktopActive && WinActive("ahk_exe firefox.exe") && KeyboardSurfing

Left:: {
    Send("{Numpad4}")
	return
}

Right:: {
    Send("{Numpad6}")
	return
}

Up:: {
    Send("{Numpad8}")
	return
}

Down:: {
    Send("{Numpad5}")
	return
}

#HotIf

#HotIf

; --- Youtube TV ---
#HotIf !DesktopActive && TVApp

~Left:: SoundPerform(LeftSound)
~Right:: SoundPerform(RightSound)
~Up:: SoundPerform(UpSound)
~Down:: SoundPerform(DownSound)
~Enter:: SoundPerform(SelectSound)
~Browser_Back:: SoundPerform(BackSound)

#HotIf

; --- Global Hotkey ---

F9::
AppsKey:: 
{
    global DesktopActive
    Log("Button AppsKey")
	if (DesktopActive) {
		Display("Hide",BackSound)	
	} else {
		Display("Show",HomeSound)	
	}
	return	
} 











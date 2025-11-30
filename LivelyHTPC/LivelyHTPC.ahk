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
IconCount := Min(IntRead(ConfigPath, "Variables", "IconCount", 5),20)
MusicCount := Min(IntRead(ConfigPath, "Variables", "Music.Playlist.Count", 0),10)
FocusIndex := IntRead(ConfigPath, "Variables", "StartPosition", 2)
NavigationSound := IntRead(ConfigPath, "Variables", "NavigationSound", 1)
StartSound := IntRead(ConfigPath, "Variables", "StartSound", 1)
VisualizerOnNav := IntRead(ConfigPath, "Variables", "VisualizerOnNav", 1)
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

; --- State ---
DesktopActive := true
LastActionTime := 0
ActionCooldown := 200
TVApp := false
Playing := false
PlaylistInit := false
VerPos := 0
PlayerPos := 0
PlaylistPos := 0
RepeatValue := 0
Player := 0
LaunchedApp := ""
NavSkin := "LivelyHTPC"
PlayerSkin := "LivelyHTPC\Player"
PlaylistSkin := "LivelyHTPC\Playlist"
VisualizerSkin := "LivelyHTPC\Visualizer"
PlayerLoaded := isLoaded(PlayerSkin)
PlaylistLoaded := isLoaded(PlaylistSkin) && MusicCount != 0
VisualizerLoaded := isLoaded(VisualizerSkin) 
RepeatTint:= Map(0, "#Color#", 1, "#MainColor#", 2, "#MainColor#")

; ----------------------------------------------------

; --- Init ---
Init() {
	global StartSound
	TaskbarDisplay("Hide")
	VisualizerDisplay("Hide",1)
	if (StartSound) {
		SoundPerform(["@Resources\Sounds\Start-1.wav", "@Resources\Sounds\Start-2.wav"][Random(1,2)])
	}	
}

; --- Logging ---
Log(message) {
	global Debug
    if (Debug) {
        FileAppend(formattedTime := FormatTime(A_Now, "dd/MM/yyyy HH:mm:ss") " - " message "`n", "Debug.log")
	}	
}

; --- Integer Read ---
IntRead(configPath, section, key, default) {
    val := IniRead(configPath, section, key, default)
    if (val = "") {
        return default
	}
    return Integer(val)
}

; --- Sound ---
SoundPerform(wav) {
	if (NavigationSound) {
		SoundPlay(wav)
	}	
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

; ----------------------------------------------------

; --- Visualizer Display ---
VisualizerDisplay(action, type) {
	if (VisualizerLoaded && !VisualizerOnNav && type = 1) {
		Bang(action, VisualizerSkin)
	}
}

; --- Playlist Display ---
PlaylistDisplay(action, type) {
	if (PlaylistLoaded && type = 1) {
		Bang(action, PlaylistSkin)
	}		
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
	global LaunchedApp
    if (!ProcessExist(pid)) {
        ; -- stop timer
		Display("Show",HomeSound)
		LaunchedApp := ""
        SetTimer(,0)
        Log("Monitoring closed") 
    }
}

; --- Taskbar Display ---
TaskbarDisplay(action) {
	if (action = "Show") {
		WinSetTransparent(255, "ahk_class Shell_TrayWnd")
	} else {
		WinSetTransparent(0, "ahk_class Shell_TrayWnd")
	}	
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
			SoundPerform(sound)
			TVApp := false
			VerPos := 0
			DesktopActive := true
			Bang(action . "FadeGroup", "LivelyHTPC")
			VisualizerDisplay(action,2)
			PlaylistDisplay(action,2)
			Log("Display: " . action . " Skin")
		} else if (DesktopActive && action = "Hide") {
			; -- hide skin
			VerPos := 0
			DesktopActive := false
			SoundPerform(sound)
			Bang(action . "FadeGroup", "LivelyHTPC")
			VisualizerDisplay(action,2)
			PlaylistDisplay(action,1)
			Log("Display: " . action . " Skin")
		} else {
			Log("Display: Needless (" . action . ")")
		}
    } catch as e {
        Log("Display Error: " . action . " | " . e.Message)
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

; --- Nav Focus ---
NavFocus(focus) {
	global VerPos
	if (focus = "On") {
		VerPos := 0
		Bang('SetTransparency 255', NavSkin)
	} else {
		Bang('SetTransparency 200', NavSkin)
	}
}


; --- Player -----------------------------------------


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
PlayerPlay(track) {
    Log("Launching Music: " . track)
	VisualizerDisplay("Show",1)
    try {
        SetTimer(HidePlayer, 50)  ; -- freq : 50ms
		Run('explorer.exe "' . track . '"', , "Hide") 	
    } catch as e {
        Log("Play Error: " . e.Message)
    }
}

; --- Stop Player ---
PlayerStop() {
	global Player, Playing, PlaylistInit
	SoundPerform(OffSound)
	if (Player) {
		WinClose(Player)
		Log("Player closed (" . Player . ")")
	} else {
		Log("Player not found (" . Player . ")")
	}
	for music in Musics {
		meter := "MeterMusic" . music.Position
		Bang('SetOption ' . meter . ' ImageTint "#Color#"', PlaylistSkin)
		Bang('HideMeter ' . meter, PlaylistSkin)	
	}
	Bang('SetOption MeterStartStop ImageTint "#MainColor#"', PlaylistSkin)
	Sleep(500)
	Playing := false
	PlaylistInit := false
	NavFocus("On")
	VisualizerDisplay("Hide",1)
	PlaylistDisplay("HideFade", 1)
	Sleep(500)
	Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\start.png"', PlaylistSkin)	
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


; --- Events -----------------------------------------


; --- Navigation Bar | Hotkeys ---
#HotIf DesktopActive && VerPos = 0

; --- Right Arrow ---
$Right:: {
    global FocusIndex, IconCount, RightSound
    if (CanPerformAction() && FocusIndex < IconCount) {
        SoundPerform(RightSound)
        FocusIndex += 1
        Notify()
    }
    Log("Button Right (f:" . FocusIndex . ")")
}

; --- Left Arrow ---
$Left:: {
    global FocusIndex, LeftSound
    if (CanPerformAction() && FocusIndex > 1) {
        SoundPerform(LeftSound)
		FocusIndex -= 1
        Notify()
    }
    Log("Button Left (f:" . FocusIndex . ")")
}

; --- Enter Button ---
$Enter:: {
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
                if (RegExMatch(icon.Action, "([^\\]+?\.exe)", &m)) {
                    processName := m[1]
				}

                LaunchedApp := processName	
				
				; -- check TVApp
				if InStr(icon.Action, "youtube.com/tv") {
					TVApp := true
				}
				Display("Hide",SelectSound)
				
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
				timer := A_TickCount

				; -- wait window visible (max 2s)
				if !WinWaitActive("ahk_exe " . processName, , 2) {
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

; --- Navigation Bar | Player | Hotkeys ---
#HotIf DesktopActive && PlayerLoaded && Playing && VerPos = 0

$Up:: {
	global VerPos, PlayerPos
	VerPos := 1
	PlayerPos := 0
	NavFocus("Off")
    SoundPerform(ClickSound)
	Bang('SetOption MeterPlayPause ImageTint "#SelectColor#"', PlayerSkin)
}

#HotIf

; --- Navigation Bar | Playlist | Hotkeys ---
#HotIf DesktopActive && PlaylistLoaded && VerPos = 0

$Down:: {
	global VerPos
	VerPos := -1
    SoundPerform(ClickSound)
	NavFocus("Off")
	if (Playing) {
		Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\stop.png"', PlaylistSkin)
	} else {
		Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\start.png"', PlaylistSkin)
	}
	Bang('SetOption MeterStartStop ImageTint "#SelectColor#"', PlaylistSkin)
	PlaylistDisplay("ShowFade", 1)
}

#HotIf

; --- Player | Hotkeys ---
#HotIf DesktopActive && PlayerLoaded && Playing && VerPos = 1

$Down:: {
	global PlayerPos
	PlayerPos := 0
	NavFocus("On")
	Bang('SetOption MeterPrev ImageTint "#Color#"', PlayerSkin)
	Bang('SetOption MeterPlayPause ImageTint "#Color#"', PlayerSkin)
	Bang('SetOption MeterNext ImageTint "#Color#"', PlayerSkin)
	Bang('SetOption MeterRepeat ImageTint "' . RepeatTint[RepeatValue] . '"', PlayerSkin)
    SoundPerform(ClickSound)
}

$Enter:: {
    SoundPerform(EnterSound)
	PlayerAction()
}

$Left:: {
	global PlayerPos
	if (PlayerPos > -1) {
		SoundPerform(ClickSound)
		PlayerPos -= 1
		PlayerNavigation("Left")
	}
}

$Right:: {
	global PlayerPos
	if (PlayerPos < 2) {
		SoundPerform(ClickSound)
		PlayerPos += 1
		PlayerNavigation("Right")
	}
}

#HotIf

; --- Playlist | Hotkeys ---
#HotIf DesktopActive && PlaylistLoaded && VerPos = -1

$Up:: {
	global PlaylistPos
	PlaylistPos := 0
    SoundPerform(ClickSound)
	for music in Musics {
		meter := "MeterMusic" . music.Position
		Bang('SetOption ' . meter . ' ImageTint "#Color#"', PlaylistSkin)
		if (!Playing) {
			Bang('HideMeter ' . meter, PlaylistSkin)	
		}
	}
	NavFocus("On")
	PlaylistDisplay("HideFade", 1)
}

$Enter:: {
	global PlaylistPos, Playing, PlaylistInit
	if (PlaylistPos = 0) {
		if (Playing) {
			PlayerStop()
		} else {
			SoundPerform(OnSound)
			Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\idle.png"', PlaylistSkin)
			for music in Musics {
				meter := "MeterMusic" . music.Position
				Bang('ShowMeter ' . meter, PlaylistSkin)	
			}
			PlaylistInit := true
		}
	} else {
		SoundPerform(EnterSound)
		index := (PlaylistPos > 0) ? (PlaylistPos + 5) : PlaylistPos + 6
		meter := "MeterMusic" . index
		Bang('SetOption ' . meter . ' ImageTint "#MainColor#"', PlaylistSkin)
		Bang('SetOption MeterStartStop ImageName "#@#Icons\Music\stop.png"', PlaylistSkin)
		Sleep(200)
		Bang('SetOption MeterStartStop ImageTint "#MainColor#"', PlaylistSkin)
		PlayerPlay(PositionToMusic[index])
		Sleep(1000)
		Playing := true
		PlaylistPos := 0
		NavFocus("On")
		PlaylistDisplay("HideFade", 1)
		for music in Musics {
			meter := "MeterMusic" . music.Position
			Bang('SetOption ' . meter . ' ImageTint "#Color#"', PlaylistSkin)
		}	
	}
}

#HotIf

; --- Playlist | Hotkeys ---
#HotIf DesktopActive && PlaylistLoaded && VerPos = -1 && PlaylistInit

$Left:: {
	global PlaylistPos
	if (-PlaylistPos < Ceil(MusicCount/2)) {
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
}

$Right:: {
	global PlaylistPos
	if (PlaylistPos < Floor(MusicCount/2)) {
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
}

#HotIf

; --- No Desktop | Hotkeys ---
#HotIf !DesktopActive

; --- Browser_Home Button ---
$F10::
$Browser_Home::
{
    global LaunchedApp
    Log("Button Browser_Home (hard kill)")
    if (LaunchedApp = "") {
        Log("No app launched")
        return
    } else {
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

#HotIf

; --- Firefox | Hotkeys | Related to Keyboard Surfing addon ---
#HotIf !DesktopActive && WinActive("ahk_exe firefox.exe") && KeyboardSurfing

$Left:: Send("{Numpad4}")
$Right:: Send("{Numpad6}")
$Up:: Send("{Numpad8}")
$Down:: Send("{Numpad5}")
$AppsKey:: Send("{Space}")
$Enter:: Send("{NumpadEnter}")

#HotIf

; --- Steam - Youtube TV | Hotkeys ---
#HotIf !DesktopActive  && (WinActive("ahk_exe steamwebhelper.exe") || TVApp)
$Browser_Back:: Send("{Escape}")
#HotIf

; --- Youtube TV | Hotkeys ---
#HotIf !DesktopActive && TVApp

~Left:: SoundPerform(LeftSound)
~Right:: SoundPerform(RightSound)
~Up:: SoundPerform(UpSound)
~Down:: SoundPerform(DownSound)
~Enter:: SoundPerform(SelectSound)
~Browser_Back:: SoundPerform(BackSound)

#HotIf

; --- No App running | Hotkeys ---
#HotIf LaunchedApp = ""

; --- Toggle Skin Display | Windows Taskbar (and disable/enable events) ---
$F9::
$AppsKey:: 
{
    global DesktopActive
    Log("Button AppsKey")
	if (DesktopActive) {
		TaskbarDisplay("Show")
		Display("Hide",BackSound)	
	} else {
		TaskbarDisplay("Hide")
		Display("Show",HomeSound)	
	}	
} 

#HotIf

; --- Global | Hotkeys ---

; --- This is an emergency button to display or hide the taskbar ---
; --- AppsKey/F9 can be used too ---
$F7::{
try {
	transparent := WinGetTransparent("ahk_class Shell_TrayWnd")
	if (transparent = "" || transparent = "255") {
		WinSetTransparent(0, "ahk_class Shell_TrayWnd")	
	} else {
		WinSetTransparent(255, "ahk_class Shell_TrayWnd")	
	}
}	
} 

; ---
; --- Remote Control --- 
; --- Possible actions : Left, Right, Up, Down, Enter, Browser_Home, Browser_Back, AppsKey, Volume_Up, Volume_Down
; ---


; *** Init *******************************************
Init()










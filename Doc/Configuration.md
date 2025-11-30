# LivelyHTPC
**Lively HTPC Launcher** – A beautiful, remote-friendly media application launcher for your Home Theater PC

<img src="Images/Banner.png" alt="LivelyHTPC Banner" />

## 🧭 Navigation
- [🏠 Home](../README.md#livelyhtpc)
- [Features](../README.md#-features)
- [Demo](../README.md#-demo)
- [Screenshots](../README.md#-screenshots)
- [Quick Start](../README.md#-quick-start)
- [Configuration](../README.md#️-configuration)
- [Recommended Setup (Best Experience)](../README.md#-recommended-setup-best-experience)
- [Navigation](../README.md#-navigation)
- [Extras](../README.md#-extras)
- [License](../README.md#-license)
- [Support & Community](../README.md#-support--community)
- [Credits](../README.md#-credits)
---


## ⚙️ Configuration

### 💠 Rainmeter 

In Rainmeter Manager : **Manage  → Settings**

- Check **Enable hardware acceleration**

In Rainmeter Manager : **Manage  → Skins → LivelyHTPC**

- Select **Player.ini**, **Clock.ini**, **Visualizer.ini**, **Playlist.ini** 
to adjust their positioning based on your preferences and screen resolution. The default layout is optimized mainly for 2K resolution. Play with `ClockScale` value too in `Variables.Inc` (see below in [Configuration](#️-configuration) section)

Example: 

2K    : `VisibleIcons=5` `IconSize=220` `IconSpacing=50` `ClockScale=1`

1080p : `VisibleIcons=5` `IconSize=180` `IconSpacing=50` `ClockScale=0.75`

| Ini| 2K Resolution | 1080p Resolution |
|-|----------------|------------------|
|  Player.ini      |  X=960,Y=60   | X=640,Y=60  |
|  Clock.ini       |  X=950,Y=150  | X=710,Y=150 |
|  Visualizer.ini  |  X=1060,Y=260 | X=740,Y=200  |
|  Playlist.ini    |  X=925,Y=1260 | X=600,Y=880  |


> Make sure the player is positioned above the icon bar (and the playlist below), otherwise navigation will be confusing 🙃😁

---

#### ⏹️ General

##### 🔹Total Icons
```ini
IconCount = 11           ; ← all the icons/apps available (max : 20 icons)
```
#####  🔹Visible Icons
```ini
VisibleIcons = 5         ; ← visible icons at the same time (recommended 4-5)
```
#####  🔹Icon Size and Spacing
```ini
IconSize=220             ; ← icon width & height
IconSpacing=50           ; ← icon spacing
```
#####  🔹Default Icon selected
```ini
StartPosition = 2        ; ← which icon is selected by default (min : 1, max : VisibleIcons)
```
#####  🔹Main & Select Color
```ini
MainColor=255,125,253    ; ← main RGB color used by player, visualizer, playlist
SelectColor=252,255,125  ; ← RGB color used by player, visualizer, playlist when selection
```
#####  🔹Clock Settings
```ini
ClockScale=1             ; ← scale of the clock display (decimal; e.g., 0.75 for 1080p, 1 for 2K)
ClockFormat24H=1         ; ← choose the time format: 24H or 12H [0 or 1]
Language=English         ; ← language used (French or English available by default)
```
> You can create your own language file by copy/paste/edit/rename **@Resources  → Language**  → `English.inc` and change after, **Language** accordingly.

---

#### ⏹️ Icon/App settings (samples here corresponding to an IconCount of 11)
```ini
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
```
> ⚠️ **Icon.N.Name** must correspond to **2 png** image files available in **@Resources  → Icons**

Ex: `Icon.1.Name=Canal` → `Canal.png` & `Canal2.png` | default image and selected image (with **2** at the end of the name)

**Icon.N.Action** is the application **command line** associated with the icon

- When the executable is **Firefox** or **Chrome**, use **--kiosk** argument for a full-screen experience
- When **Chrome**, use **--disable-session-crashed-bubble** to avoid the popup message from **Chrome** after hard killing the process

> If you want to access **Youtube TV** like a **Smart TV** keep this **Chrome** argument : `--user-agent="Mozilla/5.0 (Linux; Tizen 2.3; SmartHub; SMART-TV; SmartTV; U; Maple2012) AppleWebKit/538.1+ (KHTML, like Gecko) TV Safari/538.1+"`

- It tricks YouTube into thinking you're on a Smart TV and gives you the corresponding experience 😎😉

---

#### ⏹️ Music

You can define the number of playlists you want to use with `Music.Playlist.Count` (min : **0**, max : **10**)
```ini
Music.Playlist.Count=10
Music.Playlist.1=C:\Users\Veda\Music\Playlists\Justice-Hyperdrama.m3u8
Music.Playlist.2=C:\Users\Veda\Music\Playlists\Beverly-Hills.m3u8
Music.Playlist.3=C:\Users\Veda\Music\Playlists\Selection.m3u8
Music.Playlist.4=C:\Users\Veda\Music\Playlists\Dance.m3u8
Music.Playlist.5=C:\Users\Veda\Music\Playlists\The-Last-of-Us.m3u8
Music.Playlist.6=C:\Users\Veda\Music\Playlists\F1.m3u8
Music.Playlist.7=C:\Users\Veda\Music\Playlists\The-Supremes.m3u8
Music.Playlist.8=C:\Users\Veda\Music\Andrea Bocelli - Nessun dorma.mp3
Music.Playlist.9=C:\Users\Veda\Music\Jerry Goldsmith - The Mission.mp3
Music.Playlist.10=C:\Users\Veda\Music\Enya\Enya - Boadicea.mp3
```
You can use the path to a music **file** (**mp3, flac**, etc.) or a **playlist** file (**m3u8**, etc.).
> ⚠️  **Folder** path is **not supported**

> ⚠️ ☠️ The music player behind the scenes is **Media Player UWP** (Windows 11) and **MUST** be the **default application** used to open these music files

> 📌 **Known Media Player limitations** (independent of **LivelyHTPC**): **Playlist** files may freeze or show permission errors if the music folder isn't added to the Media Player **Music Library**  and indexed. This is the most common source of instability
→ Downside: album art will no longer appear in the player 😪 (**WebNowPlaying** plugin can't retrieve it in this configuration).
When playing **individual tracks** only (no playlists): keep the folder outside the Music Library to ensure covers are displayed properly.




---

#### ⏹️ Animation
Define the animation type and the speed used when scrolling the horizontal bar
```ini
Animation.Mode=EaseOutQuad
Animation.Speed=0.08
```
**5 Modes** available : **None** - **Linear** - **EaseOutQuad** - **EaseOutExpo** - **EaseOutExpoFast**.
Here are the recommended modes and their corresponding speeds:
| None | Linear | EaseOutQuad | EaseOutExpo | EaseOutExpoFast |
|------|--------|-------------|-------------|-----------------|
| 0 | 30 | 0.08 | 0.04 | 0.008 |

**None** and **Linear** have no performance cost, but for the other modes, a slower speed can significantly increase CPU/GPU usage and cause lag or delays.
Tweak the mode and speed that suits best for you.

---

#### ⏹️ Sound

```ini
StartSound=1       ; ← choose if you want startup sound or not [0 or 1]
NavigationSound=1  ; ← choose if you want navigation sound [0 or 1]
```

---

#### ⏹️ Visualizer

```ini
VisualizerOnNav=0 ; ← choose if you want visualizer available during navigation [0 or 1]
```

---

#### ⏹️ Firefox Addon

```ini
Addon.KeyboardSurfing=0 ; ← declare whether you use the Firefox Keyboard Surfing add-on or not [0 or 1]
```
- Firefox Add-on : [Keyboard Surfing](https://addons.mozilla.org/en-US/firefox/addon/keyboard-surfing/)
---

#### 🟧 Secret (debug mode)

```ini
Debug=0 ; ← for development only — NEVER in production
```

▶️ Back [🏠 Home](../README.md)
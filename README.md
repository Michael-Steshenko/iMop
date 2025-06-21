# iMop
A place for me to keep a set of tools, configurations and installation instructions for tools that I use for development on OSX

## Tools

### Neovim
`brew install neovim`  

### Karabiner-Elements + Hammerspoon keyboard shortcuts   
We use Karabiner elements for low-level keyboard remapping, i.e. it captures inputs before they reach the OS.  
Mainly we want to use Karabiner to set a hyperkey, then we use Hammerspoon to set keyboard shortcuts using the hyperkey.  
We use Hammerspoon and not native solutions (Shorcuts app / Apple script) because they have a noticable action delay.  

#### Install
`brew install --cask karabiner-elements`  
`brew install --cask hammerspoon`

#### Configure Karabinar Elements
In Karabiner under `Complex Modifications`:
- `Add your own rule`
- paste the contents of [karabiner-elements-rules.json](https://github.com/Michael-Steshenko/iMop/blob/main/karabiner-elements-rules.json)  

#### Configure Hammerspoon
- copy the [hammerspoon config](https://github.com/Michael-Steshenko/iMop/blob/main/.hammerspoon/init.lua) to `~/.hammerspoon/init.lua`

### pyenv - manage multiple python versions
`brew install pyenv`  
`pyenv install -l` - list available versions  
`pyenv install 3.8`  
`pyenv init` (one time, and follow instructions for interactive shell). 

`pyenv shell <version>` -- select just for current shell session  
`pyenv local <version>` -- automatically select whenever you are in the current directory (or its subdirectories)  
`pyenv global <version>` -- select globally for your user account  
to unset: `pyenv local --unset`  

### Scroll Reverser
`brew install scroll-reverser`  
Disable auto update in setttings, we can update the app through brew which ensures the update goes through the brew security verification process.

### Better display
`brew install --cask betterdisplay`

### Universal autofill for 1Password
[Universal autofill](https://support.1password.com/mac-universal-autofill/#autofill-your-mac-login) allows you to fill in passwords anywhere in the Mac using a keyboard shortcut (default - cmd + \\).  
Disable autofill and passwords in MacOs settings completely, 1Password doesn't use those.

### VMWare Fusion Pro
I'm using this over other options because at the time of writing it's the only option that's free and has hardware acceleration.  
**Note:** As of 21June2025 you cannot install VMWare Fusion through brew, use web installer instead.  
**Note:** As of 21June2025 clipboard sharing and dragging files between host and guest don't work on Linux guest running KDE with Wayland, so if we want KDE we are forced to use X11, which is inferior. This is a very old bug, so I should probably just use Gnome instead of KDE.  

#### Removing modifier key delay
By default modifier keys are sent to the host, this can cause delayed actions on the guest, for example pressing cmd to open Gnome activities will be delayed.  
To prevent this:  
- Open VMWare settings -> Keyboard and Mouse tab
- In `MacOS shortcuts` sub-tab, remove checkbox from `Enable Mac OS Host Keyboard Shortcuts`
- In `Fusion Shortcuts` sub-tab and ensure `Minimize Window` shortcut is enabled

#### Switching out of VMWare Fusion Pro
I want to be able to use modifier keys inside the VM without affecting MacOS.  

By default there are 3 keyboard shortcuts to switch out of VMWare without closing it:
- `ctrl` + `cmd` + ungrab mouse cursor
- `cmd` + `m` - minimize window
- `cmd` + `h` - hide windows  
  **Note**: VMWare does not allow you to modify those.

Since Karbiner elements is low level remapping, any remapping I make in it will affect both the host and the guest.  
This means I can write a mapping that maps `some shortcut` to `ctrl` + `cmd` in order to exit the vm.  
This also means I could reuse the mapping for switching to VMWare as the mapping to switch out, but that mapping can't rely on the hyper key without conflicts or complicated logic, and I want all app switching to be through the hyper key.  
Taking all of this into account I decided that the few extra key presses i.e. (`cmd` + `h` -> the actual app shortcut I want) is good enough.  

## Configurations

### Show full path in terminal (zsh)
`nvim ~/.zshrc`  
for custom device name (hostname)  

```
# update how command line prompt looks, show full file path
PS1='%n@<your device name> %d %# '
```

for actual hostname  
```
# update how command line prompt looks, show full file path
PS1='%n@%m %d %# '
```  

### Custom commands for ~/.zshrc
```
# ------ custom commands ------

echo_and_run() { echo "\$ $*" ; "$@" ; }

# replace npm build with npm run build
npm() {
    if [ "$1" = "build" ]; then
        shift        # eat the 'build'
        echo "replacing npm build "$@" with npm run build "$@""
        npm run build "$@"
    else
        command npm "$@"
    fi
}

# brew up - full update for brew, brew packages and brew casks (apps)
brew() {
    if [ "$1" = "up" ]; then
	echo_and_run brew update && echo_and_run brew outdated --greedy && echo_and_run brew upgrade --greedy && echo_and_run brew cleanup
    else
        command brew "$@"
    fi
}
```

### External Storage
#### Change brew cask default install folder
`nvim ~/.zprofile`  
add the following line:  
`export HOMEBREW_CASK_OPTS="--appdir=/Volumes/MSI-M461-1TB/Applications --fontdir=/Library/Fonts"`

#### Symlink external Applications folder to System Applications folder
If you want a custom icon for the external storage Applications folder, add the icon before creating the symlink.  

To set a custom icon:  
- Copy an application icon from the web (or another folder through CMD + I)
- `CMD + I` the folder you wish to set an icon for
- click the icon and paste  

To crate the symlink:  
`ln -s /Volumes/MSI-M461-1TB/Applications /Applications/ExternalSSD`

### Git
`brew install git`  
To be able to authenticate via the browser we need to install git-credential-manager 
`brew install --cask git-credential-manager`  
When cloning make sure to clone via HTTPS URL

### VSCode
After installing VSCode, we want to add VSCode CLI to path:  
In VSCode open Command Pallete and type `Shell Command: Install 'code' command in PATH`


### Enable Touch ID for sudo
- `sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local`  
- `sudo nvim /etc/pam.d/sudo_local`  
- Uncomment `auth       sufficient     pam_tid.so` as per the instructions in the file

### Instant dock auto-hide delay and hide animation
In dock settings, enable: `Automatically hide and show the Dock`.  

Then run:  
`defaults write com.apple.dock autohide-delay -float 0; defaults write com.apple.dock autohide-time-modifier -int 0; killall Dock`  

to undo:  
`defaults delete com.apple.dock "autohide-delay"; defaults delete com.apple.dock "autohide-time-modifier"; killall Dock`  

### No margins on tiled windows
System Settings > Desktop & Dock > Windows > Tiled windows have margins (switch off).  

### Custom keyboard shortcuts

With non-mac keyboards, the funtion row controls do not work by default.  
To make it work:
- Go to System Settings -> Keyboard -> Keyboard Shortcuts -> Function Keys
- Enable ```Use F1, F2, etc. keys as standard function keys```

Now for each shortcut you want to add, do the following:  
- Open automator
- Choose the type of your document: Quick Action
- Workflow receives: no input
- in: any application
- Under actions select: Run AppleScript
- write your script
- File -> save, and give the shortcut a name
- Assign a keyboard shortcut in System Settings -> Keyboard -> Keyboard Shortcuts -> Services -> General

#### Scripts I'm using:
Volume up (^F3):
```
set vol to ((output volume of (get volume settings)) + 5)
if (vol > 100) then set vol to 100
set volume output volume (vol)
```

Volume down (^F2)
```
set vol to ((output volume of (get volume settings)) - 5)
if (vol < 0) then set vol to 0
set volume output volume (vol)
```

Mute/Unmute volume (^F1)
```
-- Get current mute state via the System Preferences AppleScript API
set currentMute to (do shell script "osascript -e 'output muted of (get volume settings)'")

if currentMute is "true" then
	-- Unmute the system
	do shell script "osascript -e 'set volume without output muted'"
else
	-- Mute the system
	do shell script "osascript -e 'set volume with output muted'"
end if
```

Play/Pause Apple Music (^F6)  
Unfortunately there's no simple way to simulate the mac keyboard play/pause key, instead we send play/pause to Apple Music
```
tell application "Music"
    if player state is playing then
        pause
    else
        play
    end if
end tell
```

Next track Apple Music (^F7)
```
if application "Music" is running then
	tell application "Music" to next track
end if
```

Previous track Apple Music (^F5)
```
if application "Music" is running then
	tell application "Music" to previous track
end if
```

## TODO
- [ ] Use f18 instead of ctrl + cmd + option + shift for hyperkey in Karabiner / Hammerspoon
- [ ] Move all the music apple script keyboard shortcuts to Hammerspoon, should probably also use hyperkey.
- [ ] Switch to Obsidian for my note taking

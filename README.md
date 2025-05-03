# iMop
A place for me to keep a set of tools, configurations and installation instructions for tools that I use for development on OSX

## Tools

### Neovim
`brew install neovim`  

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
[Universal autofill](https://support.1password.com/mac-universal-autofill/#autofill-your-mac-login
) allows you to fill in passwords anywhere in the Mac using a keyboard shortcut (default - cmd + \).  
Disable autofill and passwords in MacOs settings completely, 1Password doesn't use those.

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

dafa
dafadf
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

### Remapping Mac keyboard keys
My macbook came with a `§` key instead of a `` ` `` key, I have no use for that key.  
The following instructions place `` ` `` where it belongs and make the extra key next to left shift also act as left shift.  
Originally I achieved this using an .sh script and a .plist file loaded as a LaunchAgent or a LaunchDaemon, this method stopped working for me on MacOS starting MacOS Sequoia and I couldn't get it to work, so now I wrap an .sh script in an Automator app and add it to ```System settings -> Login Items```  
The downside of this method is it remaps the keys on user login instead of on boot, but I don't really care.  
The benefit of this method is we no longer need to give the terminal app ```input monitoring``` permissions, instead we will grant the permissions to our Automator app.  
The .sh script that the Automator app is wrapping is [here](https://github.com/Michael-Steshenko/iMop/blob/main/remapkeys.sh).  

References I used for the .sh script:  
- https://apple.stackexchange.com/a/468557  
- https://stackoverflow.com/a/58981641/17555452

Hex codes for the keys can be found here:  
- https://developer.apple.com/library/archive/technotes/tn2450/_index.html  

TLDR steps:  
- Download the [Remap Mac Keys.app](https://github.com/Michael-Steshenko/iMop/blob/main/Remap%20Mac%20Keys%20app.zip) and move it to your Applications folder
- In ```System settings``` search for ```Login Items``` and add remapkeys.app there
- Reboot to test

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

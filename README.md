# iMop
A place for me to keep a set of tools, configurations and installation instructions for tools that I use for development on OSX

## Tools

### Neovim
`brew install neovim`  

## Configurations

### Git
To be able to authenticate via the browser we need to install git-credential-manager 
`brew install --cask git-credential-manager`  
When cloning make sure to clone via HTTPS URL


### Enable Touch ID for sudo
- `sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local`  
- `sudo nano /etc/pam.d/sudo_local`  
- Uncomment `auth       sufficient     pam_tid.so` as per the instructions in the file

### Swapping built-it keyboard keys
My macbook came with a `§` key instead of a `` ` `` key. I have no use for that key. The following instructions place `` ` `` where it belongs and make the extra key next to left shift also act as left shift.

- `nvim ~/my_custom_scripts/com.michaelsteshenko.remapkeys.sh`  
- paste the following:  
```
#!/bin/zsh
# remap § to ` and ± to ~
sudo hidutil property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x700000035,
      "HIDKeyboardModifierMappingDst":0x700000064},
     {"HIDKeyboardModifierMappingSrc":0x700000064,
      "HIDKeyboardModifierMappingDst":0x700000035}]
}'
```
- `chmod +x ~/my_custom_scripts/com.michaelsteshenko.remapkeys.sh`
- `sudo nvim /Library/LaunchDaemons/com.yourusername.remapkeys.plist`
- paste the following:  
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.michaelsteshenko.remapkeys</string>
    <key>RunAtLoad</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
	<string>/Users/michaelsteshenko/my_custom_scripts/com.michaelsteshenko.remapkeys.sh</string>  
    </array>
</dict>
</plist>
```
- Set permissions:  
`sudo chown root:wheel /Library/LaunchDaemons/com.michaelsteshenko.remapkeys.plist`  
`sudo chmod 644 /Library/LaunchDaemons/com.michaelsteshenko.remapkeys.plist`  
- Load the daemon:  
`sudo launchctl load -w /Library/LaunchDaemons/com.michaelsteshenko.remapkeys.plist`

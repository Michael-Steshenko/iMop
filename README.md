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
- `sudo nvim /etc/pam.d/sudo_local`  
- Uncomment `auth       sufficient     pam_tid.so` as per the instructions in the file

### Swapping built-it keyboard keys
My macbook came with a `§` key instead of a `` ` `` key. I have no use for that key. The following instructions place `` ` `` where it belongs and make the extra key next to left shift also act as left shift.  

Taken from here https://apple.stackexchange.com/a/468557 and https://stackoverflow.com/a/58981641/17555452 and modified.  
Hex codes for the keys can be found here: https://developer.apple.com/library/archive/technotes/tn2450/_index.html  

- `nvim ~/my_custom_scripts/com.michaelsteshenko.remapkeys.sh`  
- paste the following:  
```
#!/bin/zsh
# remap § to ` and ` to left shift, making this almost a normal keyboard
# 0x700000035 = §
# 0x7000000E1 = Left shift
# 0x700000064 = `
sudo hidutil property --matching '{"ProductID":0x343}' property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x700000035,
      "HIDKeyboardModifierMappingDst":0x7000000E1},
     {"HIDKeyboardModifierMappingSrc":0x700000064,
      "HIDKeyboardModifierMappingDst":0x700000035}]
}'
```
- Where `ProductId` is the product ID of the keyboard taken from:  
`Apple icon > About This Mac > System Report > Hardware > SPI > Apple Internal Keyboard`
- `sudo chmod +x ~/my_custom_scripts/com.michaelsteshenko.remapkeys.sh`
- `sudo nvim /Library/LaunchDaemons/com.michaelsteshenko.remapkeys.plist`
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
- reboot to test

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

### Remapping Mac keyboard keys
My macbook came with a `§` key instead of a `` ` `` key, I have no use for that key.  
The following instructions place `` ` `` where it belongs and make the extra key next to left shift also act as left shift.  
Originally I achieved this using an .sh script and a .plist file loaded as a LaunchAgent or a LaunchDaemon, this method stopped working for me on MacOS starting MacOS Sequoia and I couldn't get it to work, so now I wrap an .sh script in an Automator app and add it to ```System settings -> Login Items```  
The downside of this method is it remaps the keys on user login instead of on boot, but I don't really care.  
The benefit of this method is we no longer need to give the terminal app ```input monitoring``` permissions, instead we will grant the permissions to our Automator app.  
The .sh script that the Automator app is wrapping is here [here](https://github.com/Michael-Steshenko/iMop/blob/main/remapkeys.sh).  

References I used for the .sh script:  
- https://apple.stackexchange.com/a/468557  
- https://stackoverflow.com/a/58981641/17555452

Hex codes for the keys can be found here:  
- https://developer.apple.com/library/archive/technotes/tn2450/_index.html  

TLDR steps:  
- Download the [Remap Mac Keys.app](https://github.com/Michael-Steshenko/iMop/blob/main/Remap%20Mac%20Keys%20app.zip) and move it to your Applications folder
- In ```System settings``` search for ```Login Items``` and add remapkeys.app there
- Reboot to test

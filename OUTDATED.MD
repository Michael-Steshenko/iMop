### Remapping Mac keyboard keys
Note: I now use Karabiner for hyper key shortcuts so it makes sense to use it for remapping the keys as well.  
Use this if you want a solution with no external dependencies.  

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

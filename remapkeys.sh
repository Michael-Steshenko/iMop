#/bin/zsh
# remap § to ` and ` to left shift, making this almost a normal keyboard
# 0x700000035 = §
# 0x7000000E1 = Left shift
# 0x700000064 = `
echo "Script started at $(date)" >> /tmp/remapkeys.log

#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/tmp/remapkeys.log 2>&1
# Everything below will go to the file '/tmp/remapkeys.log':

# ProductId is the product ID of the keyboard taken from:
# Apple icon > About This Mac > System Report > Hardware > SPI > Apple Internal Keyboard
# Key codes can be found here: https://developer.apple.com/library/archive/technotes/tn2450/_index.html
hidutil property --matching '{"ProductID":0x343}' property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x700000035,
      "HIDKeyboardModifierMappingDst":0x7000000E1},
     {"HIDKeyboardModifierMappingSrc":0x700000064,
      "HIDKeyboardModifierMappingDst":0x700000035}]
}'

require('Config')

-- Launch MS Teams
if (not Config.disableTeams) then
  hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "t", function()
    hs.application.launchOrFocus("Microsoft Teams")
    -- switch from main Teams window to a second open teams window if it exists
    -- This is my MacOS settings keybind to switch to other windows of the same app
    hs.eventtap.keyStroke({"ctrl", "alt", "cmd", "shift"}, "space")    
  end)
end

-- Launch 1Password
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "1", function()
  hs.application.launchOrFocus("1Password")
end)

-- Launch FireFox
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "2", function()
hs.application.launchOrFocus("Firefox")
end)
 
-- Launch VSCode
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "3", function()
  hs.application.launchOrFocus("Visual Studio Code")
end)

-- Launch Terminal
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "4", function()
  hs.application.launchOrFocus("Terminal")
end)

-- Launch OneNote
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "5", function()
  hs.application.launchOrFocus("Microsoft OneNote")
end)

-- Launch Slack
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "s", function()
  hs.application.launchOrFocus("Slack")
end)

-- Launch Mail
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "m", function()
  hs.application.launchOrFocus("Mail")
end)
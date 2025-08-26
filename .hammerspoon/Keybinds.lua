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

--- Apple Music stuff Hyper + A ---
local appleMusicKey = "A"

local function favorite()
  local script = [[
  tell application "Music"
    set favorited of current track to true
    set disliked of current track to false
  end tell
  return input
  ]]
  hs.osascript.applescript(script)
  hs.alert.show("Favorite")
end

local function unfavorite()
  local script = [[
  tell application "Music"
    set favorited of current track to false
  end tell
  return input
  ]]
  hs.osascript.applescript(script)
  hs.alert.show("Unfavorite")
end

local function suggestLess()
  local script = [[
    tell application "Music"
      set favorited of current track to false
      set disliked of current track to true
      next track
    end tell
    return input
  ]]
  hs.osascript.applescript(script)
  hs.alert.show("Suggest less")
end

function appleMusicMode()
  -- use event tap to capture key presses because hs.hotkey.modal cannot act on keys we didn't bind
  evtap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local key = e:getKeyCode()
    if key == hs.keycodes.map['escape'] then -- Exit
      evtap:stop()
    elseif key == hs.keycodes.map['h'] then -- Help
      hs.alert.show("F: Favorite\nU: Unfavorite\nL: Suggest less")
    elseif key == hs.keycodes.map[appleMusicKey] then -- Launch Apple Music
      hs.application.launchOrFocus("Apple Music")
      evtap:stop()
    elseif key == hs.keycodes.map['F'] then -- Favorite
      favorite()
      evtap:stop()
    elseif key == hs.keycodes.map['U'] then -- Undo favorite
      unfavorite()
      evtap:stop()
    elseif key == hs.keycodes.map['L'] then -- Suggest less
      suggestLess()
      evtap:stop()
    else -- Invalid key
      local keyString = hs.keycodes.map[key] or tostring(key)
      hs.alert.show("Invalid key: " .. keyString)
    end
    return true -- Stop event from propogating
  end)
  hs.alert.show('Apple Music Mode')
  evtap:start()
end
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, appleMusicKey, appleMusicMode)
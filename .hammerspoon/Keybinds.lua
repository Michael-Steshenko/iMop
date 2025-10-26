require('Config')

local hyper = Config.hyper

-- Prefer bundle app Ids over app names if possible
-- i.e. prefer "org.mozilla.firefox" over "Firefox"
hs.loadSpoon("LaunchSwitch")
  :bindHotkeys({
    -- Note that you can put multiple apps for one hotkey as in the following line
    -- If multiple apps in the array are open it would cycle through them
    -- If none of the apps are open it would launch the first app in the array
    [{"com.1password.1password"}] = { hyper, "1"},
    -- ditching firefox because it doesn't play nice with window resizing via "hs.grid.set()"
    [{"com.google.Chrome", "com.apple.Safari"}] = { hyper, "2"}, 
    [{"com.microsoft.VSCode"}] = {hyper, "3"},
    [{"com.apple.Terminal"}] = {hyper, "4"},
    [{"com.microsoft.onenote.mac"}] = {hyper, "5"},
    [{"com.tinyspeck.slackmacgap"}] = {hyper, "s"},
    [{"com.apple.mail"}] = {hyper, "m"},
    [{"com.apple.iCal"}] = {hyper, "c"},
    [{"com.apple.reminders"}] = {hyper, "r"},
    [{"com.apple.finder"}] = {hyper, "f"},
    --- Safari Web Apps ---
    -- My use case was using a specific view in GH Business.
    -- The problem is this also forces opening all GH Business links in this app,
    -- there seems to be no way of changing that behaviour.
    -- For now will just cycle through open browser windows.
    -- [{Config.gitAppName}] = {hyper, "g"},
})

-- Launch MS Teams / Zoom / Discord
-- Special treatment because Teams spawns multiple windows and
-- treats its users like idiots
if (Config.messagingAppName) then
  hs.hotkey.bind(hyper, "t", function()
    hs.application.launchOrFocus(Config.messagingAppName)
    -- switch from main Teams window to a second open teams window if it exists
    -- This is my MacOS settings keybind to switch to other windows of the same app
    hs.eventtap.keyStroke(hyper, "space")    
  end)
end

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
  hs.alert.show("★")
end

local function unfavorite()
  local script = [[
  tell application "Music"
    set favorited of current track to false
  end tell
  return input
  ]]
  hs.osascript.applescript(script)
  hs.alert.show("☆")
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
  hs.alert.show("👎🏻")
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
      hs.application.launchOrFocusByBundleID("com.apple.Music")
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
hs.hotkey.bind(hyper, appleMusicKey, appleMusicMode)
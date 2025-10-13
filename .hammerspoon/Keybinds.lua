require('Config')

local hyper = {"ctrl","alt","cmd","shift"}

hs.loadSpoon("LaunchSwitch")
    -- :setLogLevel("debug") -- uncomment for console debug log
  :bindHotkeys({
    -- Note that you can put multiple apps for one hotkey as in the following line
    -- If multiple apps in the array are open it would cycle through them
    -- If none of the apps are open it would launch the first app in the array
    -- [{"Calculator", "Safari" }] = { hyper, "e" }, -- multiple apps example
    [{"1Password"}] = { hyper, "1"},
    [{"Firefox", "Safari"}] = { hyper, "2"},
    [{"Visual Studio Code"}] = {hyper, "3"},
    [{"Terminal"}] = {hyper, "4"},
    [{"Microsoft OneNote"}] = {hyper, "5"},
    [{"Slack"}] = {hyper, "s"},
    [{"Mail"}] = {hyper, "m"},
    [{"Calendar"}] = {hyper, "c"},
    --- PWA Apps ---
    [{Config.gitAppName}] = {hyper, "g"},
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
hs.hotkey.bind(hyper, appleMusicKey, appleMusicMode)
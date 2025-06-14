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

teams = {
  app = nil,
  firstSeenWindow = nil
}

-- Get or cache the Teams app object
teams.ensureApp = function()
  teams.app = teams.app or hs.application.find("Microsoft Teams")
  return teams.app
end

-- Called shortly after launch to mark the main window
teams.captureMainWindow = function()
  local app = teams.ensureApp()
  if not app then return end

  hs.timer.doAfter(1.0, function()
    local allWindows = app:allWindows()
    if #allWindows > 0 then
      teams.firstSeenWindow = allWindows[1]
    end
  end)
end

-- First seen window is our main window
teams.mainWindow = function()
  return teams.firstSeenWindow
end

-- Any other window we treat as a potential call window
teams.callWindow = function()
  local app = teams.ensureApp()
  if not app then return end

  for _, win in ipairs(app:allWindows()) do
    if not teams.firstSeenWindow or win:id() ~= teams.firstSeenWindow:id() then
      return win
    end
  end
  return nil
end

teams.bringToFront = function(window)
  if window:isMinimized() then
    window:unminimize()
  end
  window:focus()
end

-- Launch Teams and focus appropriate window
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "T", function()
  local app = teams.ensureApp()

  if not app then
    hs.application.launchOrFocus("Microsoft Teams")
    return
  end

  local main = teams.mainWindow()
  local call = teams.callWindow()

  if call then
    teams.bringToFront(call)
    if main and call:id() ~= main:id() then
      main:minimize()
    end
  elseif main then
    teams.bringToFront(main)
  end
end)

-- Watch for Teams launch/quit to keep state accurate
hs.application.watcher.new(function(appName, eventType, appObj)
  if appName ~= "Microsoft Teams" then return end

  if eventType == hs.application.watcher.launched then
    teams.app = appObj
    teams.captureMainWindow()
  elseif eventType == hs.application.watcher.terminated then
    teams.app = nil
    teams.firstSeenWindow = nil
  end
end):start()


-- Automatically reload config on save
function reloadConfig(files)
  hs.reload()
end

configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

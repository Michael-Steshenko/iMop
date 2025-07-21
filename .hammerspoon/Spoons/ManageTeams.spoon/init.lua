local obj = {}
obj.__index = obj

function obj:init()
  obj.app = hs.application.find("Microsoft Teams")
  obj.mainWindow = nil
  -- if Teams is already running when reloading config, capture the window
  obj:captureMainWindow()
end

-- Called shortly after launch to mark the main window
function obj:captureMainWindow()
  if not self.app then return end

  hs.timer.doAfter(1.0, function()
    local allWindows = obj.app:allWindows()
    if #allWindows > 0 then
      self.mainWindow = allWindows[1]
    end
  end)
end

-- Any other window we treat as a potential call window
function obj:callWindow()
  if not self.app then return end

  for _, win in ipairs(self.app:allWindows()) do
    if not self.mainWindow or win:id() ~= self.mainWindow:id() then
      return win
    end
  end
  return nil
end

function obj:bringToFront(window)
  if window:isMinimized() then
    window:unminimize()
  end
  window:focus()
end

-- Launch Teams and focus appropriate window
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "T", function()
  if not obj.app then
    hs.application.launchOrFocus("Microsoft Teams")
    return
  end

  local allWindows = obj.app:allWindows()
  -- if we closed all windows force a window to open
  if #allWindows == 0 then
    hs.application.launchOrFocus("Microsoft Teams")
    -- app was already launched, so hs.application.watcher won't fire.
    -- therefore we need to manually trigger obj.mainWindow capture
    obj:captureMainWindow()
    return
  end

  local main = obj.mainWindow
  local call = obj:callWindow()

  if call then
    obj:bringToFront(call)
    if main and call:id() ~= main:id() then
      main:minimize()
    end
  elseif main then
    obj:bringToFront(main)
  end
end)


-- Add window filter to track all Teams windows
local smallWindowFilter = hs.window.filter.new(function(window)
  return window:application() == obj.app
end)

-- Watch for any changes to Teams windows
-- We want to minimize the small Teams floating window that appears when the call window loses focus
local function startWatchingForSmallWindows()
  if obj.app then
    smallWindowFilter:subscribe({hs.window.filter.windowCreated}, function(window)
      local frame = window:frame()
      -- Check if the window is smaller than 500x500
      if frame.w < 500 and frame.h < 500 then
        window:minimize()
      end
    end)
  end
end

-- Function to stop watching windows when Teams is not running
local function stopWatchingSmallWindows()
  smallWindowFilter:unsubscribe()
end

hs.application.watcher.new(function(appName, eventType, appObj)
  if appName ~= "Microsoft Teams" then return end

  -- Watch for Teams launch/quit to keep state accurate
  if eventType == hs.application.watcher.launched then
    obj.app = appObj
    obj:captureMainWindow()
    startWatchingForSmallWindows()
  elseif eventType == hs.application.watcher.terminated then
    obj.app = nil
    obj.mainWindow = nil
    stopWatchingSmallWindows()
  end
end):start()

return obj
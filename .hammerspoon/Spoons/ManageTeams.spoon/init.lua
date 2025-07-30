local obj = {}
obj.__index = obj

function obj:init()
  obj.app = hs.application.find("Microsoft Teams")
end

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
    startWatchingForSmallWindows()
  elseif eventType == hs.application.watcher.terminated then
    obj.app = nil
    stopWatchingSmallWindows()
  end
end):start()

return obj
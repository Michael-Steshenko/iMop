require('Config')

-- keyboard shortcuts
require('Keybinds')

-- Reverse mice scroll direction, skip touchpads
require('ScrollReverser')

-- Launch and manage MS Teams windows
if (not Config.disableTeams) then
  hs.loadSpoon("ManageTeams")
  spoon.ManageTeams.init()
end

-- Automatically reload config on save
function reloadConfig(files)
  hs.reload()
end

configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- Michael Steshenko:
-- Note this is a modified version of AppWindowSwitcher.spoon
-- if no windows are open matching the specified hotkey.
-- this will launch the first app in the hotkey app array.

--- === AppWindowSwitcher ===
---
--- macOS application aware, keyboard driven window switcher. Spoon 
--- on top of Hammerspoon.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/AppWindowSwitcher.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/AppWindowSwitcher.spoon.zip)
---
--- Switches windows by focusing and raising them. All windows matching a 
--- bundelID, a list of bundleID's, an application name matchtext, 
--- or a list of application name matchtexts are switched by cycling 
--- them. Cycling applies to visible windows of currently focused space 
--- only. The spoon does not launch applications, it operates on open 
--- windows of running applications.
---
--- Example `~/.hammerspoon/init.lua` configuration:
---
--- ```
--- hs.loadSpoon("AppWindowSwitcher")
---     :bindHotkeys({
---         ["com.apple.Terminal"]        = {hyper, "t"},
---         [{"com.apple.Safari",
---           "com.google.Chrome",
---           "com.kagi.kagimacOS",
---           "com.microsoft.edgemac", 
---           "org.mozilla.firefox"}]     = {hyper, "q"},
---         ["Hammerspoon"]               = {hyper, "h"},
---         [{"O", "o"}]                  = {hyper, "o"},
---     })
--- ```
--- In this example, 
--- * `hyper-t` cycles all terminal windows (matching a single bundleID),
--- * `hyper-q` cycles all windows of the five browsers (matching either 
---   of the bundleIDs)
--- * `hyper-h` brings the Hammerspoon console forward (matching the 
---   application title),
--- * `hyper-o` cycles all windows whose application title starts 
---   with "O" or "o".
---
--- The cycling logic works as follows:
--- * If the focused window is part of the application matching a hotkey,
---   then the last window (in terms of macOS windows stacking) of the matching 
---   application(s) will be brought forward and focused.
--- * If the focused window is not part of the application matching a
---   hotkey, then the first window (in terms of macOS windows stacking) i
---   of the matching applications will be brought forward and focused.

require("hs.hotkey")
require("hs.window")
require("hs.inspect")
require("hs.fnutils")
require("hs.window.filter")

local obj={}
obj.__index = obj

-- Metadata
obj.name = "AppWindowSwitcher"
obj.version = "0.0"
obj.author = "B Viefhues"
obj.homepage = "https://github.com/bviefhues/AppWindowSwitcher.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- prefix match for text. Returns true if text starts with prefix.
function obj.startswith(text, prefix)
    return text:find(prefix, 1, true) == 1
end

-- Matches window properties with matchtexts array of texts
-- Returns true if:
-- * windows application bundleID is an element of matchtexts, or
-- * windows application title starts with an element of matchtext
function obj.match(window, matchtexts)
    local app = window:application()
    if not app then return false end
    local bundleID = app:bundleID()
    if hs.fnutils.contains(matchtexts, bundleID) then
        return true
    end
    local title = app:title()
    for _, matchtext in pairs(matchtexts) do
        if obj.startswith(title, matchtext) then
            return true
        end
    end
    return false
end

-- Reuse a cached window filter for current space and visible windows
local wf = hs.window.filter.defaultCurrentSpace

--- AppWindowSwitcher:bindHotkeys(mapping) -> self
--- Method
--- Binds hotkeys for AppWindowSwitcher
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for each application to manage 
---
--- Notes:
--- The mapping table accepts these formats per table element:
--- * A single text to match:
---   `["<matchtext>"] = {mods, key}` 
--- * A list of texts, to assign multiple applications to one hotkey:
---   `[{"<matchtext>", "<matchtext>", ...}] = {mods, key}`
--- * `<matchtext>` can be either a bundleID, or a text which is substring matched against a windows application title start. 
---
--- Returns:
---  * The AppWindowSwitcher object
function obj:bindHotkeys(mapping)
    for matchtexts, modsKey in pairs(mapping) do
        if type(matchtexts) == "string" then
            matchtexts = { matchtexts }
        end

        -- Simple matcher: match either bundleID or app-name prefix
        local function matches(win)
            local app = win and win:application()
            if not app then return false end
            local bid  = app:bundleID()
            local name = app:title()
            for _, t in ipairs(matchtexts) do
                if t == bid or obj.startswith(name, t) then
                    return true
                end
            end
            return false
        end

        local mods, key = table.unpack(modsKey)

        hs.hotkey.bind(mods, key, function()
            local focused = hs.window.focusedWindow()
            local focusedMatches = focused and matches(focused)
            local newW = nil

            -- Single pass using the window.filter cache (current Space, visible)
            local ordered = wf:getWindows()
            if focusedMatches then
                for _, w in ipairs(ordered) do
                    if matches(w) then newW = w end  -- last match
                end
            else
                for _, w in ipairs(ordered) do
                    if matches(w) then newW = w; break end
                end
            end

            if newW then
                newW:raise():focus()
            else
                local target = matchtexts[1]
                if target and target:find("%.") then
                    hs.application.launchOrFocusByBundleID(target)
                else
                    hs.application.launchOrFocus(target)
                end
            end
        end)
    end

    return self
end

return obj

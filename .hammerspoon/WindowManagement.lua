hyper = Config.hyper

-- Window management
--
-- Each screen is split into vertical zones (see Config.screenGrids). Which screen is
-- north/south/east/west of another comes from the arrangement in System
-- Settings -> Displays, so hyper+h/j/k/l can also move windows across screens.

hs.window.animationDuration = 0

-- parse a { zones = {...}, home = ... } grid spec into a layout
local function parseLayout(spec)
  -- cumulative zone boundaries, e.g. zones={1,1,1} -> bounds={0,1,2,3}
  local bounds = {0}
  for i, z in ipairs(spec.zones) do
    bounds[i + 1] = bounds[i] + z
  end
  local N = #spec.zones

  -- home zone(s) hyper+j jumps to: a single 1-indexed zone, or a {start, end}
  -- range. Defaults to the middle zone (odd N) or the middle pair (even N).
  local homeStart, homeEnd
  if type(spec.home) == "table" then
    homeStart, homeEnd = spec.home[1], spec.home[2]
  elseif spec.home then
    homeStart, homeEnd = spec.home, spec.home
  elseif N % 2 == 1 then
    homeStart, homeEnd = (N + 1) / 2, (N + 1) / 2
  else
    homeStart, homeEnd = N / 2, N / 2 + 1
  end

  -- home as (i, j) boundary indices, like place()/currentCell() use
  return { bounds = bounds, N = N, W = bounds[N + 1], homeI = homeStart - 1, homeJ = homeEnd }
end

-- Config.screenGrids.defaultGrid is the fallback layout; every other key is
-- matched against screen names
local screenGrids = Config.screenGrids or {}
local defaultLayout = parseLayout(screenGrids.defaultGrid or { zones = {1, 1, 1} })
local screenLayouts = {}
for pattern, spec in pairs(screenGrids) do
  if pattern ~= "defaultGrid" then
    table.insert(screenLayouts, { pattern = pattern, layout = parseLayout(spec) })
  end
end

-- layout for a screen: the first Config.screenGrids entry whose key is a
-- substring of the screen's name, else defaultGrid
local function layoutFor(scr)
  local name = scr:name() or ""
  for _, entry in ipairs(screenLayouts) do
    if name:find(entry.pattern, 1, true) then return entry.layout end
  end
  return defaultLayout
end

-- when Config.screenGrids has per-screen entries, flag every screen none of
-- them match, on that screen, with the exact name to use as its key
local function warnUnmatchedScreens()
  if #screenLayouts == 0 then return end
  for _, scr in ipairs(hs.screen.allScreens()) do
    if layoutFor(scr) == defaultLayout then
      hs.alert.show(string.format(
        'No Config.screenGrids entry matches this screen ("%s"), using defaultGrid layout instead',
        scr:name() or "?"), {}, scr, 6)
    end
  end
end
warnUnmatchedScreens()
-- global so it isn't garbage collected; re-check when displays are plugged in
unmatchedScreenWatcher = hs.screen.watcher.new(warnUnmatchedScreens):start()

-- frame of the cell spanning zone-boundaries [i, j] on scr. Edges are
-- floored to whole points so adjacent cells tile without gaps or overlap.
local function cellFrame(scr, layout, i, j)
  local sf = scr:frame()
  local cellW = sf.w / layout.W
  local x0 = math.floor(sf.x + layout.bounds[i + 1] * cellW)
  local x1 = math.floor(sf.x + layout.bounds[j + 1] * cellW)
  return hs.geometry.rect(x0, sf.y, x1 - x0, sf.h)
end

-- move the focused window to the cell spanning zone-boundaries [i, j] of scr
-- (defaults to the window's current screen)
local function place(i, j, scr)
  local win = hs.window.focusedWindow()
  if not win then return end
  if scr and scr ~= win:screen() then
    -- move first so macOS doesn't clamp the new size to the old screen
    win:moveToScreen(scr)
  end
  scr = scr or win:screen()
  win:setFrame(cellFrame(scr, layoutFor(scr), i, j))
end

-- the focused window, its screen, that screen's layout, and the (i, j)
-- boundary indices of the window's current cell (i, j are nil if its frame
-- doesn't line up with zone boundaries)
local function currentCell()
  local win = hs.window.focusedWindow()
  local scr = win and win:screen()
  if not scr then return nil end
  local layout = layoutFor(scr)
  local winFrame = win:frame()
  for i = 0, layout.N - 1 do
    for j = i + 1, layout.N do
      local target = cellFrame(scr, layout, i, j)
      -- apps may nudge frames by a fraction of a point; anything at or
      -- beyond 1pt is a real offset
      if math.abs(winFrame.x - target.x) < 1 and math.abs(winFrame.w - target.w) < 1
          and math.abs(winFrame.y - target.y) < 1 and math.abs(winFrame.h - target.h) < 1 then
        return win, scr, layout, i, j
      end
    end
  end
  return win, scr, layout, nil, nil
end

-- neighbouring screen per the System Settings arrangement. Strict mode skips
-- screens that don't overlap on the perpendicular axis, so e.g. a laptop
-- below the monitor never counts as "west" of it.
local function neighbour(win, scr, direction)
  return scr["to" .. direction](scr, win:frame(), true)
end

-- window hyper+j just minimized. hyper+k restores it, but only while hyper is
-- still held down since the minimize. Polls the modifier state instead of
-- watching flagsChanged with an eventtap, because secure input silently kills
-- keyboard eventtaps (see SecureInput.lua).
local restorable, releaseTimer
local function forgetRestorable()
  restorable = nil
  if releaseTimer then releaseTimer:stop() end
end
local function hyperHeld()
  local mods = hs.eventtap.checkKeyboardModifiers()
  for _, mod in ipairs(hyper) do
    if not mods[mod] then return false end
  end
  return true
end
local function minimizeRestorable(win)
  win:minimize()
  restorable = win
  releaseTimer = releaseTimer or hs.timer.new(0.05, function()
    if not hyperHeld() then forgetRestorable() end
  end)
  releaseTimer:start()
end

-- hyper + h/j/k/l
hs.hotkey.bind(hyper, "h", function() -- left: shift a single zone left, collapse to own leftmost zone, or move to the screen to the west
  local win, scr, layout, i, j = currentCell()
  if not win then return end
  if not i then place(0, 1) return end
  if j - i > 1 then
    place(i, i + 1) -- collapse to own leftmost zone
  elseif i > 0 then
    place(i - 1, j - 1) -- shift left
  else
    local west = neighbour(win, scr, "West")
    if west then
      local N = layoutFor(west).N
      place(N - 1, N, west) -- rightmost zone of the screen to the west
    end
  end
end)
hs.hotkey.bind(hyper, "j", function() -- down: jump to the home zone(s), or if already there, move to the screen below (minimize on the bottom screen)
  local win, scr, layout, i, j = currentCell()
  if not win then return end
  if i == layout.homeI and j == layout.homeJ then
    local south = neighbour(win, scr, "South")
    if south then
      local southLayout = layoutFor(south)
      place(southLayout.homeI, southLayout.homeJ, south)
    else
      minimizeRestorable(win) -- bottom screen: minimize, hyper+k undoes it until hyper is released
    end
    return
  end
  place(layout.homeI, layout.homeJ)
end)
hs.hotkey.bind(hyper, "k", function() -- up: grow toward full screen, or if already full, move to the screen above
  if restorable then -- undo a hyper+j minimize, hyper still held since
    local win = restorable
    forgetRestorable()
    win:unminimize()
    win:focus()
    return
  end
  local win, scr, layout, i, j = currentCell()
  if not win then return end
  local N = layout.N
  if not i then place(0, N) return end
  local canGrowLeft, canGrowRight = i > 0, j < N
  if not canGrowLeft and not canGrowRight then
    local north = neighbour(win, scr, "North")
    if north then
      local northLayout = layoutFor(north)
      place(northLayout.homeI, northLayout.homeJ, north)
    end
  elseif canGrowLeft and not canGrowRight then
    place(i - 1, j)
  elseif canGrowRight and not canGrowLeft then
    place(i, j + 1)
  else
    -- both sides have room: prefer whichever grow reaches a screen edge on
    -- this step; if both would, or neither would, it's genuinely ambiguous
    local leftAnchors, rightAnchors = i - 1 == 0, j + 1 == N
    if leftAnchors and not rightAnchors then place(i - 1, j)
    elseif rightAnchors and not leftAnchors then place(i, j + 1)
    else place(0, N)
    end
  end
end)
hs.hotkey.bind(hyper, "l", function() -- right: shift a single zone right, collapse to own rightmost zone, or move to the screen to the east
  local win, scr, layout, i, j = currentCell()
  if not win then return end
  local N = layout.N
  if not i then place(N - 1, N) return end
  if j - i > 1 then
    place(j - 1, j) -- collapse to own rightmost zone
  elseif j < N then
    place(i + 1, j + 1) -- shift right
  else
    local east = neighbour(win, scr, "East")
    if east then
      place(0, 1, east) -- leftmost zone of the screen to the east
    end
  end
end)

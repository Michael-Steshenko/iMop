hyper = Config.hyper

-- Window management
myGrid = Config.grid

-- cumulative zone boundaries, e.g. zones={1,1,1} -> bounds={0,1,2,3}
local bounds = {0}
for i, z in ipairs(myGrid.zones) do
  bounds[i + 1] = bounds[i] + z
end
local N = #myGrid.zones
local W = bounds[N + 1]
local H = myGrid.h

-- home zone(s) hyper+j jumps to: a single 1-indexed zone, or a {start, end}
-- range. Defaults to the middle zone (odd N) or the middle pair (even N).
local homeStart, homeEnd
if type(myGrid.home) == "table" then
  homeStart, homeEnd = myGrid.home[1], myGrid.home[2]
elseif myGrid.home then
  homeStart, homeEnd = myGrid.home, myGrid.home
elseif N % 2 == 1 then
  homeStart, homeEnd = (N + 1) / 2, (N + 1) / 2
else
  homeStart, homeEnd = N / 2, N / 2 + 1
end

Install:andUse(
  "WindowGrid",
  {
    config = { gridGeometries =
                { { W .."x" .. H } } },
    --hotkeys = {show_grid = {hyper, "g"}}, -- enable for debugging
    start = true,
  }
)
hs.grid.setMargins({0,0})
hs.window.animationDuration = 0

-- move the focused window to the cell spanning zone-boundaries [i, j]
local function place(i, j)
  local win = hs.window.focusedWindow()
  if not win then return end
  local cell = {x = bounds[i + 1], y = 0, w = bounds[j + 1] - bounds[i + 1], h = H}
  hs.grid.set(win, cell)
end

-- (i, j) boundary indices of the focused window's current cell, or nil
local function currentCell()
  local win = hs.window.focusedWindow()
  local cur = win and hs.grid.get(win)
  if not cur then return nil end
  for i = 0, N - 1 do
    for j = i + 1, N do
      if cur.x == bounds[i + 1] and cur.y == 0
        and cur.w == bounds[j + 1] - bounds[i + 1] and cur.h == H then
        return i, j
      end
    end
  end
  return nil
end

-- hyper + h/j/k/l
hs.hotkey.bind(hyper, "h", function() -- left: shift a single zone left, or collapse to own leftmost zone
  local i, j = currentCell()
  if not i then place(0, 1) return end
  if j - i == 1 then
    if i > 0 then place(i - 1, j - 1) end -- shift left (no-op at zone 1)
  else
    place(i, i + 1) -- collapse to own leftmost zone
  end
end)
hs.hotkey.bind(hyper, "j", function() -- down: jump to the home zone(s)
  place(homeStart - 1, homeEnd)
end)
hs.hotkey.bind(hyper, "k", function() -- up: grow toward full screen
  local i, j = currentCell()
  if not i then place(0, N) return end
  local canGrowLeft, canGrowRight = i > 0, j < N
  if not canGrowLeft and not canGrowRight then
    return -- already full, no-op
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
hs.hotkey.bind(hyper, "l", function() -- right: shift a single zone right, or collapse to own rightmost zone
  local i, j = currentCell()
  if not i then place(N - 1, N) return end
  if j - i == 1 then
    if j < N then place(i + 1, j + 1) end -- shift right (no-op at last zone)
  else
    place(j - 1, j) -- collapse to own rightmost zone
  end
end)

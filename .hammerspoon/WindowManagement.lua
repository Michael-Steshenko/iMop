-- Window management
-- 3 zones, left, middle and right
-- if w > 100 it defaults to 100.
myGrid = { w = 100, h = 1, left = 23, middle = 56, right = nil}
myGrid.right = myGrid.w - myGrid.left - myGrid.middle

Install:andUse(
  "WindowGrid",
  {
    config = { gridGeometries =
                { { myGrid.w .."x" .. myGrid.h } } },
    hotkeys = {show_grid = {{"ctrl", "alt", "cmd", "shift"}, "g"}},
    start = true,
  }
)
hs.grid.setMargins({0,0})

-- helper to move the focused window into a given cell
local function place(cell)
  local win = hs.window.focusedWindow()
  if win then hs.grid.set(win, cell) end
end

-- hyper + h/j/k/l                                                 
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "h", function() -- left
  place({x = 0, y = 0, w = myGrid.left, h = myGrid.h})
end)
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "j",  function() -- middle
   place({x = myGrid.left, y = 0, w = myGrid.middle, h = myGrid.h})
end)
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "k", function() -- full screen
  place({x = 0, y = 0, w = myGrid.w, h = myGrid.h})
end) 
hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "l", function() -- right
  place({x = myGrid.left + myGrid.middle, y = 0, w = myGrid.right, h = myGrid.h})
end)
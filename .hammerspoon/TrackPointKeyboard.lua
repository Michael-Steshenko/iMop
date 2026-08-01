-- =========================================================
-- TrackPoint Keyboard II: Smart Middle Click (Hardware Scroll)
-- =========================================================
local clickDelay = 0.02 -- Wait 20ms to see if scroll events arrive
local triggerKeyCode = 90 -- f20, map mouse button 3 to f20 in Karabiner

local clickTimer = nil

-- IMPORTANT: Must be a global variable, otherwise Lua garbage collects the eventtap immediately!
trackPointMouseTap = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp,
    hs.eventtap.event.types.scrollWheel
}, function(e)
    local eventType = e:getType()

    -- 1. F20 PRESSED
    if eventType == hs.eventtap.event.types.keyDown and e:getKeyCode() == triggerKeyCode then
        -- Cancel any pending clicks just in case
        if clickTimer then
            clickTimer:stop()
            clickTimer = nil
        end
        return true -- Swallow the F20 key press
    end

    -- 2. F20 RELEASED
    if eventType == hs.eventtap.event.types.keyUp and e:getKeyCode() == triggerKeyCode then
        -- Start a tiny timer. If no scrolling happens, we click!
        local pos = hs.mouse.absolutePosition()
        clickTimer = hs.timer.doAfter(clickDelay, function()
            clickTimer = nil
            
            -- Synthesize a real middle click
            local clickDown = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseDown, pos)
            clickDown:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)
            
            local clickUp = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.otherMouseUp, pos)
            clickUp:setProperty(hs.eventtap.event.properties.mouseEventButtonNumber, 2)

            clickDown:post()
            -- 20ms delay ensures browsers register the click
            hs.timer.doAfter(0.02, function()
                clickUp:post()
            end)
        end)
        
        return true -- Swallow the F20 key release
    end

    -- 3. SCROLLING DETECTED
    if eventType == hs.eventtap.event.types.scrollWheel then
        -- If the hardware starts scrolling, cancel the pending click!
        if clickTimer then
            clickTimer:stop()
            clickTimer = nil
        end
        return false -- Let the native scroll events pass through normally
    end

    return false
end)

trackPointMouseTap:start()

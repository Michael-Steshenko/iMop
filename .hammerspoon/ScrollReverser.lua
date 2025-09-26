-- event:setProperty doesn't affect iPhone Mirroring app..
-- This means that even if we try to reverse scroll based on open app,
-- scroll direction will be wrong with either mouse or touchpad
-- depenting on natural scroll setting
-- Solution 1: Setting settings natural scroll toggle - too hacky
-- Solution 2: Use Karabiner because it's operation on a lower level
-- But this requires a on device basis settings.
-- For now we wait for Apple to fix this..

-- reverse mouse scroll, skip if trackpad
reverse_mouse_scroll = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    -- detect if this is touchpad or mouse
    local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)
    if isTrackpad == 1 then
        return false -- trackpad: pass the event along
    end

    event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
    return false -- pass the event along
end):start()
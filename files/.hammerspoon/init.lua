hs.loadSpoon("ShiftIt")
spoon.ShiftIt:bindHotkeys({})

hs.window.animationDuration = 0
units = {
    right50       = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
    left50        = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
    full          = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
}

mash = { 'option', 'command' }
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, 'left', function() hs.window.focusedWindow():move(units.left50, nil, true) end)
hs.hotkey.bind(mash, 'M', function() hs.window.focusedWindow():move(units.full, nil, true) end)

for i = 1, 3 do
    hs.hotkey.bind({"cmd", "alt"}, tostring(i), function()
        local screens = hs.screen.allScreens()
        if #screens >= i then
            local focusedWindow = hs.window.frontmostWindow()
            if focusedWindow then
                focusedWindow:moveToScreen(screens[i])
            end
        end
    end)

    hs.hotkey.bind({"alt"}, tostring(i), function()
        local screens = hs.screen.allScreens()
        if i >= 1 and i <= #screens then
            local targetScreen = screens[i]
            local frame = targetScreen:frame()
            
            -- ディスプレイの中央座標にカーソルを移動させる
            local x = frame.x + frame.w / 2
            local y = frame.y + frame.h / 2
            hs.mouse.setAbsolutePosition({x = x, y = y})
        end
    end)
end

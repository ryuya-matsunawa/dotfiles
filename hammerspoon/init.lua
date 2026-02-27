hs.window.animationDuration = 0
units = {
    right50       = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
    left50        = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
    topright  = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
    topleft   = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
    botright  = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 },
    botleft   = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
    full          = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
}

mash = { 'option', 'command' }
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, 'left', function() hs.window.focusedWindow():move(units.left50, nil, true) end)
hs.hotkey.bind(mash, 'f1', function() hs.window.focusedWindow():move(units.topleft, nil, true) end)
hs.hotkey.bind(mash, 'f2', function() hs.window.focusedWindow():move(units.topright, nil, true) end)
hs.hotkey.bind(mash, 'f3', function() hs.window.focusedWindow():move(units.botleft, nil, true) end)
hs.hotkey.bind(mash, 'f4', function() hs.window.focusedWindow():move(units.botright, nil, true) end)
hs.hotkey.bind(mash, 'M', function() hs.window.focusedWindow():move(units.full, nil, true) end)

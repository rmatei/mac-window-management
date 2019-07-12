-- WINDOW MOVER
laptopMinWidth = 1280
laptopMaxWidth = 1440
defaultBuffer = 15

-- Set mode, settings & shortcuts based on current screen config
function loadCurrentScreenSettings()
  screens = hs.screen.allScreens()

  if #screens == 1 then
    hs.alert.show("Single-screen mode")
    mode = 'laptop'
    mainScreen = screens[1]
    laptopScreen = mainScreen
    buffer = 0
  else
    -- Ultrawide 30" is 3440x1440
    hs.alert.show("2-screen mode")
    mainScreen = screens[2]
    sideScreen = screens[1]
    laptopScreen = sideScreen
    mode = 'external'
    buffer = defaultBuffer
  end

  -- Settings

  left30 = {x1=0, w=0.3}
  mid40 = {x1=0.3, w=0.4}
  right30 = {x1=0.7, w=0.3}
  top50 = {y1=0, h=0.5}
  bottom50 = {y1=0.5, h=0.5}
  top33 = {y1=0, h=1/3}
  mid33 = {y1=1/3, h=1/3}
  bottom33 = {y1=0.666, h=0.333}

  left50 = {x1=0, w=0.5}
  right50 = {x1=0.5, w=0.5}

  fullw = {x1=0, w=1}
  fullh = {y1=0, h=1}

  -- Set different settings for single screen vs. 2
  settings = {}
  if mode == "laptop" then
    -- Laptop only
    settings["default"] = {mainScreen, merge(fullw, fullh)}
  else
    -- External monitor
    center = {mainScreen, {x1=0.3, w=0.4, y1=0, h=1}}
    left = {mainScreen, {x1=0, w=0.3, y1=0, h=1}}
    right = {mainScreen, {x1=0.7, w=0.3, y1=0, h=1}}

    topLeft = {mainScreen, {x1=0, w=0.3, y1=0, h=0.5}}
    bottomLeft = {mainScreen, {x1=0, w=0.3, y1=0.5, h=0.5}}
    topRight = {mainScreen, {x1=0.7, w=0.3, y1=0, h=0.5}}
    bottomRight = {mainScreen, {x1=0.7, w=0.3, y1=0.5, h=0.5}}

    -- Main work apps
    settings["default"] = center
    settings["OmniFocus"] = {mainScreen, {x1=0, w=0.4, y1=0, h=1}}

    -- Dev companions
    settings["Activity Monitor"] = topRight
    settings["Finder"] = topRight
    settings["Hammerspoon"] = bottomRight
    settings["Terminal"] = sideScreen

    -- Non-dev companions
    settings["Contacts"] = topRight -- {mainScreen, {x1=0.3, w=0.4, y1=0, h=0.4}}
    settings["Messages"] = center -- {mainScreen, {x1=0.3, w=0.4, y1=0.4, h=0.6}}
    settings["WhatsApp"] = center -- {mainScreen, {x1=0.3, w=0.4, y1=0.4, h=0.6}}
    settings["Google Calendar"] = right
    settings["Calendar"] = right

    -- Helper / reference apps
    -- settings["Google Chrome"] = {mainScreen, merge(mid40, fullh)}
    -- settings["Safari"] = {mainScreen, merge(mid40, fullh)}

    -- Non-task related companions
    settings["OmniFocus"] = {sideScreen, maximized}
    settings["iTunes"] = {sideScreen, merge(fullw, fullh)}
    settings["Spotify"] = {sideScreen, merge(fullw, fullh)}
  end

  -- Shortcuts
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "l", function()
    -- Apply settings to all windows on screen
    hs.alert.show("Arranging all...")
    processAllWindows()
  end)
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "t", function()
    -- Apply to just this window
    processWindow(hs.window.frontmostWindow())
  end)
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "h", function()
    hideAllWindows()
  end)
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "q", function()
    quitAll()
  end)

  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "m", function()
    resizeWindow(hs.window.frontmostWindow(), {mainScreen, merge(fullw, fullh)})
  end)
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function()
    centerWindow(hs.window.frontmostWindow())
  end)

  -- if mode == 'laptop' then
    -- Halves
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, merge(left50, fullh)})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, merge(right50, fullh)})
    end)
  -- else
    -- Thirds
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "1", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, merge(left30, fullh)})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "2", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, merge(mid40, fullh)})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "3", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, merge(right30, fullh)})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "0", function()
      resizeWindow(hs.window.frontmostWindow(), {sideScreen, merge(fullw, fullh)})
    end)
  -- end
end
function merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end
loadCurrentScreenSettings()


-- FLOW SYSTEM SHORTCUTS

hs.hotkey.bind({"ctrl", "shift"}, "0", function()
  hs.execute("osascript ~/Drive/Code/Flow/Task.suggest.anyinblock.start.js")
end)

hs.hotkey.bind({"ctrl", "shift"}, "-", function()
  hs.execute("osascript ~/Drive/Code/Flow/Task.suggest.any.start.js")
end)

hs.hotkey.bind({"ctrl", "shift"}, "=", function()
  hs.execute("osascript ~/Drive/Code/Flow/Task.suggest.flow.start.js")
end)

-- hs.hotkey.bind({"ctrl", "shift"}, "[", function()
--   hs.execute("osascript ~/Drive/Code/Flow/Task.start.js")
-- end)

-- hs.hotkey.bind({"ctrl", "shift"}, "[", function()
--   hs.execute("osascript ~/Drive/Code/Flow/Task.start.AT.js")
-- end)

-- hs.hotkey.bind({"ctrl", "shift"}, "]", function()
--   hs.execute("osascript ~/Drive/Code/Flow/Task.end.js")
-- end)

-- hs.hotkey.bind({"ctrl", "shift"}, "\\", function()
--   hs.execute("osascript ~/Drive/Code/Flow/Task.complete.js")
-- end)


-- DEV WORKFLOW
hs.hotkey.bind({"ctrl", "shift"}, "/", function()
  hs.execute("osascript ~/Drive/Code/Flow/Dev.rerun.command.js")
end)


-- APP SPECIFIC SHORTCUTS
appShortcuts = {}
appShortcuts["Safari"] = {
  {{"command", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"command", "option"}, "right", {"Window", "Show Next Tab"}},
}
appShortcuts["Terminal"] = {
  {{"command", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"command", "option"}, "right", {"Window", "Show Next Tab"}},
}
appShortcuts["OmniFocus"] = {
  {{"command", "shift"}, "v", {"Edit", "Paste and Match Style"}},
  {{"command", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"command", "option"}, "right", {"Window", "Show Next Tab"}},
}
currentAppShortcuts = {}

-- Define a callback function to be called when application events happen
function applicationWatcherCallback(appName, eventType, appObject)
  if (appShortcuts[appName] ~= nil) then
    if (eventType == hs.application.watcher.activated) then
      -- hs.alert.show("Enabling " .. appName)
      currentAppShortcuts[appName] = {}
      for key, shortcut in pairs(appShortcuts[appName]) do
        hotkey = hs.hotkey.new(shortcut[1], shortcut[2], nil, function()
          appObject:selectMenuItem(shortcut[3])
        end)
        hotkey:enable()
        currentAppShortcuts[appName][#currentAppShortcuts[appName]+1]=hotkey
      end

    elseif (eventType == hs.application.watcher.deactivated or eventType == hs.application.watcher.terminated) then
      -- hs.alert.show("Disabling " .. appName)
      for key, hotkey in pairs(currentAppShortcuts[appName]) do
        hotkey:disable()
      end
      currentAppShortcuts[appName] = nil
    end
  end
end
watcher = hs.application.watcher.new(applicationWatcherCallback)
watcher:start()



-- APP STARTER SHORTCUTS
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "v", function()
  hs.application.open("Visual Studio Code")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "g", function()
  hs.application.open("Google Chrome")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "e", function()
  hs.application.open("Evernote")
end)



-- WINDOW PROCESSING

function processAllWindows()
  for i, window in pairs(hs.window.allWindows()) do
    processWindow(window)
  end
end

function processWindow(window)
  -- hs.alert.show(window:application():name())
  if (settings[window:title()] ~= nil) then
    -- Try lookup by window title first - allows for more specific customization & makes Chrome Apps able to have separate settings than Chrome
    resizeWindow(window, settings[window:title()])
  elseif (settings[window:application():name()] ~= nil) then
    resizeWindow(window, settings[window:application():name()])
  else
    defaultBehavior(window)
  end
end

function defaultBehavior(window)
  if (window:size().w < (laptopWidth/2 - 2*defaultBuffer)) then -- consider a window custom-sized if it's less smaller than fullscreen, and don't maximize
    centerWindow(window)
  else
    resizeWindow(window, settings["default"])
  end
end

function centerWindow(window)
  -- hs.alert.show("Centering")
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  currentHeight = windowFrame.y2 - windowFrame.y1
  screenFrame = mainScreen:frame()
  hOffset = ((screenFrame.x2 - screenFrame.x1) - currentWidth) / 2
  vOffset = ((screenFrame.y2 - screenFrame.y1) - currentHeight) / 2
  -- window:setFrame(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
  window:move(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
end

function resizeWindow(window, appSettings)
  -- hs.alert.show("Resizing")
  window:setFrame(settingsToFrame(appSettings))
end

-- example args: {screen, {x1=0, y1=0, w=1/2, h=1}}
function settingsToFrame (args)
  screenFrame = args[1]:frame()
  screenWidth = screenFrame.x2 - screenFrame.x1
  screenHeight = screenFrame.y2 - screenFrame.y1
  x1 = screenFrame.x1 + args[2].x1 * screenWidth
  y1 = screenFrame.y1 + args[2].y1 * screenHeight
  w = args[2].w * screenWidth
  h = args[2].h * screenHeight

  if args[2].x1 == 0 then
    -- If starting on left edge add full buffer
    x1 = x1 + buffer
    w = w - buffer
  else
    x1 = x1 + buffer / 2
    w = w - buffer / 2
  end
  if args[2].y1 == 0 then
    -- If starting on top edge add full buffer
    y1 = y1 + buffer
    h = h - buffer
  else
    y1 = y1 + buffer / 2
    h = h - buffer / 2
  end
  if args[2].x1 + args[2].w == 1 then
    -- If ending on right edge add full buffer
    w = w - buffer
  else
    w = w - buffer/2
  end
  if args[2].y1 + args[2].h == 1 then
    -- If ending on bottom edge add full buffer
    h = h - buffer
  else
    h = h - buffer/2
  end

  return hs.geometry.rect({x=x1, y=y1, w=w, h=h})
end



-- OTHER HOUSEKEEPING COMMANDS

function quitAll()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    if (app ~= "Electron" and app ~= "Chromium" and app ~= "Hammerspoon" and app ~= "Spotify" and app ~= "Code" and app ~= "Notification Center" and app ~= "Tyme 2" and app ~= "Activity Monitor") then
      hs.alert.show("Killing " .. app)
      window:application():kill()
    end
  end

  -- sleep(0.5)
  -- hs.application.find("Chrome"):kill9()
end

function hideAllWindows()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    if (app ~= "OmniFocus" and app ~= "Terminal") then
      window:application():hide()
    end
  end
end



-- MANAGE / WATCH / RELOAD

-- When new app is launched
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.launched) then
    -- Workaround for localized apps - windows belong to Chrome
    if string.find(appObject:path(), "Chrome Apps") then
      appObject = hs.application.find("Chrome")
    end

    sleep(0.25) -- Needed to catch it sometimes
    windows = appObject:allWindows()
    for i, window in pairs(windows) do
      processWindow(window)
    end
  end
  -- if (eventType == hs.application.watcher.activated) then
    -- processWindow(hs.window.frontmostWindow())
  -- end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- When screens are switched
function screenWatcher()
  loadCurrentScreenSettings()
  processAllWindows()
end
scrWatcher = hs.screen.watcher.new(screenWatcher)
scrWatcher:start()

-- Automatically reload config when the file is saved (from examples)
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config reloaded")
-- hs.loadSpoon("ReloadConfiguration") -- alternate that doesn't alert
-- spoon.ReloadConfiguration:start()



-- HELPERS

-- Table pretty printer
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

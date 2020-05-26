-- WINDOW MANAGEMENT

-- First, some boilerplate to load different settings based on whether 1 or 2 screens are connected...
function loadCurrentScreenSettings()
  settings = {}

  screens = hs.screen.allScreens()
  if #screens == 1 then
    mode = 'laptop'
    mainScreen = screens[1]
    sideScreen = mainScreen
    buffer = 0
  else
    -- IMPORTANT: whichever screen menubar is assigned to (from Mac display settings) is considered the big monitor. 
    -- If your setup is reversed, then switch 1 and 2. 
    mainScreen = screens[1]
    sideScreen = screens[2]
    mode = 'external'
    buffer = 15
  end

  -- WINDOW MANAGEMENT: Actual config
  -- Specify a frame, 
  -- a global shortcut to send current window there (optional)
  -- & any apps assigned to that frame by default

  -- Even halves
  left = {mainScreen, {x1=0, w=0.5, y1=0, h=1}}
  right = {mainScreen, {x1=0.5, w=0.5, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", function()
    resizeWindow(hs.window.frontmostWindow(), left)
  end)
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", function()
    resizeWindow(hs.window.frontmostWindow(), right)
  end)
  
  -- Uneven halves
  leftBig = {mainScreen, {x1=0, w=0.6, y1=0, h=1}}
  rightSmall = {mainScreen, {x1=0.6, w=0.4, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "left", function()
    resizeWindow(hs.window.frontmostWindow(), leftBig)
  end)
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "right", function()
    resizeWindow(hs.window.frontmostWindow(), rightSmall)
  end)
  settings["Code"] = leftBig

  -- Maximize on main screen
  maximized = {mainScreen, {x1=0, w=1, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "m", function()
    resizeWindow(hs.window.frontmostWindow(), maximized)
  end)
  
  -- Center on main screen
  centerBig = {mainScreen, {x1=0.25, w=0.5, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function()
    resizeWindow(hs.window.frontmostWindow(), centerBig)
  end)

  -- Small apps
  if mode == "laptop" then
    centerSmall = {mainScreen, {x1=1/6, w=2/3, y1=1/6, h=2/3}}
  else
    centerSmall = {mainScreen, {x1=0.3, w=0.4, y1=1/6, h=2/3}}
  end
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "s", function()
    resizeWindow(hs.window.frontmostWindow(), centerSmall)
  end)
  settings["Preview"] = centerSmall
  settings["Finder"] = centerSmall
  settings["Contacts"] = centerSmall
  settings["WhatsApp"] = centerSmall
  settings["Slack"] = centerSmall
  settings["Facebook Messenger"] = centerSmall

  -- Maximize on side screen (companions when in 2-screen mode)
  side = {sideScreen, {x1=0, w=1, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "0", function()
    resizeWindow(hs.window.frontmostWindow(), side)
  end)
  settings["iTunes"] = side
  settings["Spotify"] = side
  settings["Chromium"] = side

  -- Default for apps not otherwise specified
  if mode == "laptop" then
    -- Laptop: fullscreen
    settings["default"] = maximized
    hs.alert.show("Laptop mode")
  else
    -- 2 screens: at the center of main monitor, decide where to send it
    settings["default"] = centerBig
    hs.alert.show("2-screen mode")
  end
end
loadCurrentScreenSettings()



-- WINDOW MANAGEMENT: Methods to process this or all windows

-- [Q]uit all non-essential programs
function quitAll()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    if (app ~= "Electron" and app ~= "Chromium" and app ~= "Hammerspoon" and app ~= "Spotify" and app ~= "Code" and app ~= "Notification Center" and app ~= "Tyme 2" and app ~= "Activity Monitor") then
      hs.alert.show("Killing " .. app)
      window:application():kill()
    end
  end
  -- sleep(0.5) -- When using Chrome Apps, they won't all shut down normally. 
  -- hs.application.find("Chrome"):kill9()
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "q", function()
  quitAll()
end)

-- [H]ide all windows
function hideAllWindows()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    if (app ~= "OmniFocus" and app ~= "Terminal") then
      window:application():hide()
    end
  end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "h", function() 
  hideAllWindows()
end)

-- Resize [A]ll windows according to settings
function processAllWindows()
  hs.alert.show("Arranging all...")
  for i, window in pairs(hs.window.allWindows()) do
    processWindow(window)
  end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "a", function()
  processAllWindows()
end)

-- Resize just [T]his active window
function processWindow(window)
  -- hs.alert.show("Arranging " .. window:application():name())
  app = window:application():name()
  -- if (settings[window:title()] ~= nil) then
    -- Try lookup by window title first - allows for more specific customization & makes Chrome Apps able to have separate settings than Chrome
    -- hs.alert.show(app .. " ->  by title -> " .. window:title())
    -- resizeWindow(window, settings[window:title()])
  if (settings[app]) then
    hs.alert.show(app .. " ->  by name")
    resizeWindow(window, settings[app])
  else
    hs.alert.show(app .. " ->  default")
    resizeWindow(window, settings["default"])
  end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "t", function()
  processWindow(hs.window.frontmostWindow())
end)

-- [C]enter this window
-- function centerWindow(window)
--   hs.alert.show("Centering")
--   windowFrame = window:frame()
--   currentWidth = windowFrame.x2 - windowFrame.x1
--   currentHeight = windowFrame.y2 - windowFrame.y1
--   screenFrame = mainScreen:frame()
--   hOffset = ((screenFrame.x2 - screenFrame.x1) - currentWidth) / 2
--   vOffset = ((screenFrame.y2 - screenFrame.y1) - currentHeight) / 2
--   -- window:setFrame(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
--   window:move(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
-- end
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function()
--   centerWindow(hs.window.frontmostWindow())
-- end)



-- WINDOW MANAGEMENT: Hooks to watch and process

-- When new app is launched
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.launched) then
    -- Workaround for Chrome apps - windows belong to Chrome
    -- if string.find(appObject:path(), "Chrome Apps") then
    --   appObject = hs.application.find("Chrome")
    -- end

    sleep(0.25) -- Needed to catch it sometimes
    windows = appObject:allWindows()
    for i, window in pairs(windows) do
      processWindow(window)
    end
  end
  -- For some apps that don't launch, process on activation
  if (eventType == hs.application.watcher.activated) then
    if (appObject:name() == "Finder") then
      processWindow(hs.window.frontmostWindow())
    end
  end
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
-- hs.loadSpoon("ReloadConfiguration") -- alternate that doesn't alert
-- spoon.ReloadConfiguration:start()



-- SHORTCUTS TO START/FOCUS APPS

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "v", function()
  hs.application.open("Visual Studio Code")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "g", function()
  hs.application.open("Google Chrome")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "e", function()
  hs.application.open("Evernote")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "m", function()
  hs.application.open("Messages")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "l", function()
  hs.application.open("Calendar")
end)



-- ADD CUSTOM SHORTCUTS TO APPS

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



-- HELPERS

-- Take a window size target and turn it into a "Frame" we can give Hammerspoon
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

-- Actually resize a window
function resizeWindow(window, appSettings)
  window:setFrame(settingsToFrame(appSettings))
end

-- Wait
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

-- Table pretty printer for debugging
-- function dump(o)
--    if type(o) == 'table' then
--       local s = '{ '
--       for k,v in pairs(o) do
--          if type(k) ~= 'number' then k = '"'..k..'"' end
--          s = s .. '['..k..'] = ' .. dump(v) .. ','
--       end
--       return s .. '} '
--    else
--       return tostring(o)
--    end
-- end

-- Table merger for window settings
-- function merge(t1, t2)
--   for k, v in pairs(t2) do
--     if (type(v) == "table") and (type(t1[k] or false) == "table") then
--       merge(t1[k], t2[k])
--     else
--       t1[k] = v
--     end
--   end
--   return t1
-- end
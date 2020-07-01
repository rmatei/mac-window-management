-- WINDOW MANAGEMENT

-- First, some boilerplate to load different settings based on whether 1 or 2 screens are connected...
function loadCurrentScreenSettings()
  appSettings = {}

  screens = hs.screen.allScreens()
  if #screens == 1 then
    mode = "laptop"
    mainScreen = screens[1]
    sideScreen = mainScreen
    buffer = 0
  else
    -- IMPORTANT: whichever screen menubar is assigned to (from Mac display settings) is considered the big monitor.
    -- If your setup is reversed, then switch 1 and 2.
    mainScreen = screens[1]
    sideScreen = screens[2]
    mode = "external"
    buffer = 15
  end

  -- WINDOW MANAGEMENT: Actual config
  -- Specify a frame,
  -- a global shortcut to send current window there (optional)
  -- & any apps assigned to that frame by default

  -- Halves
  if mode == "external" then
    leftBig = {mainScreen, {x1=0, w=0.6, y1=0, h=1}}
    rightSmall = {mainScreen, {x1=0.6, w=0.4, y1=0, h=1}}
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), leftBig)
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), rightSmall)
    end)
    appSettings["Code"] = leftBig
    appSettings["Calendar"] = rightSmall
    appSettings["Electron"] = rightSmall
    appSettings["Local Graph"] = rightSmall
    appSettings["Evernote"] = rightSmall
  else
    left = {mainScreen, {x1=0, w=0.5, y1=0, h=1}}
    right = {mainScreen, {x1=0.5, w=0.5, y1=0, h=1}}
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), left)
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), right)
    end)
  end
  -- leftBig = {mainScreen, {x1=0, w=0.6, y1=0, h=1}}
  -- rightSmall = {mainScreen, {x1=0.6, w=0.4, y1=0, h=1}}
  -- hs.hotkey.bind({"cmd", "shift", "ctrl"}, "left", function()
  --   resizeWindow(hs.window.frontmostWindow(), leftBig)
  -- end)
  -- hs.hotkey.bind({"cmd", "shift", "ctrl"}, "right", function()
  --   resizeWindow(hs.window.frontmostWindow(), rightSmall)
  -- end)
  -- if mode == "external" then
  --   appSettings["Code"] = leftBig
  --   appSettings["Calendar"] = rightSmall
  --   appSettings["Electron"] = rightSmall
  -- end
  
  -- Center on main screen
  centerBig = {mainScreen, {x1=0.25, w=0.5, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "up", function()
    resizeWindow(hs.window.frontmostWindow(), centerBig)
  end)

  -- Maximize on side screen
  side = {sideScreen, {x1=0, w=1, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "down", function()
    resizeWindow(hs.window.frontmostWindow(), side)
  end)
  if mode == "external" then
    appSettings["iTunes"] = side
    appSettings["Spotify"] = side
    appSettings["Chromium"] = side
    appSettings["zoom.us"] = side
  end

  -- Maximize on main screen
  maximized = {mainScreen, {x1=0, w=1, y1=0, h=1}}
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "m", function()
    resizeWindow(hs.window.frontmostWindow(), maximized)
  end)
  if mode == "laptop" then
    appSettings["Google Chrome"] = maximized
    appSettings["Code"] = maximized
  end

  -- Small / "side" apps
  if mode == "laptop" then
    centerSmall = {mainScreen, {x1 = 1 / 6, w = 2 / 3, y1 = 0.0, h = 1}}
  else
    centerSmall = {mainScreen, {x1 = 0.1, w = 0.4, y1 = 1 / 6, h = 2 / 3}} -- Center in left pane
  end
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "s", function()
    resizeWindow(hs.window.frontmostWindow(), centerSmall)
  end)
  if mode == "external" then
    sideLayout = rightSmall
  else
    sideLayout = centerSmall
  end
  -- appSettings["Terminal"] = sideLayout
  -- appSettings["Preview"] = sideLayout
  -- appSettings["Finder"] = sideLayout
  -- appSettings["Contacts"] = sideLayout
  -- appSettings["Notes"] = sideLayout
  -- appSettings["Messages"] = sideLayout
  -- appSettings["Texts"] = sideLayout
  -- appSettings["WhatsApp"] = sideLayout
  -- appSettings["Slack"] = sideLayout
  -- appSettings["Messenger"] = sideLayout
  -- appSettings["Hammerspoon"] = sideLayout
  -- appSettings["Activity Monitor"] = sideLayout

  -- Default for apps not otherwise specified
  -- Now: consider all apps other than explicitly maximized/primary ones "secondary"
  if mode == "laptop" then
    appSettings["default"] = centerSmall
    hs.alert.show("Laptop mode")
  else
    appSettings["default"] = rightSmall
    hs.alert.show("2-screen mode")
  end
end
loadCurrentScreenSettings()

-- WINDOW MANAGEMENT: Methods to process this or all windows

-- [Q]uit all apps with open windows, e.g. when starting a focus period
-- or freeing up memory
function quitAll()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    -- Specify which apps are allowed to keep running in the background
    if
      (app ~= "Electron" and app ~= "Chromium" and app ~= "Hammerspoon" and app ~= "Spotify" and app ~= "Code" and
        app ~= "Notification Center" and
        app ~= "Tyme 2" and
        app ~= "Activity Monitor")
     then
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
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  -- hs.alert.show("width: " .. currentWidth)

  -- hs.alert.show("Arranging " .. window:application():name())
  app = window:application():name()
  -- hs.alert.show(app .. " ->  by title -> " .. window:title())
  -- if (appSettings[window:title()] ~= nil) then
    -- Try lookup by window title first - allows for more specific customization & makes Chrome Apps able to have separate settings than Chrome
    -- hs.alert.show(app .. " ->  by title -> " .. window:title())
    -- resizeWindow(window, appSettings[window:title()])
  if (appSettings[app]) then
    -- hs.alert.show(app .. " ->  custom frame")
    resizeWindow(window, appSettings[app])
  elseif (currentWidth < 720) then -- less than half of laptop screen
    -- small windows get centered instead of resized
    -- hs.alert.show(app .. " ->  center")
    centerWindow(window)
  else
    -- hs.alert.show(app .. " ->  default frame")
    resizeWindow(window, appSettings["default"])
  end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "t", function()
  processWindow(hs.window.frontmostWindow())
end)

-- [C]enter this window
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
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function()
  centerWindow(hs.window.frontmostWindow())
end)



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
    sleep(1.5) -- Try again if app is slow
    windows = appObject:allWindows()
    for i, window in pairs(windows) do
      processWindow(window)
    end
  end
  -- For some apps that don't launch, process on activation
  if (eventType == hs.application.watcher.activated) then
    if (appObject:name() == "Finder" or string.find(hs.window.frontmostWindow():title(), "New Tab")) then
      processWindow(hs.window.frontmostWindow())
    end
    -- hs.alert(hs.window.frontmostWindow():title())
  end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- function windowWatcher(appName, eventType, appObject)
--   hs.alert("Window" .. appName)
--   -- if (eventType == hs.uielement.watcher.windowCreated) then
--   --   if (appObject:name() == "Finder" or string.find(hs.window.frontmostWindow():title(), "New Tab")) then
--   --     processWindow(hs.window.frontmostWindow())
--   --   end
--   --   -- hs.alert(hs.window.frontmostWindow():title())
--   -- end
-- end
-- -- ww = hs.uielement.watcher.new(windowWatcher)
-- -- ww = hs.uielement.watcher --.new() --:start(events)
-- ww = hs.uielement.newWatcher(windowWatcher)
-- ww2 = ww:start(hs.uielement.watcher.windowCreated)
-- hs.alert("Done")

-- When screens are switched
numScreens = #screens
function screenWatcher()
  loadCurrentScreenSettings()
  if #screens ~= numScreens then
    -- Rearrange if screens changed
    processAllWindows()
    numScreens = #screens
  end
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



-- SHORTCUTS TO QUICK OPEN APPS & WEBSITES

-- Core work
hs.hotkey.bind({"cmd", "ctrl"}, "[", function()
  openApp("Visual Studio Code", "Code")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "]", function()
  openApp("Google Chrome")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "t", function()
  openApp("Terminal")
end)
-- hs.hotkey.bind({"cmd", "ctrl"}, "/", function()
--   openApp("Chromium")
-- end)

-- Communication
hs.hotkey.bind({"cmd", "ctrl"}, "m", function()
  openApp("Texts")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "f", function()
  openApp("Facebook Messenger")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "e", function()
  hs.execute("open 'https://mail.google.com'")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "w", function()
  openApp("WhatsApp")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "k", function()
  openApp("Slack")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "z", function()
  openApp("zoom.us")
end)

-- Other
hs.hotkey.bind({"cmd", "ctrl"}, "c", function()
  -- hs.execute("open 'https://calendar.google.com'")
  openApp("Calendar")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "s", function()
  openApp("Spotify")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "n", function()
  openApp("Notes")
end)
hs.hotkey.bind({"cmd", "ctrl"}, "v", function()
  openApp("Evernote")
end)

-- Focus an app, or if already focused, then toggle between tabs.
function openApp(name, windowName)
  -- Sometimes the window "app name" is not the same as name needed to open app, then pass it as windowName. Use this to check if they differ.
  -- hs.alert(name .. ',' .. hs.window.frontmostWindow():application():name())
  windowName = windowName or name
  if(hs.window.frontmostWindow():application():name() == windowName) then
    hs.eventtap.keyStroke({"cmd", "option"}, "right")
  else
    hs.application.open(name)
  end
end


-- ADD CUSTOM SHORTCUTS TO APPS

appShortcuts = {}
appShortcuts["Code"] = {
  {{"ctrl"}, "/", {"Run", "Start Debugging"}},
}
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
-- WINDOW MANAGEMENT

logging = false

-- First, some boilerplate to load different settings based on whether 1 or 2 screens are connected...
function loadCurrentScreenSettings()
  appSettings = {}

  screens = hs.screen.allScreens()
  if #screens == 1 then
    mode = "laptop"
    laptopScreen = screens[1]
    mainScreen = laptopScreen
    buffer = 4
  else
    screenFrame1 = screens[1]:frame()
    screenWidth1 = (screenFrame1.x2 - screenFrame1.x1)
    screenFrame2 = screens[2]:frame()
    screenWidth2 = (screenFrame2.x2 - screenFrame2.x1)

    if screenWidth1 > screenWidth2 then
      mainScreen = screens[1]
      sideScreen = screens[2]
      sideScreenWidth = screenWidth2
    else 
      mainScreen = screens[2]
      sideScreen = screens[1]
      sideScreenWidth = screenWidth1
    end

    if sideScreenWidth <= 1080 then
      mode = "verticalPortable"
      buffer = 8
      laptopScreen = mainScreen
      tallScreen = sideScreen
      mainScreen = tallScreen
    else
      mode = "external"
      buffer = 15
    end
  end

  -- WINDOW MANAGEMENT: Actual config
  -- Specify a frame,
  -- a global shortcut to send current window there (optional)
  -- & any apps assigned to that frame by default

  if mode == "verticalPortable" then 
    if logging then
      hs.alert.show("Vertical portable")
    end

    -- Tall fullscreen
    tall = {tallScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), tall)
    end)
    hs.hotkey.bind({"command", "control", "shift"}, "left", function()
      centerWindow(hs.window.frontmostWindow(), tallScreen)
    end)
    appSettings["Code"] = tall
    appSettings["default"] = tall
    appSettings["Google Chrome"] = tall

    -- Tall partial
    -- tallSmaller = {tallScreen, {x1=0.03, w=0.94, y1=0.03, h=0.94}}

    -- Tall split top/bottom
    tallSplit = 0.6
    tallTop = {tallScreen, {x1=0, w=1, y1=0, h=tallSplit}}
    hs.hotkey.bind({"command", "control"}, "up", function()
      resizeWindow(hs.window.frontmostWindow(), tallTop)
    end)

    tallBottom = {tallScreen, {x1=0, w=1, y1=tallSplit, h=(1-tallSplit)}}
    hs.hotkey.bind({"command", "control"}, "down", function()
      resizeWindow(hs.window.frontmostWindow(), tallBottom)
    end)

    -- Laptop fullscreen
    laptop = {laptopScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), laptop)
    end)
    hs.hotkey.bind({"command", "control", "shift"}, "right", function()
      centerWindow(hs.window.frontmostWindow(), laptopScreen)
    end)
    companionApps = {"Spotify", "iTunes", "Chromium", "Activity Monitor", "Hammerspoon", "Electron", "zoom.us"}
    for _, app in ipairs(companionApps) do
      appSettings[app] = laptop
    end

    -- Laptop split left/right
    leftSize = 0.6
    laptopLeft = {laptopScreen, {x1=0, w=leftSize, y1=0, h=1}}
    hs.hotkey.bind({"command", "control", "shift"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), laptopLeft)
    end)
    laptopRight = {laptopScreen, {x1=leftSize, w=(1-leftSize), y1=0, h=1}}
    hs.hotkey.bind({"command", "control", "shift"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), laptopRight)
    end)
    appSettings["Flow: Projects - Airtable - Chromium"] = laptopLeft
    appSettings["Balanced - Chromium"] = laptopRight
  elseif mode == "laptop" then
    if logging then
      hs.alert.show("Laptop mode")
    end

    -- Maximized
    laptopMax = {laptopScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "up", function()
      resizeWindow(hs.window.frontmostWindow(), laptopMax)
    end)
    appSettings["Code"] = laptopMax
    appSettings["Google Chrome"] = laptopMax

    -- Halves
    leftSize = 0.6
    laptopLeft = {laptopScreen, {x1=0, w=leftSize, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), laptopLeft)
    end)
    laptopRight = {laptopScreen, {x1=leftSize, w=(1-leftSize), y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), laptopRight)
    end)
    appSettings["Flow: Projects - Airtable - Chromium"] = laptopLeft
    appSettings["Balanced - Chromium"] = laptopRight

    -- Centered
    hs.hotkey.bind({"command", "control", "shift"}, "up", function()
      centerWindow(hs.window.frontmostWindow(), laptopScreen)
    end)

    -- Smaller / middle of screen
    addBuffer = 0.0
    middleSize = 0.75
    laptopMiddle = {laptopScreen, {x1=(1-middleSize)/2, w=middleSize, y1=addBuffer, h=1-2*addBuffer}}
    hs.hotkey.bind({"command", "control"}, "down", function()
      resizeWindow(hs.window.frontmostWindow(), laptopMiddle)
    end)
    appSettings["default"] = laptopMiddle
  elseif mode == "external" then
    if logging then
      hs.alert.show("2-screen mode")
    end

    -- Halves
    leftBig = {mainScreen, {x1=0, w=0.6, y1=0, h=1}}
    rightSmall = {mainScreen, {x1=0.6, w=0.4, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), leftBig)
    end)
    hs.hotkey.bind({"command", "control"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), rightSmall)
    end)
    appSettings["Code"] = leftBig
    appSettings["Calendar"] = rightSmall
    appSettings["Electron"] = rightSmall
    appSettings["Local Graph"] = rightSmall
    appSettings["Evernote"] = rightSmall
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
    -- centerBig = {mainScreen, {x1=0.25, w=0.5, y1=0, h=1}}
    -- hs.hotkey.bind({"command", "control"}, "up", function()
    --   resizeWindow(hs.window.frontmostWindow(), centerBig)
    -- end)

    -- Maximize on side screen
    side = {sideScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "down", function()
      resizeWindow(hs.window.frontmostWindow(), side)
    end)
    appSettings["iTunes"] = side
    appSettings["Spotify"] = side
    appSettings["Chromium"] = side
    appSettings["zoom.us"] = side

    -- Maximize on main screen
    maximized = {mainScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "up", function()
      resizeWindow(hs.window.frontmostWindow(), maximized)
    end)
    hs.hotkey.bind({"command", "control", "shift"}, "up", function()
      centerWindow(hs.window.frontmostWindow())
    end)
    if mode == "laptop" then
      appSettings["Google Chrome"] = maximized
      appSettings["Code"] = maximized
    end

    -- Default for apps not otherwise specified
    -- Now: consider all apps other than explicitly maximized/primary ones "secondary"
    appSettings["default"] = rightSmall
  end

  -- For all layouts, these apps would normally be centered because they start out 
  -- with a small frame. Re-cast them to the default size.
  smallSpawningApps = {"Terminal", "Finder"}
  for _, app in ipairs(smallSpawningApps) do
    appSettings[app] = appSettings["default"]
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
      (app ~= "Electron" and app ~= "Chromium" and app ~= "Hammerspoon" and app ~= "Spotify" and
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
hs.hotkey.bind({"control"}, "delete", function()
  quitAll()
  -- processAllWindows()
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
hs.hotkey.bind({"command", "control"}, "h", function() 
  hideAllWindows()
end)

-- Resize [A]ll windows according to settings
function processAllWindows()
  if logging then
    hs.alert.show("Arranging all...")
  end
  for i, window in pairs(hs.window.allWindows()) do
    processWindow(window)
  end
end
hs.hotkey.bind({"command", "control", "shift"}, "a", function()
  processAllWindows()
end)

-- Resize just [T]his active window
function processWindow(window)
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  -- hs.alert.show("width: " .. currentWidth)

  app = window:application():name()
  -- if logging then
    -- hs.alert.show("Arranging " .. window:application():name() .. " - w/ title -> " .. window:title())
  -- end
  if (appSettings[window:title()] ~= nil) then
    -- Try lookup by window title first - allows for more specific customization & makes Chrome Apps able to have separate settings than Chrome
    if logging then
      hs.alert.show(app .. " ->  by title -> " .. window:title())
    end
    resizeWindow(window, appSettings[window:title()])
  elseif (appSettings[app]) then
    if logging then
      hs.alert.show(app .. " ->  custom frame")
    end
    resizeWindow(window, appSettings[app])
  elseif (currentWidth < 720) then -- less than half of laptop screen
    -- small windows get centered instead of resized
    if logging then
      hs.alert.show(app .. " ->  center - b/c width " .. currentWidth)
    end
    centerWindow(window)
  else
    if logging then
      hs.alert.show(app .. " ->  default frame")
    end
    resizeWindow(window, appSettings["default"])
  end
end
hs.hotkey.bind({"command", "control"}, "a", function()
  processWindow(hs.window.frontmostWindow())
end)

-- [C]enter this window
-- Screen is optional; defaults to main screen
function centerWindow(window, screen)
  -- hs.alert.show("Centering")
  screen = screen or mainScreen
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  currentHeight = windowFrame.y2 - windowFrame.y1
  screenFrame = screen:frame()

  -- Shrink slightly if height overflows the buffer
  currentHeight = math.min(currentHeight, (screenFrame.y2 - screenFrame.y1) - buffer*2)

  hOffset = ((screenFrame.x2 - screenFrame.x1) - currentWidth) / 2
  vOffset = ((screenFrame.y2 - screenFrame.y1) - currentHeight) / 2
  -- window:setFrame(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
  window:move(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
end



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
      if logging then
        hs.alert("Processing front-most window (not launch)")
      end
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
hs.hotkey.bind({"control", "command"}, "[", function()
  openApp("Visual Studio Code", "Code")
end)
hs.hotkey.bind({"control", "command"}, "]", function()
  openApp("Google Chrome")
end)
hs.hotkey.bind({"control", "command"}, "t", function()
  openApp("Terminal")
end)
hs.hotkey.bind({"control", "command"}, "'", function()
  -- openApp("Chromium")
  hs.osascript.applescript('tell application "Chromium" \
    activate \
  end tell')
end)
hs.hotkey.bind({"control", "command"}, "o", function()
  openApp("OmniFocus")
end)

-- Communication
hs.hotkey.bind({"control", "command"}, "m", function()
  openApp("Texts")
end)
hs.hotkey.bind({"control", "command", "shift"}, "m", function()
  openApp("Messages")
end)
hs.hotkey.bind({"control", "command"}, "b", function()
  openApp("Facebook Messenger")
end)
hs.hotkey.bind({"control", "command"}, "e", function()
  hs.execute("open 'https://mail.google.com'")
end)
hs.hotkey.bind({"control", "command"}, "w", function()
  openApp("WhatsApp")
end)
hs.hotkey.bind({"control", "command"}, "k", function()
  openApp("Slack")
end)
hs.hotkey.bind({"control", "command"}, "z", function()
  openApp("zoom.us")
end)

-- Other
hs.hotkey.bind({"control", "command"}, "c", function()
  openApp("Calendar")
end)
hs.hotkey.bind({"control", "command", "shift"}, "c", function()
  hs.execute("open 'https://calendar.google.com'")
end)
hs.hotkey.bind({"control", "command"}, "s", function()
  openApp("Spotify")
end)
hs.hotkey.bind({"control", "command"}, "n", function()
  openApp("Notes")
end)
hs.hotkey.bind({"control", "command"}, "v", function()
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
  {{"control", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"control", "option"}, "right", {"Window", "Show Next Tab"}},
}
appShortcuts["Terminal"] = {
  {{"control", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"control", "option"}, "right", {"Window", "Show Next Tab"}},
}
appShortcuts["OmniFocus"] = {
  {{"command", "shift"}, "v", {"Edit", "Paste and Match Style"}},
  {{"control", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"control", "option"}, "right", {"Window", "Show Next Tab"}},
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
      if (currentAppShortcuts[appName] ~= nil) then
        -- hs.alert.show("Disabling " .. appName)
        for key, hotkey in pairs(currentAppShortcuts[appName]) do
          hotkey:disable()
        end
        currentAppShortcuts[appName] = nil
      end
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
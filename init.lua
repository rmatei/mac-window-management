-- Set mode, settings & shortcuts based on current screen config
function loadCurrentScreenSettings()
  screens = hs.screen.allScreens()
  if #screens == 1 then
    -- MacBook Pro Retina is 2560x1600
    mode = 'laptop'
    mainScreen = screens[1]
    buffer = 0
  else
    -- Ultrawide 30" is 3440x1440
    mainScreen = screens[1]
    sideScreen = screens[2]
    mode = 'external'
    buffer = 15
  end

  -- Settings
  maximized = {x1=0, y1=0, w=1, h=1}
  left50 = {x1=0, y1=0, w=1/2, h=1}
  right50 = {x1=1/2, y1=0, w=1/2, h=1}
  left33 = {x1=0, y1=0, w=1/3, h=1}
  mid33 = {x1=1/3, y1=0, w=1/3, h=1}
  right33 = {x1=2/3, y1=0, w=1/3, h=1}

  -- Set different settings for single screen vs. 2
  settings = {}
  if mode == "laptop" then
    -- Laptop only
    settings["default"] = {mainScreen, maximized}
    settings["Safari"] = {mainScreen, left50}
    settings["Atom"] = {mainScreen, maximized}
  else
    -- External monitor
    settings["default"] = {mainScreen, mid33}
    settings["Google Chrome"] = {mainScreen, right33}
    settings["OmniFocus"] = {sideScreen, maximized}
    settings["iTunes"] = {sideScreen, maximized}

    -- Dev stuff
    -- settings["Atom"] = {mainScreen, left33}
    settings["Hammerspoon"] = {mainScreen, {x1=0, y1=0, w=1/3, h=1/3}}
    settings["Terminal"] = {mainScreen, {x1=0, y1=2/3, w=1/3, h=1/3}}
    settings["Activity Monitor"] = {mainScreen, {x1=0, y1=1/3, w=1/3, h=1/3}}
    settings["Safari"] = {mainScreen, left33}
  end

  -- Shortcuts
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "a", function()
    -- Apply settings to all windows on screen
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
    resizeWindow(hs.window.frontmostWindow(), {mainScreen, maximized})
  end)
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function()
    centerWindow(hs.window.frontmostWindow())
  end)

  if mode == 'laptop' then
    -- Halves
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, left50})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, right50})
    end)
  else
    -- Thirds
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "1", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, left33})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "2", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, mid33})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "3", function()
      resizeWindow(hs.window.frontmostWindow(), {mainScreen, right33})
    end)
    hs.hotkey.bind({"cmd", "alt", "ctrl"}, "0", function()
      resizeWindow(hs.window.frontmostWindow(), {sideScreen, maximized})
    end)
  end
end
loadCurrentScreenSettings()



-- WINDOW PROCESSING

function processAllWindows()
  for i, window in pairs(hs.window.allWindows()) do
    processWindow(window)
  end
end

function processWindow(window)
  appSettings = settings[window:application():name()]
  if (appSettings == nil) then
    defaultBehavior(window)
  else
    resizeWindow(window, appSettings)
  end
end

function defaultBehavior(window)
  if (window:size().w <= 1000) then
    centerWindow(window)
  else
    resizeWindow(window, settings["default"])
  end
end

function centerWindow(window)
  hs.alert.show("Centering")
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  currentHeight = windowFrame.y2 - windowFrame.y1
  screenFrame = screens[1]:frame()
  hOffset = ((screenFrame.x2 - screenFrame.x1) - currentWidth) / 2
  vOffset = ((screenFrame.y2 - screenFrame.y1) - currentHeight) / 2
  -- window:setFrame(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
  window:move(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
end

function resizeWindow(window, appSettings)
  hs.alert.show("Resizing")
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
  if (window:application():name() ~= "Hammerspoon") then
      window:application():kill()
    end
  end
end

function hideAllWindows()
  for i, window in pairs(hs.window.allWindows()) do
    if (window:application():name() ~= "OmniFocus") then
      window:application():hide()
    end
  end
end



-- MANAGE / WATCH / RELOAD

-- When new app is launched
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.launched) then
    hs.alert.show(appObject:path())

    -- Workaround for localized apps - windows belong to Chrome
    if string.find(appObject:path(), "Chrome Apps") then
      appObject = hs.application.find("Chrome")
    end
    -- hs.alert.show(appObject:path())

    sleep(0.25) -- Needed to catch it sometimes
    hs.alert.show(#appObject:allWindows())
    windows = appObject:allWindows()
    for i, window in pairs(windows) do
      processWindow(window)
    end
  end
  -- if (eventType == hs.application.watcher.activated) then
  --   processWindow(hs.window.frontmostWindow())
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
hs.alert.show("Config loaded")
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

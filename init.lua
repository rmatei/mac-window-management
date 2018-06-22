laptopWidth = 1280
defaultBuffer = 15

-- Set mode, settings & shortcuts based on current screen config
function loadCurrentScreenSettings()
  screens = hs.screen.allScreens()
  mainScreenFrame = screens[1]:frame()
  mainScreenWidth = mainScreenFrame.x2 - mainScreenFrame.x1
  if mainScreenWidth == laptopWidth then
    -- MacBook Pro Retina is 2560x1600
    if #screens > 1 then
      hs.alert.show("Laptop + secondary display mode")
      sideScreen = screens[2]
    else
      hs.alert.show("Laptop mode")
    end
    mode = 'laptop'
    mainScreen = screens[1]
    laptopScreen = mainScreen
    buffer = 0
  else
    -- Ultrawide 30" is 3440x1440
    hs.alert.show("External monitor mode")
    mainScreen = screens[1]
    sideScreen = screens[2]
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

  left50 = {x1=0, w=0.5}
  right50 = {x1=0.5, w=0.5}

  fullw = {x1=0, w=1}
  fullh = {y1=0, h=1}

  -- Set different settings for single screen vs. 2
  settings = {}
  if mode == "laptop" then
    -- Laptop only
    settings["default"] = {mainScreen, merge(fullw, fullh)}
    -- settings["Safari"] = {mainScreen, merge(fullw, fullh)}
    -- settings["Atom"] = {mainScreen, maximized}
    -- settings["Terminal"] = {laptopScreen, merge(fullw, bottom50)}
  else
    -- External monitor

    -- Main work apps
    settings["default"] = {mainScreen, merge(mid40, fullh)}
    settings["Atom"] = {mainScreen, merge(mid40, fullh)}
    settings["Google Inbox"] = {mainScreen, merge(mid40, fullh)}

    -- Companion apps
    settings["Google Calendar"] = {mainScreen, merge(left30, fullh)}
    -- settings["OmniFocus"] = {mainScreen, {x1=0, y1=0, w=1/3, h=3/4}}
    -- settings["Terminal"] = {mainScreen, {x1=0, y1=3/4, w=1/3, h=1/4}}

    -- Helper / reference apps
    settings["Google Chrome"] = {mainScreen, merge(right30, fullh)}

    -- Non-task related companions
    -- settings["OmniFocus"] = {sideScreen, maximized}

    settings["iTunes"] = {sideScreen, merge(fullw, fullh)}

    -- Dev companions
    settings["Hammerspoon"] = {mainScreen, merge(left30, top50)}
    -- settings["Contacts"] = {mainScreen, {x1=0, y1=0, w=0.3, h=0.5}}
    settings["Contacts"] = {mainScreen, merge(left30, bottom50)}
    -- settings["Terminal"] = {mainScreen, merge(left30, bottom50)}
    settings["Terminal"] = {mainScreen, {x1=0, w=0.3, y1=0.5, h=0.5}}

    settings["Activity Monitor"] = {mainScreen, merge(left30, top50)}
    settings["Safari"] = {mainScreen, merge(right30, fullh)}
  end
  settings["OmniFocus"] = {laptopScreen, merge(fullw, fullh)}

  -- Shortcuts
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "l", function()
    -- Apply settings to all windows on screen
    processAllWindows()
  end)
  -- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "t", function()
  --   -- Apply to just this window
  --   processWindow(hs.window.frontmostWindow())
  -- end)
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


-- Other shortcuts
-- Omnifocus scripting
hs.hotkey.bind({"ctrl"}, "=", function()
  hs.execute("osascript ~/iCloud\\ Drive/Code/OmniFocus\\ Scripting/Task.suggest.start.js")
end)

hs.hotkey.bind({"ctrl"}, "[", function()
  hs.execute("osascript ~/iCloud\\ Drive/Code/OmniFocus\\ Scripting/Task.start.js")
end)

hs.hotkey.bind({"ctrl"}, "]", function()
  hs.execute("osascript ~/iCloud\\ Drive/Code/OmniFocus\\ Scripting/Task.end.js")
end)

hs.hotkey.bind({"ctrl"}, "\\", function()
  hs.execute("osascript ~/iCloud\\ Drive/Code/OmniFocus\\ Scripting/Task.complete.js")
end)

-- Application starters
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "a", function()
  hs.application.open("Atom")
end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "o", function()
  hs.application.open("OmniFocus")
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
  if (window:size().w < (laptopWidth - 2*defaultBuffer)) then -- consider a window custom-sized if it's less smaller than fullscreen, and don't maximize
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
  screenFrame = screens[1]:frame()
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
    if (app ~= "Hammerspoon" and app ~= "iTunes" and app ~= "Terminal" and app ~= "Spotify" and app ~= "OmniFocus" and app ~= "Transmission" and app ~= "ExpressVPN" and app ~= "Atom" and app ~= "Tyme2" and app ~= "Tyme") then
      window:application():kill()
    end
  end

  sleep(0.5)
  hs.application.find("Chrome"):kill9()
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

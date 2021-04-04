-- WINDOW MANAGEMENT

logging = false

-- First, some boilerplate to load different settings based on whether 1 or 2 screens are connected...
function loadCurrentScreenSettings()
  appSettings = {}

  screens = hs.screen.allScreens()
  screenFrame1 = screens[1]:frame()
  screenWidth1 = (screenFrame1.x2 - screenFrame1.x1)
  -- hs.alert(screenWidth1)

  if #screens == 1 and screenWidth1 <= 1920 then
    mode = "singleScreen"
    laptopScreen = screens[1]
    mainScreen = laptopScreen
    buffer = 0
  elseif #screens == 1 then 
  -- else
    mode = "externalHorizontal"
    buffer = 15
    mainScreen = screens[1]
  -- end
  else
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
      mode = "externalVertical"
      buffer = 8
      laptopScreen = mainScreen
      tallScreen = sideScreen
      mainScreen = tallScreen
    else
      mode = "externalHorizontal"
      buffer = 15
      laptopScreen = sideScreen
    end
  end
  if logging then 
    hs.alert(mode)
  end



  -- WINDOW MANAGEMENT: Actual config
  -- Specify a frame,
  -- a global shortcut to send current window there (optional)
  -- & any apps assigned to that frame by default



  -- ---------------------------------------------------------------------------------------
  if mode == "externalHorizontal" then
    if logging then
      hs.alert.show("External monitor mode")
    end

    -- MAIN SCREEN

    -- Big center + sides
    centerWidth = 0.5
    center = {mainScreen, {x1=(1-centerWidth)/2, w=centerWidth, y1=0, h=1}}
    appSettings["default"] = center
    hs.hotkey.bind({"command", "control"}, "up", function()
      resizeWindow(hs.window.frontmostWindow(), center)
    end)

    smallLeft = {mainScreen, {x1=0, w=(1-centerWidth)/2, y1=0, h=1}}
    smallRight = {mainScreen, {x1=(1-centerWidth)/2+centerWidth, w=(1-centerWidth)/2, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), smallLeft)
    end)
    hs.hotkey.bind({"command", "control"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), smallRight)
    end)

    taskCompanionApps = {"zoom.us", "Photos", "Notes", "Contacts",
      "Terminal", "Finder", "Calendar", "Google Calendar", "OmniFocus", "1Password", "Electron"}
    for _, app in ipairs(taskCompanionApps) do
      appSettings[app] = smallRight
    end

    commsApps = {"Texts", "Beeper", "Messages", "Slack", "Activity Monitor"}
    for _, app in ipairs(commsApps) do
      appSettings[app] = smallRight
    end

    bigWidth = 1-(1-centerWidth)/2
    bigLeft = {mainScreen, {x1=0, w=bigWidth, y1=0, h=1}}
    bigRight = {mainScreen, {x1=1-bigWidth, w=bigWidth, y1=0, h=1}}
    hs.hotkey.bind({"command", "control", "shift"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), bigLeft)
    end)
    hs.hotkey.bind({"command", "control", "shift"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), bigRight)
    end)
    appSettings["Chromium"] = bigLeft
    appSettings["Code"] = bigLeft

    appSettings["Google Chrome"] = bigLeft
    appSettings["New task"] = smallRight

    -- centerSmall = {mainScreen, {x1=0.325, w=0.35, y1=0.15, h=0.7}}
    -- taskCompanionApps = {"zoom.us", "Photos", "Notes", "Contacts",
    --   "Terminal", "Finder", "Calendar", "OmniFocus"}
    -- for _, app in ipairs(taskCompanionApps) do
    --   appSettings[app] = centerSmall
    -- end

    -- Uneven halves
    leftSize = 0.65
    left = {mainScreen, {x1=0, w=leftSize, y1=0, h=1}}
    right = {mainScreen, {x1=leftSize, w=(1-leftSize), y1=0, h=1}}
    primarySide = right
    secondarySide = left
    hs.hotkey.bind({"command", "control", "option"}, "left", function()
      resizeWindow(hs.window.frontmostWindow(), left)
    end)
    hs.hotkey.bind({"command", "control", "option"}, "right", function()
      resizeWindow(hs.window.frontmostWindow(), right)
    end)
    -- appSettings["Code"] = primarySide
    -- appSettings["Google Chrome"] = primarySide

    -- Quarters
    qx1 = 0 -- if left side secondary
    qw = leftSize
    -- x1 = leftSize -- if right side secondary
    -- w = (1-leftSize)
    topSize = 0.55

    smallTop = {mainScreen, {x1=qx1, w=qw, y1=0, h=topSize}}
    smallBottom = {mainScreen, {x1=qx1, w=qw, y1=topSize, h=(1-topSize)}}
    hs.hotkey.bind({"command", "control", "shift"}, "up", function()
      resizeWindow(hs.window.frontmostWindow(), smallTop)
    end)
    hs.hotkey.bind({"command", "control", "shift"}, "down", function()
      resizeWindow(hs.window.frontmostWindow(), smallBottom)
    end)
    -- appSettings["Electron"] = smallBottom

    -- Maximized
    maximized = {mainScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "x", function()
      resizeWindow(hs.window.frontmostWindow(), maximized)
    end)
    -- hs.hotkey.bind({"option", "control", "shift"}, "up", function()
      -- centerWindow(hs.window.frontmostWindow())
    -- end)
    -- appSettings["Flow: Projects - Airtable - Chromium"] = maximized
    -- appSettings["Chromium"] = maximized

    if (laptopScreen) then
      -- LAPTOP SCREEN
      -- Maximized
      laptop = {laptopScreen, {x1=0, w=1, y1=0, h=1}}
      hs.hotkey.bind({"command", "control"}, "down", function()
        resizeWindow(hs.window.frontmostWindow(), laptop)
      end)
      -- hs.hotkey.bind({"command", "control", "shift"}, "down", function()
      --   centerWindow(hs.window.frontmostWindow(), laptopScreen)
      -- end)

      -- longRunningCompanionApps = {"Spotify", "iTunes", "Chromium", "Activity Monitor", 
      -- "Hammerspoon"}
      --   for _, app in ipairs(longRunningCompanionApps) do
      --   appSettings[app] = laptop
      -- end

      -- Halves
      -- leftSize = 0.6 
      -- laptopLeft = {laptopScreen, {x1=0, w=leftSize, y1=0, h=1}}
      -- hs.hotkey.bind({"command", "control", "shift"}, "left", function()
      --   resizeWindow(hs.window.frontmostWindow(), laptopLeft)
      -- end)
      -- laptopRight = {laptopScreen, {x1=leftSize, w=(1-leftSize), y1=0, h=1}}
      -- hs.hotkey.bind({"command", "control", "shift"}, "right", function()
      --   resizeWindow(hs.window.frontmostWindow(), laptopRight)
      -- end)
      -- laptopLeftOverlapping = {laptopScreen, {x1=0, w=0.975, y1=0, h=1}}
      -- appSettings["Flow: Projects - Airtable - Chromium"] = secondarySide
      -- appSettings["Balanced - Chromium"] = laptopRight
    -- else 
      -- appSettings["Spotify"] = primarySide
    end


  -- ---------------------------------------------------------------------------------------
  elseif mode == "singleScreen" then
    if logging then
      hs.alert.show("Laptop mode")
    end

    -- Maximized
    laptopMax = {laptopScreen, {x1=0, w=1, y1=0, h=1}}
    hs.hotkey.bind({"command", "control"}, "up", function()
      resizeWindow(hs.window.frontmostWindow(), laptopMax)
    end)
    -- appSettings["Code"] = laptopMax
    -- appSettings["Google Chrome"] = laptopMax
    appSettings["default"] = laptopMax

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
    -- laptopLeftOverlapping = {laptopScreen, {x1=0, w=0.975, y1=0, h=1}}
    -- appSettings["Flow: Projects - Airtable - Chromium"] = laptopMax -- laptopLeftOverlapping
    -- appSettings["Balanced - Chromium"] = laptopRight
    -- appSettings["Texts"] = laptopLeft
    -- appSettings["Messages"] = laptopRight

    -- Centered
    hs.hotkey.bind({"command", "control", "shift"}, "up", function()
      centerWindow(hs.window.frontmostWindow(), laptopScreen)
    end)

  -- Smaller / middle of screen
  -- addBuffer = 0.0
  -- middleSize = 0.75
  -- laptopMiddle = {laptopScreen, {x1=(1-middleSize)/2, w=middleSize, y1=addBuffer, h=1-2*addBuffer}}
  -- hs.hotkey.bind({"command", "control"}, "down", function()
  --   resizeWindow(hs.window.frontmostWindow(), laptopMiddle)
  -- end)
  -- appSettings["default"] = laptopMiddle


  -- ---------------------------------------------------------------------------------------
  -- elseif mode == "externalVertical" then 
  --   if logging then
  --     hs.alert.show("Vertical portable")
  --   end

  --   -- Tall fullscreen
  --   tall = {tallScreen, {x1=0, w=1, y1=0, h=1}}
  --   hs.hotkey.bind({"command", "control"}, "left", function()
  --     resizeWindow(hs.window.frontmostWindow(), tall)
  --   end)
  --   hs.hotkey.bind({"command", "control", "shift"}, "left", function()
  --     centerWindow(hs.window.frontmostWindow(), tallScreen)
  --   end)
  --   appSettings["Code"] = tall
  --   appSettings["default"] = tall
  --   appSettings["Google Chrome"] = tall

  --   -- Tall partial
  --   -- tallSmaller = {tallScreen, {x1=0.03, w=0.94, y1=0.03, h=0.94}}

  --   -- Tall split top/bottom
  --   tallSplit = 0.6
  --   tallTop = {tallScreen, {x1=0, w=1, y1=0, h=tallSplit}}
  --   hs.hotkey.bind({"command", "control"}, "up", function()
  --     resizeWindow(hs.window.frontmostWindow(), tallTop)
  --   end)

  --   tallBottom = {tallScreen, {x1=0, w=1, y1=tallSplit, h=(1-tallSplit)}}
  --   hs.hotkey.bind({"command", "control"}, "down", function()
  --     resizeWindow(hs.window.frontmostWindow(), tallBottom)
  --   end)

  --   -- Laptop fullscreen
  --   laptop = {laptopScreen, {x1=0, w=1, y1=0, h=1}}
  --   hs.hotkey.bind({"command", "control"}, "right", function()
  --     resizeWindow(hs.window.frontmostWindow(), laptop)
  --   end)
  --   hs.hotkey.bind({"command", "control", "shift"}, "right", function()
  --     centerWindow(hs.window.frontmostWindow(), laptopScreen)
  --   end)
  --   companionApps = {"Spotify", "iTunes", "Chromium", "Activity Monitor", 
  --     "Hammerspoon", "Electron", "Local Graph", "zoom.us", "Photos", "Notes", "Contacts",
  --     "Terminal", "Finder", "Calendar"}
  --   for _, app in ipairs(companionApps) do
  --     appSettings[app] = laptop
  --   end

  --   -- Laptop split left/right
  --   leftSize = 0.6
  --   laptopLeft = {laptopScreen, {x1=0, w=leftSize, y1=0, h=1}}
  --   hs.hotkey.bind({"command", "control", "shift"}, "left", function()
  --     resizeWindow(hs.window.frontmostWindow(), laptopLeft)
  --   end)
  --   laptopRight = {laptopScreen, {x1=leftSize, w=(1-leftSize), y1=0, h=1}}
  --   hs.hotkey.bind({"command", "control", "shift"}, "right", function()
  --     resizeWindow(hs.window.frontmostWindow(), laptopRight)
  --   end)
  --   laptopLeftOverlapping = {laptopScreen, {x1=0, w=0.975, y1=0, h=1}}
  --   appSettings["Flow: Projects - Airtable - Chromium"] = laptopLeftOverlapping
  --   appSettings["Balanced - Chromium"] = laptopRight
  end

  -- For all layouts, these apps would normally be centered because they start out 
  -- with a small frame. Re-cast them to the default size.
  -- smallSpawningApps = {"Terminal", "Finder"}
  -- for _, app in ipairs(smallSpawningApps) do
    -- appSettings[app] = appSettings["default"]
  -- end
end
loadCurrentScreenSettings()

-- WINDOW MANAGEMENT: Methods to process this or all windows

-- [Q]uit all apps with open windows, e.g. when starting a focus period
-- or freeing up memory
-- Specify which apps are allowed to keep running in the background
leaveRunningApps = {
  ["Electron"] = true,
  ["Chromium"] = true,
  ["Hammerspoon"] = true,
  ["Tyme 2"] = true,
  ["Spotify"] = true,
  ["Activity Monitor"] = true,
  ["Transmission"] = true,
  ["Terminal"] = true,
  -- ["Google Chrome"] = true,
  -- ["Photos"] = true,
  -- ["Slack"] = true,
  ["Texts"] = true,
  -- ["Beeper"] = true,
  ["Messages"] = true,
  -- ["Notification Center"] = true,
  -- ["OmniFocus"] = true,
  ["Code"] = true,
  ["Brave Browser"] = true, -- for music & others
}
leaveVisibleApps = {
  -- ["Chromium"] = true,
  ["Terminal"] = true,
}
function quitAll()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    -- hs.alert.show("Killing " .. app)
    if leaveRunningApps[app] ~= true then
      hs.alert.show("Killing " .. app)
      window:application():kill()
    end
  end
  -- sleep(0.5) -- When using Chrome Apps, they won't all shut down normally.
  -- hs.application.find("Chrome"):kill9()
  hideAllWindows()
end
hs.hotkey.bind({"control"}, "delete", function()
  quitAll()
  -- processAllWindows()
end)

-- [H]ide all windows
function hideAllWindows()
  for i, window in pairs(hs.window.allWindows()) do
    app = window:application():name()
    if leaveVisibleApps[app] ~= true then
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
hs.hotkey.bind({"command", "control"}, "a", function()
  processAllWindows()
end)

-- Resize just [T]his active window
function processWindow(window)
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  currentHeight = windowFrame.y2 - windowFrame.y1
  -- hs.alert.show("width: " .. currentWidth)

  app = window:application():name()
  if logging then
    hs.alert.show("Arranging " .. window:application():name() .. " - w/ title -> " .. window:title())
  end
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
  elseif (currentWidth < 800 and currentHeight < 800) then -- less than half of laptop screen
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
hs.hotkey.bind({"command", "control", "shift"}, "a", function()
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
  -- if (eventType == hs.application.watcher.activated) then
  --   if (appObject:name() == "Finder" or string.find(hs.window.frontmostWindow():title(), "New Tab")) then
  --     if logging then
  --       hs.alert("Processing front-most window (not launch)")
  --     end
  --     processWindow(hs.window.frontmostWindow())
  --   end
  --   -- hs.alert(hs.window.frontmostWindow():title())
  -- end
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
-- Doing this through shortcuts IN specific Electron apps
hs.hotkey.bind({"control", "command"}, "]", function()
  openApp("Electron")
  -- hs.osascript.applescript('tell application "Electron" \
    -- activate \
  -- end tell')
end)
hs.hotkey.bind({"control", "command"}, "\\", function()
  -- openApp("Google Chrome")
  openApp("Safari")
end)
hs.hotkey.bind({"control", "command", "shift"}, "\\", function()
  openApp("Google Chrome")
  -- openApp("Safari")
end)
hs.hotkey.bind({"control", "command"}, "b", function()
  openApp("Brave Browser")
end)
hs.hotkey.bind({"control", "command"}, "'", function()
  -- openApp("Chromium")
  -- hs.osascript.applescript('tell application "Chromium" \
    -- activate \
  -- end tell')
  -- hs.execute("open 'https://airtable.com/tbl5NSKDgMWTgpPzh?blocks=hide'")
  openApp("Google Chrome")
end)
-- hs.hotkey.bind({"control", "command"}, "'", function()
--   hs.execute("open 'https://airtable.com/tbl5NSKDgMWTgpPzh/viwQ39cW1DM6vuqgq?blocks=hide'")
-- end)
hs.hotkey.bind({"control", "command"}, "o", function()
  openApp("OmniFocus")
end)

-- Communication
hs.hotkey.bind({"control", "command"}, "m", function()
  -- openApp("Messages")
  openApp("Texts")
  if(not (hs.application.find("Messages") and hs.application.find("Messages"):isRunning())) then
    openApp("Messages")
    -- sleep(4)
  end
  -- if(not hs.application.find("Messages"):isHidden()) then
    -- hs.application.find("Messages"):hide()
  -- end
  hs.application.find("Texts"):activate()
end)
hs.hotkey.bind({"control", "command"}, "b", function()
  openApp("Beeper")
end)
hs.hotkey.bind({"control", "command", "shift"}, "m", function()
  openApp("Messages")
end)
-- hs.hotkey.bind({"control", "command"}, "b", function()
--   openApp("Facebook Messenger")
-- end)
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
hs.hotkey.bind({"control", "command"}, "l", function()
  openApp("Calendar")
end)
hs.hotkey.bind({"control", "command", "shift"}, "l", function()
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
hs.hotkey.bind({"control", "command"}, "t", function()
  openApp("Terminal")
end)
hs.hotkey.bind({"control", "command"}, "p", function()
  openApp("Photos")
end)

-- bulk messenger: send and advance
hs.hotkey.bind({"control", "option"}, "return", function()
  -- openApp("Chromium")
  hs.osascript.applescript('tell application "System Events" \
  key code 36 \
  delay 0.5 \
  key code 48 using command down \
  delay 0.5 \
	key code 36 \
end tell')
end)

-- bulk messenger: skip and advance
hs.hotkey.bind({"control", "option"}, "/", function()
  hs.osascript.applescript('tell application "System Events" \
  keystroke "a" using command down \
  delay 0.5 \
  key code 51 \
  delay 0.5 \
  key code 48 using command down \
  delay 0.5 \
	key code 36 \
end tell')
end)

hs.hotkey.bind({"control"}, "'", function()
  hs.osascript.applescript('tell application "Terminal" \
  activate \
end tell \
tell application "System Events" \
  delay 0.5 \
	key code 36 \
end tell')
end)

-- hs.hotkey.bind({"control"}, "[", function()
--   hs.osascript.applescript('tell application "OmniFocus" \
-- 	activate \
-- end tell \
-- delay 1 \
-- set s to the clipboard as text \
-- display notification "" with title s subtitle "" sound name "Frog"')
--   hideAllWindows()
-- end)

-- hs.hotkey.bind({"control"}, "]", function()
--   hs.osascript.applescript('tell application "OmniFocus" \
-- 	activate \
-- end tell')
-- end)

-- Focus an app, or if already focused, then toggle between tabs.
function openApp(name, windowName)
  -- Sometimes the window "app name" is not the same as name needed to open app, then pass it as windowName. Use this to check if they differ.
  -- hs.alert(name .. ',' .. hs.window.frontmostWindow():application():name())
  windowName = windowName or name
  if(hs.window.frontmostWindow() and hs.window.frontmostWindow():application():name() == windowName) then
    hs.eventtap.keyStroke({"cmd", "option"}, "right")
  else
    hs.application.open(name)
  end
end


-- ADD CUSTOM SHORTCUTS TO APPS

appShortcuts = {}
appShortcuts["Code"] = {
  {{"ctrl"}, "\\", {"Run", "Start Debugging"}},
}
appShortcuts["Safari"] = {
  {{"command", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"command", "option"}, "right", {"Window", "Show Next Tab"}},
  -- {{"command", "shift"}, "v", {"Edit", "Paste and Match Style"}},
}
appShortcuts["Terminal"] = {
  {{"command", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"command", "option"}, "right", {"Window", "Show Next Tab"}},
}
appShortcuts["OmniFocus"] = {
  {{"command", "shift"}, "v", {"Edit", "Paste and Match Style"}},
  {{"command", "option"}, "left", {"Window", "Show Previous Tab"}},
  {{"command", "option"}, "right", {"Window", "Show Next Tab"}},
  {{"control", "option"}, "up", {"Organize", "Move", "Move Up"}},
  {{"control", "option"}, "down", {"Organize", "Move", "Move Down"}},
  {{"control", "option"}, "left", {"Organize", "Move", "Move Left"}},
  {{"control", "option"}, "right", {"Organize", "Move", "Move Right"}}
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
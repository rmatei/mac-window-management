-- Load screen dimensions
screen = hs.screen.mainScreen()
screenFrame = screen:frame()

-- Set base mode and dimensions
if screen:name() == "Color LCD" then
  mode = 'laptop'
  buffer = 0
else
  mode = 'external'
  buffer = 15
end

-- Shared computations
x1 = screenFrame.x1 + buffer
y1 = screenFrame.y1 + buffer
x2 = screenFrame.x2 - buffer
y2 = screenFrame.y2 - buffer
screenWidth = x2-x1
screenHeight = y2-y1
maximized = hs.geometry.rect(x1, y1, screenWidth, screenHeight)

halfWidth = (screenWidth - buffer) / 2
left50 = hs.geometry.rect({x=x1, y=y1, w=halfWidth, h=screenHeight})
right50 = hs.geometry.rect(x1+halfWidth+buffer, y1, halfWidth, screenHeight)

-- Set different settings for single screen vs. 2
settings = {}
if mode == "laptop" then
  -- Laptop only
  settings["Safari"] = left50
  settings["Atom"] = maximized
else
  -- External monitor
  settings["Atom"] = left50
  settings["Google Chrome"] = right50
  settings["OmniFocus"] = left50
end




-- Test code
-- local log = hs.logger.new("Window mover", "error")
-- log:d("Hello world")
-- hs.screen:currentMode()

function resizeWindow()
  window = hs.window.frontmostWindow()

  appSettings = settings[window:application():name()]

  if (appSettings == nil) then
    hs.alert.show("Centering")
    centerWindow(window)
    -- window:centerOnScreen()
    -- window:maximize()
  else
    hs.alert.show("Resizing")
    window:setFrame(appSettings)
    -- window:setTopLeft(appSettings.x, appSettings.y)
    -- window:setSize(appSettings.w, appSettings.h)
  end
end

function centerWindow(window)
  -- hs.alert.show("Centering")
  windowFrame = window:frame()
  currentWidth = windowFrame.x2 - windowFrame.x1
  currentHeight = windowFrame.y2 - windowFrame.y1
  hOffset = ((screenFrame.x2 - screenFrame.x1) - currentWidth) / 2
  vOffset = ((screenFrame.y2 - screenFrame.y1) - currentHeight) / 2
  -- window:setFrame(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
  window:move(hs.geometry.rect({x1 = screenFrame.x1 + hOffset, y1 = screenFrame.y1 + vOffset, x2 = screenFrame.x2 - hOffset, y2 = screenFrame.y2 - vOffset}))
end


-- Application watcher to apply this
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.launched) then
    resizeWindow()
  end
  if (eventType == hs.application.watcher.activated) then
    resizeWindow()
  end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Also screen watcher to apply this
function screenWatcher()
  resizeWindow()
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

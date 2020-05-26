# Mac persistent window management

A flexible config using [Hammmerspoon](https://www.hammerspoon.org/) to put apps where you like them on the screen. Unlike OS X or existing window managers, this allows you to:
- automatically resize apps when they're started
- automatically resize apps when you plug in your monitor (w/ different settings for external monitors)
- start / focus apps with one shortcut

## Installation

- install Hammerspoon
- `$ git clone https://github.com/rmatei/mac-window-management.git ~/.hammerspoon`
- edit `~/.hammerspoon/init.lua` to set shortcuts and per-app settings

## Other features

Beyond window management, there are examples for how to:

- hide all windows, or quit all programs except for a specified set, to clean up your workspace
- re-assign keyboard shortcuts for specific apps (e.g. if an app has a non-standard search shortcut), in a way that persists across computers
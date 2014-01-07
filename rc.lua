-- Catch errors and fallback to /etc/xdg/awesome/rc.lua if aw.lua fails
-- a la http://www.markurashi.de/dotfiles/awesome/rc.lua

local awful = require('awful')
local naughty = require('naughty')

local rc, err = loadfile(awful.util.getdir('config') .. '/aw.lua')
if rc then
  rc, err = xpcall(rc, debug.traceback)
  if rc then
    return
  end
end

print('Awesome crashed during startup:\n\n' .. err .. '\n\nFalling back on recovery configuration.')
naughty.notify {
  text = 'Awesome crashed during startup:\n\n' .. err .. '\n\nFalling back on recovery configuration.',
  timeout = 0,
  fg = '#cccccc',
  bg = '#111111',
  font = awesome.font,
  border_color = '#333333',
}

dofile(awful.util.getdir('config') .. '/aw-recovery.lua')


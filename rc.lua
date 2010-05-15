-- Catch errors and fallback to /etc/xdg/awesome/rc.lua if aw.lua fails
-- a la http://www.markurashi.de/dotfiles/awesome/rc.lua

require('awful')
require('naughty')

local rc, err = loadfile(awful.util.getdir('config') .. '/aw.lua')
if rc then
    rc, err = pcall(rc)
    if rc then
        return
    end
end

naughty.notify { text = 'Awesome crashed during startup on ' .. os.date('%F %T:\n\n') ..  err .. '\n', timeout = 0 }

dofile(awful.util.getdir('config') .. '/aw-recovery.lua')


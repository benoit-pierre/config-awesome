-- {{{ Clock widget

local utils = require('widgets.utils')
local awful = require('awful')

-- Just a clock: YY-MM-DD, week/day, HH:MM:SS (numeric timezone)
local format = '%F, %V/%a, ' .. utils.bold('%T') .. ' (%z)'
local timeout = 0.2
local clock = {}

if '3.4' == aw_ver then

  clock.new = function()
    return awful.widget.textclock({}, format, timeout)
  end

end

if '3.5' == aw_ver then

  clock.new = function()
    return awful.widget.textclock(format, timeout)
  end

end

return utils.widget_class(clock)

-- }}}

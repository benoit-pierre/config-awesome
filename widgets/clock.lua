-- {{{ Clock widget

local utils = require('widgets.utils')
local awful = require('awful')

-- Just a clock: YY-MM-DD, week/day, HH:MM (numeric timezone)
local format = utils.widget_base(utils.bold('%F') .. ', %V/%a, ' .. utils.bold('%H:%M') .. ' (%z)')
local timeout = 5
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

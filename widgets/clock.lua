-- {{{ Clock widget

local utils = require('widgets.utils')
local awful = require('awful')

-- Just a clock: YY-MM-DD, week/day, HH:MM (numeric timezone)
local format = utils.widget_base(utils.bold('%F') .. ', %V/%a, ' .. utils.bold('%H:%M') .. ' (%z)')
local timeout = 5
local clock = {}

if aw_ver >= 3.5 then
  clock.new = function()
    return awful.widget.textclock(format, timeout)
  end
elseif aw_ver >= 3.4 then
  clock.new = function()
    return awful.widget.textclock({}, format, timeout)
  end
end

return utils.widget_class(clock)

-- }}}

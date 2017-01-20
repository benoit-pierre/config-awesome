-- {{{ Clock widget

local utils = require('widgets.utils')

-- Just a clock: YY-MM-DD, week/day, HH:MM (numeric timezone)
local format = utils.widget_base(utils.bold('%F') .. ', %V/%a, ' .. utils.bold('%H:%M') .. ' (%z)')
local timeout = 5
local clock = {}

if aw_ver >= 4.0 then
  local wibox = require('wibox')
  clock.new = function()
    return wibox.widget.textclock(format, timeout)
  end
elseif aw_ver >= 3.5 then
  local awful = require('awful')
  clock.new = function()
    return awful.widget.textclock(format, timeout)
  end
elseif aw_ver >= 3.4 then
  local awful = require('awful')
  clock.new = function()
    return awful.widget.textclock({}, format, timeout)
  end
end

return utils.widget_class(clock)

-- }}}

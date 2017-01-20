-- {{{ Systray widget

local utils = require('widgets.utils')

local systray = {}

if aw_ver >= 3.5 then
  local wibox = require('wibox')
  systray.new = function()
    return wibox.widget.systray()
  end
elseif aw_ver >= 3.4 then
  systray.new = function()
    return widget({ type = 'systray' })
  end
end

return utils.widget_class(systray)

-- }}}

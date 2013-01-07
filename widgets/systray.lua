-- {{{ Systray widget

local utils = require('widgets.utils')

local systray = {}

if '3.4' == aw_ver then

  systray.new = function()
    return widget({ type = 'systray' })
  end

end

if '3.5' == aw_ver then

  local wibox = require('wibox')

  systray.new = function()
    return wibox.widget.systray()
  end

end

return utils.widget_class(systray)

-- }}}

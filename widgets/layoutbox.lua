-- {{{ Layoutbox widget

local utils = require('widgets.utils')
local awful = require('awful')

local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
awful.button(k_n, 1, function () awful.layout.inc(layouts, 1) end),
awful.button(k_n, 3, function () awful.layout.inc(layouts, -1) end),
awful.button(k_n, 4, function () awful.layout.inc(layouts, 1) end),
awful.button(k_n, 5, function () awful.layout.inc(layouts, -1) end),
nil
)

layoutbox.new = function(screen_number)
  local w = awful.widget.layoutbox(screen_number)
  w:buttons(layoutbox.buttons)
  return w
end

return utils.widget_class(layoutbox)

-- }}}

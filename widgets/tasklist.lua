-- {{{ Tasklist widget

local utils = require('widgets.utils')
local awful = require('awful')

local tasklist = {}

if aw_ver >= 3.5 then
  tasklist.new = function(screen_number, buttons)
    return awful.widget.tasklist(screen_number, awful.widget.tasklist.filter.currenttags, tasklist.buttons)
  end
elseif aw_ver >= 3.4 then
  tasklist.new = function(screen_number)
    local filter = function(c)
      return awful.widget.tasklist.label.currenttags(c, screen_number)
    end
    local w = awful.widget.tasklist(filter, tasklist.buttons)
    awful.widget.layout.margins[w] = { right = screen[screen_number].geometry.width / 2 }
    return w
  end
end

tasklist.buttons = awful.util.table.join(
awful.button(k_n, 1, function (c)
  if not c:isvisible() then
    awful.tag.viewonly(c:tags()[1])
  end
  client.focus = c
  c:raise()
end),
awful.button(k_n, 3, function ()
  if instance then
    instance:hide()
    instance = nil
  else
    instance = awful.menu.clients({ width = 250 })
  end
end),
awful.button(k_n, 4, focus_next),
awful.button(k_n, 5, focus_previous),
nil
)

return utils.widget_class(tasklist)

-- }}}

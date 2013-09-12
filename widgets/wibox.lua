-- {{{ Wibox widget

local utils = require('widgets.utils')
local beautiful = require('beautiful')
local awful = require('awful')

local wibox = {}

if '3.4' == aw_ver then

  wibox._set_widgets = function(w, left_widgets, right_widgets)
    local layout = { layout = awful.widget.layout.horizontal.leftright }

    if left_widgets then
      for k, v in pairs(left_widgets) do
        if v then
          table.insert(layout, v)
        end
      end
    end

    if right_widgets then
      local right = {}
      right.layout = awful.widget.layout.horizontal.rightleft
      for k, v in pairs(right_widgets) do
        if v then
          table.insert(right, v)
        end
      end
      table.insert(layout, right)
    end

    w.widgets = layout
  end

end

if '3.5' == aw_ver then

  wibox._set_widgets = function(w, left_widgets, right_widgets)
    local wibox = require('wibox')
    local layout = wibox.layout.align.horizontal()

    if left_widgets then
      local left_layout = wibox.layout.fixed.horizontal()
      for k, v in pairs(left_widgets) do
        if v then
          left_layout:add(v)
        end
      end
      layout:set_left(left_layout)
    end

    if right_widgets then
      local right_layout = wibox.layout.fixed.horizontal()
      for k, v in pairs(right_widgets) do
        if v then
          right_layout:add(v)
        end
      end
      layout:set_right(right_layout)
    end

    w:set_widget(layout)
  end

end

function wibox.new(position, screen, left_widgets, right_widgets)
  local t =
  {
    position = position,
    screen = screen,
    height = beautiful.wibox_height,
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
  }
  local w = awful.wibox(t)

  wibox._set_widgets(w, left_widgets, right_widgets)

  return w
end

return utils.widget_class(wibox)

-- }}}

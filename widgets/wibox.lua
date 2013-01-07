-- {{{ Wibox widget

local utils = require('widgets.utils')
local beautiful = require('beautiful')
local awful = require('awful')

local wibox = {}

if '3.4' == aw_ver then

  wibox._set_widgets = function(w, left_widgets, right_widgets)
    local layout = { layout = awful.widget.layout.horizontal.leftright }

    if left_widgets then
      for i, v in ipairs(left_widgets) do
        table.insert(layout, v)
      end
    end

    if right_widgets then
      local right = {}
      right.layout = awful.widget.layout.horizontal.rightleft
      for i, v in ipairs(right_widgets) do
        table.insert(right, v)
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
      for i, v in ipairs(left_widgets) do
        left_layout:add(v)
      end
      layout:set_left(left_layout)
    end

    if right_widgets then
      local right_layout = wibox.layout.fixed.horizontal()
      for i, v in ipairs(right_widgets) do
        right_layout:add(v)
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

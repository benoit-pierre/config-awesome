-- {{{ Taglist widget

local utils = require('widgets.utils')
local awful = require('awful')

local taglist = {}

if '3.4' == aw_ver then

  taglist.viewnext = awful.tag.viewnext
  taglist.viewprev = awful.tag.viewprev

  taglist._new = function(screen_number, buttons)
    return awful.widget.taglist(screen_number, awful.widget.taglist.label.all, buttons)
  end

end

if '3.5' == aw_ver then

  taglist.viewnext = function(t)
    awful.tag.viewnext(awful.tag.getscreen(t))
  end
  taglist.viewprev = function(t)
    awful.tag.viewprev(awful.tag.getscreen(t))
  end

  taglist._new = function(screen_number, buttons)
    return awful.widget.taglist(screen_number, awful.widget.taglist.filter.all, buttons)
  end

end

taglist.buttons = awful.util.table.join(
awful.button(k_n, 1, awful.tag.viewonly),
awful.button(k_m, 1, awful.client.movetotag),
awful.button(k_n, 3, awful.tag.viewtoggle),
awful.button(k_m, 3, awful.client.toggletag),
awful.button(k_n, 4, taglist.viewnext),
awful.button(k_n, 5, taglist.viewprev),
nil
)

function taglist.new(screen_number)
  return taglist._new(screen_number, taglist.buttons)
end

return utils.widget_class(taglist)

-- }}}

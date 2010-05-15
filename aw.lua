
require('awful')
require('awful.rules')
require('beautiful')

package.path = awful.util.getdir('config') .. '/lib/?.lua;' .. package.path
package.cpath = awful.util.getdir('config') .. '/lib/?.so;' .. package.cpath

-- {{{ Variable definitions

-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir('config') .. '/theme.lua')

terminal = 'xterm'

modkey = 'Mod4'
k_n    = {}
k_m    = { modkey }
k_ms   = { modkey, 'Shift' }
k_mc   = { modkey, 'Control' }

-- }}}

-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1 }, s, awful.layout.suit.max)
end

-- }}}

-- {{{ Wibox

-- {{{ And the wibox itself

-- Create a wibox for each screen and add it
witop = {}
wibottom = {}

for s = 1, screen.count() do

  -- Create wiboxes
  witop[s]    = awful.wibox({ position = "top",    screen = s, height = beautiful.wibox_height, fg = beautiful.fg_normal, bg = beautiful.bg_normal })
  wibottom[s] = awful.wibox({ position = "bottom", screen = s, height = beautiful.wibox_height, fg = beautiful.fg_normal, bg = beautiful.bg_normal })

  -- Add widgets to wiboxes - order matters
  witop[s].widgets =
  {
    layout = awful.widget.layout.horizontal.leftright,
  }

  wibottom[s].widgets =
  {
    layout = awful.widget.layout.horizontal.leftright,
  }
end

-- }}}

-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(

awful.key(k_m, 'j', function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end),
awful.key(k_m, 'k', function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),

-- Standard program
awful.key(k_m, 'Return', function () awful.util.spawn(terminal) end),
awful.key(k_mc, 'r', awesome.restart),
awful.key(k_ms, 'q', awesome.quit)

)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     size_hints_honor = false } },
}
-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.add_signal('manage', function (c, startup)

  -- Enable sloppy focus
  c:add_signal('mouse::enter', function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end
end)

client.add_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.add_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- vim: foldmethod=marker

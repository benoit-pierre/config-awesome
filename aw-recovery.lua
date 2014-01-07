
local awful = require('awful')

-- {{{ Variable definitions

terminal = 'xterm'

modkey = 'Mod4'
k_n    = {}
k_m    = { modkey }
k_ms   = { modkey, 'Shift' }
k_mc   = { modkey, 'Control' }

-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1 }, s, awful.layout.suit.max)
end

-- }}}

-- {{{ Key bindings

-- Global.
globalkeys = awful.util.table.join(
awful.key(k_m, 'semicolon', function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),
awful.key(k_m, 'o', function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end),
awful.key(k_m, 'Return', function () awful.util.spawn(terminal) end),
awful.key(k_mc, 'r', awesome.restart),
awful.key(k_ms, 'q', awesome.quit)
)
root.keys(globalkeys)

-- Client
clientkeys = awful.util.table.join(
awful.key(k_m, 'f', function (c)
  awful.client.floating.toggle(c)
  if awful.client.property.get(c, 'floating') then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
  end
end)
)

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

  c.border_width = 1
  c:keys(clientkeys)

  if not startup then
    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
    client.focus = c
  end

end)

client.add_signal('focus', function(c) c.border_color = '#6a6a6a' end)
client.add_signal('unfocus', function(c) c.border_color = '#333333' end)

-- }}}

awful.util.spawn(terminal, false)


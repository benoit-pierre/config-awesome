
local awful = require('awful')
local naughty = require('naughty')
local utils = require('utils')

local keepassx = {}

function dbg(text)
  naughty.notify {
    text = text,
    timeout = 0,
  }
end

keepassx.run_or_raise = function ()

  local matcher = function (c)
    return awful.rules.match(c, { class = 'Keepassx' } )
  end

  for c in awful.client.iterate(matcher) do
    if client.focus then
      local s = client.focus.screen
      local t = awful.tag.selected(s)
      c:tags({ t })
    end
    c.hidden = false
    c.minimized = false
    awful.client.jumpto(c, false)
    return
  end

  awful.util.spawn('keepassx')

end

keepassx.callback = function (c)

  connect_signal(c, c, 'property::minimized', function (c)
    if c.minimized then
      c.hidden = true
    end
  end)

  awful.client.jumpto(c)

end

keepassx.rules =   {
  rule = { class = 'Keepassx' },
  callback = keepassx.callback,
  properties =
  {
    floating = true,
    sticky = true,
  },
}

return keepassx



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

keepassx.toggle = function ()

  local matcher = function (c)
    return awful.rules.match(c, { class = 'Keepassx' } )
  end

  for c in awful.client.iterate(matcher) do
    if client.focus == c then
      -- Keepassx is the current focused client, hide it.
      c.hidden = true
      return
    end
    -- Move the window on the current tag and focus it.
    local s = mouse.screen
    local t = awful.tag.selected(s)
    c:tags({ t })
    c.hidden = false
    awful.client.jumpto(c, false)
    return
  end

  -- No Keepassx window found, start it.
  awful.util.spawn('keepassx')

end

keepassx.callback = function (c)

  connect_signal(c, c, 'property::minimized', function (c)
    if c.minimized then
      c.hidden = true
    end
  end)

end

keepassx.rules =   {
  rule = { class = 'Keepassx' },
  callback = keepassx.callback,
  properties =
  {
    floating = true,
  },
}

return keepassx


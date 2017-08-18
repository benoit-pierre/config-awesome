
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
    return awful.rules.match(c, keepassx.rules.rule)
  end

  for c in client_iterate(matcher) do
    if client.focus == c then
      -- Keepassx is the current focused client, hide it.
      c.hidden = true
      return
    end
    -- Move the window on the current tag and focus it.
    local s = mouse.screen
    local t = screen_selected_tag(s)
    c:tags({ t })
    c.hidden = false
    client_jumpto(c, false)
    return
  end

  -- No Keepassx window found, start it.
  spawn('keepassxc')

end

keepassx.callback = function (c)

  connect_signal(c, c, 'property::minimized', function (c)
    if c.minimized then
      c.hidden = true
    end
  end)

end

keepassx.rules =   {
  rule = { class = 'keepassxc' },
  callback = keepassx.callback,
  properties =
  {
    floating = true,
  },
}

return keepassx


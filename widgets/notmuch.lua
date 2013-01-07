-- {{{ Notmuch mail status

local utils = require('widgets.utils')

local timeout = 60
local notmuch = {}

function notmuch.status()
  local f = io.popen('notmuch count tag:unread')
  local s = f:read('*a')
  local unread = 0 + s
  local text
  f:close()
  if 0 == unread then
    text = 'no unread mail'
  else
    text = utils.bold(unread) .. ' unread mail'
    if 1 ~= unread then
      text = text .. 's'
    end
  end
  return utils.widget_base(text)
end

if '3.4' == aw_ver then

  notmuch._new = function(t)
    local w = widget { type = 'textbox' }
    t:add_signal('timeout', function() w.text = notmuch.status() end)
    return w
  end

end

if '3.5' == aw_ver then

  local wibox = require('wibox')

  notmuch._new = function(t)
    local w = wibox.widget.textbox()
    t:connect_signal('timeout', function() w:set_markup(notmuch.status()) end)
    return w
  end

end

function notmuch.new()
  local t = timer { timeout = timeout }
  local w = notmuch._new(t)
  t:start()
  t:emit_signal('timeout')
  return w
end

return utils.widget_class(notmuch)

-- }}}

-- {{{ Notmuch mail status

local utils = require('widgets.utils')

-- Start by checking notmuch is actually present and configured.
if not os.execute('notmuch config get database.path') then
  return utils.dummy
end

local timeout = 60
local notmuch = {}

function notmuch.status()
  local f = io.popen('notmuch count tag:unread')
  local s = f:read('*a')
  local unread = tonumber(s) or 0
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

function notmuch.new()
  local w = utils.textbox()
  local t = timer { timeout = timeout }
  connect_signal(t, t, 'timeout', function() w:set_markup(notmuch.status()) end)
  t:emit_signal('timeout')
  t:start()
  return w
end

return utils.widget_class(notmuch)

-- }}}

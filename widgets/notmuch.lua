-- {{{ Notmuch mail status

local utils = require('widgets.utils')
local awutil = require('awful.util')

local timeout = 60
local notmuch = {}

function notmuch.status()

  local s = utils.pread('notmuch count tag:unread')
  local unread = tonumber(s) or 0

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

  -- Start by checking notmuch is actually present and configured.
  if not os.execute('notmuch config get database.path >/dev/null 2>&1') then
    return nil
  end

  local w = utils.textbox()
  local t = timer { timeout = timeout }

  connect_signal(t, t, 'timeout', function() w:set_markup(notmuch.status()) end)
  t:emit_signal('timeout')
  t:start()

  return w

end

return utils.widget_class(notmuch)

-- }}}

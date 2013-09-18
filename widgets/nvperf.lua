-- {{{ NVidia powermizer performance level status

local utils = require('widgets.utils')
local awful = require('awful')

local timeout = 1
local nvperf = {}

local function refresh(w)

  local level = awful.util.pread('nvperf')

  level = string.sub(level, 1, -2)
  if 'maximum' == level then
    level = utils.bold(level)
  end
  if w.locked then
    level = utils.hilight(level)
  end

  w.widget:set_markup(utils.widget_base(level))

end

local function toggle_lock(w)

  local level
  if w.locked then
    level = 'adapt'
  else
    level = 'max'
  end
  os.execute('nvperf >/dev/null ' .. level)
  w.locked = not w.locked
  w:refresh()

end

function nvperf.new()

  -- Start by checking nvperf is actually present.
  if not os.execute('nvperf >/dev/null 2>&1') then
    return nil
  end

  local w = {
    widget = utils.textbox();
    timer = timer { timeout = timeout };
    locked = false;
    refresh = refresh;
    toggle_lock = toggle_lock;
  }

  w:refresh()

  w.widget:buttons(awful.util.table.join(
  awful.button({}, 1, function () w:toggle_lock() end)
  ))

  connect_signal(w.timer, w.timer, 'timeout', function () w:refresh() end)
  w.timer:start()

  return w.widget

end

return utils.widget_class(nvperf)

-- }}}

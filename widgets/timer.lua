-- {{{ Timer

local utils = require('widgets.utils')
local awful = require('awful')
local ctimer = timer

local timer = {}

local function toggle(w)

  if w.started then
    w.started = false
    w.timer:stop()
    w.elapsed = w.elapsed + os.difftime(os.time(), w.start_time)
    w.start_time = nil
  else
    w.start_time = os.time()
    w.timer:start()
    w.started = true
  end

end

local function reset(w)

  w.elapsed = 0
  w.start_time = os.time()
  w.widget:set_markup(utils.widget_base('00:00:00'))

end

local function refresh(w)

  s = os.difftime(os.time(), w.start_time) + w.elapsed
  m = math.floor(s / 60)
  s = s - m * 60
  h = math.floor(m / 60)
  m = m - h * 60
  w.widget:set_markup(utils.widget_base(string.format('%02u:%02u:%02u', h, m, s)))

end

function timer.new()

  local w = {
    widget = utils.textbox();
    timer = ctimer { timeout = 0.2 };
    started = false;
    reset = reset;
    toggle = toggle;
    refresh = refresh;
  }

  w:reset()

  w.widget:buttons(awful.util.table.join(
  awful.button({}, 1, function () w:toggle() end),
  awful.button({}, 3, function () w:reset() end)
  ))

  connect_signal(w.timer, w.timer, 'timeout', function () w:refresh() end)

  return w.widget

end

return utils.widget_class(timer)

-- }}}

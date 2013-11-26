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
  w:refresh()

end

local function refresh(w)

  local t

  if not w.mouseover and not w.started and 0 == w.elapsed then
    t = 'T'
  else
    local h, m, s

    s = w.elapsed

    if w.started then
      s = s + os.difftime(os.time(), w.start_time)
    end

    m = math.floor(s / 60)
    s = s - m * 60
    h = math.floor(m / 60)
    m = m - h * 60
    t = string.format('%02u:%02u:%02u', h, m, s)
  end

  w.widget:set_markup(utils.widget_base(t))

end

function timer.new()

  local w = {
    widget = utils.textbox();
    timer = ctimer { timeout = 0.2 };
    started = false;
    reset = reset;
    toggle = toggle;
    refresh = refresh;
    mouseover = false;
  }

  w:reset()

  w.widget:buttons(awful.util.table.join(
  awful.button({}, 1, function () w:toggle() end),
  awful.button({}, 3, function () w:reset() end)
  ))

  local function on_mouseover(enter)

    w.mouseover = enter
    w:refresh()

  end

  connect_signal(w.widget, w.widget, 'mouse::enter', function () on_mouseover(true) end)
  connect_signal(w.widget, w.widget, 'mouse::leave', function () on_mouseover(false) end)

  connect_signal(w.timer, w.timer, 'timeout', function () w:refresh() end)

  return w.widget

end

return utils.widget_class(timer)

-- }}}

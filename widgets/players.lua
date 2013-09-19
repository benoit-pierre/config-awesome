-- {{{ Media players handling.

local utils = require('widgets.utils')
local beautiful = require('beautiful')
local awful = require('awful')

local timeout = 1
local players = {}

local w = {}

w.properties =
{
  floating = true,
  focus = false,
  ontop = true,
  sticky = true,
  skip_taskbar = true,
  size_hints_honor = true,
}

function w.control(w, c, cmd)
  c = c or w.players[1]
  if not c then
    return
  end
  awful.util.spawn('mp-control '..c.pid..' '..cmd)
end

function w.toggle(w, c)
  c = c or w.players[1]
  if not c then
    return
  end
  c.hidden = not c.hidden
  local cmd
  if c.hidden then
    cmd = 'pause'
  else
    cmd = 'resume'
  end
  w:control(c, cmd)
end

function w.place(w, c)

  c = c or w.players[1]
  if not c then
    return
  end

  if c.fullscreen or not awful.client.floating.get(c) then
    return
  end

  local g = c:geometry()
  local s = screen[c.screen]

  -- Place on top right of the screen.
  local ng = {
    x = s.geometry.width - g.width - c.border_width,
    y = beautiful.wibox_height + c.border_width,
    width = g.width,
    height = g.height,
  }

  if ng.x ~= g.x or ng.y ~= g.y then
    c:geometry(ng)
  end

end

function w.unmanage(w, c)

  c = c or w.players[1]
  if not c then
    return
  end

  for k, v in ipairs(w.players) do
    if v == c then
      table.remove(w.players, k)
    end
  end

  local pc = w.players[1]
  if pc and pc.hidden then
    pc.hidden = false
    w:control(pc, 'resume')
  end

  w:refresh()

end

function w.manage(w, c)

  -- Hide and pause previous player.
  local pc = w.players[1]
  if pc then
    w:control(pc, 'pause')
    pc.hidden = true
  end

  -- Add to the list.
  table.insert(w.players, 1, c)

  -- Remove from list on exit, and show/resume previous player (if applicable).
  connect_signal(c, c, 'unmanage', w.on_unmanage)

  -- Force click to focus.
  awful.client.property.set(c, 'nofocus', true)

  -- Placement, need to be delayed for MPlayer/Vlc...
  c.hidden = true
  local t = timer { timeout = 0.1 }
  connect_signal(t, t, 'timeout', function ()
    t:stop()
    w:place(c)
    c.hidden = false
  end)
  t:start()

  -- Hide fullscreen client when loosing focus.
  connect_signal(c, c, 'unfocus', function (c)
    if c.fullscreen then
      w:toggle(c)
    end
  end)

  -- Restore ontop property when leaving fullscreen.
  connect_signal(c, c, 'property::fullscreen', function (c)
    if not c.fullscreen and awful.client.floating.get(c) then
      c.ontop = true
    end
  end)

  w:refresh()

end

function w.refresh(w)

  local text

  if w.selection then
    text = tostring(w.selection)..' - '..w.players[w.selection].name
  else
    text = tostring(#w.players)
  end

  w.widget:set_markup(utils.widget_base(text))

end

function w.select_start(w)

  if #w.players < 1 then
    return
  end

  local c

  w.selection = 1

  c = w.players[w.selection]
  c.hidden = false

  w:refresh()

end

function w.select_cycle(w, step)

  if #w.players < 2 then
    return
  end

  local c

  c = w.players[w.selection]
  w:control(c, 'pause')
  c.hidden = true

  w.selection = (w.selection -1 + #w.players + step) % #w.players + 1

  c = w.players[w.selection]
  c.hidden = false

  w:refresh()

end

function w.select_hide(w)

  if #w.players < 1 then
    return
  end

  local c

  c = w.players[w.selection]
  w:control(c, 'pause')
  c.hidden = true

  w.selection = nil

  w:refresh()

end

function w.select_kill(w)

  if #w.players < 1 then
    return
  end

  local c

  c = w.players[w.selection]

  disconnect_signal(c, c, 'unmanage', w.on_unmanage)

  for k, v in ipairs(w.players) do
    if v == c then
      table.remove(w.players, k)
    end
  end

  c:kill()

  if 0 == #w.players then
    w.selection = nil
  else
    if w.selection > 1 then
      w.selection = (w.selection -2) % #w.players + 1
    end
    c = w.players[w.selection]
    c.hidden = false
  end

  w:refresh()

end

function w.select_end(w)

  if not w.selection then
    return
  end

  local c

  c = w.players[w.selection]

  if 1 ~= w.selection then
    table.remove(w.players, w.selection)
    table.insert(w.players, 1, c)
  end

  if not c.hidden then
    w:control(nil, 'resume')
  end

  w.selection = nil

  w:refresh()

end

function players.new()

  local w = awful.util.table.clone(w)

  w.players = {};
  w.widget = utils.textbox();
  w.on_unmanage = function (c) w:unmanage(c) end

  w.widget:buttons(awful.util.table.join(
  awful.button({}, 1, function () w:select_hide() end),
  awful.button({}, 3, function () w:select_kill() end),
  awful.button({}, 4, function () w:select_cycle(-1) end),
  awful.button({}, 5, function () w:select_cycle( 1) end)
  ))

  connect_signal(w.widget, w.widget, 'mouse::enter', function () w:select_start() end)
  connect_signal(w.widget, w.widget, 'mouse::leave', function () w:select_end() end)

  w:refresh()

  return w

end

return utils.widget_class(players)

-- }}}

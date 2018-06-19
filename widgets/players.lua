-- {{{ Media players handling.

local wutils = require('widgets.utils')
local beautiful = require('beautiful')
local awful = require('awful')
local utils = require('utils')

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

-- Persistent state support.
w.client_fields = {}
w.client_properties = { 'player_idx' }

function w.control(w, c, cmd)
  c = c or w.players[1]
  if not c then
    return
  end
  cmd = string.format('mp-control %u %s', c.pid, cmd)
  spawn(cmd)
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

  if c.fullscreen or not awful.client.property.get(c, 'floating') then
    return
  end

  local g = c:geometry()
  local s = screen[c.screen]

  -- Place on top right of the screen.
  local ng = {
    x = s.geometry.width - g.width - 2 * c.border_width,
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

  local managed = false

  for k, v in ipairs(w.players) do
    if v == c then
      table.remove(w.players, k)
      w:update_indexes()
      local pc = w.players[1]
      if pc and pc.hidden then
        w:toggle(pc)
      end
      w:refresh()
      return
    end
  end

end

function w.manage(w, c)

  local player_idx = awful.client.property.get(c, 'player_idx')

  if not player_idx then

    player_idx = #w.players + 1
    awful.client.property.set(c, 'player_idx', player_idx)

    -- Start paused unless not other players are active.
    local startup = not w.players[1]

    -- Force click to focus.
    awful.client.property.set(c, 'nofocus', true)

    -- Placement, need to be delayed for MPlayer/Vlc...
    c.hidden = true
    local t = timer { timeout = 0.1 }
    connect_signal(t, t, 'timeout', function ()
      t:stop()
      w:place(c)
      if startup then
        w:toggle(c)
      end
    end)
    t:start()

  end

  -- Add to the list.
  w.players[player_idx] = c

  -- Add player index to persistent state properties.
  local state_properties = awful.client.property.get(c, 'state_properties')
  if not state_properties then
    state_properties = {}
    awful.client.property.set(c, 'state_properties', state_properties)
  end
  table.insert(state_properties, 'player_idx')

  -- Show progress when entering window.
  local mouse_over = false
  connect_signal(c, c, 'mouse::enter', function (c)
    if not mouse_over then
      mouse_over = c == mouse.object_under_pointer()
      if mouse_over then
        w:control(c, 'show-progress')
      end
    end
  end)
  connect_signal(c, c, 'mouse::leave', function (c)
    if mouse_over then
      mouse_over = c == mouse.object_under_pointer()
    end
  end)

  -- Restore ontop property when leaving fullscreen.
  connect_signal(c, c, 'property::fullscreen', function (c)
    if not c.fullscreen and awful.client.property.get(c, 'floating') then
      c.ontop = true
    end
  end)

  -- Raise and give back focus when fullscreen and not hidden anymore.
  connect_signal(c, c, 'property::hidden', function (c)
    if c.fullscreen and not c.hidden then
      client.focus = c
      c:raise()
    end
  end)

  -- Hide fullscreen client when loosing focus.
  connect_signal(c, c, 'unfocus', function (c)
    if c.fullscreen and not c.hidden then
      w:toggle(c)
    end
  end)

  connect_signal(c, c, 'property::width', function (c)
    w:place(c)
  end)

  w:refresh()

end

function w.refresh(w)

  local text

  if w.selection then
    name = awful.util.escape(w.players[w.selection].name)
    text = tostring(w.selection)..' - '..name
  else
    text = tostring(#w.players)
  end

  w.widget:set_markup(wutils.widget_base(text))

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

  for k, v in ipairs(w.players) do
    if v == c then
      table.remove(w.players, k)
      w:update_indexes()
      break
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
    w:update_indexes()
  end

  if c and not c.hidden then
    w:control(nil, 'resume')
  end

  w.selection = nil

  w:refresh()

end

function w.update_indexes(w)
  for k, v in ipairs(w.players) do
    awful.client.property.set(v, 'player_idx', k)
  end
end

function players.new()

  local w = awful.util.table.clone(w)

  w.players = {}
  w.widget = wutils.textbox()

  w.widget:buttons(awful.util.table.join(
  awful.button({}, 1, function () w:select_hide() end),
  awful.button({}, 3, function () w:select_kill() end),
  awful.button({}, 4, function () w:select_cycle(-1) end),
  awful.button({}, 5, function () w:select_cycle( 1) end)
  ))

  -- Remove from list on exit, and show/resume previous player (if applicable).
  connect_signal(client, 'unmanage', function (c) w:unmanage(c) end)

  connect_signal(w.widget, w.widget, 'mouse::enter', function () w:select_start() end)
  connect_signal(w.widget, w.widget, 'mouse::leave', function () w:select_end() end)

  w:refresh()

  return w

end

return wutils.widget_class(players)

-- }}}

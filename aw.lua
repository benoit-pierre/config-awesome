
local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')

-- {{{ Global variable definitions.

-- {{{ Version dependent code.

aw_ver = 0.0 + awesome.version:match('v([0-9].[0-9]).?')

if aw_ver >= 4.0 then
  local gears = require('gears')
  function connect_signal(instance, ...)
    instance.connect_signal(...)
  end
  function disconnect_signal(instance, ...)
    instance.disconnect_signal(...)
  end
  function tag_screen(t)
    return t.screen
  end
  function tag_viewonly(t)
    t:view_only(t)
  end
  function client_jumpto(c, merge)
    c:jump_to(merge)
  end
  function client_movetotag(tag, c)
    if c == nil then
      c = client.focus
    end
    c:move_to_tag(tag)
  end
  function client_toggletag(tag, c)
    if c == nil then
      c = client.focus
    end
    c:toggle_tag(tag)
  end
  function screen_index(s)
    return s.index
  end
  function screen_selected_tag(s)
    return s.selected_tag
  end
  client_iterate = awful.client.iterate
  spawn = awful.spawn
  timer = gears.timer
elseif aw_ver >= 3.5 then
  function connect_signal(instance, ...)
    instance.connect_signal(...)
  end
  function disconnect_signal(instance, ...)
    instance.disconnect_signal(...)
  end
  function tag_screen(t)
    return awful.tag.getscreen(t)
  end
  function client_jumpto(c, merge)
    awful.client.jumpto(c, merge)
  end
  function screen_index(s)
    return s
  end
  client_iterate = awful.client.iterate
  client_movetotag = awful.client.movetotag
  client_toggletag = awful.client.toggletag
  screen_selected_tag = awful.tag.selected
  spawn = awful.util.spawn
  tag_viewonly = awful.tag.viewonly
elseif aw_ver >= 3.4 then
  function connect_signal(instance, ...)
    instance.add_signal(...)
  end
  function disconnect_signal(instance, ...)
    instance.remove_signal(...)
  end
  function tag_screen(t)
    return t.screen
  end
  function client_jumpto(c, merge)
    local s = client.focus and client.focus.screen or mouse.screen
    if s ~= c.screen then
      mouse.screen = c.screen
    end
    local t = c:tags()[1]
    if t and not c:isvisible() then
        if merge then
            t.selected = true
        else
            tag_viewonly(t)
        end
    end
    client.focus = c
    c:raise()
  end
  function screen_index(s)
    return s
  end
  client_iterate = awful.client.cycle
  client_movetotag = awful.client.movetotag
  client_toggletag = awful.client.toggletag
  screen_selected_tag = awful.tag.selected
  spawn = awful.util.spawn
  tag_viewonly = awful.tag.viewonly
end

-- Must be sourced after global functions/variables definitions.
local keepassx = require('keepassx')
local utils = require('utils')

-- }}}

-- Directories.
config_dir = awful.util.getdir('config')
icons_dir = config_dir..'/icons'

-- Themes define colours, icons, and wallpapers.
beautiful.init(config_dir..'/theme.lua')

-- Configure notifications icon size.
if aw_ver >= 3.5 then
  naughty.config.defaults.icon_size = '48'
end

-- Programs.
editor = 'gvim -f'
terminal = 'term'
calculator = 'term -rc calc'
screenlocker = 'xdg-screensaver lock'

-- Modifiers.
modkey = 'Mod4'
k_n    = {}
k_m    = { modkey }
k_ms   = { modkey, 'Shift' }
k_mc   = { modkey, 'Control' }
k_mcs  = { modkey, 'Control', 'Shift' }

-- Icons.
awesome_icon = icons_dir..'/awesome.png'

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
}

-- Track mouse coordinates for each screen.
screen_mouse_coords = {}
for s = 1, screen.count() do
  local g = screen[s].geometry
  local x = g.x + g.width / 2
  local y = g.y + g.height / 2
  screen_mouse_coords[s] = { x = x; y = y }
end

-- }}}

-- {{{ Utility functions.

-- {{{ Client focus.

-- Focus next/previous.
function focus_by_idx(step)
  awful.client.focus.byidx(step)
  if client.focus then
    client.focus:raise()
  end
end
function focus_next() focus_by_idx(1) end
function focus_previous() focus_by_idx(-1) end

-- Focus next/previous visible client.
function focus_visible_by_idx(step)
  local fc = client.focus
  local nc = fc
  while true do
    nc = awful.client.next(step, nc)
    if not nc or nc == c then
      break
    end
    if nc:isvisible() then
      client.focus = nc
      break
    end
  end
end
function focus_visible_next() focus_visible_by_idx(1) end
function focus_visible_previous() focus_visible_by_idx(-1) end

-- }}}

-- {{{ Client (automatic) bottom left placement.

function place_bottom_left(c)
  local g = c:geometry()
  local s = screen[c.screen]
  local y = (s.geometry.height - (g.height + beautiful.wibox_height))
  if awful.client.property.get(c, 'old_width') ~= g.width and y ~= g.y then
    awful.client.property.set(c, 'old_width', g.width)
    g.y = y
    c:geometry(g)
  end
end

function setup_autoplace_bottom_left(c)
  place_bottom_left(c)
  connect_signal(c, c, 'property::height', place_bottom_left)
end

-- }}}

-- {{{ Client keymap handling.

local default_keymap = 'colemak'
local alternate_keymap = 'us'
local current_keymap = default_keymap

function client_apply_keymap(c)
  local keymap = awful.client.property.get(c, 'keymap')
  if not keymap then
    keymap = default_keymap
  end
  if keymap == current_keymap then
    return
  end
  local cmd = 'setxinput -k'
  if keymap ~= default_keymap then
    cmd = cmd..' '..keymap
  end
  os.execute(cmd)
  current_keymap = keymap
  client.emit_signal('keymap', keymap)
end

function client_toggle_keymap(c)
  local keymap = awful.client.property.get(c, 'keymap')
  if keymap and keymap ~= default_keymap then
    keymap = default_keymap
  else
    keymap = alternate_keymap
  end
  awful.client.property.set(c, 'keymap', keymap)
  client_apply_keymap(c)
end

if aw_ver >= 4.0 then
elseif aw_ver >= 3.5 then
  client.add_signal('keymap')
end
connect_signal(client, 'focus', client_apply_keymap)

-- }}}

-- {{{ Client move/resize handling.

function client_move_resize(c, x, y, d)
  local g = c:geometry()
  local s = screen[c.screen]
  local sw
  local sh
  local w
  local h

  -- Translation.
  x = math.floor(s.geometry.width * x / 100 + 0.5)
  y = math.floor(s.geometry.height * y / 100 + 0.5)

  -- Remove top wibox from equation, force inside screen.
  -- g.x = g.x - c.border_width
  if g.x < 0 then
    x = x - g.x
    g.x = 0
  end
  -- g.y = g.y - c.border_width - beautiful.wibox_height
  g.y = g.y - beautiful.wibox_height
  if g.y < 0 then
    y = y - g.y
    g.y = 0
  end

  -- Usable screen width/height.
  sw = s.geometry.width - 2 * c.border_width
  sh = s.geometry.height - 2 * c.border_width - 2 * beautiful.wibox_height

  -- New width/height.
  w = g.width + math.floor(g.width * d / 100 + 0.5)
  h = math.floor(w * g.height / g.width + 0.5)

  if w < g.width and (g.x + g.width) >= (sw - 10) then
    x = x + g.width - w
  end

  if h < g.height and (g.y + g.height) >= (sh - 10) then
    y = y + g.height - h
  end

  if (g.x + x) < 0 then
    x = -g.x
  end
  if (g.x + w + x) > sw then
    x = sw - w - g.x
  end

  if (g.y + y) < 0 then
    y = -g.y
  end
  if (g.y + h + y) > sh then
    y = sh - h - g.y
  end

  awful.client.moveresize(x, y, w - g.width, h - g.height, c)
end

-- }}}

-- }}}

-- {{{ State handling.

local state = {}

state.filename = awful.util.getdir('config') .. '/state_' .. os.getenv('DISPLAY')

state.client_fields = {
  'above',
  'below',
  'fullscreen',
  'hidden',
  'maximized_horizontal',
  'maximized_vertical',
  'minimized',
  'ontop',
  'screen',
  'size_hints_honor',
  'sticky',
  'urgent',
}

state.client_properties = {
  'floating_geometry',
  'floating',
  'nofocus',
}

state.state = nil

-- {{{ Saving.

function state.save()

  local s = {}

  -- Global state.
  s.focus = client.focus and client.focus.window
  s.mouse = mouse.coords()

  -- Clients state.
  for c in client_iterate(function () return true end) do
    local client_state = {}
    for k, v in ipairs(state.client_properties) do
      client_state[v] = awful.client.property.get(c, v)
    end
    for k, v in ipairs(state.client_fields) do
      if aw_ver >= 4.0 and v == 'screen' then
        client_state[v] = c[v].index
      else
        client_state[v] = c[v]
      end
    end
    client_state.geometry = c:geometry()
    s[c.window] = client_state
  end

  -- Write it...
  local f = io.open(state.filename, 'w+')
  f:write('local state\n')
  utils.serialize(f, 'state', s)
  f:write('return state\n')
  f:close()

end

--- }}}

--- {{{ Restoring.

function state.restore()

  -- Do we have a state file?
  if not awful.util.file_readable(state.filename) then
    return
  end

  -- Read it.
  local rc, err = loadfile(state.filename)
  if rc then
    rc, err = xpcall(rc, debug.traceback)
  end
  if not rc then
    -- Rename state file for later inspection.
    os.rename(state.filename, state.filename..'~')
    naughty.notify {
      text = 'Error loading state file:\n\n' .. err,
      timeout = 0,
    }
    return
  end

  -- And remove it so we don't try to read it later.
  os.remove(state.filename)

  state.state = err

end

state.restore()

--- }}}

-- Will check configuration is still valid before restarting.
function awesome_restart()
  local rc, err = loadfile(awful.util.getdir('config') .. '/aw.lua')
  if rc then
    state.save()
    awesome.restart()
    return
  end
  naughty.notify {
    text = 'Invalid configuration:\n\n' .. err .. '\n\nAborting restart.',
    timeout = 0,
  }
end

-- }}}

-- {{{ Session handling.

function xsession_kill(signal)
  xsession_pid = os.getenv('XSESSION_PID')
  spawn('kill -'..signal..' '..xsession_pid)
end

function lock()
  spawn(screenlocker)
end

function logout()
  awesome.quit()
end

function hibernate()
  lock()
  spawn('shutdown -S')
end

function suspend()
  lock()
  spawn('shutdown -s')
end

function reboot()
  xsession_kill('USR1')
  logout()
end

function halt()
  xsession_kill('USR2')
  logout()
end

-- }}}

-- {{{ Tags.

-- Define a tag table which hold all screen tags.
local ns = screen.count()
local nw = 8 / screen.count()
if nw == 0 then nw = 1 end
local wn = 0
tags_by_num = {}
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  local t = {}
  for n = 1, nw do t[n] = wn + n end
  tags[s] = awful.tag(t, s, awful.layout.suit.max)
  for n = 1, nw do
    tags_by_num[wn + n] = tags[s][n]
  end
  wn = wn + nw
end

-- Use floating layout for 5th tag.
awful.layout.set(awful.layout.suit.floating, tags_by_num[5])

-- }}}

-- {{{ Menu.

-- Awesome.
awesomemenu =
{
   { 'edit config', editor..' '..config_dir..'/aw.lua' },
   { 'restart', awesome_restart },
   { 'quit', function() awesome.quit() end },
}

-- Programs.
programsmenu =
{
    { 'editor', editor },
    { 'terminal', terminal },
}

-- Session.
sessionmemenu =
{
  { 'lock', lock },
  { 'logout', logout },
}

-- Machine.
machinememenu =
{
  { 'hibernate', hibernate },
  { 'suspend', suspend },
  { 'reboot', reboot },
  { 'halt', halt },
}

-- Main menu.
mainmenu = awful.menu({
  items =
  {
    { 'programs', programsmenu },
    { 'session', sessionmemenu },
    { 'machine', machinememenu },
    { 'awesome', awesomemenu },
  }
})
function mainmenu_show()
  mainmenu:show({ keygrabber = true })
end

-- Power menu.
powermenu = awful.menu({
  items = machinememenu
})
function powermenu_show()
  powermenu:show({ keygrabber = true })
end

-- }}}

-- {{{ Wiboxes.

-- Must be sourced after global functions/variables definitions.
local widgets = require('widgets')

-- Create a wibox for each screen and add it.
witop = {}
wibottom = {}

-- Clock.
clockbox = widgets.clock()

-- Keymap.
keymapbox = widgets.utils.textbox()
keymapbox.update = function (self)
  self:set_markup(widgets.utils.widget_base(current_keymap))
end
keymapbox:update()
connect_signal(client, 'keymap', function () keymapbox:update() end)

-- Timer.
timerbox = widgets.timer()

-- Layouts.
layoutbox = {}

-- Media players handling.
players = widgets.players()
state.client_fields = awful.util.table.join(state.client_fields, players.client_fields)
state.client_properties = awful.util.table.join(state.client_properties, players.client_properties)
function players_callback(c)
  players:manage(c)
end

-- Menu launcher.
menulauncher = awful.widget.launcher({ image = awesome_icon, menu = mainmenu })

-- Notmuch mail status.
-- nmmailbox = widgets.notmuch()

-- NVPerf status.
-- nvperfbox = widgets.nvperf()

-- Prompt.
promptbox = {}

-- Systray.
systray = widgets.systray()

-- Taglist.
taglist = {}

-- Tasklist.
tasklist = {}

function configure_screen(s)

  -- Per screen widgets.
  layoutbox[s] = widgets.layoutbox(s)
  promptbox[s] = awful.widget.prompt()
  taglist[s] = widgets.taglist(s)
  tasklist[s] = widgets.tasklist(s)

  -- Create wiboxes.

  witop[s] = widgets.wibox('top', s,
  {
    -- Left widgets.
    menulauncher,
    taglist[s],
    layoutbox[s],
  },
  {
    -- Middle widgets.
    tasklist[s],
  },
  {
    -- Right widgets.
    players.widget,
  })

  wibottom[s] = widgets.wibox('bottom', s,
  {
    -- Left widgets.
    clockbox,
    timerbox,
    -- nmmailbox,
    -- nvperfbox,
    keymapbox,
    promptbox[s],
  },
  {
    -- Middle widgets.
  },
  {
    -- Right widgets.
    screen_index(s) == 1 and systray or nil,
  })

end

if aw_ver >= 4.0 then
  awful.screen.connect_for_each_screen(configure_screen)
else
  for s = 1, screen.count() do
    configure_screen(s)
  end
end

-- }}}

-- {{{ Key bindings.

globalkeys = awful.util.table.join(

-- {{{ Client manipulation, global part.

awful.key(k_m, 'Down',
function ()
  c = client.focus
  if c then
    c:raise()
  end
end),
awful.key(k_m, 'Up',
function ()
  c = client.focus
  if c then
    c:lower()
  end
end),
awful.key(k_m, 'Left', focus_visible_previous),
awful.key(k_m, 'Right', focus_visible_next),
awful.key(k_m, 'n', function () awful.client.focus.bydirection('left') end),
awful.key(k_m, 'e', function () awful.client.focus.bydirection('down') end),
awful.key(k_m, 'u', function () awful.client.focus.bydirection('up') end),
awful.key(k_m, 'i', function () awful.client.focus.bydirection('right') end),
awful.key(k_m, 'semicolon', function () focus_by_idx(-1) end),
awful.key(k_m, 'colon', function () focus_by_idx(-1) end),
awful.key(k_m, 'o', function () focus_by_idx(1) end),

-- }}}

-- {{{ Menus.

awful.key(k_m, 'Menu', mainmenu_show),
awful.key(k_m, 'm', mainmenu_show),

-- }}}

-- {{{ Media players.

awful.key(k_m, 'grave', function () players:toggle() end),

-- }}}

-- {{{ Programs.

awful.key(k_m, 'Return', function () spawn(terminal) end),
awful.key(k_mc, 'r', awesome_restart),
awful.key(k_ms, 'q', awesome.quit),

awful.key(k_n, 'XF86Calculator', function () spawn(calculator) end),
awful.key(k_n, 'XF86Eject', function () spawn('eject -T') end),

awful.key(k_m, 'k', keepassx.toggle),

-- }}}

-- {{{ Power management.

awful.key(k_n, 'XF86PowerOff', powermenu_show),

-- }}}

-- {{{ Prompts.

awful.key(k_m, 'r', function () promptbox[mouse.screen]:run() end),

-- }}}

awful.key(k_ms, 'l', function () awful.layout.inc(layouts, 1) end),

nil

)

-- {{{ Client manipulation, client part.

clientkeys = awful.util.table.join(
awful.key(k_m, 'c', function (c) c:kill() end),
awful.key(k_m, 'f', function (c)
  awful.client.floating.toggle(c)
  if awful.client.property.get(c, 'floating') then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
  end
end),
awful.key(k_m, 'x', function (c)
  local nofocus = not awful.client.property.get(c, 'nofocus')
  awful.client.property.set(c, 'nofocus', nofocus)
end),
awful.key(k_m, 'h', function (c) c.hidden = not c.hidden end),
awful.key(k_m, 's', function (c) c.sticky = not c.sticky end),
awful.key(k_m, 't', function (c) c.ontop = not c.ontop end),
awful.key(k_m, 'z', function (c) c.minimized = true end),
awful.key(k_m, 'Tab', client_toggle_keymap),
awful.key(k_ms, 'n',         function (c) client_move_resize(c, -5,  0,   0) end),
awful.key(k_ms, 'e',         function (c) client_move_resize(c,  0,  5,   0) end),
awful.key(k_ms, 'u',         function (c) client_move_resize(c,  0, -5,   0) end),
awful.key(k_ms, 'i',         function (c) client_move_resize(c,  5,  0,   0) end),
awful.key(k_ms, 'semicolon', function (c) client_move_resize(c,  0,  0,  10) end),
awful.key(k_ms, 'colon',     function (c) client_move_resize(c,  0,  0,  10) end),
awful.key(k_ms, 'o',         function (c) client_move_resize(c,  0,  0, -10) end),
nil
)

-- }}}

-- {{{ Assign keys for each tag.

-- Bind keyboard digits.
-- Compute the maximum number of digit we need, limited to 12.
local keynumber = #tags_by_num

local digits_alternate_keys = {
  'exclam',
  'at',
  'numbersign',
  'dollar',
  'percent',
  'asciicircum',
  'ampersand',
  'asterisk',
  'parenleft',
}
digits_alternate_keys[0] = 'parenright'

for i = 1, keynumber do
  local keys = {
    i % 10, -- 10 become 0
    digits_alternate_keys[i % 10],
  }
  for n, k in pairs(keys) do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key(k_m, k,
      function ()
        local t = tags_by_num[i]
        local ms = mouse.screen
        local ts = tag_screen(t)
        if ms ~= ts then
          screen_mouse_coords[ms] = mouse.coords()
          mouse.coords(screen_mouse_coords[ts])
        end
        tag_viewonly(t)
      end),
    awful.key(k_mc, k,
      function ()
        local ms = mouse.screen
        if tags[ms][i] then
          awful.tag.viewtoggle(tags[ms][i])
        end
      end),
    awful.key(k_ms, k,
      function ()
        local c = client.focus
        if c and tags_by_num[i] then
          local mc
          local cs = c.screen
          local t = tags_by_num[i]
          local ts = tag_screen(t)
          if ts ~= cs then
            mc = mouse.coords()
            awful.client.movetoscreen(c, ts)
          end
          client_movetotag(t, c)
          if ts ~= cs then
            mouse.coords(mc)
          end
        end
      end),
    awful.key(k_mcs, k,
      function ()
        local c = client.focus
        if c and tags_by_num[i] then
          client_toggletag(tags_by_num[i], c)
        end
      end))
    end
end

-- }}}

-- {{{ Client manipulation, mouse bindings.

clientbuttons = awful.util.table.join(
awful.button(k_n, 1, function (c) client.focus = c end),
awful.button(k_m, 1, awful.mouse.client.move),
awful.button(k_m, 3, awful.mouse.client.resize)
)

-- }}}

-- Set keys.
root.keys(globalkeys)

-- }}}

-- {{{ Rules.

awful.rules = require('awful.rules')

awful.rules.rules =
{
  -- All clients will match this rule.
  {
    rule = { },
    properties =
    {
      focus = true,
      raise = true,
      size_hints_honor = false,
    }
  },
  {
    rule = { name = 'calc' },
    properties =
    {
      floating = true,
    },
  },
  keepassx.rules,
  {
    rule = { class = 'Amphetype.py' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { class = 'Pavucontrol' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { name = 'Plover:.*' },
    properties =
    {
      focus = false,
      ontop = true,
      sticky = true,
      floating = true,
      skip_taskbar = true,
    },
  },
  {
    rule = { class = 'Klavaro' },
    properties =
    {
      floating = true,
    },
  },
  -- {{{ Media players.
  {
    rule = { class = 'mpv' },
    properties = players.properties,
    callback = players_callback,
  },
  {
    rule = { class = 'MPlayer' },
    properties = players.properties,
    callback = players_callback,
  },
  {
    rule = { class = 'Smplayer' },
    properties = players.properties,
    callback = players_callback,
  },
  {
    rule = { class = 'Umplayer' },
    properties = players.properties,
    callback = players_callback,
  },
  {
    rule = { class = 'Vlc' },
    properties = players.properties,
    callback = players_callback,
  },
  -- }}}
  -- {{{ Browsers.
  {
    rule = { class = 'Firefox' },
    properties =
    {
      tag = tags_by_num[2],
    },
  },
  {
    rule = { class = 'Google-chrome' },
    properties =
    {
      tag = tags_by_num[2],
    },
  },
  -- Fix for fullscreen flash videos.
  {
    rule = { class = 'Plugin-container' },
    properties =
    {
      floating = true,
    },
  },
  -- }}}
  -- {{{ Games.
  {
    rule = { class = 'Steam' },
    properties =
    {
      floating = true,
      tag = tags_by_num[5],
    },
  },
  {
    rule = { class = 'Wine' },
    properties =
    {
      floating = true,
      tag = tags_by_num[5],
    },
    callback = setup_autoplace_bottom_left,
  },
  -- }}}
  {
    rule = { class = 'Gajim' },
    properties =
    {
      floating = true,
      tag = tags_by_num[6],
    },
  },
  {
    rule = { name = 'sudo' },
    properties =
    {
      tag = tags_by_num[8],
    },
  },
  -- {{{ X utilities.
  {
    rule = { name = 'Event Tester' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { class = 'Xephyr' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { class = 'Xmessage' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { name = 'Xnest' },
    properties =
    {
      floating = true,
    },
  },
  -- }}}
}

-- }}}

-- {{{ Improved focus filter.

orig_focus_filter = awful.client.focus.filter

function focus_filter(c)
  if awful.client.property.get(c, 'nofocus') then
    return nil
  end
  return orig_focus_filter(c)
end

awful.client.focus.filter = focus_filter

-- }}}

-- {{{ Autofocus handling.

-- Use custom version with correct handling of sticky clients.
require('autofocus')

--- }}}

-- {{{ Signals.

-- No 'started' signal, so use this crude hack...
local starting = true
local t = timer { timeout = 0.0 }
connect_signal(t, t, 'timeout', function ()
  if state.state and state.state.mouse then
    mouse.coords(state.state.mouse, true)
  end
  starting = false
  t:stop()
  t = nil
end)
t:start()

disconnect_signal(client, 'manage', awful.rules.apply)

-- Signal function to execute when a new client appears.
function manage_client(c, startup)

  -- Enable sloppy focus.
  connect_signal(c, c, 'mouse::enter', function(c)
    if not starting
      and awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  c.border_width = beautiful.border_width
  c.border_color = beautiful.border_normal
  c:buttons(clientbuttons)
  c:keys(clientkeys)

  -- Put windows in a smart way, only if they does not set an initial position.
  if not c.size_hints.user_position and not c.size_hints.program_position then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
  end

  if not startup then
    -- Apply rules.
    awful.rules.apply(c)
    return
  end

  -- Try to restore state.
  local client_state = state.state and state.state[c.window]

  if not client_state then
    -- Apply rules.
    awful.rules.apply(c)
    return
  end

  for k, v in ipairs(state.client_properties) do
    awful.client.property.set(c, v, client_state[v])
  end
  for k, v in ipairs(state.client_fields) do
    c[v] = client_state[v]
  end

  -- Apply rules.
  awful.rules.apply(c)

  c:geometry(client_state.geometry)

  if state.state.focus == c.window then
    client_jumpto(c)
  end

end
if aw_ver >= 4.0 then
  connect_signal(client, 'manage', function (c) manage_client(c, awesome.startup) end)
elseif aw_ver >= 3.4 then
  connect_signal(client, 'manage', manage_client)
end

connect_signal(client, 'focus', function(c) c.border_color = beautiful.border_focus end)
connect_signal(client, 'unfocus', function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- vim: foldmethod=marker foldlevel=0

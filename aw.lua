
local awful = require('awful')
awful.autofocus = require('awful.autofocus')
awful.rules = require('awful.rules')
local beautiful = require('beautiful')
local naughty = require('naughty')

-- {{{ Global variable definitions

-- Awesome version
aw_ver = '???'
if awesome.version:match('v3[.]4[.]?') then
  aw_ver = '3.4'
end
if awesome.version:match('v3[.]5[.]?') then
  aw_ver = '3.5'
end

if '3.4' == aw_ver then
  function connect_signal(instance, ...)
    instance.add_signal(...)
  end
  function disconnect_signal(instance, ...)
    instance.remove_signal(...)
  end
end
if '3.5' == aw_ver then
  function connect_signal(instance, ...)
    instance.connect_signal(...)
  end
  function disconnect_signal(instance, ...)
    instance.disconnect_signal(...)
  end
end

-- Directories
config_dir = awful.util.getdir('config')
icons_dir = config_dir..'/icons'

-- Themes define colours, icons, and wallpapers
beautiful.init(config_dir..'/theme.lua')

-- Programs
editor = 'gvim -f'
terminal = 'term'
calculator = 'term -rc calc'
screenlocker = 'xtrlock'

-- Modifiers
modkey = 'Mod4'
k_n    = {}
k_m    = { modkey }
k_ms   = { modkey, 'Shift' }
k_mc   = { modkey, 'Control' }
k_mcs  = { modkey, 'Control', 'Shift' }

-- Icons
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
    awful.layout.suit.magnifier
}

-- }}}

-- {{{ Functions

-- {{{ Utils

-- Focus next/previous
function focus_by_idx(step)
  awful.client.focus.byidx(step)
  if client.focus then
    client.focus:raise()
  end
end
function focus_next() focus_by_idx(1) end
function focus_previous() focus_by_idx(-1) end

-- Focus next/previous visible client
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

-- Session handling {{{

function xsession_kill(signal)
  xsession_pid = os.getenv('XSESSION_PID')
  os.execute('kill -'..signal..' '..xsession_pid)
end

function logout()
  xsession_kill('CONT')
  awesome.quit()
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

-- }}}

-- Must be sourced after global functions/variables definitions.
local widgets = require('widgets')

-- {{{ Tags

-- Define a tag table which hold all screen tags.
local ns = screen.count()
local nw = 8 / screen.count()
if nw == 0 then nw = 1 end
local wn = 0
screen_by_tag = {}
tags_by_num = {}
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  local t = {}
  for n = 1, nw do t[n] = wn + n end
  tags[s] = awful.tag(t, s, awful.layout.suit.max)
  for n = 1, nw do
    tags_by_num[wn + n] = tags[s][n]
    screen_by_tag[wn + n] = s
  end
  wn = wn + nw
end

-- }}}

screen_mouse_coords = {}
for s = 1, screen.count() do
  local g = screen[s].geometry
  local x = g.x + g.width / 2
  local y = g.y + g.height / 2
  screen_mouse_coords[s] = { x = x; y = y }
end

-- {{{ Menu

-- Awesome
awesomemenu =
{
   { 'edit config', editor..' '..config_dir..'/aw.lua' },
   { 'restart', awesome.restart },
   { 'quit', awesome.quit },
}

-- Programs
programsmenu =
{
    { 'editor', editor },
    { 'terminal', terminal },
}

-- Session
sessionmemenu =
{
  { 'lock', screenlocker },
  { 'logout', logout },
}

-- Machine
machinememenu =
{
  { 'reboot', reboot },
  { 'halt', halt },
}

-- Main menu
mainmenu = awful.menu({
  items =
  {
    { 'programs', programsmenu },
    { 'session', sessionmemenu },
    { 'machine', machinememenu },
    { 'awesome', awesomemenu },
  }
})
function mainmenu_toggle()
  mainmenu:toggle({ keygrabber = true })
end

-- }}}

-- {{{ And the wibox itself

-- Create a wibox for each screen and add it
witop = {}
wibottom = {}

-- Clock box
clockbox = widgets.clock()

-- Layout box
layoutbox = {}

-- Menu launcher
menulauncher = awful.widget.launcher({ image = awesome_icon, menu = mainmenu })

-- Notmuch mail status
nmmailbox = widgets.notmuch()

-- Prompt box
promptbox = {}

-- Systray
systray = widgets.systray()

-- Taglist
taglist = {}

-- Tasklist
tasklist = {}

for s = 1, screen.count() do

  -- Per screen widgets
  layoutbox[s] = widgets.layoutbox(s)
  promptbox[s] = awful.widget.prompt()
  taglist[s] = widgets.taglist(s)
  tasklist[s] = widgets.tasklist(s)

  -- Create wiboxes

  witop[s] = widgets.wibox('top', s,
  {
    -- Left widgets
    menulauncher,
    taglist[s],
    layoutbox[s],
    tasklist[s],
  },
  {
    -- Right widgets
  })

  wibottom[s] = widgets.wibox('bottom', s,
  {
    -- Left widgets
    clockbox,
    nmmailbox,
    promptbox[s],
  },
  {
    -- Right widgets
    s == 1 and systray or nil,
  })

end

-- }}}

-- }}}

-- {{{ MPlayer handling

mplayer = nil

function mplayer_toggle()
  if not mplayer then
    return
  end
  mplayer.hidden = not mplayer.hidden
  local cmd
  if mplayer.hidden then
    cmd = 'pausing_keep_force pause'
  else
    cmd = 'pause'
  end
  awful.util.spawn('mp-control '..mplayer.pid..' '..cmd)
end

connect_signal(client, 'unmanage', function (c)
  if mplayer == c then
    mplayer = nil
  end
end)

function mplayer_callback(c)
  awful.client.property.set(c, 'nofocus', true)
  mplayer = c
end

mplayer_properties =
{
  floating = true,
  focus = false,
  ontop = true,
  sticky = true,
  skip_taskbar = true,
  size_hints_honor = true,
}

-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(

-- {{{ Client manipulation, global part

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
awful.key(k_m, 'o', function () focus_by_idx(1) end),

-- }}}

-- {{{ Menus

awful.key(k_m, 'Menu', function () mainmenu_toggle() end),
awful.key(k_m, 'm', function () mainmenu_toggle() end),

-- }}}

-- {{{ MPlayer

awful.key(k_m, 'grave', mplayer_toggle),

-- }}}

-- {{{ Programs

awful.key(k_m, 'Return', function () awful.util.spawn(terminal) end),
awful.key(k_mc, 'r', awesome.restart),
awful.key(k_ms, 'q', awesome.quit),

awful.key(k_n, 'XF86Calculator', function () awful.util.spawn(calculator) end),
awful.key(k_n, 'XF86Eject', function () awful.util.spawn('eject -T') end),

-- }}}

-- {{{ Prompts

awful.key(k_m, 'r', function () promptbox[mouse.screen]:run() end),

-- }}}

-- {{{ Xkb layout

awful.key(k_m, 'F10', function () awful.util.spawn('setxkbd') end),
awful.key(k_m, 'F11', function () awful.util.spawn('setxkbmap us') end),
awful.key(k_m, 'F12', function () awful.util.spawn('setxkbmap fr') end),

-- }}}

awful.key(k_ms, 'l', function () awful.layout.inc(layouts, 1) end),

nil

)

-- {{{ Client manipulation, client part

clientkeys = awful.util.table.join(
awful.key(k_m, 'c', function (c) c:kill() end),
awful.key(k_m, 'f', function (c)
  awful.client.floating.toggle(c)
  if awful.client.property.get(c, 'floating') then
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
  end
end),
awful.key(k_m, 's', function (c) c.sticky = not c.sticky end),
awful.key(k_m, 't', function (c) c.ontop = not c.ontop end),
nil
)

-- }}}

-- {{{ Client (automatic) bottom left placement

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

-- {{{ Assign keys for each tag

-- Bind keyboard digits
-- Compute the maximum number of digit we need, limited to 12
local keynumber = #tags_by_num

for i = 1, keynumber do
  local k
  if i == 11 then
    k = "minus"
  elseif i == 12 then
    k = "equal"
  else
    k = i % 10 -- 10 become 0
  end
  globalkeys = awful.util.table.join(globalkeys,
    awful.key(k_m, k,
      function ()
        local ms = mouse.screen
        local ts = screen_by_tag[i]
        if ms ~= ts then
          screen_mouse_coords[ms] = mouse.coords()
          mouse.coords(screen_mouse_coords[ts])
        end
        awful.tag.viewonly(tags_by_num[i])
      end),
    awful.key(k_mc, k,
      function ()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewtoggle(tags[screen][i])
        end
      end),
    awful.key(k_ms, k,
      function ()
        local c = client.focus
        if c and tags_by_num[i] then
          local cs = c.screen
          local ts = screen_by_tag[i]
          local ms
          if ts ~= cs then
            ms = mouse.coords()
            awful.client.movetoscreen(c, ts)
          end
          awful.client.movetotag(tags_by_num[i])
          if ts ~= cs then
            mouse.coords(ms)
          end
        end
      end),
    awful.key(k_mcs, k,
      function ()
        if client.focus and tags_by_num[i] then
          awful.client.toggletag(tags_by_num[i])
        end
      end))
end

-- }}}

-- Client buttons
clientbuttons = awful.util.table.join(
awful.button(k_n, 1, function (c) client.focus = c end),
awful.button(k_m, 1, awful.mouse.client.move),
awful.button(k_m, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

awful.rules.rules =
{
  -- All clients will match this rule.
  {
    rule = { },
    properties =
    {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      size_hints_honor = false,
      keys = clientkeys,
      buttons = clientbuttons,
    }
  },
  {
    rule = { name = 'Event Tester' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { name = 'calc' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { class = 'Amphetype.py' },
    properties =
    {
      floating = true,
    },
  },
  {
    rule = { class = 'Klavaro' },
    properties =
    {
      floating = true,
    },
  },
  -- {{{ Media players
  {
    rule = { class = 'MPlayer' },
    properties = mplayer_properties,
    callback = mplayer_callback,
  },
  {
    rule = { class = 'Smplayer' },
    properties = mplayer_properties,
    callback = mplayer_callback,
  },
  {
    rule = { class = 'Umplayer' },
    properties = mplayer_properties,
    callback = mplayer_callback,
  },
  {
    rule = { class = 'Vlc' },
    properties = mplayer_properties,
    callback = mplayer_callback,
  },
  -- }}}
  -- {{{ Firefox
  {
    rule = { class = 'Firefox' },
    properties =
    {
      tag = tags_by_num[2],
    },
  },
  -- Fix for fullscreen flash videos
  {
    rule = { class = 'Plugin-container' },
    properties =
    {
      floating = true,
    },
  },
  -- }}}
  -- {{{ Games
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

orig_focus_history_add = awful.client.focus.history.add

function focus_history_add(c)
  if awful.client.property.get(c, 'nofocus') then
    return
  end
  orig_focus_history_add(c)
end

awful.client.focus.history.add = focus_history_add

disconnect_signal(client, 'focus', orig_focus_history_add)
connect_signal(client, 'focus', focus_history_add)

--- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
connect_signal(client, 'manage', function (c, startup)

  -- Enable sloppy focus
  connect_signal(c, c, 'mouse::enter', function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end
end)

connect_signal(client, 'focus', function(c) c.border_color = beautiful.border_focus end)
connect_signal(client, 'unfocus', function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- vim: foldmethod=marker


require('awful')
require("awful.autofocus")
require('awful.rules')
require('beautiful')
require('naughty')

package.path = awful.util.getdir('config') .. '/lib/?.lua;' .. package.path
package.cpath = awful.util.getdir('config') .. '/lib/?.so;' .. package.cpath

-- {{{ Variable definitions

-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir('config') .. '/theme.lua')

-- Programs
editor = 'gvim -f'
terminal = 'term'
screenlocker = 'xtrlock'

-- Modifiers
modkey = 'Mod4'
k_n    = {}
k_m    = { modkey }
k_ms   = { modkey, 'Shift' }
k_mc   = { modkey, 'Control' }
k_mcs  = { modkey, 'Control', 'Shift' }

-- Icons
awesome_icon = awful.util.getdir('config') .. '/icons/awesome.png'

-- }}}

-- {{{ Functions

-- {{{ Utils

-- Set background color
function bg(color, text)
  return '<bg color="' .. color .. '" />' .. text
end

-- Set foreground color
function fg(color, text)
  return '<span color="' .. color .. '">' .. text .. '</span>'
end

-- Boldify text
function bold(text)
  return '<b>' .. text .. '</b>'
end

-- Mono font
function mono(text)
  return '<span font_desc=">' .. beautiful.font_mono .. '">' .. text .. '</span>'
end

-- Widget base
function widget_base(content)
  if content and content ~= "" then
    return fg(beautiful.text_hilight, " [ ") .. content .. fg(beautiful.text_hilight, " ] ")
  end
end

-- Focus next/previous
function focus_by_idx(step)
  awful.client.focus.byidx(step)
  if client.focus then
    client.focus:raise()
  end
end
function focus_next() focus_by_idx(1) end
function focus_previous() focus_by_idx(-1) end

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

-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8 }, s, awful.layout.suit.max)
end

-- }}}

-- {{{ Wibox

-- {{{ Clock widget

-- Just a clock: YY-MM-DD, week/day, HH:MM:SS (numeric timezone)
function widget_clock()
  return widget_base(os.date('%F, %V/%a, ' .. bold('%T') .. ' (%z)'))
end

clockbox = widget({ type = "textbox", align = "left" })
clockbox.text = widget_clock()

-- Timer updating clock widget every 0.2 second
clock_timer = timer { timeout = 0.2 }
clock_timer:add_signal("timeout", function ()
  clockbox.text = widget_clock()
end)
clock_timer:start()

-- }}}

-- Spacer {{{

spacer = widget({ type = "textbox", align = "left" })
spacer.text = " "

-- }}}

-- Systray {{{

systray = widget({ type = "systray" })

-- }}}

-- {{{ Menu

-- Awesome
awesomemenu =
{
   { 'edit config', editor .. ' ' .. awful.util.getdir('config') .. '/aw.lua' },
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
  { 'reboot', reboot },
  { 'halt', halt },
}

-- Main menu
mainmenu = awful.menu({
  items =
  {
    { 'programs', programsmenu },
    { 'session', sessionmemenu },
    { 'awesome', awesomemenu },
  }
})
function mainmenu_toggle()
  mainmenu:toggle({ keygrabber = true })
end

-- }}}

-- {{{ Menu launcher

menulauncher = awful.widget.launcher({ image = awesome_icon, menu = mainmenu })

-- }}}

-- {{{ And the wibox itself

-- Create a wibox for each screen and add it
witop = {}
wibottom = {}

-- Prompt box
promptbox = {}

-- Tag list {{{

taglist = {}
taglist.buttons = awful.util.table.join(
awful.button(k_n, 1, awful.tag.viewonly),
awful.button(k_m, 1, awful.client.movetotag),
awful.button(k_n, 3, awful.tag.viewtoggle),
awful.button(k_m, 3, awful.client.toggletag),
awful.button(k_n, 4, awful.tag.viewnext),
awful.button(k_n, 5, awful.tag.viewprev),
nil
)

-- }}}

-- {{{ Tasklist

tasklist = {}
tasklist.buttons = awful.util.table.join(
awful.button(k_n, 1, function (c)
  if not c:isvisible() then
    awful.tag.viewonly(c:tags()[1])
  end
  client.focus = c
  c:raise()
end),
awful.button(k_n, 3, function ()
  if instance then
    instance:hide()
    instance = nil
  else
    instance = awful.menu.clients({ width=250 })
  end
end),
awful.button(k_n, 4, focus_next),
awful.button(k_n, 5, focus_previous),
nil
)

-- }}}

for s = 1, screen.count() do

  -- Create a promptbox for each screen
  promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

  -- Create a taglist widget
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)

  -- Create a tasklist widget
  tasklist[s] = awful.widget.tasklist(function(c)
    return awful.widget.tasklist.label.currenttags(c, s)
  end, tasklist.buttons)
  awful.widget.layout.margins[tasklist[s]] = { right = screen[s].geometry.width / 2 }

  -- Create wiboxes
  witop[s]    = awful.wibox({ position = "top",    screen = s, height = beautiful.wibox_height, fg = beautiful.fg_normal, bg = beautiful.bg_normal })
  wibottom[s] = awful.wibox({ position = "bottom", screen = s, height = beautiful.wibox_height, fg = beautiful.fg_normal, bg = beautiful.bg_normal })

  -- Add widgets to wiboxes - order matters
  witop[s].widgets =
  {
    layout = awful.widget.layout.horizontal.leftright,
    menulauncher,
    spacer,
    taglist[s],
    spacer,
    tasklist[s],
  }

  wibottom[s].widgets =
  {
    layout = awful.widget.layout.horizontal.leftright,
    clockbox,
    spacer,
    promptbox[s],
    {
      layout = awful.widget.layout.horizontal.rightleft,
      s == 1 and systray or nil,
    }
  }
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
  awful.util.spawn('mp-control pause')
end

client.add_signal('unmanage', function (c)
  if mplayer == c then
    mplayer = nil
  end
end)

-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(

-- {{{ Client manipulation, global part

awful.key(k_m, 'j', focus_next),
awful.key(k_m, 'k', focus_previous),
awful.key(k_m, 'Down', focus_next),
awful.key(k_m, 'Up', focus_previous),
awful.key(k_m, 'u', awful.client.urgent.jumpto),

-- }}}

-- {{{ Menus

awful.key(k_m, 'Menu', function () mainmenu_toggle() end),

-- }}}

-- {{{ MPlayer

awful.key(k_m, 'grave', mplayer_toggle),

-- }}}

-- {{{ Programs

awful.key(k_m, 'Return', function () awful.util.spawn(terminal) end),
awful.key(k_mc, 'r', awesome.restart),
awful.key(k_ms, 'q', awesome.quit),

-- }}}

-- {{{ Prompts

awful.key(k_m, 'r', function () promptbox[mouse.screen]:run() end),

-- }}}

-- {{{ Xkb layout

awful.key(k_m, 'F10', function () awful.util.spawn('setxkbmap dvorak,us && xset r on') end),
awful.key(k_m, 'F11', function () awful.util.spawn('setxkbmap us,dvorak && xset r off') end),

-- }}}

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
nil
)

-- }}}

-- {{{ Assign keys for each tag

-- Bind keyboard digits
-- Compute the maximum number of digit we need, limited to 12
keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(12, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
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
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
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
        if client.focus and tags[client.focus.screen][i] then
          awful.client.movetotag(tags[client.focus.screen][i])
        end
      end),
    awful.key(k_mcs, k,
      function ()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.toggletag(tags[client.focus.screen][i])
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
    rule = { class = 'MPlayer' },
    properties =
    {
      floating = true,
      focus = false,
      ontop = true,
      sticky = true,
      skip_taskbar = true,
    },
    callback = function (c)
      awful.client.property.set(c, 'nofocus', true)
      mplayer = c
    end,
  },
  {
    rule = { class = 'Firefox' },
    properties =
    {
      tag = tags[1][2],
    },
  },
  {
    rule = { class = 'Wine' },
    properties =
    {
      floating = true,
      tag = tags[1][5],
    },
  },
  {
    rule = { class = 'Gajim.py' },
    properties =
    {
      floating = true,
      tag = tags[1][6],
    },
  },
  {
    rule = { name = 'screen-sudo' },
    properties =
    {
      tag = tags[1][8],
    },
  },
  {
    rule = { name = 'screen-xsession' },
    properties =
    {
      tag = tags[1][1],
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

--- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.add_signal('manage', function (c, startup)

  -- Enable sloppy focus
  c:add_signal('mouse::enter', function(c)
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

client.add_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.add_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- }}}

-- vim: foldmethod=marker

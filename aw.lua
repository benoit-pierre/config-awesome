
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
awful.button(k_m, 3, awful.client.toggletag)
)

function taglist.label_custom(t, args)
  if not args then args = {} end
  local theme = beautiful.get()
  local fg_focus = args.fg_focus or theme.taglist_fg_focus or theme.fg_focus
  local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus
  local fg_urgent = args.fg_urgent or theme.taglist_fg_urgent or theme.fg_urgent
  local bg_urgent = args.bg_urgent or theme.taglist_bg_urgent or theme.bg_urgent
  local bg_color = nil
  local fg_color = nil

  local text = awful.util.escape(t.name)

  local sel = client.focus
  local cls = t:clients()

  if t.selected then
    bg_color = bg_focus
    fg_color = fg_focus
  end

  if not sel or not sel:tags()[t] then
    for k, c in pairs(t:clients()) do
      if c.urgent and not t.selected then
        if bg_urgent then bg_color = bg_urgent end
        if fg_urgent then fg_color = fg_urgent end
        break
      end
    end
  end

  if #cls > 0 then
    text = bold(text)
  end

  if bg_color and fg_color then
    text = fg(fg_color, text)
  end
  text = " " .. text .. " "
  return text, bg_color, nil, nil

end

-- }}}

for s = 1, screen.count() do

  -- Create a promptbox for each screen
  promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

  -- Create a taglist widget
  taglist[s] = awful.widget.taglist(s, taglist.label_custom, taglist.buttons)

  -- Create wiboxes
  witop[s]    = awful.wibox({ position = "top",    screen = s, height = beautiful.wibox_height, fg = beautiful.fg_normal, bg = beautiful.bg_normal })
  wibottom[s] = awful.wibox({ position = "bottom", screen = s, height = beautiful.wibox_height, fg = beautiful.fg_normal, bg = beautiful.bg_normal })

  -- Add widgets to wiboxes - order matters
  witop[s].widgets =
  {
    layout = awful.widget.layout.horizontal.leftright,
    menulauncher,
    taglist[s],
  }

  wibottom[s].widgets =
  {
    layout = awful.widget.layout.horizontal.leftright,
    clockbox,
    promptbox[s],
    {
      layout = awful.widget.layout.horizontal.rightleft,
      systray,
    }
  }
end

-- }}}

-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(

-- {{{ Client manipulation, global part

awful.key(k_m, 'j', function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end),
awful.key(k_m, 'k', function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),
awful.key(k_m, 'u', awful.client.urgent.jumpto),

-- }}}

-- {{{ Menus

awful.key(k_m, 'Menu', function () mainmenu_toggle() end),

-- }}}

-- {{{ Programs

awful.key(k_m, 'Return', function () awful.util.spawn(terminal) end),
awful.key(k_mc, 'r', awesome.restart),
awful.key(k_ms, 'q', awesome.quit),

-- }}}

-- {{{ Prompts

awful.key(k_m, 'r', function () promptbox[mouse.screen]:run() end),

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
      sticky = true
    },
    callback = function (c)
      awful.client.property.set(c, 'nofocus', true)
    end,
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

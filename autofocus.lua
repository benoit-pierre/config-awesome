
local awful = require('awful')

-- {{{ Helpers.

local function history_del(t, ov)
  for k, v in ipairs(t) do
    if v == ov then
      table.remove(t, k)
      break
    end
  end
end

local function history_add(t, nv)
  history_del(t, nv)
  table.insert(t, 1, nv)
end

-- }}}

-- {{{ Global focus history.

local global_focus_history = {}

local function global_focus_history_del(c)
  history_del(global_focus_history, c)
end

local function global_focus_history_add(c)
  history_add(global_focus_history, c)
end

-- }}}

-- {{{ Per tag focus history.

local tag_focus_history = {}

for tag_num, tag in ipairs(tags_by_num) do
  tag_focus_history[tag_num] = {}
end

local function tag_focus_history_del(tag_num, c)
  history_del(tag_focus_history[tag_num], c)
end

local function tag_focus_history_add(tag_num, c)
  history_add(tag_focus_history[tag_num], c)
end

-- }}}

-- {{{ Debugging.

local focus_debug = false

local client_tostring
local tag_tostring

local focus_msg
local focus_print
local focus_history_print

if focus_debug then

  local utils = require('utils')

  client_tostring = utils.client_tostring
  tag_tostring = utils.tag_tostring

  focus_msg = function (...)
    print(...)
  end

  focus_print = function ()
    local str = 'focus '
    if client.focus then
      str = str .. client_tostring(client.focus)
    end
    print(str)
  end

  focus_history_print = function (scr)
    local str = 'global_focus_history '
    for k, v in ipairs(global_focus_history) do
      print(str .. client_tostring(v))
    end
    for tag_num, t in ipairs(tags_by_num) do
      if scr == awful.tag.getscreen(t) and t.selected then
        local tag_str = 'tag_focus_history ' .. tag_tostring(t) .. ' '
        for k, v in ipairs(tag_focus_history[tag_num]) do
          print(tag_str .. client_tostring(v))
        end
      end
    end
  end

else

  client_tostring = function () return '' end
  tag_tostring = client_tostring

  focus_msg = function (...) end
  focus_print = focus_msg
  focus_history_print = focus_msg

end

-- }}}

-- Remove client from all focus histories.
local function focus_history_del(c)
  focus_msg('focus_history_del ' .. client_tostring(c))
  for tag_num, t in ipairs(tags_by_num) do
    tag_focus_history_del(tag_num, c)
  end
  global_focus_history_del(c)
end

-- Add client to global and currently selected tag histories.
local function focus_history_add(c)
  focus_msg('focus_history_add ' .. client_tostring(c))
  if awful.client.property.get(c, 'nofocus') then
    return
  end
  global_focus_history_add(c)
  for tag_num, t in ipairs(tags_by_num) do
    if c.screen == awful.tag.getscreen(t) and t.selected then
      tag_focus_history_add(tag_num, c)
    end
  end
end

-- Get the latest focus entry from histories.
function focus_history_get(scr)
  local fc
  local idx
  for k, c in ipairs(global_focus_history) do
    if c.screen == scr and c:isvisible() then
      for tag_num, t in ipairs(tags_by_num) do
        if awful.tag.getscreen(t) == scr and t.selected then
          for k, v in ipairs(tag_focus_history[tag_num]) do
            if v == c then
              if 1 == k then
                -- Best match, no need to keep going.
                return c
              end
              if not fc or k < idx then
                fc = c
                idx = k
              end
              break
            end
          end
        end
      end
    end
  end
  if fc then
    return fc
  end
  -- Fallback, first visible client.
  for k, c in pairs(client.get(scr)) do
    if c:isvisible() and awful.client.focus.filter(c) then
      return c
    end
  end
end

local function focus_check_fullscreen(c)
  if not c then
    return false
  end
  focus_msg('focus_check_fullscreen', c.name, c.fullscreen, c:isvisible())
  return c.screen == mouse.screen and c.fullscreen and c:isvisible()
end

local function focus_check()
  local c = client.focus
  local ms = mouse.screen
  focus_msg('focus_check ' .. ms)
  focus_print()
  -- Keep focus on fullscreen client.
  if focus_check_fullscreen(c) then
    return
  end
  focus_history_print(ms)
  c = focus_history_get(ms)
  if c and c ~= client.focus then
    client.focus = c
    focus_print()
  end
end

local function on_visibility_change(c)
  focus_msg('focus_check', c)
  -- Re-focus fullscreen client when it become visible again.
  if focus_check_fullscreen(c) then
    client.focus = c
    return
  end
  focus_check()
end

connect_signal(client, 'focus', focus_history_add)
connect_signal(client, 'unmanage', focus_history_del)

connect_signal(tag, 'property::selected', focus_check)
connect_signal(client, 'unmanage', focus_check)
connect_signal(client, 'untagged', focus_check)
connect_signal(client, 'property::hidden', on_visibility_change)
connect_signal(client, 'property::minimized', on_visibility_change)

-- vim: foldmethod=marker foldlevel=0
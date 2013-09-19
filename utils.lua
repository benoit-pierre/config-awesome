
local awful = require('awful')

local utils = {}

-- Convert a client to a human readable string.
function utils.client_tostring(c)
  local str = string.format('%08x', c.window)
  if c.name then
    str = str .. '[' .. c.name .. ']'
  end
  if c:isvisible() then
    str = str .. '+'
  end
  if c.fullscreen then
    str = str .. 'f'
  end
  if client.focus == c then
    str = str .. '*'
  end
  return str
end

-- Convert a client geometry to a human readable string.
function utils.geometry_tostring(g)
  local vorqm = function(v) if v then return v else return '?' end end
  if g then
    s = string.format('%s+%s:%sx%s', vorqm(g.x), vorqm(g.y), vorqm(g.width), vorqm(g.height))
  else
    s = '????'
  end
  return s
end

-- Convert a tag to a human readable string.
function utils.tag_tostring(t)
  local str = awful.tag.getscreen(t) .. '.' .. t.name
  if t.selected then
    str = str .. '*'
  end
  return str
end

return utils

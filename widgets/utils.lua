
local beautiful = require('beautiful')

local utils = {}

-- Boldify text
function utils.bold(text)
  return '<b>' .. text .. '</b>'
end

-- Set foreground color
function utils.fg(color, text)
  return '<span color="' .. color .. '">' .. text .. '</span>'
end

-- Set background color
function utils.bg(color, text)
  return '<bg color="' .. color .. '" />' .. text
end

-- Widget base
function utils.widget_base(content)
  if content and content ~= "" then
    return utils.fg(beautiful.text_hilight, " [ ") .. content .. utils.fg(beautiful.text_hilight, " ] ")
  end
end

function utils.widget_class(class)
  class.mt = {}
  function class.mt:__call(...)
    return class.new(...)
  end
  return setmetatable(class, class.mt)
end

if '3.4' == aw_ver then

  function utils.textbox()
    local w = widget { type = 'textbox' }
    function w.set_markup(w, t)
      w.text = t
    end
  end

end

if '3.5' == aw_ver then

  local wibox = require('wibox')

  function utils.textbox()
    local w = wibox.widget.textbox()
    return w
  end

end

local dummy = {}

dummy.new = function(t)
  local w = utils.textbox()
  w:set_markup(' ')
  return w
end

utils.dummy = utils.widget_class(dummy)

return utils


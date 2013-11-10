
local beautiful = require('beautiful')

local utils = {}

-- Boldify text
function utils.bold(text)
  return '<b>' .. text .. '</b>'
end

-- Highlight text
function utils.hilight(text)
  return utils.fg(beautiful.text_hilight, text)
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
    return utils.hilight(" [ ") .. content .. utils.hilight(" ] ")
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
    local w = {
      widget = widget { type = 'textbox' };
      add_signal = function (w, ...) w.widget:add_signal(...) end;
      set_markup = function (w, t) w.widget.text = t end;
      buttons = function (w, t) w.widget:buttons(t) end;
    }
    return w
  end

end

if '3.5' == aw_ver then

  local wibox = require('wibox')

  function utils.textbox()
    local w = wibox.widget.textbox()
    return w
  end

end

return utils


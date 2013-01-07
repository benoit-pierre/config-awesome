
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

return utils


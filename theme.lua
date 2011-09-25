
theme = {}

theme.font          = 'Dejavu Sans 9'
theme.font_mono     = 'Dejavu Sans Mono 9'

theme.bg_normal     = '#111111'
theme.bg_focus      = '#aacc88'
theme.bg_urgent     = '#111111'

theme.fg_normal     = '#cccccc'
theme.fg_focus      = '#000000'
theme.fg_urgent     = '#cc7766'

theme.border_width  = '1'
theme.border_normal = '#111111'
theme.border_focus  = '#333333'

theme.naughty_fg    = '#aacc88'
theme.naughty_bg    = '#222222'
theme.naughty_cri   = '#cc7766'

theme.battery_low   = '#ff4444'

theme.text_hilight  = '#aacc88'

theme.wibox_height  = '16'

theme.wallpaper_cmd = { 'xsetroot -solid black' }

-- Display the taglist squares
theme.taglist_squares_sel   = icons_dir..'/taglist/square_sel.png'
theme.taglist_squares_unsel = icons_dir..'/taglist/square_unsel.png'

return theme



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

-- You can use your own layout icons like this:
theme.layout_fairh      = icons_dir..'/layouts/fairh.png'
theme.layout_fairv      = icons_dir..'/layouts/fairv.png'
theme.layout_floating   = icons_dir..'/layouts/floating.png'
theme.layout_magnifier  = icons_dir..'/layouts/magnifier.png'
theme.layout_max        = icons_dir..'/layouts/max.png'
theme.layout_fullscreen = icons_dir..'/layouts/fullscreen.png'
theme.layout_tilebottom = icons_dir..'/layouts/tilebottom.png'
theme.layout_tileleft   = icons_dir..'/layouts/tileleft.png'
theme.layout_tile       = icons_dir..'/layouts/tile.png'
theme.layout_tiletop    = icons_dir..'/layouts/tiletop.png'
theme.layout_spiral     = icons_dir..'/layouts/spiral.png'
theme.layout_dwindle    = icons_dir..'/layouts/dwindle.png'

return theme


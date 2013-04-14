--[[
	Awesome WM v3.5.1 Vicious Powerarrow theme

	Adapted from:
		Original (Awesome WM v3.4.13) theme: https://github.com/romockee/powerarrow
		Original Author: romockee
	
	Current version:
		Git Repo: 
		Adapted by: Martin11175
--]]

-- Standard awesome library
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local gears = require("gears")
-- Themes
local beautiful = require("beautiful")
-- Notifications
local naughty = require("naughty")
local menubar = require("menubar")
-- Widgets
local vicious = require("vicious")
local wibox = require("wibox")
require('couth.couth') -- Volume changer widget
require('couth.alsa') -- Volume changer integration
-- Menu icons
require('freedesktop.utils')

hostname = io.popen("uname -n"):read() -- Host name for if you want the same rc.lua for multiple setups

--{{---| Java GUI's fix |---------------------------------------------------------------------------

awful.util.spawn_with_shell("wmname LG3D")

--{{---| Error handling |---------------------------------------------------------------------------

if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors })
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		if in_error then return end
		in_error = true
		naughty.notify({ preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err })
		in_error = false
	end)
end

--{{---| Theme |------------------------------------------------------------------------------------

config_dir = awful.util.getdir("config")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/vicious-powerarrow/theme.lua")

--{{---| Variables |--------------------------------------------------------------------------------

modkey        = "Mod4" -- Windows (super) key
terminal      = "terminator"
	freedesktop.utils.terminal = terminal
terminalr     = "terminator -x su root" -- Root terminal
musicplr      = "terminator -e cmus"
editor        = os.getenv("EDITOR") or "vim"
editor_cmd    = terminal .. " -e " .. editor
browser       = "google-chrome"

--{{---| Couth Alsa volume applet |-----------------------------------------------------------------

couth.CONFIG.ALSA_CONTROLS = { 'Master' }

--{{---| Table of layouts |-------------------------------------------------------------------------

layouts =
{
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
  	awful.layout.suit.tile.bottom,
  	awful.layout.suit.tile.top,
  	awful.layout.suit.floating
}

--{{---| Wallpaper |--------------------------------------------------------------------------------

if beautiful.wallpaper then
    	for s = 1, screen.count() do
        	gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    	end
end

--{{---| Naughty theme |----------------------------------------------------------------------------

naughty.config.defaults.font         		= beautiful.notify_font
naughty.config.defaults.fg           		= beautiful.notify_fg
naughty.config.defaults.bg           		= beautiful.notify_bg
naughty.config.presets.normal.border_color 	= beautiful.notify_border
naughty.config.presets.normal.opacity      	= 0.8
naughty.config.presets.low.opacity         	= 0.8
naughty.config.presets.critical.opacity    	= 0.8

--{{---| Tags |-------------------------------------------------------------------------------------

tags = {}
for s = 1, screen.count() do
    	tags[s] = awful.tag({ "☉", "☿", "♀", "⊕", "♂", "♃", "♄", "♅", "♆" }, s, layouts[1])
	awful.tag.viewonly(tags[s][4]) 
end

--{{---| Menu |-------------------------------------------------------------------------------------

myawesomemenu = {
  	{"edit config",         "terminator -e vim ~/.config/awesome/rc.lua"},
  	{"edit theme",          "terminator -e vim ~/.config/awesome/themes/powerarrow/theme.lua"},
  	{"restart",             awesome.restart },
  	{"quit",                awesome.quit },
  	{"reboot",              "reboot"},
	{"power off",           "poweroff"}
}

mymainmenu = awful.menu({ items = { 
  	{ " @wesome",           myawesomemenu, beautiful.awesome_icon },
	{ " Chrome", 		"google-chrome", freedesktop.utils.lookup_icon( { icon = 'google-chrome' } ) },
  	{ " root terminal",     terminalr, beautiful.terminalroot_icon},
  	{ " terminal",          terminal, beautiful.terminal_icon} 
} })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })


--{{---| Wibox |------------------------------------------------------------------------------------

mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytasklist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ width=450 })
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end))
for s = 1, screen.count() do
    	mypromptbox[s] = awful.widget.prompt()
    	mylayoutbox[s] = awful.widget.layoutbox(s)
    	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

--{{---| Music widget |-----------------------------------------------------------------------------

	music = wibox.widget.imagebox()
	music:set_image(beautiful.widget_music)
	-- Click to spawn music player
	music:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))

--{{---| MEM widget |-------------------------------------------------------------------------------

	memwidget = wibox.widget.textbox()
	vicious.register(memwidget, vicious.widgets.mem, '<span background="#777E76" font="Terminus 12"> <span font="Terminus 9" color="#EEEEEE" background="#777E76">$2MB </span></span>', 10)
	memicon = wibox.widget.imagebox()
	memicon:set_image(beautiful.widget_mem)

--{{---| CPU / sensors widget |---------------------------------------------------------------------

	cpuwidget = wibox.widget.textbox()
	vicious.register(cpuwidget, vicious.widgets.cpu,
		'<span background="#4B696D" font="Terminus 12"> <span font="Terminus 9" color="#DDDDDD">$2% <span color="#888888">·</span> $3% </span></span>', 3)
	cpuicon = wibox.widget.imagebox()
	cpuicon:set_image(beautiful.widget_cpu)

	sensors = wibox.widget.textbox()
	vicious.register(sensors, vicious.widgets.thermal,
	 	'<span background="#4B3B51" font="Terminus 12"> <span font="Terminus 9" color="#DDDDDD"> $1° </span></span>', 10, "thermal_zone0")
	tempicon = wibox.widget.imagebox()
	tempicon:set_image(beautiful.widget_temp)

--{{---| FS's widget |-----------------------------------------------------------

	fsicon = wibox.widget.imagebox()
	fsicon:set_image(beautiful.widget_hdd)
	fswidget = wibox.widget.textbox()
	vicious.register(fswidget, vicious.widgets.fs,
		'<span background="#D0785D" font="Terminus 12"> <span font="Terminus 9" color="#EEEEEE">${/ avail_gb}GB </span></span>', 60)

--{{---| Battery widget |---------------------------------------------------------------------------  

	baticon = wibox.widget.imagebox()
	baticon:set_image(beautiful.widget_battery)
	batwidget = wibox.widget.textbox()
	if hostname ~= "Arch-Quad" then
		vicious.register( batwidget, vicious.widgets.bat, '<span background="#92B0A0" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF" background="#92B0A0">$1$2% </span></span>', 60, "BAT1" )
	end

--{{---| Net widget |-------------------------------------------------------------------------------

	netwidget = wibox.widget.textbox()
	if hostname == "Arch-Quad" then
		vicious.register(netwidget,
			vicious.widgets.net,
			'<span background="#C2C2A4" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF">${eth0 down_kb} ↓↑ ${eth0 up_kb}</span> </span>', 2)
	else
		vicious.register(netwidget, 
			vicious.widgets.net,
			'<span background="#C2C2A4" font="Terminus 12"> <span font="Terminus 9" color="#FFFFFF">${wlp2s0 down_kb} ↓↑ ${wlp2s0 up_kb}</span> </span>', 2)
	end
	neticon = wibox.widget.imagebox()
	neticon:set_image(beautiful.widget_net)

--{{---| Separators widgets |-----------------------------------------------------------------------

	arr1 = wibox.widget.imagebox()
	arr1:set_image(beautiful.arr1)
	arr2 = wibox.widget.imagebox()
	arr2:set_image(beautiful.arr2)
	arr3 = wibox.widget.imagebox()
	arr3:set_image(beautiful.arr3)
	arr4 = wibox.widget.imagebox()
	arr4:set_image(beautiful.arr4)
	arr5 = wibox.widget.imagebox()
	arr5:set_image(beautiful.arr5)
	arr6 = wibox.widget.imagebox()
	arr6:set_image(beautiful.arr6)
	arr7 = wibox.widget.imagebox()
	arr7:set_image(beautiful.arr7)
	arr8 = wibox.widget.imagebox()
	arr8:set_image(beautiful.arr8)
	arr9 = wibox.widget.imagebox()
	arr9:set_image(beautiful.arr9)
	arr0 = wibox.widget.imagebox()
	arr0:set_image(beautiful.arr0)

--{{---| Clock |------------------------------------------------------------------------------------

	mytextclock = awful.widget.textclock('<span color="#FFFFFF"> %a %b %d, %H:%M </span>', 60)
  
--{{---| Panel |------------------------------------------------------------------------------------

	mywibox[s] = awful.wibox({ position = "top", screen = s, height = "16" })

    	-- Widgets that are aligned to the left
    	local left_layout = wibox.layout.fixed.horizontal()
    	left_layout:add(mylauncher)
    	left_layout:add(mytaglist[s])
    	left_layout:add(mypromptbox[s])
	
    	-- Widgets that are aligned to the right
    	local right_layout = wibox.layout.fixed.horizontal()
    	if s == 1 then right_layout:add(wibox.widget.systray()) end
    	right_layout:add(arr9)
     	right_layout:add(music)
    	right_layout:add(arr8)
    	right_layout:add(memicon)
    	right_layout:add(memwidget)
    	right_layout:add(arr7)
	right_layout:add(cpuicon)
	right_layout:add(cpuwidget)
    	right_layout:add(arr6)
     	right_layout:add(tempicon)
     	right_layout:add(sensors)
    	right_layout:add(arr5)
	right_layout:add(fsicon)
     	right_layout:add(fswidget)
    	right_layout:add(arr4)
    	right_layout:add(baticon)
    	right_layout:add(batwidget)
    	right_layout:add(arr3)
     	right_layout:add(neticon)
     	right_layout:add(netwidget)
    	right_layout:add(arr2)
	right_layout:add(mytextclock)
    	right_layout:add(arr9)
    	right_layout:add(mylayoutbox[s])

    	-- Now bring it all together (with the tasklist in the middle)
    	local layout = wibox.layout.align.horizontal()
    	layout:set_left(left_layout)
    	layout:set_middle(mytasklist[s])
    	layout:set_right(right_layout)

    	mywibox[s]:set_widget(layout)
	
end

--{{---| Mouse bindings |---------------------------------------------------------------------------

root.buttons(awful.util.table.join(awful.button({ }, 3, function () mymainmenu:toggle() end)))

--{{---| Key bindings |-----------------------------------------------------------------------------

globalkeys = awful.util.table.join(
	-- Ubuntu style tag (workspace) switching
    	awful.key({ "Mod1", "Control" }, "Left",   awful.tag.viewprev       ),
    	awful.key({ "Mod1", "Control" }, "Right",  awful.tag.viewnext       ),
	awful.key({ "Mod1", "Control", "Shift" }, "Left", function () if client.focus 
		then awful.client.movetotag(tags[client.focus.screen][awful.tag.getidx() - 1])
			awful.tag.viewprev() end end),
	awful.key({ "Mod1", "Control", "Shift" }, "Right", function () if client.focus
		then awful.client.movetotag(tags[client.focus.screen][awful.tag.getidx() + 1])
			awful.tag.viewnext() end end),

	-- Travel to first open client regardless of tag
    	awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
	
	-- Client switching
    	awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1)
            	if client.focus then client.focus:raise() end end),
    	awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1)
            	if client.focus then client.focus:raise() end end),

	-- Show main menu
    	awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

	-- Change client priority 
    	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),

	-- Change client column 
    	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

	-- Move to urgent client
    	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

	-- Switch clients Alt-tab style
    	awful.key({ "Mod1",           }, "Tab", function () awful.client.focus.history.next()
        	if client.focus then client.focus:raise() end end),
    	awful.key({ "Mod1", "Shift"   }, "Tab", function () awful.client.focus.history.previous()
        	if client.focus then client.focus:raise() end end),

--{{---| Hotkeys |------------------------------------------------------------------------------------\-\\

	awful.key({ modkey,           }, "Return",   function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Shift"   }, "Return",   function () awful.util.spawn(terminalr) end),

--{{--------------------------------------------------------------------------------------------------/-//

	-- Awesome WM Controls
	awful.key({ modkey, "Control" }, "r",        awesome.restart),
	awful.key({ modkey, "Shift",     "Control"}, "r", awesome.quit),
	awful.key({ modkey, "Control" }, "n",        awful.client.restore),
	awful.key({ modkey },            "r",        function () mypromptbox[mouse.screen]:run() end), --run program entered
	awful.key({ modkey,           }, "l",        function () awful.tag.incmwfact( 0.05)    end), --Change master windows width factor
	awful.key({ modkey,           }, "h",        function () awful.tag.incmwfact(-0.05)    end),
	awful.key({ modkey, "Shift"   }, "h",        function () awful.tag.incnmaster( 1)      end), --Change number of master windows (screens)
	awful.key({ modkey, "Shift"   }, "l",        function () awful.tag.incnmaster(-1)      end),
	awful.key({ modkey, "Control" }, "h",        function () awful.tag.incncol( 1)         end), --Change number of tiled columns
	awful.key({ modkey, "Control" }, "l",        function () awful.tag.incncol(-1)         end), 
	awful.key({ modkey,           }, "space",    function () awful.layout.inc(layouts,  1) end), --Change client layout
	awful.key({ modkey, "Shift"   }, "space",    function () awful.layout.inc(layouts, -1) end),
	awful.key({ modkey },            "Print",    "scrot '%Y-%m-%d.png' -e 'mv $f ~/Pictures/Screenshots/'"), --Take screenshot

	-- Function keys
	awful.key({ }, "XF86Sleep",                  function () awful.util.spawn_with_shell("sleep") end),
	awful.key({ }, "XF86AudioPlay",              function () awful.util.spawn_with_shell("ncmpcpp toggle") end),
	awful.key({ }, "XF86AudioStop",              function () awful.util.spawn_with_shell("ncmpcpp stop") end),
	awful.key({ }, "XF86AudioPrev",              function () awful.util.spawn_with_shell("ncmpcpp prev") end),
	awful.key({ }, "XF86AudioNext",              function () awful.util.spawn_with_shell("ncmpcpp next") end),
	awful.key({ }, "XF86AudioLowerVolume",       function () couth.notifier:notify(couth.alsa:setVolume('Master','3dB-')) end),
	awful.key({ }, "XF86AudioRaiseVolume",       function () couth.notifier:notify(couth.alsa:setVolume('Master','3dB+')) end),
	awful.key({ }, "XF86AudioMute",              function () couth.notifier:notify(couth.alsa:setVolume('Master','toggle')) end),

	-- Show menubar for searching programs
	awful.key({ modkey }, "Tab", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",        function (c) c.fullscreen = not c.fullscreen  end), --toggle fullscreen client
	awful.key({ modkey,           }, "c",        function (c) c:kill()                         end), --kill client
 	awful.key({ modkey, "Control" }, "space",    awful.client.floating.toggle                     ), --toggle floating client
	awful.key({ modkey, "Control" }, "Return",   function (c) c:swap(awful.client.getmaster()) end), --Change screen
	awful.key({ modkey,           }, "o",        awful.client.movetoscreen                        ), --Move to screen
	awful.key({ modkey, "Shift"   }, "r",        function (c) c:redraw()                       end), --Redraw window
	awful.key({ modkey,           }, "n",        function (c) c.minimized = true		   end), --Hide client
	awful.key({ modkey,           }, "m",        function (c) c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical end) --toggle maximised
)

keynumber = 0
for s = 1, screen.count() do keynumber = math.min(9, math.max(#tags[s], keynumber)); end
for i = 1, keynumber do globalkeys = awful.util.table.join(globalkeys,
	-- Show all clients on this tag index only
	awful.key({ modkey }, "#" .. i + 9, function () local screen = mouse.screen
		if tags[screen][i] then awful.tag.viewonly(tags[screen][i]) end end),

	-- Show all clients on this tag index as well
	awful.key({ modkey, "Control" }, "#" .. i + 9, function () local screen = mouse.screen
		if tags[screen][i] then awful.tag.viewtoggle(tags[screen][i]) end end),

	-- Move the current focussed client to this tag index
	awful.key({ modkey, "Shift" }, "#" .. i + 9, function () if client.focus and 
		tags[client.focus.screen][i] then awful.client.movetotag(tags[client.focus.screen][i]) end end),

	-- Add the current focussed client to this tag index
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function () if client.focus and
		tags[client.focus.screen][i] then awful.client.toggletag(tags[client.focus.screen][i]) end end)) end
clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

--{{---| Set keys |---------------------------------------------------------------------------------

root.keys(globalkeys)

--{{---| Rules |------------------------------------------------------------------------------------

-- Set clients of certain types to behave in certain ways
awful.rules.rules = {
    { rule = { },
    	properties = { size_hints_honor = false,
    		border_width = beautiful.border_width,
    		border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
		floating = false,
    		keys = clientkeys,
    		buttons = clientbuttons } },
    { rule = { class = "gimp" },
    	properties = { floating = true } },
}

--{{---| Signals |----------------------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--{{---| run_once |---------------------------------------------------------------------------------

function run_once(prg)
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")") end

--{{---| run_once with args |-----------------------------------------------------------------------

function run_oncewa(prg) if not prg then do return nil end end
    awful.util.spawn_with_shell('ps ux | grep -v grep | grep -F ' .. prg .. ' || ' .. prg .. ' &') end

--{{Xx----------------------------------------------------------------------------------------------

run_oncewa("pulseaudio --start") --Sound fix

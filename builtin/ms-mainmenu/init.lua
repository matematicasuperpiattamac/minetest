--Matematica Superpiatta
--Copyright (C) 2023 Matematica Superpiatta
--
--Minetest
--Copyright (C) 2014 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

-- Matematica Superpiatta's environment

SERVER_ADDRESS = core.settings:get("ms_address") or "mt.matematicasuperpiatta.it"
SERVER_PORT = core.settings:get("ms_port") or 29999
URL_GET = "http://"..SERVER_ADDRESS..":"..SERVER_PORT

SERVICE_DISCOVERY = core.settings:get("ms_discovery") or "fvqyugucy1.execute-api.eu-south-1.amazonaws.com/release"
SERVICE_DISCOVERY_LOCAL = core.settings:get("ms_discovery_local") or "192.168.0.4"
WISCOMS_URL = core.settings:get("wiscoms_url") or "https://wiscoms.matematicasuperpiatta.it/wiscom"
WISCOMS_URL_LOCAL = core.settings:get("wiscoms_url_local") or "http://" .. SERVICE_DISCOVERY_LOCAL .. ":8000/wiscom"
PANEL_DATA = core.settings:get("panel_data") or ""

CMD_USR = core.settings:get("cmd_usr") or ""
CMD_PWD = core.settings:get("cmd_pwd") or ""

mt_color_grey  = "#AAAAAA"
mt_color_blue  = "#6389FF"
mt_color_green = "#72FF63"
mt_color_dark_green = "#25C191"
mt_color_orange  = "#FF8800"

defaulttexturedir = core.get_texturepath_share() .. DIR_DELIM .. "base" ..
						DIR_DELIM .. "pack" .. DIR_DELIM

ms_mainmenu = {}

local basepath = core.get_builtin_path()
local menupath = basepath .. "ms-mainmenu" .. DIR_DELIM

local default_menupath = core.get_mainmenu_path()
dofile(default_menupath .. DIR_DELIM .. "async_event.lua")
dofile(menupath .. "lib" .. DIR_DELIM .. "delay.lua")
dofile(menupath .. "oop" .. DIR_DELIM .. "handshake.lua")

handshake = Handshake:new()
global_data = {
	message_type = "default",
	message_text = fgettext("Unable to connect to the server!\n\nCheck your internet connection and restart Matematica Superpiatta.\nIf the problem persists contact us at:\nassistenza@matematicasuperpiatta.it")
}
global_ms_type = "full"
lambda_waiting = false
lambda_read = true
lambda_error = false


--------------------------------------------------------------------------------
local function bootstrap()

	dofile(basepath .. "common" .. DIR_DELIM .. "filterlist.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "buttonbar.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "dialog.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "tabview.lua")
	dofile(basepath .. "fstk" .. DIR_DELIM .. "ui.lua")
	dofile(default_menupath .. DIR_DELIM .. "common.lua")
	dofile(default_menupath .. DIR_DELIM .. "pkgmgr.lua")
	dofile(default_menupath .. DIR_DELIM .. "serverlistmgr.lua")
	dofile(default_menupath .. DIR_DELIM .. "game_theme.lua")

	dofile(default_menupath .. DIR_DELIM .. "dlg_config_world.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_settings_advanced.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_contentstore.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_create_world.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_delete_content.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_delete_world.lua")
	dofile(default_menupath .. DIR_DELIM .. "dlg_rename_modpack.lua")

	dofile(menupath .. "oop" .. DIR_DELIM .. "oo_formspec.lua")

	dofile(menupath .. "dlg_whoareu.lua")
	dofile(menupath .. "dlg_errors.lua")
	dofile(menupath .. "dlg_version_info.lua")

	return {
		ms       = dofile(menupath .. "tab_ms.lua"),
		settings = dofile(default_menupath .. DIR_DELIM .. "tab_settings.lua"),
		about    = dofile(menupath .. "tab_about.lua")
	}
end

--------------------------------------------------------------------------------
local function main_event_handler(tabview, event)
	if event == "MenuQuit" then
		core.close()
	end
	return true
end

--------------------------------------------------------------------------------
local function init_globals(tabs)
	-- Init gamedata
	gamedata.worldindex = 0

	menudata.worldlist = filterlist.create(
		core.get_worlds,
		compare_worlds,
		-- Unique id comparison function
		function(element, uid)
			return element.name == uid
		end,
		-- Filter function
		function(element, gameid)
			return element.gameid == gameid
		end
	)

	menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
	menudata.worldlist:set_sortmode("alphabetic")

	if not core.settings:get("menu_last_game") then
		local default_game = core.settings:get("default_game") or "minetest"
		core.settings:set("menu_last_game", default_game)
	end

	mm_game_theme.init()

	-- Create main tabview
	local tv_main = tabview_create("maintab", {x = 12, y = 5.4}, {x = 0, y = 0})

	tv_main:set_autosave_tab(true)
	tv_main:add(tabs.ms)

	tv_main:add(tabs.settings)
	tv_main:add(tabs.about)

	tv_main:set_global_event_handler(main_event_handler)
	tv_main:set_fixed_size(false)

	local last_tab = core.settings:get("maintab_LAST")
	if last_tab and tv_main.current_tab ~= last_tab then
		tv_main:set_tab(last_tab)
	end
	tv_main:set_tab("settings")
	tv_main:show()
	ui.update()
	core.log("warning","Set tab on settings")
	tv_main:set_tab("online")
	tv_main:show()
	ui.update()
	core.log("warning","Set tab on online")

	-- check if the client needs to be updated
	check_new_version(handshake)

	if PANEL_DATA == '' then
		-- MS has been launched normally
		core.log("warning", "NO INTENT")
		global_ms_type = "full"

		if CMD_USR == '' and CMD_PWD == '' then
			ui.set_default("maintab")
			tv_main:show()
			ui.update()
		else
			core.log("warning", "CMD ARGS")
			update_flavor()

			local http = core.get_http_api()
			local response = http.fetch_sync({
				url = WISCOMS_URL .. "/api/token/",
				timeout = 10,
				post_data = { username = CMD_USR, password = CMD_PWD },
			})
			if response == nil then
				if string.find(CMD_USR, "demo") then
					response = http.fetch_sync({
						url = WISCOMS_URL_LOCAL .. "/api/token/",
						timeout = 10,
						post_data = { username = CMD_USR, password = CMD_PWD },
					})
				end
			end

			if response.succeeded then
				core.log("info", "Payload is " .. response.data)
				local json = minetest.parse_json(response.data)
				error_msg = handle_connection(json, CMD_USR, CMD_PWD)
				if response.code ~= 200 then
					global_data.message_type = "error"
					global_data.message_text = "Autenticazione non riuscita.\nCodice errore: " .. response.code

					core.log("warning", "Error calling lambdaClient")
					local error_dlg = create_fatal_error_dlg()
					ui.cleanup()
					error_dlg:show()
					ui.update()
				end
			else
				core.log("warning", "Error calling lambdaClient")
				local error_dlg = create_fatal_error_dlg()
				ui.cleanup()
				error_dlg:show()
				ui.update()
				--return true
			end
		end
	else
		-- MS has been launched from a panel
		core.log("warning", "INTENT")
		global_ms_type = "panel"
		update_flavor()

		local http = core.get_http_api()
		local response = http.fetch_sync({
			url = WISCOMS_URL .. "/api/panel/token/",
			timeout = 10,
			post_data = core.parse_json(PANEL_DATA),
		})
		if response.succeeded then
			core.log("warning", "PANEL RESPONSE: " .. response.data)
			local json = core.parse_json(response.data)
			if response.code == 200 then
				local user = json.username
				local error_msg = handle_connection(json, user, "")
				if error_msg ~= '' then
					core.log("warning", "HANDLE_CONNECTION: " .. error_msg)
				end
			else
				global_data.message_type = "error"
				global_data.message_text = "Autenticazione non riuscita.\nErrore sconosciuto."

				if response.code == 401 then
					if json.code ~= nil then
						global_data.message_text = "Autenticazione non riuscita.\nCodice errore: " .. json.code
					end
				end

				local error_dlg = create_fatal_error_dlg()
				ui.cleanup()
				error_dlg:show()
				ui.update()
			end
		else
			local error_dlg = create_fatal_error_dlg()
			ui.cleanup()
			error_dlg:show()
			ui.update()
		end
	end

	--pkgmgr.update_gamelist()
	--core.log("warning", "menu_last_game: " .. core.settings:get("menu_last_game"))
	--core.log("warning", "gamelist: " .. core.write_json(pkgmgr.games))
	core.log("warning", "menu_last_game: " .. core.write_json(pkgmgr.find_by_gameid(core.settings:get("menu_last_game"))))

	mm_game_theme.reset()
	mm_game_theme.update_game(pkgmgr.find_by_gameid(core.settings:get("menu_last_game")))
end

init_globals( bootstrap() )

core:module("UserManager")
core:import("CoreEvent")
core:import("CoreTable")

UserManager = UserManager or class()
UserManager.PLATFORM_CLASS_MAP = {}

-- Lines: 9 to 11
function UserManager:new(...)
	local platform = SystemInfo:platform()

	return (self.PLATFORM_CLASS_MAP[platform:key()] or GenericUserManager):new(...)
end
GenericUserManager = GenericUserManager or class()
GenericUserManager.STORE_SETTINGS_ON_PROFILE = false
GenericUserManager.CAN_SELECT_USER = false
GenericUserManager.CAN_SELECT_STORAGE = false
GenericUserManager.NOT_SIGNED_IN_STATE = nil
GenericUserManager.CAN_CHANGE_STORAGE_ONLY_ONCE = true

-- Lines: 23 to 45
function GenericUserManager:init()
	self._setting_changed_callback_handler_map = {}
	self._user_state_changed_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._active_user_state_changed_callback_handler = CoreEvent.CallbackEventHandler:new()
	self._storage_changed_callback_handler = CoreEvent.CallbackEventHandler:new()

	if not self:is_global_initialized() then
		Global.user_manager = {
			initializing = true,
			setting_map = {},
			setting_data_map = {},
			setting_data_id_to_name_map = {},
			user_map = {}
		}

		self:setup_setting_map()

		Global.user_manager.initializing = nil
	end
end

-- Lines: 47 to 49
function GenericUserManager:init_finalize()
	self:update_all_users()
end

-- Lines: 51 to 52
function GenericUserManager:is_global_initialized()
	return Global.user_manager and not Global.user_manager.initializing
end
local is_ps3 = SystemInfo:platform() == Idstring("PS3")
local is_x360 = SystemInfo:platform() == Idstring("X360")
local is_ps4 = SystemInfo:platform() == Idstring("PS4")
local is_xb1 = SystemInfo:platform() == Idstring("XB1")

-- Lines: 59 to 210
function GenericUserManager:setup_setting_map()
	self:setup_setting(1, "invert_camera_x", false)
	self:setup_setting(2, "invert_camera_y", false)
	self:setup_setting(3, "camera_sensitivity", 1)
	self:setup_setting(4, "rumble", true)
	self:setup_setting(5, "music_volume", 100)
	self:setup_setting(6, "sfx_volume", 100)
	self:setup_setting(7, "subtitle", true)
	self:setup_setting(8, "brightness", 1)
	self:setup_setting(9, "hold_to_steelsight", true)
	self:setup_setting(10, "hold_to_run", not is_ps3 and not is_x360 and not is_ps4 and not is_xb1 and true)
	self:setup_setting(11, "voice_volume", 100)
	self:setup_setting(12, "controller_mod", {})
	self:setup_setting(13, "alienware_mask", true)
	self:setup_setting(14, "developer_mask", true)
	self:setup_setting(15, "voice_chat", true)
	self:setup_setting(16, "push_to_talk", true)
	self:setup_setting(17, "hold_to_duck", false)
	self:setup_setting(18, "video_color_grading", nil)
	self:setup_setting(19, "video_anti_alias", "AA")
	self:setup_setting(20, "video_animation_lod", not is_ps3 and not is_x360 and 3 or 2)
	self:setup_setting(21, "video_streaks", true)
	self:setup_setting(22, "mask_set", "clowns")
	self:setup_setting(23, "use_lightfx", false)
	self:setup_setting(24, "fov_standard", 75)
	self:setup_setting(25, "fov_zoom", 75)
	self:setup_setting(26, "camera_zoom_sensitivity", 1)
	self:setup_setting(27, "enable_camera_zoom_sensitivity", false)
	self:setup_setting(28, "light_adaption", true)
	self:setup_setting(29, "menu_theme", "fire")
	self:setup_setting(30, "newest_theme", "fire")
	self:setup_setting(31, "hit_indicator", true)
	self:setup_setting(32, "aim_assist", true)
	self:setup_setting(33, "controller_mod_type", "pc")
	self:setup_setting(34, "objective_reminder", true)
	self:setup_setting(35, "effect_quality", _G.tweak_data.EFFECT_QUALITY)
	self:setup_setting(36, "fov_multiplier", 1)
	self:setup_setting(37, "southpaw", false)
	self:setup_setting(38, "dof_setting", "standard")
	self:setup_setting(39, "fps_cap", 135)
	self:setup_setting(40, "use_headbob", true)
	self:setup_setting(41, "max_streaming_chunk", 4096)
	self:setup_setting(42, "net_packet_throttling", false)
	self:setup_setting(43, "__unused", false)
	self:setup_setting(44, "net_use_compression", true)
	self:setup_setting(45, "net_forwarding", true)
	self:setup_setting(46, "flush_gpu_command_queue", true)
	self:setup_setting(47, "use_thq_weapon_parts", true)
	self:setup_setting(48, "video_ao", "aob")
	self:setup_setting(49, "parallax_mapping", true)
	self:setup_setting(50, "video_aa", "fxaa")
	self:setup_setting(51, "workshop", false)
	self:setup_setting(52, "enable_fov_based_sensitivity", false)
	self:setup_setting(53, "quickplay_stealth", true)
	self:setup_setting(54, "quickplay_loud", true)
	self:setup_setting(55, "corpse_limit", 8)
	self:setup_setting(56, "quickplay_mutators", false)
	self:setup_setting(57, "crimenet_filter_friends_only", false)
	self:setup_setting(58, "crimenet_filter_new_servers_only", -1)
	self:setup_setting(59, "crimenet_filter_in_lobby", -1)
	self:setup_setting(60, "crimenet_filter_level_appopriate", true)
	self:setup_setting(61, "crimenet_filter_mutators", false)
	self:setup_setting(62, "crimenet_filter_tactic", -1)
	self:setup_setting(63, "crimenet_filter_max_servers", 30)
	self:setup_setting(64, "crimenet_filter_distance", 1)
	self:setup_setting(65, "crimenet_filter_difficulty", -1)
	self:setup_setting(66, "crimenet_filter_contract", -1)
	self:setup_setting(67, "crimenet_filter_kick", -1)
	self:setup_setting(68, "crimenet_filter_safehouses", false)
	self:setup_setting(69, "camera_sensitivity_x", 1)
	self:setup_setting(70, "camera_sensitivity_y", 1)
	self:setup_setting(71, "enable_camera_sensitivity_separate", false)
	self:setup_setting(73, "throwable_contour", false)
	self:setup_setting(74, "ammo_contour", false)
	self:setup_setting(75, "chromatic_setting", "standard")
	self:setup_setting(76, "mute_heist_vo", false)
	self:setup_setting(77, "camera_zoom_sensitivity_x", 1)
	self:setup_setting(78, "camera_zoom_sensitivity_y", 1)
	self:setup_setting(80, "sticky_aim", true)
	self:setup_setting(82, "crimenet_gamemode_filter", "standard")
	self:setup_setting(83, "crime_spree_lobby_diff", -1)
	self:setup_setting(84, "loading_screen_show_controller", true)
	self:setup_setting(85, "loading_screen_show_hints", true)
	self:setup_setting(86, "crimenet_filter_modded", true)
	self:setup_setting(300, "adaptive_quality", true)
	self:setup_setting(301, "window_zoom", true)
end

-- Lines: 212 to 221
function GenericUserManager:setup_setting(id, name, default_value)
	assert(not Global.user_manager.setting_data_map[name], "[UserManager] Setting name \"" .. tostring(name) .. "\" already exists.")
	assert(not Global.user_manager.setting_data_id_to_name_map[id], "[UserManager] Setting id \"" .. tostring(id) .. "\" already exists.")

	local setting_data = {
		id = id,
		default_value = self:get_clone_value(default_value)
	}
	Global.user_manager.setting_data_map[name] = setting_data
	Global.user_manager.setting_data_id_to_name_map[id] = name
	Global.user_manager.setting_map[id] = self:get_default_setting(name)
end

-- Lines: 223 to 224
function GenericUserManager:update(t, dt)
end

-- Lines: 226 to 228
function GenericUserManager:paused_update(t, dt)
	self:update(t, dt)
end

-- Lines: 230 to 234
function GenericUserManager:reset_setting_map()
	for name in pairs(Global.user_manager.setting_data_map) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 236 to 253
function GenericUserManager:reset_controls_setting_map()
	local settings = {
		"camera_sensitivity",
		"camera_zoom_sensitivity",
		"enable_camera_zoom_sensitivity",
		"enable_fov_based_sensitivity",
		"invert_camera_y",
		"southpaw",
		"hold_to_steelsight",
		"hold_to_run",
		"hold_to_duck",
		"rumble",
		"aim_assist",
		"controller_mod",
		"controller_mod_type",
		"invert_camera_x",
		"camera_sensitivity_x",
		"camera_sensitivity_y",
		"enable_camera_sensitivity_separate",
		"camera_zoom_sensitivity_x",
		"camera_zoom_sensitivity_y",
		"sticky_aim"
	}

	for _, name in pairs(settings) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 255 to 299
function GenericUserManager:reset_video_setting_map()
	local settings = {
		"subtitle",
		"hit_indicator",
		"objective_reminder",
		"brightness",
		"effect_quality",
		"dof_setting",
		"chromatic_setting",
		"video_animation_lod",
		"fps_cap",
		"use_lightfx",
		"fov_multiplier",
		"use_headbob",
		"max_streaming_chunk",
		"flush_gpu_command_queue",
		"video_color_grading",
		"video_anti_alias",
		"video_streaks",
		"fov_standard",
		"fov_zoom",
		"light_adaption",
		"use_thq_weapon_parts",
		"video_ao",
		"parallax_mapping",
		"video_aa",
		"corpse_limit",
		"adaptive_quality",
		"window_zoom"
	}

	for _, name in pairs(settings) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 301 to 309
function GenericUserManager:reset_sound_setting_map()
	local settings = {
		"music_volume",
		"sfx_volume",
		"voice_volume",
		"voice_chat",
		"push_to_talk"
	}

	for _, name in pairs(settings) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 311 to 324
function GenericUserManager:reset_network_setting_map()
	local settings = {
		"net_packet_throttling",
		"net_forwarding",
		"net_use_compression"
	}

	for _, name in pairs(settings) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 327 to 335
function GenericUserManager:reset_gameplay_setting_map()
	local settings = {
		"throwable_contour",
		"ammo_contour"
	}

	for _, name in pairs(settings) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 339 to 351
function GenericUserManager:reset_quickplay_setting_map()
	local settings = {
		"quickplay_stealth",
		"quickplay_loud",
		"quickplay_mutators"
	}

	for _, name in pairs(settings) do
		self:set_setting(name, self:get_default_setting(name))
	end
end

-- Lines: 354 to 360
function GenericUserManager:get_clone_value(value)
	if type(value) == "table" then
		return CoreTable.deep_clone(value)
	else
		return value
	end
end

-- Lines: 362 to 367
function GenericUserManager:get_setting(name)
	local setting_data = Global.user_manager.setting_data_map[name]

	assert(setting_data, "[UserManager] Tried to get non-existing setting \"" .. tostring(name) .. "\".")

	return Global.user_manager.setting_map[setting_data.id]
end

-- Lines: 370 to 375
function GenericUserManager:get_default_setting(name)
	local setting_data = Global.user_manager.setting_data_map[name]

	assert(setting_data, "[UserManager] Tried to get non-existing default setting \"" .. tostring(name) .. "\".")

	return self:get_clone_value(setting_data.default_value)
end

-- Lines: 378 to 399
function GenericUserManager:set_setting(name, value, force_change)
	local setting_data = Global.user_manager.setting_data_map[name]

	if not setting_data then
		Application:error("[UserManager] Tried to set non-existing default setting \"" .. tostring(name) .. "\".")

		return
	end

	local old_value = Global.user_manager.setting_map[setting_data.id]
	Global.user_manager.setting_map[setting_data.id] = value

	if self:has_setting_changed(old_value, value) or force_change then
		managers.savefile:setting_changed()

		local callback_handler = self._setting_changed_callback_handler_map[name]

		if callback_handler then
			callback_handler:dispatch(name, old_value, value)
		end
	end
end

-- Lines: 401 to 416
function GenericUserManager:add_setting_changed_callback(setting_name, callback_func, trigger_changed_from_default_now)
	assert(Global.user_manager.setting_data_map[setting_name], "[UserManager] Tried to add setting changed callback for non-existing setting \"" .. tostring(setting_name) .. "\".")

	local callback_handler = self._setting_changed_callback_handler_map[setting_name] or CoreEvent.CallbackEventHandler:new()
	self._setting_changed_callback_handler_map[setting_name] = callback_handler

	callback_handler:add(callback_func)

	if trigger_changed_from_default_now then
		local value = self:get_setting(setting_name)
		local default_value = self:get_default_setting(setting_name)

		if self:has_setting_changed(default_value, value) then
			callback_func(setting_name, default_value, value)
		end
	end
end

-- Lines: 418 to 424
function GenericUserManager:remove_setting_changed_callback(setting_name, callback_func)
	local callback_handler = self._setting_changed_callback_handler_map[setting_name]

	assert(Global.user_manager.setting_data_map[setting_name], "[UserManager] Tried to remove setting changed callback for non-existing setting \"" .. tostring(setting_name) .. "\".")
	assert(callback_handler, "[UserManager] Tried to remove non-existing setting changed callback for setting \"" .. tostring(setting_name) .. "\".")
	callback_handler:remove(callback_func)
end

-- Lines: 426 to 444
function GenericUserManager:has_setting_changed(old_value, new_value)
	if type(old_value) == "table" and type(new_value) == "table" then
		for k, old_sub_value in pairs(old_value) do
			if self:has_setting_changed(new_value[k], old_sub_value) then
				return true
			end
		end

		for k, new_sub_value in pairs(new_value) do
			if self:has_setting_changed(new_sub_value, old_value[k]) then
				return true
			end
		end

		return false
	else
		return old_value ~= new_value
	end
end

-- Lines: 446 to 447
function GenericUserManager:is_online_menu()
	return false
end

-- Lines: 449 to 450
function GenericUserManager:update_all_users()
end

-- Lines: 451 to 452
function GenericUserManager:update_user(user_index, ignore_username_change)
end

-- Lines: 454 to 456
function GenericUserManager:add_user_state_changed_callback(callback_func)
	self._user_state_changed_callback_handler:add(callback_func)
end

-- Lines: 457 to 459
function GenericUserManager:remove_user_state_changed_callback(callback_func)
	self._user_state_changed_callback_handler:remove(callback_func)
end

-- Lines: 461 to 463
function GenericUserManager:add_active_user_state_changed_callback(callback_func)
	self._active_user_state_changed_callback_handler:add(callback_func)
end

-- Lines: 464 to 466
function GenericUserManager:remove_active_user_state_changed_callback(callback_func)
	self._active_user_state_changed_callback_handler:remove(callback_func)
end

-- Lines: 468 to 470
function GenericUserManager:add_storage_changed_callback(callback_func)
	self._storage_changed_callback_handler:add(callback_func)
end

-- Lines: 471 to 473
function GenericUserManager:remove_storage_changed_callback(callback_func)
	self._storage_changed_callback_handler:remove(callback_func)
end

-- Lines: 476 to 481
function GenericUserManager:set_user_soft(user_index, platform_id, storage_id, username, signin_state, ignore_username_change)
	local old_user_data = self:_get_user_data(user_index)
	local user_data = {
		user_index = user_index,
		platform_id = platform_id,
		storage_id = storage_id,
		username = username,
		signin_state = signin_state
	}
	Global.user_manager.user_map[user_index] = user_data
end

-- Lines: 484 to 491
function GenericUserManager:set_user(user_index, platform_id, storage_id, username, signin_state, ignore_username_change)
	local old_user_data = self:_get_user_data(user_index)
	local user_data = {
		user_index = user_index,
		platform_id = platform_id,
		storage_id = storage_id,
		username = username,
		signin_state = signin_state
	}
	Global.user_manager.user_map[user_index] = user_data

	self:check_user_state_change(old_user_data, user_data, ignore_username_change)
end

-- Lines: 494 to 564
function GenericUserManager:check_user_state_change(old_user_data, user_data, ignore_username_change)
	local username = user_data and user_data.username
	local signin_state = user_data and user_data.signin_state or self.NOT_SIGNED_IN_STATE
	local old_signin_state = old_user_data and old_user_data.signin_state or self.NOT_SIGNED_IN_STATE
	local old_username = old_user_data and old_user_data.username
	local username_changed = old_username ~= username
	local old_user_has_signed_out = old_user_data and old_user_data.has_signed_out
	local user_changed, active_user_changed = nil
	local was_signed_in = old_signin_state ~= self.NOT_SIGNED_IN_STATE
	local is_signed_in = signin_state ~= self.NOT_SIGNED_IN_STATE
	local sign_in_state_changed = was_signed_in ~= is_signed_in
	local user_index = user_data and user_data.user_index or old_user_data and old_user_data.user_index
	local was_active_user = user_index == self:get_index()

	if sign_in_state_changed or not ignore_username_change and username_changed or old_user_has_signed_out then
		if was_active_user then
			active_user_changed = true
		end

		if Global.category_print.user_manager then
			if active_user_changed then
				cat_print("user_manager", "[UserManager] Active user changed.")
			else
				cat_print("user_manager", "[UserManager] User index changed.")
			end

			cat_print("user_manager", "[UserManager] Old user: " .. self:get_user_data_string(old_user_data) .. ".")
			cat_print("user_manager", "[UserManager] New user: " .. self:get_user_data_string(user_data) .. ".")
		end

		user_changed = true
	end

	if user_changed then
		if active_user_changed then
			self:active_user_change_state(old_user_data, user_data)
		end

		self._user_state_changed_callback_handler:dispatch(old_user_data, user_data)
	end

	local storage_id = user_data and user_data.storage_id
	local old_storage_id = old_user_data and old_user_data.storage_id
	local ignore_storage_change = self.CAN_CHANGE_STORAGE_ONLY_ONCE and Global.user_manager.storage_changed

	if not ignore_storage_change and (active_user_changed or user_index == self:get_index() and storage_id ~= old_storage_id) then
		self:storage_changed(old_user_data, user_data)

		Global.user_manager.storage_changed = true
	end
end

-- Lines: 566 to 588
function GenericUserManager:active_user_change_state(old_user_data, user_data)
	if self:get_active_user_state_change_quit() or is_x360 and managers.savefile:is_in_loading_sequence() then
		print("-- Cause loading", self:get_active_user_state_change_quit(), managers.savefile:is_in_loading_sequence())

		local dialog_data = {
			title = managers.localization:text("dialog_signin_change_title"),
			text = managers.localization:text("dialog_signin_change"),
			id = "user_changed"
		}
		local ok_button = {text = managers.localization:text("dialog_ok")}
		dialog_data.button_list = {ok_button}

		managers.system_menu:add_init_show(dialog_data)
		self:perform_load_start_menu()
	end

	self._active_user_state_changed_callback_handler:dispatch(old_user_data, user_data)
end

-- Lines: 590 to 602
function GenericUserManager:perform_load_start_menu()
	managers.system_menu:force_close_all()
	self:set_index(nil)
	managers.menu:on_user_sign_out()

	if managers.groupai then
		managers.groupai:state():set_AI_enabled(false)
	end

	_G.setup:load_start_menu()
	_G.game_state_machine:set_boot_from_sign_out(true)
	self:set_active_user_state_change_quit(false)
end

-- Lines: 606 to 609
function GenericUserManager:storage_changed(old_user_data, user_data)
	managers.savefile:storage_changed()
	self._storage_changed_callback_handler:dispatch(old_user_data, user_data)
end

-- Lines: 611 to 615
function GenericUserManager:load_platform_setting_map(callback_func)
	if callback_func then
		callback_func(nil)
	end
end

-- Lines: 617 to 619
function GenericUserManager:get_user_string(user_index)
	local user_data = self:_get_user_data(user_index)

	return self:get_user_data_string(user_data)
end

-- Lines: 622 to 635
function GenericUserManager:get_user_data_string(user_data)
	if user_data then
		local user_index = tostring(user_data.user_index)
		local signin_state = tostring(user_data.signin_state)
		local username = tostring(user_data.username)
		local platform_id = tostring(user_data.platform_id)
		local storage_id = tostring(user_data.storage_id)

		return string.format("User index: %s, Platform id: %s, Storage id: %s, Signin state: %s, Username: %s", user_index, platform_id, storage_id, signin_state, username)
	else
		return "nil"
	end
end

-- Lines: 637 to 638
function GenericUserManager:get_index()
	return Global.user_manager.user_index
end

-- Lines: 641 to 661
function GenericUserManager:set_index(user_index)
	if Global.user_manager.user_index ~= user_index then
		local old_user_index = Global.user_manager.user_index

		cat_print("user_manager", "[UserManager] Changed user index from " .. tostring(old_user_index) .. " to " .. tostring(user_index) .. ".")

		Global.user_manager.user_index = user_index
		local old_user_data = old_user_index and self:_get_user_data(old_user_index)

		if not user_index and old_user_data and not is_xb1 then
			old_user_data.storage_id = nil
		end

		if not user_index and not is_xb1 then
			for _, data in pairs(Global.user_manager.user_map) do
				data.storage_id = nil
			end
		end

		local user_data = self:_get_user_data(user_index)

		self:check_user_state_change(old_user_data, user_data, false)
	end
end

-- Lines: 663 to 664
function GenericUserManager:get_active_user_state_change_quit()
	return Global.user_manager.active_user_state_change_quit
end

-- Lines: 667 to 672
function GenericUserManager:set_active_user_state_change_quit(active_user_state_change_quit)
	if not Global.user_manager.active_user_state_change_quit ~= not active_user_state_change_quit then
		cat_print("user_manager", "[UserManager] User state change quits to title screen: " .. tostring(not not active_user_state_change_quit))

		Global.user_manager.active_user_state_change_quit = active_user_state_change_quit
	end
end

-- Lines: 674 to 676
function GenericUserManager:get_platform_id(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.platform_id
end

-- Lines: 679 to 681
function GenericUserManager:is_signed_in(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.signin_state ~= self.NOT_SIGNED_IN_STATE
end

-- Lines: 684 to 686
function GenericUserManager:signed_in_state(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.signin_state
end

-- Lines: 689 to 691
function GenericUserManager:get_storage_id(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.storage_id
end

-- Lines: 694 to 701
function GenericUserManager:is_storage_selected(user_index)
	if self.CAN_SELECT_STORAGE then
		local user_data = self:_get_user_data(user_index)

		return user_data and not not user_data.storage_id
	else
		return true
	end
end

-- Lines: 703 to 705
function GenericUserManager:_get_user_data(user_index)
	local user_index = user_index or self:get_index()

	return user_index and Global.user_manager.user_map[user_index]
end

-- Lines: 708 to 737
function GenericUserManager:check_user(callback_func, show_select_user_question_dialog)
	if not self.CAN_SELECT_USER or self:is_signed_in(nil) then
		if callback_func then
			callback_func(true)
		end
	else
		local confirm_callback = callback(self, self, "confirm_select_user_callback", callback_func)

		if show_select_user_question_dialog then
			self._active_check_user_callback_func = callback_func
			local dialog_data = {
				id = "show_select_user_question_dialog",
				title = managers.localization:text("dialog_signin_title"),
				text = managers.localization:text("dialog_signin_question"),
				focus_button = 1
			}
			local yes_button = {
				text = managers.localization:text("dialog_yes"),
				callback_func = callback(self, self, "_success_callback", confirm_callback)
			}
			local no_button = {
				text = managers.localization:text("dialog_no"),
				callback_func = callback(self, self, "_fail_callback", confirm_callback)
			}
			dialog_data.button_list = {
				yes_button,
				no_button
			}

			managers.system_menu:show(dialog_data)
		else
			confirm_callback(true)
		end
	end
end

-- Lines: 739 to 743
function GenericUserManager:_success_callback(callback_func)
	if callback_func then
		callback_func(true)
	end
end

-- Lines: 744 to 748
function GenericUserManager:_fail_callback(callback_func)
	if callback_func then
		callback_func(false)
	end
end

-- Lines: 750 to 757
function GenericUserManager:confirm_select_user_callback(callback_func, success)
	self._active_check_user_callback_func = nil

	if success then
		managers.system_menu:show_select_user({
			count = 1,
			callback_func = callback(self, self, "select_user_callback", callback_func)
		})
	elseif callback_func then
		callback_func(false)
	end
end

-- Lines: 759 to 766
function GenericUserManager:select_user_callback(callback_func)
	self:update_all_users()

	if callback_func then
		self._active_check_user_callback_func = nil

		callback_func(self:is_signed_in(nil))
	end
end

-- Lines: 768 to 785
function GenericUserManager:check_storage(callback_func, auto_select)
	if not self.CAN_SELECT_STORAGE or self:get_storage_id(nil) then
		if callback_func then
			callback_func(true)
		end
	else

		-- Lines: 774 to 782
		local function wrapped_callback_func(success, result, ...)
			if success then
				self:update_all_users()
			end

			if callback_func then
				callback_func(success, result, ...)
			end
		end

		managers.system_menu:show_select_storage({
			count = 1,
			min_bytes = managers.savefile.RESERVED_BYTES,
			callback_func = wrapped_callback_func,
			auto_select = auto_select
		})
	end
end

-- Lines: 787 to 788
function GenericUserManager:get_setting_map()
	return CoreTable.deep_clone(Global.user_manager.setting_map)
end

-- Lines: 791 to 796
function GenericUserManager:set_setting_map(setting_map)
	for id, value in pairs(setting_map) do
		local name = Global.user_manager.setting_data_id_to_name_map[id]

		self:set_setting(name, value)
	end
end

-- Lines: 800 to 805
function GenericUserManager:save_setting_map(setting_map, callback_func)
	if callback_func then
		Appliction:error("[UserManager] Setting map cannot be saved on this platform.")
		callback_func(false)
	end
end

-- Lines: 808 to 815
function GenericUserManager:save(data)
	local state = self:get_setting_map()
	data.UserManager = state

	if Global.DEBUG_MENU_ON then
		data.debug_post_effects_enabled = Global.debug_post_effects_enabled
	end
end

-- Lines: 817 to 840
function GenericUserManager:load(data, cache_version)
	if cache_version == 0 then
		self:set_setting_map(data)
	else
		self:set_setting_map(data.UserManager)
	end

	if SystemInfo:platform() ~= Idstring("PS3") then
		local NEWEST_THEME = "zombie"

		if self:get_setting("newest_theme") ~= NEWEST_THEME then
			self:set_setting("newest_theme", NEWEST_THEME)
			self:set_setting("menu_theme", NEWEST_THEME)
		end
	end

	if Global.DEBUG_MENU_ON then
		Global.debug_post_effects_enabled = data.debug_post_effects_enabled ~= false
	else
		Global.debug_post_effects_enabled = true
	end

	self:sanitize_settings()
end

-- Lines: 844 to 863
function GenericUserManager:sanitize_settings()
	local color_grading = self:get_setting("video_color_grading")
	local color_grading_valid = false

	for _, cg in ipairs(_G.tweak_data.color_grading) do
		if color_grading == cg.value then
			color_grading_valid = true

			break
		end
	end

	if not color_grading_valid then
		self:set_setting("video_color_grading", nil)
	end
end
Xbox360UserManager = Xbox360UserManager or class(GenericUserManager)
Xbox360UserManager.NOT_SIGNED_IN_STATE = "not_signed_in"
Xbox360UserManager.STORE_SETTINGS_ON_PROFILE = true
Xbox360UserManager.CAN_SELECT_USER = true
Xbox360UserManager.CAN_SELECT_STORAGE = true
Xbox360UserManager.CUSTOM_PROFILE_VARIABLE_COUNT = 3
Xbox360UserManager.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT = 999
Xbox360UserManager.CAN_CHANGE_STORAGE_ONLY_ONCE = false
UserManager.PLATFORM_CLASS_MAP[Idstring("X360"):key()] = Xbox360UserManager

-- Lines: 877 to 893
function Xbox360UserManager:init()
	self._platform_setting_conversion_func_map = {gamer_control_sensitivity = callback(self, self, "convert_gamer_control_sensitivity")}

	GenericUserManager.init(self)
	managers.platform:add_event_callback("signin_changed", callback(self, self, "signin_changed_callback"))
	managers.platform:add_event_callback("profile_setting_changed", callback(self, self, "profile_setting_changed_callback"))
	managers.platform:add_event_callback("storage_devices_changed", callback(self, self, "storage_devices_changed_callback"))
	managers.platform:add_event_callback("disconnect", callback(self, self, "disconnect_callback"))
	managers.platform:add_event_callback("connect", callback(self, self, "connect_callback"))

	self._setting_map_save_counter = 0
end

-- Lines: 895 to 910
function Xbox360UserManager:disconnect_callback(reason)
	print("  Xbox360UserManager:disconnect_callback", reason, XboxLive:signin_state(0))

	if Global.game_settings.single_player then
		return
	end

	if managers.network:session() and managers.network:session():_local_peer_in_lobby() then
		managers.menu:xbox_disconnected()
	elseif self._in_online_menu then
		print("leave crimenet")
		managers.menu:xbox_disconnected()
	elseif managers.network:session() then
		managers.network:session():xbox_disconnected()
	end
end

-- Lines: 913 to 914
function Xbox360UserManager:connect_callback()
end

-- Lines: 916 to 918
function Xbox360UserManager:on_entered_online_menus()
	self._in_online_menu = true
end

-- Lines: 920 to 922
function Xbox360UserManager:on_exit_online_menus()
	self._in_online_menu = false
end

-- Lines: 924 to 925
function Xbox360UserManager:is_online_menu()
	return self._in_online_menu
end

-- Lines: 928 to 938
function Xbox360UserManager:setup_setting_map()
	local platform_default_type_map = {
		invert_camera_y = "gamer_yaxis_inversion",
		camera_sensitivity = "gamer_control_sensitivity"
	}
	Global.user_manager.platform_setting_map = nil
	Global.user_manager.platform_default_type_map = platform_default_type_map

	GenericUserManager.setup_setting_map(self)
end

-- Lines: 940 to 948
function Xbox360UserManager:convert_gamer_control_sensitivity(value)
	if value == "low" then
		return 0.5
	elseif value == "medium" then
		return 1
	else
		return 1.5
	end
end

-- Lines: 950 to 966
function Xbox360UserManager:get_default_setting(name)
	if Global.user_manager.platform_setting_map then
		local platform_default_type = Global.user_manager.platform_default_type_map[name]

		if platform_default_type then
			local platform_default = Global.user_manager.platform_setting_map[platform_default_type]
			local conversion_func = self._platform_setting_conversion_func_map[platform_default_type]

			if conversion_func then
				return conversion_func(platform_default)
			else
				return platform_default
			end
		end
	end

	return GenericUserManager.get_default_setting(self, name)
end

-- Lines: 969 to 975
function Xbox360UserManager:active_user_change_state(old_user_data, user_data)
	Global.user_manager.platform_setting_map = nil

	managers.savefile:active_user_changed()
	GenericUserManager.active_user_change_state(self, old_user_data, user_data)
end

-- Lines: 977 to 980
function Xbox360UserManager:load_platform_setting_map(callback_func)
	cat_print("user_manager", "[UserManager] Loading platform setting map.")
	XboxLive:read_profile_settings(self:get_platform_id(nil), callback(self, self, "_load_platform_setting_map_callback", callback_func))
end

-- Lines: 982 to 990
function Xbox360UserManager:_load_platform_setting_map_callback(callback_func, platform_setting_map)
	cat_print("user_manager", "[UserManager] Done loading platform setting map. Success: " .. tostring(not not platform_setting_map))

	Global.user_manager.platform_setting_map = platform_setting_map

	self:reset_setting_map()

	if callback_func then
		callback_func(platform_setting_map)
	end
end

-- Lines: 992 to 995
function Xbox360UserManager:save_platform_setting(setting_name, setting_value, callback_func)
	cat_print("user_manager", "[UserManager] Saving platform setting \"" .. tostring(setting_name) .. "\": " .. tostring(setting_value))
	XboxLive:write_profile_setting(self:get_platform_id(nil), setting_name, setting_value, callback(self, self, "_save_platform_setting_callback", callback_func))
end

-- Lines: 999 to 1005
function Xbox360UserManager:_save_platform_setting_callback(callback_func, success)
	cat_print("user_manager", "[UserManager] Done saving platform setting \"" .. tostring("Dont get setting name in callback") .. "\". Success: " .. tostring(success))

	if callback_func then
		callback_func(success)
	end
end

-- Lines: 1007 to 1022
function Xbox360UserManager:get_setting_map()
	local platform_setting_map = Global.user_manager.platform_setting_map
	local setting_map = nil

	if platform_setting_map then
		local packed_string_value = ""

		for i = 1, self.CUSTOM_PROFILE_VARIABLE_COUNT, 1 do
			local setting_name = "title_specific" .. i
			packed_string_value = packed_string_value .. (platform_setting_map[setting_name] or "")
		end

		setting_map = Utility:unpack(packed_string_value) or {}
	end

	return setting_map
end

-- Lines: 1025 to 1060
function Xbox360UserManager:save_setting_map(callback_func)
	if self._setting_map_save_counter > 0 then
		Appliction:error("[UserManager] Tried to set setting map again before it was done with previous set.")

		if callback_func then
			callback_func(false)

			return
		end
	end

	local complete_setting_value = Utility:pack(Global.user_manager.setting_map)
	local current_char = 1
	local char_count = #complete_setting_value
	local setting_count = 1
	local max_char_count = self.CUSTOM_PROFILE_VARIABLE_COUNT * self.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT

	if max_char_count < char_count then
		Application:stack_dump_error("[UserManager] Exceeded (" .. char_count .. ") maximum character count that can be stored in the profile (" .. max_char_count .. ").")
		callback_func(false)

		return
	end

	self._setting_map_save_success = true

	repeat
		local setting_name = "title_specific" .. setting_count
		local end_char = math.min((current_char + self.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT) - 1, char_count)
		local setting_value = string.sub(complete_setting_value, current_char, end_char)

		cat_print("save_manager", "[UserManager] Saving profile setting \"" .. setting_name .. "\" (" .. current_char .. " to " .. end_char .. " of " .. char_count .. " characters).")

		Global.user_manager.platform_setting_map[setting_name] = setting_value
		self._setting_map_save_counter = self._setting_map_save_counter + 1

		self:save_platform_setting(setting_name, setting_value, callback(self, self, "_save_setting_map_callback", callback_func))

		current_char = end_char + 1
		setting_count = setting_count + 1
	until char_count <= current_char
end

-- Lines: 1063 to 1070
function Xbox360UserManager:_save_setting_map_callback(callback_func, success)
	self._setting_map_save_success = self._setting_map_save_success and success
	self._setting_map_save_counter = self._setting_map_save_counter - 1

	if callback_func and self._setting_map_save_counter == 0 then
		callback_func(self._setting_map_save_success)
	end
end

-- Lines: 1073 to 1105
function Xbox360UserManager:signin_changed_callback(...)
	for user_index, signed_in in ipairs({...}) do
		local was_signed_in = self:is_signed_in(user_index)
		Global.user_manager.user_map[user_index].has_signed_out = was_signed_in and not signed_in

		if Global.user_manager.user_index == user_index and not was_signed_in and signed_in and self._active_check_user_callback_func then
			print("RUN ACTIVE USER CALLBACK FUNC")
			managers.system_menu:close("show_select_user_question_dialog")
			self._active_check_user_callback_func(true)

			self._active_check_user_callback_func = nil
		end

		if not signed_in ~= not was_signed_in then
			self:update_user(user_index, false)
		else
			local platform_id = user_index - 1
			local signin_state = XboxLive:signin_state(platform_id)
			local old_signin_state = Global.user_manager.user_map[user_index].signin_state

			if old_signin_state ~= signin_state then
				Global.user_manager.user_map[user_index].signin_state = signin_state
			end
		end
	end
end

-- Lines: 1116 to 1117
function Xbox360UserManager:profile_setting_changed_callback(...)
end

-- Lines: 1119 to 1123
function Xbox360UserManager:update_all_users()
	for user_index = 1, 4, 1 do
		self:update_user(user_index, false)
	end
end

-- Lines: 1125 to 1141
function Xbox360UserManager:update_user(user_index, ignore_username_change)
	local platform_id = user_index - 1
	local signin_state = XboxLive:signin_state(platform_id)
	local is_signed_in = signin_state ~= self.NOT_SIGNED_IN_STATE
	local storage_id, username = nil

	if is_signed_in then
		username = XboxLive:name(platform_id)
		storage_id = Application:current_storage_device_id(platform_id)

		if storage_id == 0 then
			storage_id = nil
		end
	end

	self:set_user(user_index, platform_id, storage_id, username, signin_state, ignore_username_change)
end

-- Lines: 1143 to 1145
function Xbox360UserManager:storage_devices_changed_callback()
	self:update_all_users()
end

-- Lines: 1147 to 1155
function Xbox360UserManager:check_privilege(user_index, privilege, callback_func)
	local platform_id = self:get_platform_id(user_index)
	local result = XboxLive:check_privilege(platform_id, privilege)

	if callback_func then
		func(result)
	end

	return result
end

-- Lines: 1158 to 1160
function Xbox360UserManager:get_xuid(user_index)
	local platform_id = self:get_platform_id(user_index)

	return XboxLive:xuid(platform_id)
end

-- Lines: 1163 to 1167
function Xbox360UserManager:invite_accepted_by_inactive_user()
	managers.platform:set_rich_presence("Idle")
	self:perform_load_start_menu()
	managers.menu:reset_all_loaded_data()
end
PS3UserManager = PS3UserManager or class(GenericUserManager)
UserManager.PLATFORM_CLASS_MAP[Idstring("PS3"):key()] = PS3UserManager

-- Lines: 1172 to 1176
function PS3UserManager:init()
	self._init_finalize_index = not self:is_global_initialized()

	GenericUserManager.init(self)
end

-- Lines: 1178 to 1185
function PS3UserManager:init_finalize()
	GenericUserManager.init_finalize(self)

	if self._init_finalize_index then
		self:set_user(1, nil, true, nil, true, false)

		self._init_finalize_index = nil
	end
end

-- Lines: 1187 to 1194
function PS3UserManager:set_index(user_index)
	if user_index then
		self:set_user_soft(user_index, nil, true, nil, true, false)
	end

	GenericUserManager.set_index(self, user_index)
end
PS4UserManager = PS4UserManager or class(GenericUserManager)
UserManager.PLATFORM_CLASS_MAP[Idstring("PS4"):key()] = PS4UserManager

-- Lines: 1200 to 1206
function PS4UserManager:init()
	self._init_finalize_index = not self:is_global_initialized()

	GenericUserManager.init(self)
	managers.platform:add_event_callback("disconnect", callback(self, self, "disconnect_callback"))
end

-- Lines: 1208 to 1218
function PS4UserManager:disconnect_callback()
	if Global.game_settings.single_player then
		return
	end

	if managers.network:session() and managers.network:session():_local_peer_in_lobby() then
		managers.menu:psn_disconnected()
	elseif managers.network:session() then
		managers.network:session():psn_disconnected()
	end
end

-- Lines: 1220 to 1227
function PS4UserManager:init_finalize()
	GenericUserManager.init_finalize(self)

	if self._init_finalize_index then
		self:set_user(1, nil, true, nil, true, false)

		self._init_finalize_index = nil
	end
end

-- Lines: 1229 to 1236
function PS4UserManager:set_index(user_index)
	if user_index then
		self:set_user_soft(user_index, nil, true, nil, true, false)
	end

	GenericUserManager.set_index(self, user_index)
end
WinUserManager = WinUserManager or class(GenericUserManager)
UserManager.PLATFORM_CLASS_MAP[Idstring("WIN32"):key()] = WinUserManager

-- Lines: 1242 to 1246
function WinUserManager:init()
	self._init_finalize_index = not self:is_global_initialized()

	GenericUserManager.init(self)
end

-- Lines: 1248 to 1259
function WinUserManager:init_finalize()
	GenericUserManager.init_finalize(self)

	if self._init_finalize_index then
		if Application:editor() then
			self:set_index(1)
		else
			self:set_user(1, nil, true, nil, true, false)
		end

		self._init_finalize_index = nil
	end
end

-- Lines: 1261 to 1268
function WinUserManager:set_index(user_index)
	if user_index then
		self:set_user_soft(user_index, nil, true, nil, true, false)
	end

	GenericUserManager.set_index(self, user_index)
end
XB1UserManager = XB1UserManager or class(GenericUserManager)
XB1UserManager.NOT_SIGNED_IN_STATE = "not_signed_in"
XB1UserManager.STORE_SETTINGS_ON_PROFILE = false
XB1UserManager.CAN_SELECT_USER = true
XB1UserManager.CAN_SELECT_STORAGE = true
XB1UserManager.CUSTOM_PROFILE_VARIABLE_COUNT = 3
XB1UserManager.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT = 999
XB1UserManager.CAN_CHANGE_STORAGE_ONLY_ONCE = false
UserManager.PLATFORM_CLASS_MAP[Idstring("XB1"):key()] = XB1UserManager

-- Lines: 1282 to 1301
function XB1UserManager:init()
	self._platform_setting_conversion_func_map = {gamer_control_sensitivity = callback(self, self, "convert_gamer_control_sensitivity")}

	GenericUserManager.init(self)
	managers.platform:add_event_callback("signin_changed", callback(self, self, "signin_changed_callback"))
	managers.platform:add_event_callback("profile_setting_changed", callback(self, self, "profile_setting_changed_callback"))
	managers.platform:add_event_callback("storage_devices_changed", callback(self, self, "storage_devices_changed_callback"))
	managers.platform:add_event_callback("disconnect", callback(self, self, "disconnect_callback"))
	managers.platform:add_event_callback("connect", callback(self, self, "connect_callback"))

	self._setting_map_save_counter = 0
end

-- Lines: 1303 to 1326
function XB1UserManager:update(t, dt)
	XB1UserManager.super.update(self, t, dt)

	if not self._disconnected and (self._in_online_menu or not Global.game_settings.single_player and not rawget(_G, "setup").IS_START_MENU) and not rawget(_G, "setup"):has_queued_exec() then
		local wall_time = TimerManager:wall():time()

		if not self._privilege_check_enabled then
			self._privilege_check_enabled = true
			self._next_privilege_check_time = wall_time + 2
		elseif self._next_privilege_check_time and self._next_privilege_check_time < wall_time then
			self._next_privilege_check_time = nil
			local result = self:check_privilege(nil, "multiplayer_sessions", callback(self, self, "_check_privilege_callback"))

			if not result then
				self:_check_privilege_callback(true)
			end
		end
	elseif self._privilege_check_enabled then
		self._privilege_check_enabled = nil
		self._next_privilege_check_time = nil
		self._privilege_check_fail_count = nil
	end
end

-- Lines: 1328 to 1346
function XB1UserManager:_check_privilege_callback(is_success)
	if not self._privilege_check_enabled then
		return
	end

	self._privilege_check_enabled = false

	if not is_success and (self._in_online_menu or not Global.game_settings.single_player and not rawget(_G, "setup").IS_START_MENU) and not rawget(_G, "setup"):has_queued_exec() then
		self._privilege_check_fail_count = (self._privilege_check_fail_count or 0) + 1

		if self._privilege_check_fail_count > 1 then
			print("[XB1UserManager] Lost privileges.")

			local user_data = self:_get_user_data(nil)

			self:active_user_change_state(user_data, user_data)
		end
	else
		self._privilege_check_fail_count = nil
	end
end

-- Lines: 1348 to 1370
function XB1UserManager:disconnect_callback(reason)
	print("  XB1UserManager:disconnect_callback", reason)

	if Global.game_settings.single_player then
		return
	end

	if self._disconnected then
		print("[XB1UserManager:disconnect_callback] Already disconnected. No action taken.")

		return
	end

	self._disconnected = true

	if managers.network:session() and managers.network:session():_local_peer_in_lobby() then
		managers.menu:xbox_disconnected()
	elseif self._in_online_menu then
		print("leave crimenet")
		managers.menu:xbox_disconnected()
	elseif managers.network:session() then
		managers.network:session():xbox_disconnected()
	end
end

-- Lines: 1373 to 1374
function XB1UserManager:connect_callback()
end

-- Lines: 1376 to 1379
function XB1UserManager:on_entered_online_menus()
	self._disconnected = nil
	self._in_online_menu = true
end

-- Lines: 1381 to 1383
function XB1UserManager:on_exit_online_menus()
	self._in_online_menu = false
end

-- Lines: 1385 to 1386
function XB1UserManager:is_online_menu()
	return self._in_online_menu
end

-- Lines: 1389 to 1397
function XB1UserManager:convert_gamer_control_sensitivity(value)
	if value == "low" then
		return 0.5
	elseif value == "medium" then
		return 1
	else
		return 1.5
	end
end

-- Lines: 1399 to 1405
function XB1UserManager:active_user_change_state(old_user_data, user_data)
	Global.user_manager.platform_setting_map = nil

	managers.savefile:active_user_changed()
	GenericUserManager.active_user_change_state(self, old_user_data, user_data)
end

-- Lines: 1407 to 1410
function XB1UserManager:load_platform_setting_map(callback_func)
	cat_print("user_manager", "[UserManager] Loading platform setting map.")
	XboxLive:read_profile_settings(self:get_platform_id(nil), callback(self, self, "_load_platform_setting_map_callback", callback_func))
end

-- Lines: 1412 to 1420
function XB1UserManager:_load_platform_setting_map_callback(callback_func, platform_setting_map)
	cat_print("user_manager", "[UserManager] Done loading platform setting map. Success: " .. tostring(not not platform_setting_map))

	Global.user_manager.platform_setting_map = platform_setting_map

	self:reset_setting_map()

	if callback_func then
		callback_func(platform_setting_map)
	end
end

-- Lines: 1422 to 1425
function XB1UserManager:save_platform_setting(setting_name, setting_value, callback_func)
	cat_print("user_manager", "[UserManager] Saving platform setting \"" .. tostring(setting_name) .. "\": " .. tostring(setting_value))
	XboxLive:write_profile_setting(self:get_platform_id(nil), setting_name, setting_value, callback(self, self, "_save_platform_setting_callback", callback_func))
end

-- Lines: 1429 to 1435
function XB1UserManager:_save_platform_setting_callback(callback_func, success)
	cat_print("user_manager", "[UserManager] Done saving platform setting \"" .. tostring("Dont get setting name in callback") .. "\". Success: " .. tostring(success))

	if callback_func then
		callback_func(success)
	end
end

-- Lines: 1438 to 1473
function XB1UserManager:save_setting_map(callback_func)
	if self._setting_map_save_counter > 0 then
		Appliction:error("[UserManager] Tried to set setting map again before it was done with previous set.")

		if callback_func then
			callback_func(false)

			return
		end
	end

	local complete_setting_value = Utility:pack(Global.user_manager.setting_map)
	local current_char = 1
	local char_count = #complete_setting_value
	local setting_count = 1
	local max_char_count = self.CUSTOM_PROFILE_VARIABLE_COUNT * self.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT

	if max_char_count < char_count then
		Application:stack_dump_error("[UserManager] Exceeded (" .. char_count .. ") maximum character count that can be stored in the profile (" .. max_char_count .. ").")
		callback_func(false)

		return
	end

	self._setting_map_save_success = true

	repeat
		local setting_name = "title_specific" .. setting_count
		local end_char = math.min((current_char + self.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT) - 1, char_count)
		local setting_value = string.sub(complete_setting_value, current_char, end_char)

		cat_print("save_manager", "[UserManager] Saving profile setting \"" .. setting_name .. "\" (" .. current_char .. " to " .. end_char .. " of " .. char_count .. " characters).")

		Global.user_manager.platform_setting_map[setting_name] = setting_value
		self._setting_map_save_counter = self._setting_map_save_counter + 1

		self:save_platform_setting(setting_name, setting_value, callback(self, self, "_save_setting_map_callback", callback_func))

		current_char = end_char + 1
		setting_count = setting_count + 1
	until char_count <= current_char
end

-- Lines: 1476 to 1483
function XB1UserManager:_save_setting_map_callback(callback_func, success)
	self._setting_map_save_success = self._setting_map_save_success and success
	self._setting_map_save_counter = self._setting_map_save_counter - 1

	if callback_func and self._setting_map_save_counter == 0 then
		callback_func(self._setting_map_save_success)
	end
end

-- Lines: 1485 to 1515
function XB1UserManager:signin_changed_callback(selected_xuid)
	print("[XB1UserManager:signin_changed_callback] selected_xuid", selected_xuid)

	local selected_user_index = selected_xuid and tostring(selected_xuid)
	local old_user_index = self:get_index()

	for user_index, user_data in pairs(Global.user_manager.user_map) do
		local was_signed_in = user_data.signin_state ~= self.NOT_SIGNED_IN_STATE
		local is_signed_in = XboxLive:signin_state(user_data.platform_id) ~= "not_signed_in"
		user_data.has_signed_out = was_signed_in and not is_signed_in
	end

	if selected_user_index and self._active_check_user_callback_func then
		print("[XB1UserManager:signin_changed_callback] executing _active_check_user_callback_func")
		managers.system_menu:close("show_select_user_question_dialog")
		self._active_check_user_callback_func(true)

		self._active_check_user_callback_func = nil
	end

	self:update_all_users()

	if selected_xuid then
		self:set_index(selected_xuid)
	end
end

-- Lines: 1526 to 1527
function XB1UserManager:profile_setting_changed_callback(...)
end

-- Lines: 1529 to 1554
function XB1UserManager:update_all_users()
	local old_user_indexes = {}

	for user_index, user_data in pairs(Global.user_manager.user_map) do
		table.insert(old_user_indexes, user_index)
	end

	local xuids = XboxLive:all_user_XUIDs()

	for _, xuid in pairs(xuids) do
		self:update_user(xuid, false)
	end

	for _, user_index in ipairs(old_user_indexes) do
		local found = nil

		for _, xuid in pairs(xuids) do
			if user_index == tostring(xuid) then
				found = true

				break
			end
		end

		if not found then
			self:update_user(Global.user_manager.user_map[user_index].platform_id, false)

			Global.user_manager.user_map[user_index] = nil
		end
	end
end

-- Lines: 1556 to 1577
function XB1UserManager:update_user(xuid, ignore_username_change)
	if type(xuid) == "string" then
		xuid = Xuid.from_string(xuid)
	end

	local signin_state = XboxLive:signin_state(xuid)
	local is_signed_in = signin_state ~= self.NOT_SIGNED_IN_STATE
	local storage_id, username = nil

	print("[XB1UserManager:update_user] xuid", xuid, "signin_state", signin_state, "is_signed_in", is_signed_in)

	if is_signed_in then
		username = XboxLive:name(xuid)
		storage_id = Application:current_storage_device_id(xuid)

		print(" username", username, "storage_id", storage_id)

		if storage_id == 0 then
			storage_id = nil
		end
	end

	local user_index = tostring(xuid)

	self:set_user(user_index, xuid, storage_id, username, signin_state, ignore_username_change)
end

-- Lines: 1579 to 1581
function XB1UserManager:storage_devices_changed_callback()
	self:update_all_users()
end

-- Lines: 1583 to 1585
function XB1UserManager:check_privilege(user_index, privilege, callback_func)
	local platform_id = self:get_platform_id(user_index)

	return XboxLive:check_privilege(platform_id, privilege, callback_func)
end

-- Lines: 1588 to 1590
function XB1UserManager:get_xuid(user_index)
	local platform_id = self:get_platform_id(user_index)

	return platform_id
end

-- Lines: 1596 to 1597
function XB1UserManager:invite_accepted_by_inactive_user()
end

-- Lines: 1599 to 1612
function XB1UserManager:set_index(user_index)
	local old_user_index = Global.user_manager.user_index

	print("[XB1UserManager:set_index]", user_index, "old_user_index", old_user_index)
	Application:stack_dump()

	local user_index_str = user_index and tostring(user_index) or nil

	if old_user_index ~= user_index_str then
		XboxLive:set_current_user(user_index)

		if user_index then
			self:update_user(user_index, false)
		end
	end

	XB1UserManager.super.set_index(self, user_index_str)
end


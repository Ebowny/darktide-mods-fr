--[[
    title: always_first_attack
    author: Zombine
    date: 02/05/2023
    version: 1.2.0
]]
local mod = get_mod("always_first_attack")

-- ##############################
-- Indicator
-- ##############################

mod:io_dofile("always_first_attack/scripts/mods/always_first_attack/always_first_attack_utils")

local classname = "HudElementFirstAttack"
local filename = "always_first_attack/scripts/mods/always_first_attack/always_first_attack_elements"

mod:add_require_path(filename)

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
    if not table.find_by_key(elements, "class_name", classname) then
        table.insert(elements, {
            class_name = classname,
            filename = filename,
            use_hud_scale = true,
            visibility_groups = {
                "alive",
            },
        })
    end

    return func(self, elements, visibility_groups, params)
end)

-- ##############################
-- Main
-- ##############################

local ACTION_ONE = {
    action_one_pressed = true,
    action_one_hold = true,
    action_one_release = true,
}
local WIELD = {
    quick_wield = true,
    wield_2 = true,
    wield_3 = true,
    wield_4 = true,
    wield_scroll_down = true,
    wield_scroll_up = true,
}

local init = function()
    mod._debug_mode = mod:get("enable_debug_mode")
    mod._proc_timing = mod:get("proc_timing")
    mod._proc_on_missed_swing = mod:get("enable_on_missed_swing")
    mod._auto_swing = mod:get("enable_auto_swing")
    mod._start_on_enabled = mod:get("enable_auto_start")
    mod._show_indicator = mod:get("enable_indicator")
    mod._hit_num = 0
    mod._request = {}
    mod._allow_manual_input = true
    mod._is_heavy = false
    mod._is_canceled = false
    mod._canceler = {
        action_two_hold = true,
        combat_ability_hold = true,
        grenade_ability_hold = true,
        quick_wield = true,
        wield_2 = true,
        wield_3 = true,
        wield_4 = true,
        wield_scroll_down = true,
        wield_scroll_up = true,
        weapon_extra_hold = true,
        weapon_reload_hold = true,
    }

    if mod._debug_mode then
        mod:echo("mod initialized")
    end
end

local break_attack_chain = function(triggers, attaking_unit, damage_profile)
    if not mod._is_enabled or not triggers[mod._proc_timing] then
        return
    end

    if mod._auto_swing then
        mod._is_heavy = damage_profile and damage_profile.melee_attack_strength == "heavy"
    end

    local local_player_unit = mod.get_local_player_unit()
    local request = mod._request

    if attaking_unit == local_player_unit then
        request.wield_2 = true
    end
end

mod:hook_safe("ActionSweep", "init", init)

mod:hook_safe("ActionSweep", "_reset_sweep_component", function()
    init()

    if mod._is_enabled then
        mod._allow_manual_input = false
    end

    if mod._debug_mode then
        mod:echo("reset sweep component")
    end
end)

mod:hook_safe("ActionSweep", "_process_hit", function(self)
    mod._hit_num = mod._hit_num + 1

    local triggers = {
        on_hit = true
    }

    break_attack_chain(triggers, self._player_unit, self._damage_profile)
end)

mod:hook_safe("ActionSweep", "_exit_damage_window", function(self)
    if not mod._proc_on_missed_swing and mod._hit_num == 0 then
        mod._allow_manual_input = true
        return
    end

    local triggers = {
        on_hit = true,
        on_sweep_finish = true
    }

    break_attack_chain(triggers, self._player_unit, self._damage_profile)
end)

mod:hook_safe("ActionSweep", "finish", function(self)
    mod._allow_manual_input = true
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local out = func(self, action_name)

    if mod._is_enabled and mod._request then
        local request = mod._request

        if out then
            if not mod._allow_manual_input and (ACTION_ONE[action_name]) then
                if mod._debug_mode then
                    mod:echo("action disabled: " .. action_name)
                end

                return false
            end

            if mod._auto_swing and mod._canceler[action_name] and mod._is_primary then
                mod._request = {}
                mod._is_canceled = true

                return out
            end
        end

        for request_name, val in pairs(request) do
            if val and request_name == action_name then
                if mod._debug_mode then
                    mod:echo(request_name)
                end

                if request_name == "wield_1" then
                    if mod._is_primary then
                        mod._allow_manual_input = true
                        request.wield_1 = false
                    end
                elseif request_name ~= "wield_2" then
                    request[request_name] = false
                end

                out = true

                if request_name == "action_one_pressed" then
                    request.action_one_hold = true
                elseif request_name == "action_one_hold" then
                    request.action_one_release = true
                end
            end
        end
    end

    return out
end)

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name)
    local request = mod._request

    if not mod._is_enabled then
        return
    end

    if slot_name == "slot_secondary" and request.wield_2 then
        request.wield_2 = false
        request.wield_1 = true
    elseif slot_name == "slot_primary" then
        if mod._auto_swing and not mod._is_canceled and not mod._is_heavy then
            request.action_one_pressed = true
        end
    end
end)

mod:hook_safe("PlayerUnitWeaponExtension", "update", function(self)
	local inventory_component = self._inventory_component
	local wielded_slot = inventory_component and inventory_component.wielded_slot

    mod._is_primary = wielded_slot == "slot_primary"
end)

mod.on_all_mods_loaded = function()
    mod.recreate_hud()
    init()
end

mod.on_setting_changed = function()
    mod.recreate_hud()
    init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        init()
    end
end

mod.on_enabled = function()
    mod._is_enabled = true
end

mod.on_disabled = function()
    mod._is_enabled = false
end

mod.toggle_mod = function()
    if not mod.is_in_hub() and not Managers.ui:chat_using_input() then
        init()
        mod._is_enabled = not mod._is_enabled
        local state = mod._is_enabled and Localize("loc_settings_menu_on") or Localize("loc_settings_menu_off")
        mod:notify(mod:localize("mod_name") .. ": " .. state)
    end
end

mod.toggle_auto_swing = function()
    if not mod.is_in_hub() and not Managers.ui:chat_using_input() then
        mod:set("enable_auto_swing", not mod._auto_swing)
        init()

        if mod._auto_swing and mod._start_on_enabled then
            mod._request.wield_2 = true
        end

        local state = mod._auto_swing and Localize("loc_settings_menu_on") or Localize("loc_settings_menu_off")
        mod:notify(mod:localize("auto_swing") .. ": " .. state)
    end
end
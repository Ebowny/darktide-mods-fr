local mod = get_mod("range_finder")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local decimals = mod:get("decimals")
local font_size = mod:get("font_size")
local size = { font_size * (decimals + 3), font_size }
local opacity = mod:get("font_opacity")
local position_x = mod:get("position_x")
local position_y = mod:get("position_y")

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    range_finder = {
        parent = "screen",
        scale = "fit",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = size,
        position = { position_x, position_y, 10 },
    },
}

local default_color = Color.terminal_text_header(opacity, true)
local widget_definitions = {
    range_finder = UIWidget.create_definition({
        {
            value_id = "text",
            style_id = "text",
            pass_type = "text",
            style = {
                font_size = font_size,
                drop_shadow = true,
                font_type = "machine_medium",
                text_color = default_color,
                size = size,
                text_horizontal_alignment = "center",
                text_vertical_alignment = "center",
            },
        }
    }, "range_finder")
}

local definitions = {
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
}

local HudElementRangeFinder = class("HudElementRangeFinder", "HudElementBase")

function HudElementRangeFinder:init(parent, draw_layer, start_scale)
    HudElementRangeFinder.super.init(self, parent, draw_layer, start_scale, definitions)

    self._is_in_hub = mod.is_in_hub()
    self._player_unit = mod.get_local_player_unit()
    self._widgets_by_name.range_finder.content.text = ""

    self._update_timer = 0
    self._update_delay = mod:get("update_delay") / 1000
end

function HudElementRangeFinder:update(dt, t, ui_renderer, render_settings, input_service)
    HudElementRangeFinder.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    if not mod._is_enabled or self._is_in_hub then
        self._widgets_by_name.range_finder.content.text = ""
        return
    end

    if self._update_timer < self._update_delay then
        self._update_timer = self._update_timer + dt
        return
    end

    if mod._distance ~= nil then
        self:_update_distance(mod._distance)
    end

    self._update_timer = 0
end

function HudElementRangeFinder:_update_distance(distance)
    local widget = self._widgets_by_name.range_finder
    local content = widget.content
    local style = widget.style
    local text_color = default_color

    if distance == 0 then
        content.text = "N/A"
        style.text.text_color = text_color
        return
    end

    content.text = string.format("%." .. decimals .. "f", math.floor(distance * 10 ^ decimals) / 10 ^ decimals)

    for key, color in pairs(mod.color_table(opacity)) do
        local threshold = mod:get(key)
        if threshold and threshold ~= 0 and distance <= threshold then
            text_color = color
            break
        end
    end

    style.text.text_color = text_color
end

return HudElementRangeFinder

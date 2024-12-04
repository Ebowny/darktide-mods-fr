local mod = get_mod("range_finder")

local locres = {
    mod_name = {
        en = "Range Finder",
        ["zh-cn"] = "距离指示器",
        ru = "Дальномер",
    },
    mod_description = {
        en = "Display the distance to the aimed position.",
        ja = "照準した位置までの距離を表示します。",
        ["zh-cn"] = "显示准星指向位置的距离。",
        ru = "Range Finder - Показывает расстояние до цели.",
    },
    update_delay = {
        en = "Update interval (ms)",
        ja = "アップデート間隔 (ms)",
        ["zh-cn"] = "更新间隔（毫秒）",
        ru = "Интервал обновления (мс)",
    },
    delay_caution = {
        en = "Caution: Lowering this value will result in smoother execution, but may impact stability and performance.",
        ja = "注意：この値を下げると動作がよりなめらかになりますが、安定性やパフォーマンスに影響を与える可能性があります。",
        ["zh-cn"] = "注意：降低此设置会使数值变化更平缓，但可能会影响稳定和性能。",
        ru = "Внимание: уменьшение этого значения приведёт к более плавному выполнению, но может сильно повлиять на стабильность и производительность.",
    },
    decimals = {
        en = "Number of decimal places",
        ja = "少数点以下の桁数",
        ["zh-cn"] = "小数位数",
        ru = "Количество десятичных знаков",
    },
    font = {
        en = "Font settings",
        ja = "フォント設定",
        ["zh-cn"] = "字体设置",
        ru = "Настройки шрифта",
    },
    font_size = {
        en = "Size",
        ja = "大きさ",
        ["zh-cn"] = "大小",
        ru = "Размер",
    },
    font_opacity = {
        en = "Opacity",
        ja = "不透明度",
        ["zh-cn"] = "不透明度",
        ru = "Прозрачность",
    },
    position = {
        en = "Display position",
        ja = "表示位置",
        ["zh-cn"] = "显示位置",
        ru = "Положение на экране",
    },
    position_x = {
        en = "X",
    },
    position_y = {
        en = "Y",
    },
    distance = {
        en = "Distance to change color (m)",
        ja = "色を変える距離 (m)",
        ["zh-cn"] = "颜色变化距离（米）",
        ru = "Расстояние для смены цвета (м)",
    },
    distance_mid = {
        en = "Yellow",
        ja = "黄色",
        ["zh-cn"] = "黄色",
        ru = "Жёлтый",
    },
    distance_close = {
        en = "Orange",
        ja = "オレンジ色",
        ["zh-cn"] = "橙色",
        ru = "Оранжевый",
    },
    distance_very_close = {
        en = "Red",
        ja = "赤色",
        ["zh-cn"] = "红色",
        ru = "Красный",
    },
}

mod.color_table = function(opacity)
    local color_table = {
        distance_mid = Color.ui_hud_warp_charge_low(opacity, true),
        distance_close = Color.ui_hud_warp_charge_medium(opacity, true),
        distance_very_close = Color.ui_hud_warp_charge_high(opacity, true),
    }

    return color_table
end

for key, color in pairs(mod.color_table(255)) do
    if locres[key] then
        for lang, text in pairs(locres[key]) do
            locres[key][lang] = "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}" .. text .. "{#reset()}"
        end
    end
end

return locres

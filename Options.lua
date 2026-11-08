local _, ns = ...
local L = ns.L

-- Options page in Blizzard's settings (Options > AddOns > Profession Tracking Highlight).

local function OnChanged()
    ns.RestyleButtons()
end

local function SpellLabel(id, fallback)
    return ns.SpellName(id) or fallback
end

function ns.InitOptions()
    if ns.settingsCategory or not (Settings and Settings.RegisterVerticalLayoutCategory) then
        return
    end
    local category, layout = Settings.RegisterVerticalLayoutCategory(L.TITLE)
    layout = layout or SettingsPanel:GetLayout(category)

    local function Header(text)
        if CreateSettingsListSectionHeaderInitializer then
            layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
        end
    end

    local function Register(key, varType, label)
        local setting = Settings.RegisterAddOnSetting(category, "ProfessionTrackingHighlight_" .. key, key, ns.db,
            varType, label, ns.DEFAULTS[key])
        setting:SetValueChangedCallback(OnChanged)
        return setting
    end

    local function Checkbox(key, label, tooltip)
        Settings.CreateCheckbox(category, Register(key, Settings.VarType.Bool, label), tooltip)
    end

    local function Color(key, label, tooltip)
        Settings.CreateColorSwatch(category, Register(key, Settings.VarType.String, label), tooltip)
    end

    local herbs = SpellLabel(ns.FIND_HERBS, "Find Herbs")
    local minerals = SpellLabel(ns.FIND_MINERALS, "Find Minerals")
    local examples = {}
    for index, id in ipairs(ns.OTHER_EXAMPLES) do
        examples[index] = SpellLabel(id, "?")
    end

    Header(L.OPT_HEADER_TRACKING)
    Checkbox("otherTracking", L.OPT_OTHER, L.OPT_OTHER_TIP:format(unpack(examples)))

    Header(L.OPT_HEADER_LOOK)
    local sliderOptions = Settings.CreateSliderOptions(1, 8, 1)
    if MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label then
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    end
    Settings.CreateSlider(category, Register("thickness", Settings.VarType.Number, L.OPT_THICKNESS), sliderOptions,
        L.OPT_THICKNESS_TIP)
    Checkbox("glow", L.OPT_GLOW, L.OPT_GLOW_TIP)
    Color("colorHerbs", L.OPT_COLOR:format(herbs), L.OPT_COLOR_TIP:format(herbs))
    Color("colorMinerals", L.OPT_COLOR:format(minerals), L.OPT_COLOR_TIP:format(minerals))
    Color("colorOther", L.OPT_COLOR_OTHER, L.OPT_COLOR_OTHER_TIP)

    Settings.RegisterAddOnCategory(category)
    ns.settingsCategory = category
end

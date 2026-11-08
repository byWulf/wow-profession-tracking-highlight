local ADDON, ns = ...

ns.DEFAULTS = {
    otherTracking = false,
    glow = false,
    thickness = 3,
    colorHerbs = "ff33dd33",
    colorMinerals = "ffff9900",
    colorOther = "ffffd100",
}

-- The profession trackings. Forever knows each under two spell IDs (the second one as used by EnhanceQoL's
-- Forever build); trackings with other IDs are still recognized by their name.
ns.FIND_HERBS = 2383
ns.FIND_MINERALS = 2580
local PROFESSION = {
    [2383] = "herbs",
    [8387] = "herbs",
    [2580] = "minerals",
    [8388] = "minerals",
}

-- Examples of class and racial trackings, for the option's tooltip: Find Treasure, Track Beasts, Sense Undead.
ns.OTHER_EXAMPLES = { 2481, 1494, 5502 }

local COLOR_KEYS = { herbs = "colorHerbs", minerals = "colorMinerals", other = "colorOther" }

---------------------------------------------------------------------------
-- Helpers

-- Values may be secret in combat in this client; those can't be compared or used.
function ns.IsSecret(value)
    return issecretvalue ~= nil and issecretvalue(value) == true
end

local RawSpellName = (C_Spell and C_Spell.GetSpellName) or function(id)
    return (GetSpellInfo(id))
end

function ns.SpellName(id)
    if type(id) ~= "number" or ns.IsSecret(id) then
        return nil
    end
    local ok, name = pcall(RawSpellName, id)
    if ok and not ns.IsSecret(name) and type(name) == "string" and name ~= "" then
        return name
    end
    return nil
end

function ns.HexToRGB(hex)
    hex = type(hex) == "string" and hex or "ffffffff"
    if #hex == 8 then
        hex = hex:sub(3)
    end
    local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    return (r or 255) / 255, (g or 255) / 255, (b or 255) / 255
end

function ns.KindColor(kind)
    return ns.HexToRGB(ns.db[COLOR_KEYS[kind] or "colorOther"])
end

---------------------------------------------------------------------------
-- Active tracking

-- Names of the profession trackings in the client's language, filled once the client knows them.
local professionNames

local function ProfessionByName(name)
    if not professionNames then
        local names, complete = {}, true
        for id, kind in pairs(PROFESSION) do
            local spellName = ns.SpellName(id)
            if spellName then
                names[spellName] = kind
            else
                complete = false
            end
        end
        if not complete then
            return names[name]
        end
        professionNames = names
    end
    return professionNames[name]
end

local function KindOf(spellID, name)
    return PROFESSION[spellID] or (name and ProfessionByName(name)) or "other"
end

-- The active trackings we mark: kind by spell ID and by name (name catches a bar spell with another ID).
local activeIDs, activeNames = {}, {}

-- Reads the minimap's tracking list. Returns nil when the client doesn't (yet) give a readable answer.
local function ReadTracking()
    local api = C_Minimap
    if not (api and api.GetNumTrackingTypes and api.GetTrackingInfo) then
        return nil
    end
    local ok, count = pcall(api.GetNumTrackingTypes)
    if not ok or ns.IsSecret(count) or type(count) ~= "number" then
        return nil
    end
    local ids, names = {}, {}
    for index = 1, count do
        local okInfo, info = pcall(api.GetTrackingInfo, index)
        if not okInfo or ns.IsSecret(info) then
            return nil
        end
        if type(info) == "table" then
            local spellID, active, name = info.spellID, info.active, info.name
            if ns.IsSecret(spellID) or ns.IsSecret(active) or ns.IsSecret(name) then
                return nil
            end
            -- Entries without a spell (flight masters, mailboxes, ...) are not trackings of yours.
            if active == true and type(spellID) == "number" then
                local kind = KindOf(spellID, name)
                if kind ~= "other" or ns.db.otherTracking then
                    ids[spellID] = kind
                    local spellName = ns.SpellName(spellID) or name
                    if type(spellName) == "string" then
                        names[spellName] = kind
                    end
                end
            end
        end
    end
    return ids, names
end

function ns.UpdateTracking()
    if not ns.db then
        return
    end
    local ids, names = ReadTracking()
    if ids then
        activeIDs, activeNames = ids, names
    end
    ns.UpdateButtons()
end

function ns.RequestTrackingUpdate()
    if ns.trackingPending then
        return
    end
    ns.trackingPending = true
    C_Timer.After(0.1, function()
        ns.trackingPending = false
        ns.UpdateTracking()
    end)
end

-- The kind of active tracking a spell on a button stands for, or nil.
function ns.ActiveKind(spellID)
    if type(spellID) ~= "number" then
        return nil
    end
    local kind = activeIDs[spellID]
    if kind then
        return kind
    end
    local name = ns.SpellName(spellID)
    return name and activeNames[name] or nil
end

---------------------------------------------------------------------------
-- Slash command

local function OpenOptions()
    if ns.settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(ns.settingsCategory:GetID())
    end
end

SLASH_PROFESSIONTRACKINGHIGHLIGHT1 = "/pth"
SLASH_PROFESSIONTRACKINGHIGHLIGHT2 = "/professiontracking"
SlashCmdList.PROFESSIONTRACKINGHIGHLIGHT = OpenOptions

---------------------------------------------------------------------------
-- Events

local function InitDB()
    ProfessionTrackingHighlightDB = ProfessionTrackingHighlightDB or {}
    for key, value in pairs(ns.DEFAULTS) do
        if ProfessionTrackingHighlightDB[key] == nil then
            ProfessionTrackingHighlightDB[key] = value
        end
    end
    ns.db = ProfessionTrackingHighlightDB
end

local handlers = {}

function handlers.ADDON_LOADED(name)
    if name == ADDON then
        InitDB()
    else
        ns.RequestButtonScan()
    end
end

function handlers.PLAYER_LOGIN()
    ns.InitOptions()
    ns.InstallLibActionButtonHooks()
end

function handlers.PLAYER_ENTERING_WORLD()
    -- The walk over all frames (for unknown bar addons) only once per session.
    ns.RequestButtonScan(not ns.didFullScan)
    ns.didFullScan = true
    ns.RequestTrackingUpdate()
end

handlers.MINIMAP_UPDATE_TRACKING = ns.RequestTrackingUpdate
handlers.SPELLS_CHANGED = ns.RequestTrackingUpdate
-- Values that were secret in combat can be read again.
handlers.PLAYER_REGEN_ENABLED = ns.RequestTrackingUpdate

local function ButtonsChanged()
    ns.RequestButtonUpdate()
end
handlers.ACTIONBAR_SLOT_CHANGED = ButtonsChanged
handlers.ACTIONBAR_PAGE_CHANGED = ButtonsChanged
handlers.UPDATE_BONUS_ACTIONBAR = ButtonsChanged
handlers.UPDATE_SHAPESHIFT_FORM = ButtonsChanged
handlers.UPDATE_MACROS = ButtonsChanged

local frame = CreateFrame("Frame")
for event in pairs(handlers) do
    -- Not every event exists in every client build.
    pcall(frame.RegisterEvent, frame, event)
end
frame:SetScript("OnEvent", function(_, event, ...)
    if event ~= "ADDON_LOADED" and not ns.db then
        return
    end
    handlers[event](...)
end)

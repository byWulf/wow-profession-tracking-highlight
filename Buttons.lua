local _, ns = ...

-- Every action button we know of, from any action bar addon. Buttons are matched by the spell they show,
-- so the bar addon doesn't matter as long as its buttons are found.
local buttons = {}
local overlays = {}
local shownKind = {}

local HasAction = (C_ActionBar and C_ActionBar.HasAction) or HasAction
local GetActionInfo = GetActionInfo
local GetMacroSpell = GetMacroSpell
local IsSecret = ns.IsSecret

-- Buttons by name: Blizzard's bars, Bartender4, Dominos, EllesmereUI, ElvUI and DaylightUI.
local NAMED = {
    { "ActionButton", 12 },
    { "MultiBarBottomLeftButton", 12 },
    { "MultiBarBottomRightButton", 12 },
    { "MultiBarRightButton", 12 },
    { "MultiBarLeftButton", 12 },
    { "MultiBar5Button", 12 },
    { "MultiBar6Button", 12 },
    { "MultiBar7Button", 12 },
    { "BonusActionButton", 12 },
    { "BT4Button", 180 },
    { "DominosActionButton", 180 },
    { "MultiBarRightActionButton", 12 },
    { "MultiBarLeftActionButton", 12 },
    { "MultiBarBottomRightActionButton", 12 },
    { "MultiBarBottomLeftActionButton", 12 },
    { "MultiBar5ActionButton", 12 },
    { "MultiBar6ActionButton", 12 },
    { "MultiBar7ActionButton", 12 },
    { "EABButton", 180 },
}
for bar = 1, 15 do
    NAMED[#NAMED + 1] = { "ElvUI_Bar" .. bar .. "Button", 12 }
end
for bar = 1, 10 do
    NAMED[#NAMED + 1] = { "DaylightUIBar" .. bar .. "Button", 12 }
end

local LAB_MAJORS = { "LibActionButton-1.0", "LibActionButton-1.0-ElvUI" }

local function IsUsableFrame(frame)
    if type(frame) ~= "table" or type(frame.GetObjectType) ~= "function" then
        return false
    end
    local ok, forbidden = pcall(function()
        return frame.IsForbidden and frame:IsForbidden()
    end)
    return ok and not forbidden
end

local function Add(button)
    if not buttons[button] and IsUsableFrame(button) then
        buttons[button] = true
    end
end

local function LooksLikeActionButton(frame)
    local ok, result = pcall(function()
        if frame:IsForbidden() or not frame:IsObjectType("Button") then
            return false
        end
        if frame._state_type ~= nil then
            return true -- LibActionButton
        end
        return type(frame.action) == "number" and (frame.icon ~= nil or frame.Icon ~= nil)
    end)
    return ok and result
end

-- Finds the buttons; `full` also walks all frames once, for action bar addons not listed above.
function ns.CollectButtons(full)
    for _, entry in ipairs(NAMED) do
        for index = 1, entry[2] do
            local button = _G[entry[1] .. index]
            if button then
                Add(button)
            end
        end
    end
    if ActionBarButtonEventsFrame and type(ActionBarButtonEventsFrame.frames) == "table" then
        for _, button in pairs(ActionBarButtonEventsFrame.frames) do
            Add(button)
        end
    end
    if LibStub then
        for _, major in ipairs(LAB_MAJORS) do
            local lab = LibStub(major, true)
            if lab and lab.GetAllButtons then
                for button in pairs(lab:GetAllButtons()) do
                    Add(button)
                end
            end
        end
    end
    if full and EnumerateFrames then
        local frame = EnumerateFrames()
        while frame do
            if not buttons[frame] and LooksLikeActionButton(frame) then
                Add(frame)
            end
            frame = EnumerateFrames(frame)
        end
    end
end

function ns.RequestButtonScan(full)
    ns.scanFull = ns.scanFull or full
    if ns.scanPending then
        return
    end
    ns.scanPending = true
    C_Timer.After(full and 2 or 1, function()
        ns.scanPending = false
        local isFull = ns.scanFull
        ns.scanFull = false
        ns.CollectButtons(isFull)
        ns.UpdateButtons()
    end)
end

function ns.RequestButtonUpdate()
    if ns.buttonUpdatePending then
        return
    end
    ns.buttonUpdatePending = true
    C_Timer.After(0.05, function()
        ns.buttonUpdatePending = false
        ns.UpdateButtons()
    end)
end

function ns.InstallLibActionButtonHooks()
    if not LibStub then
        return
    end
    for _, major in ipairs(LAB_MAJORS) do
        local lab = LibStub(major, true)
        if lab and lab.RegisterCallback then
            local owner = {}
            lab.RegisterCallback(owner, "OnButtonCreated", function(_, button)
                Add(button)
                ns.RequestButtonUpdate()
            end)
            lab.RegisterCallback(owner, "OnButtonContentsChanged", function()
                ns.RequestButtonUpdate()
            end)
        end
    end
end

---------------------------------------------------------------------------
-- What a button shows
--
-- Each function returns `readable` first (false while the client keeps the answer secret, then the button keeps
-- its current look), followed by up to two spell IDs the button may stand for.

local UNREADABLE = false

local function MacroSpell(index)
    if IsSecret(index) or type(index) ~= "number" or not GetMacroSpell then
        return true
    end
    local ok, spellID = pcall(GetMacroSpell, index)
    if not ok or IsSecret(spellID) then
        return UNREADABLE
    end
    return true, spellID
end

local function SlotSpells(slot)
    if IsSecret(slot) then
        return UNREADABLE
    end
    if type(slot) ~= "number" or slot <= 0 then
        return true
    end
    local ok, has = pcall(HasAction, slot)
    if not ok or IsSecret(has) then
        return UNREADABLE
    end
    if not has then
        return true
    end
    local ok2, kind, id, subType = pcall(GetActionInfo, slot)
    if not ok2 or IsSecret(kind) or IsSecret(id) or IsSecret(subType) then
        return UNREADABLE
    end
    if kind == "spell" then
        return true, id
    elseif kind == "macro" then
        -- Depending on the client, a macro that shows a spell gives that spell's ID here, or the macro's index.
        local readable, spellID = MacroSpell(id)
        if subType == "spell" then
            return readable, id, spellID
        end
        return readable, spellID
    end
    return true
end

local function ButtonSlot(button)
    local slot = button.action
    if type(slot) ~= "number" and button.CalculateAction then
        local ok, value = pcall(button.CalculateAction, button)
        slot = ok and value or nil
    end
    if type(slot) ~= "number" and button.GetAttribute then
        local ok, value = pcall(button.GetAttribute, button, "action")
        slot = ok and (IsSecret(value) and value or tonumber(value)) or nil
    end
    return slot
end

local function ButtonSpells(button)
    local stateType = button._state_type
    if stateType == nil then
        return SlotSpells(ButtonSlot(button))
    end
    -- LibActionButton (Bartender4, ElvUI, ...)
    local value = button._state_action
    if IsSecret(stateType) or IsSecret(value) then
        return UNREADABLE
    end
    if stateType == "action" then
        return SlotSpells(value)
    elseif stateType == "spell" then
        return true, tonumber(value)
    elseif stateType == "macro" then
        return MacroSpell(value)
    end
    return true
end

local function KindOfButton(button)
    local readable, first, second = ButtonSpells(button)
    if not readable then
        return nil, false
    end
    return ns.ActiveKind(first) or ns.ActiveKind(second), true
end

---------------------------------------------------------------------------
-- Border and glow

local GLOW_TEXTURE = [[Interface\SpellActivationOverlay\IconAlert]]

local function CreateOverlay(button)
    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel(button:GetFrameLevel() + 8)
    overlay.edges = {}
    for index = 1, 4 do
        overlay.edges[index] = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
    end

    local glow = overlay:CreateTexture(nil, "OVERLAY", nil, 6)
    glow:SetTexture(GLOW_TEXTURE)
    glow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    glow:SetBlendMode("ADD")
    glow:SetPoint("CENTER")
    local pulse = glow:CreateAnimationGroup()
    pulse:SetLooping("BOUNCE")
    local alpha = pulse:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0.3)
    alpha:SetToAlpha(1)
    alpha:SetDuration(0.75)
    alpha:SetSmoothing("IN_OUT")
    overlay.glow, overlay.pulse = glow, pulse

    overlays[button] = overlay
    return overlay
end

local function LayoutEdges(overlay, button, thickness)
    local top, bottom, left, right = unpack(overlay.edges)
    for _, edge in ipairs(overlay.edges) do
        edge:ClearAllPoints()
    end
    -- One unit outside the button, the rest inside, so neighbouring buttons don't cover it.
    top:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
    top:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, 1)
    top:SetHeight(thickness)
    bottom:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -1, -1)
    bottom:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    bottom:SetHeight(thickness)
    left:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
    left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -1, -1)
    left:SetWidth(thickness)
    right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, 1)
    right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    right:SetWidth(thickness)
end

local function ApplyKind(button, kind)
    local overlay = overlays[button]
    if not kind then
        if overlay then
            overlay.pulse:Stop()
            overlay:Hide()
        end
        return
    end
    overlay = overlay or CreateOverlay(button)
    local r, g, b = ns.KindColor(kind)
    LayoutEdges(overlay, button, ns.db.thickness or 3)
    for _, edge in ipairs(overlay.edges) do
        edge:SetColorTexture(r, g, b, 1)
    end
    if ns.db.glow then
        local width, height = button:GetSize()
        overlay.glow:SetSize(width * 1.5, height * 1.5)
        overlay.glow:SetVertexColor(r, g, b)
        overlay.glow:Show()
        if not overlay.pulse:IsPlaying() then
            overlay.pulse:Play()
        end
    else
        overlay.pulse:Stop()
        overlay.glow:Hide()
    end
    overlay:Show()
end

-- Redraws everything, e.g. after the options changed.
function ns.RestyleButtons()
    wipe(shownKind)
    ns.UpdateTracking()
end

function ns.UpdateButtons()
    if not ns.db then
        return
    end
    for button in pairs(buttons) do
        local kind, readable = KindOfButton(button)
        if readable and shownKind[button] ~= (kind or false) then
            shownKind[button] = kind or false
            ApplyKind(button, kind)
        end
    end
end

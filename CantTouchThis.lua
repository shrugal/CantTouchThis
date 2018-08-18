local Name, Addon = ...
local PS = LibStub("LibPlayerSpells-1.0")

-- The types of CC we are interested in
Addon.CC_TYPES = bit.bor(PS.constants.DISORIENT, PS.constants.INCAPACITATE, PS.constants.ROOT, PS.constants.STUN)

-- NPC database
CantTouchThisDB = CantTouchThisDB or {}
Addon.npcs = CantTouchThisDB

-- Recently stunned npcs
Addon.stunned = {}

-------------------------------------------------------
--                      Locale                       --
-------------------------------------------------------

local locale, L = GetLocale(), {}

-- enUS
L["CC_IMMUNE"] = "Immune to crowd control"

-- deDE
if locale == "deDE" then
    L["CC_IMMUNE"] = "Immun gegen Kontrolleffekte"
end

-------------------------------------------------------
--                   Events/Hooks                    --
-------------------------------------------------------

-- Register events
Addon.frame = CreateFrame("Frame")
Addon.frame:SetScript("OnEvent", function (self, e, ...) Addon[e](Addon, ...) end)
Addon.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Combat log event
function Addon:COMBAT_LOG_EVENT_UNFILTERED()
    local t, event, _, sourceGUID, source, _, _, destGUID, dest, _, _, spellId, _, _, arg1 = CombatLogGetCurrentEventInfo()

    -- Check if we are interested in the event
    if not source or not dest or not UnitPlayerControlled(source) or UnitPlayerControlled(dest) then return end
    if not (event == "SPELL_AURA_APPLIED" or event == "SPELL_MISSED" and arg1 == "IMMUNE") then return end

    -- Get spell info
    local info, _, _, details = PS:GetSpellInfo(spellId)
    if not (info and details) then return end

    -- Check if it's a CC we are interested in
    if bit.band(info, PS.constants.CROWD_CTRL) > 0 and bit.band(details, Addon.CC_TYPES) > 0 then
        local npcId = Addon.GetNPCId(destGUID)

        if event == "SPELL_AURA_APPLIED" then
            Addon.stunned[npcId] = true
            Addon.npcs[npcId] = nil
        elseif event == "SPELL_MISSED" and not Addon.stunned[npcId] then
            Addon.npcs[npcId] = true
        end
    end
end

-- Unit tooltip
GameTooltip:HookScript('OnTooltipSetUnit', function(self)
    local name, unit = GameTooltip:GetUnit()
    if unit or name then
        local npcId = Addon.GetNPCId(UnitGUID(unit or name))
        if npcId and Addon.npcs[npcId] then
            GameTooltip:AddLine(L["CC_IMMUNE"])
        end
    end
end)

-------------------------------------------------------
--                       Util                        --
-------------------------------------------------------

-- Get an NPC's id from its GUID
function Addon.GetNPCId(guid)
    return tonumber(select(6, ("-"):split(guid)), 10)
end
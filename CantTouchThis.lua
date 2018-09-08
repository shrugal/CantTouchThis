local Name, Addon = ...
local PS = LibStub("LibPlayerSpells-1.0")

-- TODO: DEBUG
CTT = Addon

-- The types of CC we are interested in
Addon.CC_TYPES = bit.bor(PS.constants.DISORIENT, PS.constants.INCAPACITATE, PS.constants.ROOT, PS.constants.STUN)

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
Addon.frame:SetScript("OnEvent", function (self, e, ...) Addon[e](...) end)
Addon.frame:RegisterEvent("ADDON_LOADED")
Addon.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Addon loading event
function Addon.ADDON_LOADED(name)
    if name == Name then
        CantTouchThisDB = CantTouchThisDB or Addon.immuneFound
        Addon.immuneFound = CantTouchThisDB
    end
end

-- Combat log event
function Addon.COMBAT_LOG_EVENT_UNFILTERED()
    local t, event, _, sourceGUID, source, _, _, destGUID, dest, _, _, spellId, spellName, _, arg1 = CombatLogGetCurrentEventInfo()

    -- Check if we are interested in the event
    if not source or not dest or Addon.IsNPC(sourceGUID) or not Addon.IsNPC(destGUID) then return end
    if not (event == "SPELL_AURA_APPLIED" or event == "SPELL_MISSED" and arg1 == "IMMUNE") then return end

    -- Get spell info
    local info, _, _, details = PS:GetSpellInfo(spellId)
    if not (info and details) then return end

    -- Check if it's a CC we are interested in
    if bit.band(info, PS.constants.CROWD_CTRL) > 0 and bit.band(details, Addon.CC_TYPES) > 0 then
        local npcId = Addon.GetNPCId(destGUID)
        if npcId then
            if event == "SPELL_AURA_APPLIED" then
                Addon.stunned[npcId] = true
                Addon.immuneFound[npcId] = nil
            elseif event == "SPELL_MISSED" and not Addon.stunned[npcId] then
                Addon.immuneFound[npcId] = true
            end
        end
    end
end

-- Unit tooltip
GameTooltip:HookScript('OnTooltipSetUnit', function(self)
    local name, unit = GameTooltip:GetUnit()
    if unit or name then
        local guid = UnitGUID(unit or name)
        if guid then
        local npcId = Addon.GetNPCId(guid)
            if npcId and Addon.immuneFound[npcId] or Addon.immuneKnown[npcId] then
                GameTooltip:AddLine(L["CC_IMMUNE"])
            end
        end
    end
end)

-------------------------------------------------------
--                       Util                        --
-------------------------------------------------------

function Addon.IsNPC(guid)
    return guid:sub(1, 8) == "Creature"
end

-- Get an NPC's id from its GUID
function Addon.GetNPCId(guid)
    return tonumber(select(6, ("-"):split(guid)), 10)
end

-------------------------------------------------------
--                       Data                        --
-------------------------------------------------------

-- Recently stunned npcs
Addon.stunned = {}

-- Immune NPCs we found
Addon.immuneFound = {}

-- Immune NPCs that are known already
Addon.immuneKnown = {}
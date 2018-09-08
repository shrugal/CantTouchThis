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
        if npcId and not Addon.immuneKnown[npcId] then
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
Addon.immuneKnown = {
    [128969] = true,
    [129227] = true,
    [129369] = true,
    [131318] = true,
    [131436] = true,
    [131817] = true,
    [132056] = true,
    [133384] = true,
    [133430] = true,
    [133436] = true,
    [133912] = true,
    [134012] = true,
    [134158] = true,
    [134174] = true,
    [134251] = true,
    [134331] = true,
    [134691] = true,
    [134701] = true,
    [134991] = true,
    [135231] = true,
    [135245] = true,
    [135263] = true,
    [135472] = true,
    [136160] = true,
    [136250] = true,
    [136549] = true,
    [136613] = true,
    [136984] = true,
    [137204] = true,
    [137474] = true,
    [137484] = true,
    [137665] = true,
    [137704] = true,
    [137969] = true,
    [138255] = true,
    [138281] = true,
    [138465] = true,
    [139110] = true,
    [139425] = true,
    [144086] = true,
}
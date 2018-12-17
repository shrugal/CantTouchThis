local Name, Addon = ...
local PS = LibStub("LibPlayerSpells-1.0")

-- TODO: DEBUG
CTT = Addon

-- The types of CC we are interested in
Addon.CC_TYPES = bit.bor(PS.constants.DISORIENT, PS.constants.INCAPACITATE, PS.constants.ROOT, PS.constants.STUN)

-------------------------------------------------------
--                      Locale                       --
-------------------------------------------------------

local LINE = ({
    deDE = "Immun gegen Kontrolleffekte",
    zhCN = "免疫群体控制"
})[GetLocale()] or "Immune to crowd control"

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

        -- Remove known NPCs from the list
        for npcId in pairs(Addon.immuneKnown) do Addon.immuneFound[npcId] = nil end
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
                GameTooltip:AddLine(LINE)
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
	[120850] = true,
	[127072] = true,
	[127315] = true,
	[128184] = true,
	[128455] = true,
	[129214] = true,
	[129231] = true,
	[129552] = true,
	[129699] = true,
	[129802] = true,
	[131156] = true,
	[131157] = true,
	[131812] = true,
	[131825] = true,
	[131863] = true,
	[131864] = true,
	[132253] = true,
	[133172] = true,
	[133379] = true,
	[133389] = true,
	[133935] = true,
	[134629] = true,
	[134739] = true,
	[134993] = true,
	[135329] = true,
	[135365] = true,
	[135475] = true,
	[135759] = true,
	[136076] = true,
	[136100] = true,
	[136391] = true,
	[137478] = true,
	[137486] = true,
	[138489] = true,
	[139422] = true,
	[139946] = true,
	[140615] = true,
	[141806] = true,
	[148550] = true,
	[31146] = true,
	[64587] = true,
	[65310] = true,
    [122965] = true,
    [122968] = true,
    [122984] = true,
    [125977] = true,
    [126963] = true,
    [127479] = true,
    [127484] = true,
    [127490] = true,
    [128584] = true,
    [128969] = true,
    [129227] = true,
    [129369] = true,
    [129602] = true,
    [130025] = true,
    [130400] = true,
    [130655] = true,
    [130912] = true,
    [131318] = true,
    [131436] = true,
    [131577] = true,
    [131789] = true,
    [131817] = true,
    [132056] = true,
    [132074] = true,
    [132998] = true,
    [133007] = true,
    [133298] = true,
    [133384] = true,
    [133430] = true,
    [133436] = true,
    [133439] = true,
    [133463] = true,
    [133492] = true,
    [133912] = true,
    [134002] = true,
    [134010] = true,
    [134012] = true,
    [134034] = true,
    [134056] = true,
    [134058] = true,
    [134060] = true,
    [134063] = true,
    [134069] = true,
    [134144] = true,
    [134150] = true,
    [134158] = true,
    [134174] = true,
    [134251] = true,
    [134331] = true,
    [134417] = true,
    [134442] = true,
    [134445] = true,
    [134590] = true,
    [134635] = true,
    [134637] = true,
    [134691] = true,
    [134701] = true,
    [134717] = true,
    [134828] = true,
    [134991] = true,
    [135016] = true,
    [135231] = true,
    [135245] = true,
    [135263] = true,
    [135322] = true,
    [135452] = true,
    [135472] = true,
    [135706] = true,
    [135770] = true,
    [136083] = true,
    [136160] = true,
    [136203] = true,
    [136214] = true,
    [136249] = true,
    [136250] = true,
    [136254] = true,
    [136295] = true,
    [136297] = true,
    [136323] = true,
    [136353] = true,
    [136493] = true,
    [136502] = true,
    [136510] = true,
    [136549] = true,
    [136601] = true,
    [136613] = true,
    [136684] = true,
    [136984] = true,
    [137119] = true,
    [137204] = true,
    [137321] = true,
    [137474] = true,
    [137484] = true,
    [137649] = true,
    [137665] = true,
    [137704] = true,
    [137708] = true,
    [137881] = true,
    [137969] = true,
    [137983] = true,
    [138255] = true,
    [138281] = true,
    [138288] = true,
    [138465] = true,
    [138529] = true,
    [138967] = true,
    [139051] = true,
    [139110] = true,
    [139233] = true,
    [139381] = true,
    [139425] = true,
    [139487] = true,
    [140393] = true,
    [140398] = true,
    [140599] = true,
    [141264] = true,
    [141266] = true,
    [142148] = true,
    [142207] = true,
    [142219] = true,
    [142242] = true,
    [142243] = true,
    [142433] = true,
    [142802] = true,
    [144086] = true,
}
--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

----------------------------------------------------------------------------]]--

--[[

excludedspells is a list of spell ids the player has disabled
    ["excludedspells"] = { spellid1, spellid2, spellid3, ... }
  
flagoverrides is a table of tuples with bits to set and clear.
    ["flagoverrides"] = {
        ["spellid"] = { bits_to_set, bits_to_clear },
        ...
    }

The modified mount flags are then:
    ( flags | bits_to_set ) & !bits_to_clear

The reason to do it this way instead of just storing the xor is that
the default flags might change and we don't want the override to suddenly
go from disabling somthing to enabling it.

]]--

local Default_LM_OptionsDB = {
    ["excludedspells"] = { },
    ["flagoverrides"]  = { },
}

LM_Options = { }

function LM_Options:Initialize()

    if not LM_OptionsDB then
        LM_OptionsDB = Default_LM_OptionsDB
    end

    -- Compatibility fixups
    if not LM_OptionsDB.excludedspells then
        local orig = LM_OptionsDB
        LM_OptionsDB = Default_LM_OptionsDB
        LM_OptionsDB.excludedspells = orig
    end

    self.excludedspells = LM_OptionsDB.excludedspells
    self.flagoverrides = LM_OptionsDB.flagoverrides

end

--[[----------------------------------------------------------------------------
   Excluded Spell stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedSpell(id)
    for _,s in ipairs(self.excludedspells) do
        if s == id then return true end
    end
end

function LM_Options:AddExcludedSpell(id)
    LM_Debug(string.format("Disabling mount %s (%d).", GetSpellInfo(id), id))
    if not self:IsExcludedSpell(id) then
        table.insert(self.excludedspells, id)
        table.sort(self.excludedspells)
    end
end

function LM_Options:RemoveExcludedSpell(id)
    LM_Debug(string.format("Enabling mount %s (%d).", GetSpellInfo(id), id))
    for i = 1, #self.excludedspells do
        if self.excludedspells[i] == id then
            table.remove(self.excludedspells, i)
            return
        end
    end
end

function LM_Options:SetExcludedSpells(idlist)
    LM_Debug("Setting complete list of disabled mounts.")
    table.wipe(self.excludedspells)
    for _,id in ipairs(idlist) do
        table.insert(self.excludedspells, id)
    end
    table.sort(self.excludedspells)
end

--[[----------------------------------------------------------------------------
   Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplySpellFlags(id, flags)
    local ov = self.flagoverrides[id]

    if not ov then return flags end

    flags = bit.bor(flags, ov[1])
    flags = bit.band(flags, bit.bnot(ov[2]))

    return flags
end

function LM_Options:SetSpellFlagBit(id, flagbit)
    LM_Debug(string.format("Setting flag bit %d for spell %s (%d).",
                           flagbit, GetSpellInfo(id), id))

    self.flagoverrides[id][1] = bit.bor(self.flagoverrides[id][1], flagbit)
end

function LM_Options:ClearSpellFlagBit(id, flagbit)
    LM_Debug(string.format("Clearing flag bit %d for spell %s (%d).",
                           flagbit, GetSpellInfo(id), id))

    self.flagoverrides[id][2] = bit.bor(self.flagoverrides[id][2], flagbit)
end

function LM_Options:ResetSpellFlags(id)
    LM_Debug(string.format("Defaulting flags for spell %s (%d).",
                           GetSpellInfo(id), id))

    self.flagoverrides[id] = nil
end

function LM_Options:SetSpellFlags(id, origflags, newflags)

    if origflags == newflags then
        self:ResetSpellFlags(id)
        return
    end

    if not self.flagoverrides[id] then
        self.flagoverrides[id] = { 0, 0 }
    end

    local toset = bit.band(bit.bxor(origflags, newflags), newflags)
    local toclear = bit.band(bit.bxor(origflags, newflags), bit.bnot(newflags))

    self.flagoverrides[id][1] = toset
    self.flagoverrides[id][2] = toclear
end


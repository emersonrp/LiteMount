--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

----------------------------------------------------------------------------]]--

LM_Mount = { }
LM_Mount.__index = LM_Mount
function LM_Mount:new() return setmetatable({ }, LM_Mount) end

local FlagOverrideTable = {
    [LM_SPELL_AQUATIC_FORM]      = bit.bor(LM_FLAG_BIT_FLOAT,LM_FLAG_BIT_SWIM),
    [LM_SPELL_RIDING_TURTLE]     = bit.bor(LM_FLAG_BIT_FLOAT,LM_FLAG_BIT_SWIM),
    [LM_SPELL_SEA_TURTLE]        = bit.bor(LM_FLAG_BIT_FLOAT,LM_FLAG_BIT_SWIM),
    [LM_SPELL_FLIGHT_FORM]       = bit.bor(LM_FLAG_BIT_FLY),
    [LM_SPELL_SWIFT_FLIGHT_FORM] = bit.bor(LM_FLAG_BIT_FLY),
    [LM_SPELL_RUNNING_WILD]      = bit.bor(LM_FLAG_BIT_WALK),
}
for _,s in ipairs(LM_AQ_MOUNT_SPELLS) do
    FlagOverrideTable[s] = bit.band(LM_FLAG_BIT_AQ)
end
for _,s in ipairs(LM_VASHJIR_MOUNT_SPELLS) do
    FlagOverrideTable[s] = bit.band(LM_FLAG_BIT_VASHJIR)
end

function LM_Mount:FixupFlags()
    local flags = FlagOverrideTable[self.spellid]
    if flags then
        self.flags = flags
    end

    -- Which fly/walk flagged mounts can mount in no-fly areas is arbitrary.
    if bit.band(self.flags, LM_FLAG_BIT_FLY) > 0 then
        self.flags = LM_FLAG_BIT_FLY
    end

    if self.casttime == 0 then
        self.flags = bit.bor(self.flags, LM_FLAG_BIT_MOVING)
    end
end

function LM_Mount:GetMountBySpell(spellId)
    local m = LM_Mount:new()
    local si = { GetSpellInfo(spellId) }
    m.name = si[1]
    m.spellid = spellId
    m.spellname = si[1]
    m.icon = si[3]
    m.flags = 0
    m.casttime = si[7]
    m:FixupFlags()
    return m
end

function LM_Mount:GetMountByIndex(mountIndex)
    local m = LM_Mount:new()
    local ci = { GetCompanionInfo("MOUNT", mountIndex) }

    m.name = ci[2]
    m.spellid = ci[3]
    m.icon = ci[4]
    m.flags = ci[6]

    local si = { GetSpellInfo(m.spellid) }
    m.spellname = si[1]
    m.casttime = si[7]

    m:FixupFlags()
    return m
end

function LM_Mount:SpellId()
    return self.spellid
end

function LM_Mount:SpellName()
    return self.spellname
end

function LM_Mount:Icon()
    return self.icon
end

function LM_Mount:Name()
    return self.name
end

function LM_Mount:Flags()
    return self.flags
end

function LM_Mount:CanFly()
    return bit.band(self.flags, LM_FLAG_BIT_FLY)
end

function LM_Mount:CanWalk()
    return bit.band(self.flags, LM_FLAG_BIT_WALK)
end

function LM_Mount:CanFloat()
    return bit.band(self.flags, LM_FLAG_BIT_FLOAT)
end

function LM_Mount:CanSwim()
    return bit.band(self.flags, LM_FLAG_BIT_SWIM)
end

function LM_Mount:CastTime()
    return self.casttime
end

function LM_Mount:Useable()
    return IsUsableSpell(self.spellid)
end

function LM_Mount:Dump()
    LM_Print(string.format("%s %d %02x", self.name, self.spellid, self.flags))
end
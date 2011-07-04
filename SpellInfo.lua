--[[----------------------------------------------------------------------------

  LiteMount/SpellInfo.lua

  Constants for mount spell information.

----------------------------------------------------------------------------]]--

-- Bits 1 through 16 match Blizzard's flags in GetCompanionInfo()
LM_FLAG_BIT_WALK = 1
LM_FLAG_BIT_FLY = 2
LM_FLAG_BIT_FLOAT = 4
LM_FLAG_BIT_SWIM = 8
LM_FLAG_BIT_JUMP = 16
LM_FLAG_BIT_UNUSED = 32
LM_FLAG_BIT_AQ = 64
LM_FLAG_BIT_VASHJIR = 128

LM_SPELL_AQUATIC_FORM = 1066
LM_SPELL_FLIGHT_FORM = 33943
LM_SPELL_RIDING_TURTLE = 30174
LM_SPELL_SWIFT_FLIGHT_FORM = 40120
LM_SPELL_SEA_TURTLE = 64731
LM_SPELL_ABYSSAL_SEAHORSE = 75207
LM_SPELL_RUNNING_WILD = 87840
LM_SPELL_BLUE_QIRAJI_TANK = 25953
LM_SPELL_GREEN_QIRAJI_TANK = 26054
LM_SPELL_RED_QIRAJI_TANK = 26055
LM_SPELL_YELLOW_QIRAJI_TANK = 26056

LM_RACIAL_MOUNT_SPELLS = {
    LM_SPELL_RUNNING_WILD,
}

LM_CLASS_MOUNT_SPELLS = {
    LM_SPELL_AQUATIC_FORM,
    LM_SPELL_FLIGHT_FORM,
    LM_SPELL_SWIFT_FLIGHT_FORM,
}

LM_AQ_MOUNT_SPELLS = {
    LM_SPELL_BLUE_QIRAJI_TANK,
    LM_SPELL_GREEN_QIRAJI_TANK,
    LM_SPELL_RED_QIRAJI_TANK,
    LM_SPELL_YELLOW_QIRAJI_TANK,
}

LM_VASHJIR_MOUNT_SPELLS = {
    LM_SPELL_ABYSSAL_SEAHORSE,
}

--[[----------------------------------------------------------------------------

  LiteMount/Core.lua

  Addon core.

----------------------------------------------------------------------------]]--

local MACRO_DISMOUNT = "/dismount"
local MACRO_CANCELFORM = "/cancelform"
local MACRO_EXITVEHICLE = "/run VehicleExit()"
local MACRO_DISMOUNT_CANCELFORM = "/dismount\n/cancelform"

LiteMount = LM_CreateAutoEventFrame("Button", "LiteMount", UIParent, "SecureActionButtonTemplate")
LiteMount:RegisterEvent("PLAYER_LOGIN")

local RescanEvents = {
    -- Companion change
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Might have learned a new mount spell
    "TRAINER_CLOSED",
    -- You might have learned instant ghost wolf
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item
    "BAG_UPDATE"
}

function LiteMount:Initialize()

    LM_Debug("Initialize")

    LM_Options:Initialize()
    LM_MountList:Initialize()

    -- Delayed scanning does two things. It stops us rescanning unecessarily,
    -- but more importantly it prevents a weird situation on loading where
    -- the scan errors because GetCompanionInfo("MOUNT", i) fails for some
    -- i < GetNumCompanions("MOUNT").
    self.needscan = true

    SlashCmdList["LiteMount"] = function () InterfaceOptionsFrame_OpenToCategory(LiteMountOptions) end
    SLASH_LiteMount1 = "/litemount"
    SLASH_LiteMount2 = "/lmt"

    self.playerClass = select(2, UnitClass("player"))

    if self.playerClass == "DRUID" or self.playerClass == "SHAMAN" then
        self.defaultMacro = MACRO_DISMOUNT_CANCELFORM
    else
        self.defaultMacro = MACRO_DISMOUNT
    end

    -- Button-fu
    self:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    self:SetScript("PreClick", function () LiteMount:PreClick() end)
    self:SetScript("PostClick", function () LiteMount:PostClick() end)
    self:SetAttribute("macrotext", self.defaultMacro)
    self:SetAttribute("type", "macro")
    self:SetAttribute("unit", "player")

    -- Mount event setup
    for _,ev in ipairs(RescanEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got rescan event "..event)
                            self.needscan = true
                        end
        self:RegisterEvent(ev)
    end

end

function LiteMount:ScanMounts()
    if not self.needscan then return end
    LM_Debug("Rescanning list of mounts.")
    LM_MountList:ScanMounts()
    self.needscan = nil
end

function LiteMount:GetAllMounts()
    if not LM_MountList then return {} end
    self:ScanMounts()
    local allmounts = LM_MountList:GetMounts()
    table.sort(allmounts, function(a,b) return a:Name() < b:Name() end)
    return allmounts
end

function LiteMount:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")

    -- We might login already in combat.
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        self:Initialize()
    end
end

function LiteMount:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:Initialize()
end

function LiteMount:SetAsDefault()
    LM_Debug("Setting action to default.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", self.defaultMacro)
end

function LiteMount:SetAsDismount()
    LM_Debug("Setting action to Dismount.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_DISMOUNT)
end

function LiteMount:SetAsVehicleExit()
    LM_Debug("Setting action to VehicleExit.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_EXITVEHICLE)
end

function LiteMount:SetAsCancelForm()
    LM_Debug("Setting action to CancelForm.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", MACRO_CANCELFORM)
end

function LiteMount:SetAsPlayerTargetedSpell(spellId)
    local name = GetSpellInfo(LM_SPELL_SLOW_FALL)
    LM_Debug("Setting action to " .. name .. ".")
    self:SetAttribute("type", "spell")
    self:SetAttribute("spell", name)
    -- self:SetAttribute("unit", "player") -- Already done in setup
end

function LiteMount:SetAsFlexweaveUnderlay()
    LM_Debug("Setting action to Flexweave Underlay.")
    self:SetAttribute("type", "macro")
    self:SetAttribute("macro", "/use 15")
end

function LiteMount:FallingPanic()
    LM_Debug("Falling! Panic! Trying last resort options.")

    for _,spellid in ipairs(LM_HELP_IM_FALLING_SPELLS) do
        if IsUsableSpell(spellid) then
            self:SetAsPlayerTargetedSpell(spellid)
            return true
        end
    end

    local cloakid = GetInventoryItemID("player", INVSLOT_BACK)
    if cloakid and not GetItemCooldown(cloakid) then
        self:SetAsFlexweaveUnderlay()
        return true
    end
end

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LiteMount:PreClick()

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called.")

    self:ScanMounts()

    -- Mounted -> dismount
    if IsMounted() then
        self:SetAsDismount()
        return
    end

    -- In vehicle -> exit it
    if CanExitVehicle() then
        self:SetAsVehicleExit()
        return
    end

    -- The (true) here stops it returning stances and other pseudo-forms
    local form = GetShapeshiftForm(true)

    if self.playerClass == "DRUID" and form == 2 or form == 4 or form == 6 then
        self:SetAsCancelForm()
        return
    elseif self.playerClass == "SHAMAN" and form == 1 then
        self:SetAsCancelForm()
        return
    end

    local m

    if not m and LM_Location:CanFly() then
        m = LM_MountList:GetRandomFlyingMount()
    end

    if not m and LM_Location:IsVashjir() then
        m = LM_MountList:GetRandomVashjirMount()
    end

    if not m and LM_Location:CanSwim() then
        m = LM_MountList:GetRandomSwimmingMount()
    end

    if not m and LM_Location:IsAQ() then
        m = LM_MountList:GetRandomAQMount()
    end

    if not m and LM_Location:CanWalk() then
        m = LM_MountList:GetRandomWalkingMount()
                or LM_MountList:GetRandomSlowWalkingMount()
    end

    if m then
        LM_Debug("calling m:SetupActionButton")
        m:SetupActionButton(self)
        return
    elseif IsFalling() and self:FallingPanic() then
        -- Nothing
        return
    else
        -- This isn't a great message, but there isn't a better one that
        -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
        -- LM_Warning("You don't know any mounts you can use right now.")
        LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)
    end

end

function LiteMount:PostClick()
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    self:SetAsDefault()
end

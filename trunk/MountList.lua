--[[----------------------------------------------------------------------------

  LiteMount/MountList.lua

  Information on all your mounts.

----------------------------------------------------------------------------]]--

LM_MountList = { }
LM_MountList.__index = LM_MountList

local function IterateCompanionMounts()
    local i = 0
    local max = GetNumCompanions("MOUNT")

    return function ()
            i = i + 1
            if i <= n then return Mount:GetMountByIndex(i) end
        end
end

local function IterateRacialMounts()
    local i = 0
    local max = table.getn(LM_RACIAL_MOUNT_SPELLS)

    return function ()
            while i <= max do
                i = i + 1
                if MountSpell:IsKnown(LM_RACIAL_MOUNT_SPELLS[i]) then
                    return Mount:GetMountBySpell(LM_RACIAL_MOUNT_SPELLS[i])
                end
            end
        end
end

local function IterateClassMounts()
    local i = 0
    local max = table.getn(LM_CLASS_MOUNT_SPELLS)

    return function ()
            while i <= max do
                i = i + 1
                if MountSpell:IsKnown(LM_CLASS_MOUNT_SPELLS[i]) then
                    return Mount:GetMountBySpell(LM_CLASS_MOUNT_SPELLS[i])
                end
            end
        end
    
end

function LM_MountList:new()
    local ml = setmetatable({ }, LM_MountList)
    ml.byname = { }
    return ml
end

function LM_MountList:ScanMounts()

    table.wipe(self.byname)

    for m in IterateCompanionMounts() do
        self.byname[m.name] = m
    end
        
    for m in IterateRacialMounts() do
        self.byname[m.name] = m
    end
        
    for m in IterateClassMounts() do
        self.byname[m.name] = m
    end

    -- Saves having to do it on display
    table.sort(self.byname)
end

function LM_MountList:GetRandomMount(flags)
    local poss = { }

    for _, m in pairs(self.byname) do
        table.insert(poss, m)
    end

    -- Shuffle, http://forums.wowace.com/showthread.php?t=16628
    for i = #poss, 2, -1 do
        local r = math.random(i)
        poss[i], poss[r] = poss[r], poss[i]
    end

    -- Test for usable here?
    return poss[1]
end

function LM_MountList:GetRandomFlyingMount()
    -- XXX FIXME XXX Druid forms are instant cast and frankly a lot better.
    return self:GetRandomMount(LM_FLAG_BIT_FLY)
end

function LM_MountList:GetRandomWalkingMount()
    return self:GetRandomMount(LM_FLAG_BIT_WALK)
end

function LM_MountList:GetRandomAQMount()
    return self:GetRandomMount(LM_FLAG_BIT_AQ)
end

function LM_MountList:GetRandomVashjirMount()
    return self:GetRandomMount(LM_FLAG_BIT_VASHJIR)
end

function LM_MOuntList:GetRandomSwimmingMount()
    return self:GetRandomMount(LM_FLAG_BIT_SWIM)
end

function LM_MountList:Dump()
    for _,m in pairs(self.byname) do
        m:Dump()
    end
end
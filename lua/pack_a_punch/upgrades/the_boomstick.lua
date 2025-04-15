local UPGRADE = {}
UPGRADE.id = "the_boomstick"
UPGRADE.class = "weapon_ttt_tf2_caber"
UPGRADE.name = "The Boomstick"
UPGRADE.desc = "No self-damage, infinite explosions!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    local timername = "TTTPAPTheBoomstick" .. SWEP:EntIndex()

    timer.Create(timername, 1, 0, function()
        if not IsValid(SWEP) then
            timer.Remove(timername)

            return
        end

        SWEP:SetExploded(false)
        SWEP:SetClip1(1)

        if IsValid(SWEP.v_model) then
            SWEP.v_model:Remove()
            SWEP.SwitchedViewModel = false
        end
    end)

    self:AddToHook(SWEP, "Think", function()
        if IsValid(SWEP.v_model) and SWEP.v_model:GetMaterial() ~= TTTPAP.camo then
            SWEP.v_model:SetPAPCamo()
        end
    end)

    self:AddHook("EntityTakeDamage", function(ply, dmg)
        local inflictor = dmg:GetInflictor()
        if not self:IsValidUpgrade(inflictor) then return end
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) then return end
        if attacker == ply then return true end
    end)
end

TTTPAP:Register(UPGRADE)
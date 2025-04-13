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

        if IsValid(self.v_model) then
            self.v_model:Remove()
            self.SwitchedViewModel = false
        end
    end)

    self:AddHook("PlayerShouldTakeDamage", function(ply, attacker)
        if not IsValid(ply) or not IsValid(attacker) then return end
        local wep = attacker:GetActiveWeapon()
        if not IsValid(wep) then return end
        if self:IsValidUpgrade(wep) and ply == attacker then return false end
    end)
end

TTTPAP:Register(UPGRADE)
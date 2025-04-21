local UPGRADE = {}
UPGRADE.id = "cloak_and_dagger"
UPGRADE.class = "weapon_ttt_tf2_inviswatch"
UPGRADE.name = "Cloak and Dagger"
UPGRADE.desc = "Recharges while standing still and not attacking!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    local maxVel = 40

    self:AddHook("PlayerPostThink", function(ply)
        local wep = ply:GetWeapon(self.class)
        if not self:IsValidUpgrade(wep) then return end

        if wep.CloakCostTimer < CurTime() and wep:Clip1() < wep:GetMaxClip1() and not ply:KeyDown(IN_ATTACK) and not ply:KeyDown(IN_ATTACK2) and not ply:KeyDown(IN_RELOAD) then
            local vel = ply:GetVelocity()
            if math.abs(vel.x) > maxVel or math.abs(vel.y) > maxVel or math.abs(vel.z) > maxVel then return end
            wep:SetClip1(wep:Clip1() + 1)
            wep.CloakCostTimer = CurTime() + 0.2
        end
    end)
end

TTTPAP:Register(UPGRADE)
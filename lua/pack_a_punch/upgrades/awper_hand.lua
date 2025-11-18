local UPGRADE = {}
UPGRADE.id = "awper_hand"
UPGRADE.class = "weapon_ttt_tf2_sniper"
UPGRADE.name = "AWPer Hand"
UPGRADE.desc = "Full-charge headshots always kill!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    self:SetClip(SWEP, 3)

    self:AddHook("ScalePlayerDamage", function(victim, hitgroup, dmg)
        if hitgroup ~= HITGROUP_HEAD then return end
        local inflictor = dmg:GetInflictor()
        if not self:IsValidUpgrade(inflictor) or inflictor.Primary.Damage < inflictor.Primary.FullChargeDamage then return end
        dmg:SetDamage(10000)
        inflictor:EmitSound("player/crit_hit.wav")
        if CLIENT then return end

        timer.Simple(0.1, function()
            if not self:IsAlivePlayer(victim) then return end
            victim:Kill()
        end)
    end)
end

TTTPAP:Register(UPGRADE)
local UPGRADE = {}
UPGRADE.id = "steak_sandvich"
UPGRADE.class = "weapon_ttt_tf2_sandvich"
UPGRADE.name = "Buffalo Steak Sandvich"
UPGRADE.desc = "Om nom nom... Sandvich last long!\nSandvich make more damage and speed!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.Duration = SWEP.Duration * 2

    self:AddHook("ScalePlayerDamage", function(_, _, dmg)
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) or not attacker.TF2SandvichHealth then return end
        dmg:ScaleDamage(1.3)
    end)

    if SERVER then
        -- Hijack the Sandvich's health value that is automatically set/unset as the Sandvich takes effect
        self:AddHook("PlayerPostThink", function(ply)
            if ply.TF2SandvichHealth and not ply.TF2SandvichSpeed then
                ply.TF2SandvichSpeed = ply:GetLaggedMovementValue()
                ply:SetLaggedMovementValue(ply.TF2SandvichSpeed * 1.5)
            elseif not ply.TF2SandvichHealth and ply.TF2SandvichSpeed then
                ply:SetLaggedMovementValue(ply.TF2SandvichSpeed)
                ply.TF2SandvichSpeed = nil
            end
        end)
    end
end

TTTPAP:Register(UPGRADE)
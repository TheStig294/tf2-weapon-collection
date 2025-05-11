local UPGRADE = {}
UPGRADE.id = "amputator"
UPGRADE.class = "weapon_ttt_tf2_bonesaw"
UPGRADE.name = "Amputator"
UPGRADE.desc = "Health regen increased, also heals nearby players!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    self:AddToHook(SWEP, "Think", function()
        local owner = SWEP:GetOwner()
        if not IsValid(owner) then return end
        -- Other players are healed slower than default
        SWEP.HealAmount = 1

        for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), 100)) do
            if not IsValid(ent) or ent == owner or not ent:IsPlayer() or not ent:Alive() or ent:IsSpec() then continue end
            SWEP:DoHeal(ent)
        end

        -- Owner is healed faster than default, handled by the weapon's base Think hook
        SWEP.HealAmount = 2
    end)
end

TTTPAP:Register(UPGRADE)
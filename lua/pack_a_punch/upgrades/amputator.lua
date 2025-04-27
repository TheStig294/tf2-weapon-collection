local UPGRADE = {}
UPGRADE.id = "amputator"
UPGRADE.class = "weapon_ttt_tf2_bonesaw"
UPGRADE.name = "Amputator"
UPGRADE.desc = "Health regen increased, now given to nearby players!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.HealAmount = 2

    self:AddToHook(SWEP, "Think", function()
        local owner = SWEP:GetOwner()
        if not IsValid(owner) then return end

        for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), 250)) do
            if not IsValid(ent) or not ent:IsPlayer() or not ent:Alive() or ent:IsSpec() then return end
            SWEP:DoHeal(ent)
        end
    end)
end

TTTPAP:Register(UPGRADE)
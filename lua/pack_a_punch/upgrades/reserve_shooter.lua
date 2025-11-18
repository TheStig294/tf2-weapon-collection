local UPGRADE = {}
UPGRADE.id = "reserve_shooter"
UPGRADE.class = "weapon_ttt_tf2_shotgun"
UPGRADE.name = "Reserve Shooter"
UPGRADE.desc = "1-shot kills anyone in the air!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.Primary.Sound = "weapons/reserve_shooter_0" .. math.random(4) .. ".wav"

    self:AddToHook(SWEP, "PrimaryAttack", function()
        SWEP.Primary.Sound = "weapons/reserve_shooter_0" .. math.random(4) .. ".wav"
    end)

    self:AddHook("EntityTakeDamage", function(ent, dmg)
        if not IsValid(ent) or IsValid(ent:GetGroundEntity()) or ent:GetGroundEntity():IsWorld() then return end
        local inflictor = dmg:GetInflictor()

        if self:IsValidUpgrade(inflictor) then
            dmg:SetDamage(10000)
            inflictor:EmitSound("weapons/reserve_shooter_0" .. math.random(4) .. "_crit.wav")
        end
    end)
end

TTTPAP:Register(UPGRADE)
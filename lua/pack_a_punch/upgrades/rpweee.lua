local UPGRADE = {}
UPGRADE.id = "rpweee"
UPGRADE.class = "weapon_ttt_tf2_rpg"
UPGRADE.name = "RPWeeeeee!"
UPGRADE.desc = "Immune to fall & self-damage while held\nlaunches players hilariously far!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.Primary.Force = SWEP.Primary.Force * 2
    SWEP.AmmoEnt = nil
    SWEP.Primary.Ammo = "RPG_Round"
    SWEP.ReserveAmmo = 8
    self:SetClip(SWEP, 4)
    local own = SWEP:GetOwner()

    if IsValid(own) then
        own:SetAmmo(SWEP.ReserveAmmo, "RPG_Round")
        SWEP.ReserveAmmo = 0
    else
        self:AddToHook(SWEP, "Deploy", function()
            local owner = SWEP:GetOwner()
            if not IsValid(owner) then return end
            own:SetAmmo(SWEP.ReserveAmmo, "RPG_Round")
            SWEP.ReserveAmmo = 0
        end)
    end

    self:AddHook("EntityTakeDamage", function(ent, dmg)
        if not self:IsAlivePlayer(ent) then return end
        local activeWep = ent:GetActiveWeapon()
        if not self:IsValidUpgrade(activeWep) then return end
        -- Immune to fall damage while held
        if dmg:IsFallDamage() then return true end
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) then return end
        -- Immune to your own rocket explosions
        if inflictor:GetClass() == "ttt_tf2_rocket" or inflictor:GetClass() == "weapon_ttt_tf2_rpg" and inflictor:GetOwner() == ent then return true end
    end)
end

TTTPAP:Register(UPGRADE)
local UPGRADE = {}
UPGRADE.id = "blutsauger"
UPGRADE.class = "weapon_ttt_tf2_syringegun"
UPGRADE.name = "Blutsauger"
UPGRADE.desc = "Heals 3 HP for every hit!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    self:AddHook("PostEntityTakeDamage", function(ent, dmg, damageTaken)
        if not damageTaken or not self:IsAlivePlayer(ent) then return end
        local inflictor = dmg:GetInflictor()
        if not self:IsValidUpgrade(inflictor) then return end
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) then return end
        local health = attacker:Health()
        local newHealth = health + 3
        local maxHealth = attacker:GetMaxHealth()

        if newHealth < maxHealth then
            attacker:SetHealth(newHealth)
        elseif health < maxHealth then
            attacker:SetHealth(maxHealth)
        end
    end)
end

TTTPAP:Register(UPGRADE)
local UPGRADE = {}
UPGRADE.id = "the_equalizer"
UPGRADE.class = "weapon_ttt_tf2_escapeplan"
UPGRADE.name = "The Equalizer"
UPGRADE.desc = "Damage increases as health decreases as well!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.Primary.TTTPAPDamageOG = SWEP.Primary.Damage

    self:AddToHook(SWEP, "Think", function()
        if SWEP.CurrentSpeedBoost then
            SWEP.Primary.Damage = SWEP.CurrentSpeedBoost * SWEP.Primary.TTTPAPDamageOG
        end
    end)
end

TTTPAP:Register(UPGRADE)
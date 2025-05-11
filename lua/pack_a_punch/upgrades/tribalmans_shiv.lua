local UPGRADE = {}
UPGRADE.id = "tribalmans_shiv"
UPGRADE.class = "weapon_ttt_tf2_machete"
UPGRADE.name = "Tribalman's Shiv"
UPGRADE.desc = "Bleed lasts forever, kills are silent!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    SWEP.BleedDamageTicks = 1000
    SWEP.DamageType = DMG_SLASH
end

TTTPAP:Register(UPGRADE)
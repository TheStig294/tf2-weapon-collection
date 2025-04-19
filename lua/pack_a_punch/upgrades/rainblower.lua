local UPGRADE = {}
UPGRADE.id = "rainblower"
UPGRADE.class = "weapon_ttt_tf2_flamethrower"
UPGRADE.name = "Rainblower"
UPGRADE.desc = "Increased damage, range and ammo... Shoots rainbows!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_rainblower"
UPGRADE.ammoMult = 2
UPGRADE.damageMult = 1.5

function UPGRADE:Apply(SWEP)
    SWEP.Primary.Range = SWEP.Primary.Range * 2
end

TTTPAP:Register(UPGRADE)
local UPGRADE = {}
UPGRADE.id = "loose_cannon"
UPGRADE.class = "weapon_ttt_tf2_grenadelauncher"
UPGRADE.name = "Loose Cannon"
UPGRADE.desc = "Hold fire to charge, shoots high-damage cannonballs!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_loosecannon"

function UPGRADE:Apply(SWEP)
    self:SetClip(SWEP, 1)
end

TTTPAP:Register(UPGRADE)
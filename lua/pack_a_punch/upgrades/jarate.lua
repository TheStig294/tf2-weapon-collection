local UPGRADE = {}
UPGRADE.id = "jarate"
UPGRADE.class = "weapon_ttt_tf2_smg"
UPGRADE.name = "Jarate"
UPGRADE.desc = "Throw at players to make them temporarily take more damage!"
UPGRADE.noSound = true
UPGRADE.newClass = "weapon_ttt_tf2_jarate"

function UPGRADE:Apply(SWEP)
    self:SetClip(SWEP, -1)
end

TTTPAP:Register(UPGRADE)
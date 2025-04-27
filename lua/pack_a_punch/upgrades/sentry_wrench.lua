local UPGRADE = {}
UPGRADE.id = "sentry_wrench"
UPGRADE.class = "weapon_ttt_tf2_eurekaeffect"
UPGRADE.name = "Sentry Wrench"
UPGRADE.desc = "Press Right-Click to place and build a sentry!"
UPGRADE.noSound = true

function UPGRADE:Apply(SWEP)
    TF2WC:AddSentryPlacerFunctions(SWEP)
end

TTTPAP:Register(UPGRADE)
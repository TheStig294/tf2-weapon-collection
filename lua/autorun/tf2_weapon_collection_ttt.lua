game.AddParticles("particles/flamethrower.pcf")
game.AddParticles("particles/medicgun_beam.pcf")
game.AddParticles("particles/rockettrail.pcf")
game.AddParticles("particles/stickybomb.pcf")
PrecacheParticleSystem("rockettrail")
PrecacheParticleSystem("pyro_blast")
PrecacheParticleSystem("flamethrower")
PrecacheParticleSystem("pipebombtrail_red")
PrecacheParticleSystem("stickybombtrail_red")
PrecacheParticleSystem("stickybomb_pulse_red")

if SERVER then
    resource.AddSingleFile("resource/fonts/tf2build.ttf")
else
    surface.CreateFont("TF2Font", {
        font = "TF2 Build",
        extended = false,
        size = 20,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
end

-- Makes the crowbar droppable so that we can pick up the melee weapons that spawn on the ground that this mod adds
-- This is the exact behaviour taken from Custom Roles, to be as compatible with existing mods as possible
hook.Add("PreRegisterSWEP", "TF2WeaponCollectionDroppableCrowbar", function(SWEP, class)
    if class == "weapon_zm_improvised" then
        SWEP.AllowDrop = true

        function SWEP:OnDrop()
        end

        -- Don't drop the crowbar when a player dies, as it makes a distinct loud sound the gives away players dying
        hook.Add("DoPlayerDeath", "TF2WeaponCollectionStopCrowbarDeathNoise", function(ply)
            ply:StripWeapon("weapon_zm_improvised")
        end)

        hook.Remove("PreRegisterSWEP", "TF2WeaponCollectionDroppableCrowbar")
    end
end)
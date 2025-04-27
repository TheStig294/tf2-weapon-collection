game.AddParticles("particles/flamethrower.pcf")
game.AddParticles("particles/medicgun_beam.pcf")
game.AddParticles("particles/rockettrail.pcf")
game.AddParticles("particles/stickybomb.pcf")
game.AddParticles("particles/items_demo.pcf")
game.AddParticles("particles/halloween.pcf")
game.AddParticles("particles/item_fx.pcf")
PrecacheParticleSystem("rockettrail")
PrecacheParticleSystem("pyro_blast")
PrecacheParticleSystem("flamethrower")
PrecacheParticleSystem("flamethrower_rainbow")
PrecacheParticleSystem("pipebombtrail_red")
PrecacheParticleSystem("stickybombtrail_red")
PrecacheParticleSystem("stickybomb_pulse_red")
PrecacheParticleSystem("fuse_sparks")
PrecacheParticleSystem("peejar_impact")
PrecacheParticleSystem("peejar_drips")
PrecacheParticleSystem("peejar_trail_red")

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

hook.Add("PostGamemodeLoaded", "TF2RoleGlobals", function()
    TF2WC = TF2WC or {}

    TF2WC.REDRoles = {
        [ROLE_REDSCOUT] = true,
        [ROLE_REDSOLIDER] = true,
        [ROLE_REDPYRO] = true,
        [ROLE_REDDEMOMAN] = true,
        [ROLE_REDHEAVY] = true,
        [ROLE_REDENGINEER] = true,
        [ROLE_REDMEDIC] = true,
        [ROLE_REDSNIPER] = true,
        [ROLE_REDSPY] = true,
        [ROLE_REDMANN] = true
    }

    TF2WC.BLURoles = {
        [ROLE_BLUSCOUT] = true,
        [ROLE_BLUSOLIDER] = true,
        [ROLE_BLUPYRO] = true,
        [ROLE_BLUDEMOMAN] = true,
        [ROLE_BLUHEAVY] = true,
        [ROLE_BLUENGINEER] = true,
        [ROLE_BLUMEDIC] = true,
        [ROLE_BLUSNIPER] = true,
        [ROLE_BLUSPY] = true,
        [ROLE_BLUMANN] = true
    }

    TF2WC.REDRolesList = {ROLE_REDSCOUT, ROLE_REDSOLIDER, ROLE_REDPYRO, ROLE_REDDEMOMAN, ROLE_REDHEAVY, ROLE_REDENGINEER, ROLE_REDMEDIC, ROLE_REDSNIPER, ROLE_REDSPY}

    TF2WC.BLURolesList = {ROLE_BLUSCOUT, ROLE_BLUSOLIDER, ROLE_BLUPYRO, ROLE_BLUDEMOMAN, ROLE_BLUHEAVY, ROLE_BLUENGINEER, ROLE_BLUMEDIC, ROLE_BLUSNIPER, ROLE_BLUSPY}

    function TF2WC:IsValidTF2Role(ply)
        return IsValid(ply) and (self.REDRoles[ply:GetRole()] or self.BLURoles[ply:GetRole()])
    end
end)
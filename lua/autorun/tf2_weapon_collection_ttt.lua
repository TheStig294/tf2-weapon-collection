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

    TF2WC.Classes = {
        {
            name = "scout",
            roles = {ROLE_REDSCOUT, ROLE_BLUSCOUT},
            loadout = {"weapon_ttt_tf2_sandman", "weapon_ttt_tf2_pistol", "weapon_ttt_tf2_scattergun"},
            speed = 1.33
        },
        {
            name = "soldier",
            roles = {ROLE_REDSOLDIER, ROLE_BLUSOLDIER},
            loadout = {"weapon_ttt_tf2_rpg", "weapon_ttt_tf2_shotgun", "weapon_ttt_tf2_escapeplan"},
            speed = 0.8
        },
        {
            name = "pyro",
            roles = {ROLE_REDPYRO, ROLE_BLUPYRO},
            loadout = {"weapon_ttt_tf2_flamethrower", "weapon_ttt_tf2_shotgun", "weapon_ttt_tf2_lollichop"}
        },
        {
            name = "demoman",
            roles = {ROLE_REDDEMOMAN, ROLE_BLUDEMOMAN},
            loadout = {"weapon_ttt_tf2_grenadelauncher", "weapon_ttt_tf2_stickybomblauncher", "weapon_ttt_tf2_caber"},
            speed = 0.93
        },
        {
            name = "heavy",
            roles = {ROLE_REDHEAVY, ROLE_BLUHEAVY},
            loadout = {"weapon_ttt_tf2_minigun", "weapon_ttt_tf2_sandvich", "weapon_ttt_tf2_goldenfryingpan"},
            speed = 0.77
        },
        {
            name = "engineer",
            roles = {ROLE_REDENGINEER, ROLE_BLUENGINEER},
            loadout = {"weapon_ttt_tf2_eurekaeffect", "weapon_ttt_tf2_pistol", "weapon_ttt_tf2_shotgun"}
        },
        {
            name = "medic",
            roles = {ROLE_REDMEDIC, ROLE_BLUMEDIC},
            loadout = {"weapon_ttt_tf2_medigun", "weapon_ttt_tf2_syringegun", "weapon_ttt_tf2_bonesaw"},
            speed = 1.07
        },
        {
            name = "sniper",
            roles = {ROLE_REDSNIPER, ROLE_BLUSNIPER},
            loadout = {"weapon_ttt_tf2_sniper", "weapon_ttt_tf2_smg", "weapon_ttt_tf2_machete"}
        },
        {
            name = "spy",
            roles = {ROLE_REDSPY, ROLE_BLUSPY},
            loadout = {"weapon_ttt_tf2_knife", "weapon_ttt_tf2_revolver", "weapon_ttt_tf2_inviswatch"},
            speed = 1.07
        }
    }

    hook.Add("TTTPlayerRoleChanged", "TF2_ClassChangeReset", function(ply, _, newRole)
        for _, class in ipairs(TF2WC.Classes) do
            if newRole == class.roles[1] or newRole == class.roles[2] then
                if SERVER then
                    TF2WC:StripAndGiveLoadout(ply, class.loadout)
                    SetRoleHealth(ply)
                    ply:EmitSound("player/" .. class.name .. "/spawn" .. math.random(5) .. ".wav")
                end

                ply.TF2SpeedMult = class.speed

                return
            end
        end

        ply.TF2SpeedMult = nil
    end)

    hook.Add("TTTSpeedMultiplier", "TF2_ClassSpeedMult", function(ply, mults)
        if ply.TF2SpeedMult then
            table.insert(mults, ply.TF2SpeedMult)
        end
    end)

    -- Gives ammo to a player's gun equivalent to ammo boxes, without going over TTT's reserve ammo limits
    function TF2WC:DirectGiveAmmoBoxes(ply, class, boxNumber)
        local SWEP = weapons.Get(class)
        local ammoEnt = SWEP.AmmoEnt
        local ammoType = SWEP.Primary.Ammo

        if ammoEnt then
            if ammoEnt == "item_ammo_pistol_ttt" then
                ply:SetAmmo(math.min(60, ply:GetAmmoCount(ammoType) + 20 * boxNumber), ammoType)
            elseif ammoEnt == "item_ammo_smg1_ttt" then
                ply:SetAmmo(math.min(60, ply:GetAmmoCount(ammoType) + 30 * boxNumber), ammoType)
            elseif ammoEnt == "item_ammo_revolver_ttt" then
                ply:SetAmmo(math.min(36, ply:GetAmmoCount(ammoType) + 12 * boxNumber), ammoType)
            elseif ammoEnt == "item_ammo_357_ttt" then
                ply:SetAmmo(math.min(20, ply:GetAmmoCount(ammoType) + 10 * boxNumber), ammoType)
            elseif ammoEnt == "item_box_buckshot_ttt" then
                ply:SetAmmo(math.min(24, ply:GetAmmoCount(ammoType) + 8 * boxNumber), ammoType)
            end
        end
    end

    function TF2WC:StripAndGiveLoadout(ply, loadout)
        local stripWepKinds = {}

        for _, class in ipairs(loadout) do
            local SWEP = weapons.Get(class)
            stripWepKinds[SWEP.Kind] = true
        end

        for _, SWEP in ipairs(ply:GetWeapons()) do
            if stripWepKinds[SWEP.Kind] then
                SWEP:Remove()
            end
        end

        timer.Simple(0.1, function()
            for _, class in ipairs(loadout) do
                ply:Give(class)
                self:DirectGiveAmmoBoxes(ply, class, 2)
            end

            ply:SelectWeapon(loadout[1])
        end)
    end
end)
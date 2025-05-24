game.AddParticles("particles/flamethrower.pcf")
game.AddParticles("particles/medicgun_beam.pcf")
game.AddParticles("particles/rockettrail.pcf")
game.AddParticles("particles/stickybomb.pcf")
game.AddParticles("particles/items_demo.pcf")
game.AddParticles("particles/halloween.pcf")
game.AddParticles("particles/item_fx.pcf")
game.AddParticles("particles/flag_particles.pcf")
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
PrecacheParticleSystem("player_intel_papertrail")

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
            loadout = {"weapon_ttt_tf2_sandman", "weapon_ttt_tf2_pistol", "weapon_ttt_tf2_scattergun"},
            speed = 1.33,
            health = 66,
            prompt = "+1 jump, extra speed"
        },
        {
            name = "soldier",
            loadout = {"weapon_ttt_tf2_rpg", "weapon_ttt_tf2_shotgun", "weapon_ttt_tf2_escapeplan"},
            speed = 0.8,
            health = 120,
            prompt = "No fall damage"
        },
        {
            name = "pyro",
            loadout = {"weapon_ttt_tf2_flamethrower", "weapon_ttt_tf2_shotgun", "weapon_ttt_tf2_lollichop"},
            health = 100,
            prompt = "No fire damage"
        },
        {
            name = "demoman",
            loadout = {"weapon_ttt_tf2_grenadelauncher", "weapon_ttt_tf2_stickybomblauncher", "weapon_ttt_tf2_caber"},
            speed = 0.93,
            health = 100,
            prompt = "No explosion damage"
        },
        {
            name = "heavy",
            loadout = {"weapon_ttt_tf2_minigun", "weapon_ttt_tf2_sandvich", "weapon_ttt_tf2_goldenfryingpan"},
            speed = 0.77,
            health = 200,
            prompt = "More health, less speed"
        },
        {
            name = "engineer",
            loadout = {"weapon_ttt_tf2_eurekaeffect", "weapon_ttt_tf2_pistol", "weapon_ttt_tf2_shotgun"},
            health = 66
        },
        {
            name = "medic",
            loadout = {"weapon_ttt_tf2_medigun", "weapon_ttt_tf2_syringegun", "weapon_ttt_tf2_bonesaw"},
            speed = 1.07,
            health = 80,
            prompt = "Passive health regen"
        },
        {
            name = "sniper",
            loadout = {"weapon_ttt_tf2_sniper", "weapon_ttt_tf2_smg", "weapon_ttt_tf2_machete"},
            health = 66,
            prompt = "No rifle charge"
        },
        {
            name = "spy",
            loadout = {"weapon_ttt_tf2_knife", "weapon_ttt_tf2_revolver", "weapon_ttt_tf2_inviswatch"},
            speed = 1.07,
            health = 66
        }
    }

    for _, classFile in ipairs(file.Find("tf2_classes/*.lua", "LUA")) do
        if SERVER then
            AddCSLuaFile("tf2_classes/" .. classFile)
        end

        include("tf2_classes/" .. classFile)
    end

    hook.Add("TTTSpeedMultiplier", "TF2_ClassSpeedMult", function(ply, mults)
        if ply.TF2Class and ply.TF2Class.speed then
            table.insert(mults, ply.TF2Class.speed)
        end
    end)

    local function ShouldDoDeathCam(ply)
        if not IsValid(ply) or ply:Alive() or not ply:IsSpec() then return false end
        if ply.TF2Class then return true end
        if (ply.IsREDMann and ply:IsREDMann()) or (ply.IsBLUMann and ply:IsBLUMann()) then return true end
        if TTT2 and ROLE_REDMANN and ply:IsActive() and (ply:GetSubRole() == ROLE_REDMANN or ply:GetSubRole() == ROLE_BLUMANN) then return true end

        return false
    end

    hook.Add("DoPlayerDeath", "TF2_PlayerDeathFreezeCam", function(ply, attacker, dmg)
        timer.Simple(1, function()
            if not ShouldDoDeathCam(ply) then return end

            if not IsValid(attacker) and IsValid(dmg) then
                attacker = dmg:GetInflictor()
            end

            if attacker == ply then
                attacker = ply.server_ragdoll or ply:GetRagdollEntity()
            end

            if not IsValid(attacker) then return end
            ply:SendLua("surface.PlaySound(\"misc/freeze_cam.wav\")")
            ply:SetObserverMode(OBS_MODE_FREEZECAM)
            ply:SpectateEntity(attacker)
        end)
    end)

    hook.Add("TTTPrepareRound", "TF2_ClassReset", function()
        for _, ply in player.Iterator() do
            TF2WC:SetClass(ply, nil)
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

    function TF2WC:StripAndGiveLoadout(ply, class)
        local stripWepKinds = {}

        for _, classname in ipairs(class.loadout) do
            local SWEP = weapons.Get(classname)
            stripWepKinds[SWEP.Kind] = true
        end

        for _, SWEP in ipairs(ply:GetWeapons()) do
            if stripWepKinds[SWEP.Kind] then
                SWEP:Remove()
            end
        end

        timer.Simple(0.1, function()
            for _, classname in ipairs(class.loadout) do
                ply:Give(classname)
                self:DirectGiveAmmoBoxes(ply, classname, 2)
            end

            ply:SelectWeapon(class.loadout[1])
        end)
    end

    function TF2WC:DoSpawnSound(ply, class)
        if not ply.TF2NoSpawnSound and ply:Alive() and not ply:IsSpec() then
            ply.TF2NoSpawnSound = true
            ply:EmitSound("player/" .. class.name .. "/spawn" .. math.random(5) .. ".wav", 0, 100, 100, CHAN_VOICE)

            timer.Create("TF2EnableSpawnSound", 12, 1, function()
                if IsValid(ply) then
                    ply.TF2NoSpawnSound = nil
                end
            end)
        end
    end

    if SERVER then
        util.AddNetworkString("TF2FullClassUpdate")
    end

    function TF2WC:SetClass(ply, class)
        if isnumber(class) then
            class = TF2WC.Classes[class]
        end

        if class then
            if SERVER then
                TF2WC:StripAndGiveLoadout(ply, class)
                ply:SetHealth(class.health)
                ply:SetMaxHealth(class.health)

                if not CR_VERSION then
                    ply:SetLaggedMovementValue(class.speed or 1)
                end
            else
                TF2WC:DoSpawnSound(ply, class)
            end

            if CLIENT and class.prompt then
                timer.Create("TF2ClassChangeHUDPrompt", 2, 1, function()
                    hook.Add("HUDPaint", "TF2_ClassChangeHUDPrompt", function()
                        if GetRoundState() ~= ROUND_ACTIVE then
                            hook.Remove("HUDPaint", "TF2_ClassChangeHUDPrompt")

                            return
                        end

                        draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, class.prompt, "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
                    end)

                    timer.Create("TF2ClassChangeHUDPromptRemove", 10, 1, function()
                        hook.Remove("HUDPaint", "TF2_ClassChangeHUDPrompt")
                    end)
                end)
            end
        end

        hook.Run("TF2ClassChanged", ply, class, ply.TF2Class)
        ply.TF2Class = class

        if SERVER then
            local classIndex = 0

            if class then
                for index, c in ipairs(TF2WC.Classes) do
                    if c.name == class.name then
                        classIndex = index
                        break
                    end
                end
            end

            net.Start("TF2FullClassUpdate")
            net.WriteUInt(classIndex, 4)
            net.Send(ply)
        end
    end

    if CLIENT then
        net.Receive("TF2FullClassUpdate", function()
            local classIndex = net.ReadUInt(4)
            local client = LocalPlayer()
            if not IsValid(client) then return end
            TF2WC:SetClass(client, TF2WC.Classes[classIndex])
        end)
    end

    function TF2WC:IsClass(ply, className)
        return ply.TF2Class and ply.TF2Class.name == className
    end

    function TF2WC:IsInnocentTeam(ply)
        return ply:GetRole() == ROLE_DETECTIVE or ply:GetRole() == ROLE_INNOCENT or (ply.IsInnocentTeam and ply:IsInnocentTeam()) or (ply.GetTeam and ply:GetTeam() == TEAM_INNOCENT) or (Randomat and Randomat.IsInnocentTeam and Randomat:IsInnocentTeam(ply))
    end

    function TF2WC:IsTraitorTeam(ply)
        return ply:GetRole() == ROLE_TRAITOR or (ply.IsTraitorTeam and ply:IsTraitorTeam() or (ply.GetTeam and ply:GetTeam() == TEAM_TRAITOR)) or (Randomat and Randomat.IsTraitorTeam and Randomat:IsTraitorTeam(ply))
    end

    function TF2WC:GetXHUDOffset()
        if SERVER then return 0 end

        return TTT2 and ScrW() / 5 or 265
    end
end)
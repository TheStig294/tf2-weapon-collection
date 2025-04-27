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

    -- TF2WC.REDRoles = {
    --     [ROLE_REDSCOUT] = true,
    --     [ROLE_REDSOLIDER] = true,
    --     [ROLE_REDPYRO] = true,
    --     [ROLE_REDDEMOMAN] = true,
    --     [ROLE_REDHEAVY] = true,
    --     [ROLE_REDENGINEER] = true,
    --     [ROLE_REDMEDIC] = true,
    --     [ROLE_REDSNIPER] = true,
    --     [ROLE_REDSPY] = true,
    --     [ROLE_REDMANN] = true
    -- }
    -- TF2WC.BLURoles = {
    --     [ROLE_BLUSCOUT] = true,
    --     [ROLE_BLUSOLIDER] = true,
    --     [ROLE_BLUPYRO] = true,
    --     [ROLE_BLUDEMOMAN] = true,
    --     [ROLE_BLUHEAVY] = true,
    --     [ROLE_BLUENGINEER] = true,
    --     [ROLE_BLUMEDIC] = true,
    --     [ROLE_BLUSNIPER] = true,
    --     [ROLE_BLUSPY] = true,
    --     [ROLE_BLUMANN] = true
    -- }
    -- TF2WC.REDRolesList = {ROLE_REDSCOUT, ROLE_REDSOLIDER, ROLE_REDPYRO, ROLE_REDDEMOMAN, ROLE_REDHEAVY, ROLE_REDENGINEER, ROLE_REDMEDIC, ROLE_REDSNIPER, ROLE_REDSPY}
    -- TF2WC.BLURolesList = {ROLE_BLUSCOUT, ROLE_BLUSOLIDER, ROLE_BLUPYRO, ROLE_BLUDEMOMAN, ROLE_BLUHEAVY, ROLE_BLUENGINEER, ROLE_BLUMEDIC, ROLE_BLUSNIPER, ROLE_BLUSPY}
    TF2WC.REDRoles = {
        [ROLE_REDENGINEER] = true,
        [ROLE_REDMANN] = true
    }

    TF2WC.BLURoles = {
        [ROLE_BLUENGINEER] = true,
        [ROLE_BLUMANN] = true
    }

    TF2WC.REDRolesList = {ROLE_REDENGINEER}

    TF2WC.BLURolesList = {ROLE_BLUENGINEER}

    function TF2WC:IsValidTF2Role(ply)
        return IsValid(ply) and (self.REDRoles[ply:GetRole()] or self.BLURoles[ply:GetRole()])
    end

    function TF2WC:StripAndGiveLoadout(ply, loadout)
        local stripWepKinds = {}

        for _, wep in ipairs(loadout) do
            stripWepKinds[wep.Kind] = true
        end

        for _, wep in ipairs(ply:GetWeapons()) do
            if stripWepKinds[wep.Kind] then
                wep:Remove()
            end
        end

        for _, wep in ipairs(loadout) do
            ply:Give(wep)
        end

        ply:SelectWeapon(loadout[1])
    end

    function TF2WC:AddSentryPlacerFunctions(SWEP)
        SWEP.PlaceRange = 128
        SWEP.DamageAmount = 10
        SWEP.PlaceOffset = 10
        SWEP.SentryModel = "models/buildables/sentry1.mdl"

        function SWEP:SecondaryAttack()
            if not self.TTTPAPSentryWrenchSpawned then
                self.TTTPAPSentryWrenchSpawned = true
                self:SpawnSentry()
            end
        end

        function SWEP:SpawnSentry()
            if CLIENT then return end
            local owner = self:GetOwner()
            if not IsValid(owner) then return end
            local tr = owner:GetEyeTrace()
            if not tr.HitWorld then return end

            if tr.HitPos:Distance(owner:GetPos()) > self.PlaceRange then
                owner:PrintMessage(HUD_PRINTCENTER, "Look at the ground to place the sentry")

                return
            end

            local Views = owner:EyeAngles().y
            local sentry = ents.Create("ttt_tf2_sentry")
            sentry:SetOwner(owner)
            sentry:SetPos(tr.HitPos + tr.HitNormal)
            sentry:SetAngles(Angle(0, Views, 0))
            sentry.Damage = self.DamageAmount
            sentry:Spawn()
            sentry:Activate()
            owner:EmitSound("player/engineer/sentry_build" .. math.random(2) .. ".wav")
        end

        function SWEP:RemoveHologram()
            if IsValid(self.Hologram) then
                self.Hologram:Remove()
            end
        end

        -- Draw hologram when placing down the sentry
        function SWEP:DrawHologram()
            if self.TTTPAPSentryWrenchSpawned then
                self:RemoveHologram()

                return
            end

            if not CLIENT then return end
            local owner = self:GetOwner()
            if not IsValid(owner) then return end
            local TraceResult = owner:GetEyeTrace()
            local startPos = TraceResult.StartPos
            local endPos = TraceResult.HitPos
            local dist = math.Distance(startPos.x, startPos.y, endPos.x, endPos.y)

            if dist < self.PlaceRange then
                local hologram

                if IsValid(self.Hologram) then
                    hologram = self.Hologram
                else
                    -- Make the hologram see-through to indicate it isn't placed yet
                    hologram = ClientsideModel(self.SentryModel)
                    hologram:SetColor(Color(200, 200, 200, 200))
                    hologram:SetRenderMode(RENDERMODE_TRANSCOLOR)
                    self.Hologram = hologram
                end

                endPos.z = endPos.z + self.PlaceOffset
                local pitch, yaw, roll = owner:EyeAngles():Unpack()
                pitch = 0
                hologram:SetPos(endPos)
                hologram:SetAngles(Angle(pitch, yaw, roll))
                hologram:DrawModel()
            else
                self:RemoveHologram()
            end
        end

        self:AddToHook(SWEP, "Think", function()
            SWEP:DrawHologram()
        end)

        function SWEP:Holster()
            SWEP:RemoveHologram()

            return true
        end

        function SWEP:OwnerChanged()
            SWEP:RemoveHologram()
        end

        function SWEP:OnRemove()
            SWEP:RemoveHologram()
        end

        if CLIENT then
            function SWEP:DrawHUD()
                if self.TTTPAPSentryWrenchSpawned then return end
                draw.WordBox(8, 265, ScrH() - 50, "Right-click to place sentry", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
            end
        end
    end
end)
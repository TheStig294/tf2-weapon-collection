SWEP.PrintName = "Lollichop"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Sends you to Pyroland..."
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_pyro_arms.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_fireaxe.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A slow but hard-hitting melee weapon...\n\nthat sends you to Pyroland!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_fireaxe.png"
end

SWEP.Primary.Sound = Sound("Weapon_FireAxe.Miss")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 50
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128

SWEP.Primary.Anims = {"fa_swing_a", "fa_swing_b", "fa_swing_c"}

SWEP.PitchMultiplier = 1.5
SWEP.HooksSet = false

function SWEP:SetHooks()
    if self.HooksSet then return end

    if SERVER then
        util.AddNetworkString("TF2LollichopConfetti")
    else
        -- Credit to Nick and Mal for making this function as part of the Custom Roles Jester confetti effect
        local confettiMat = Material("confetti.png")
        local balloonMat = Material("effects/balloon001")

        local balloonColours = {Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255), Color(255, 255, 0), Color(255, 0, 255), Color(0, 255, 255)}

        local confettiCount = 10
        local balloonCount = 3

        -- Confetti and laughter effect on damaging a player
        net.Receive("TF2LollichopConfetti", function()
            local ent = net.ReadEntity()
            if not IsValid(ent) then return end
            ent:EmitSound("player/pyro/laugh" .. math.random(9) .. ".mp3")
            local pos = ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z)

            if ent.GetShootPos then
                pos = ent:GetShootPos()
            end

            local velMax = 200
            local gravMax = 50
            local gravity = Vector(math.random(-gravMax, gravMax), math.random(-gravMax, gravMax), math.random(-gravMax, 0))
            -- Handles particles
            local emitter = ParticleEmitter(pos, true)

            for _ = 1, confettiCount do
                local p = emitter:Add(confettiMat, pos)
                p:SetStartSize(math.random(6, 10))
                p:SetEndSize(0)
                p:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                p:SetAngleVelocity(Angle(math.random(5, 50), math.random(5, 50), math.random(5, 50)))
                p:SetVelocity(Vector(math.random(-velMax, velMax), math.random(-velMax, velMax), math.random(-velMax, velMax)))
                p:SetColor(255, 255, 255)
                p:SetDieTime(math.random(4, 7))
                p:SetGravity(gravity)
                p:SetAirResistance(125)
                p.TF2LollichopParticle = true
            end

            gravity = -gravity

            for _ = 1, balloonCount do
                local p = emitter:Add(balloonMat, pos)
                p:SetStartSize(math.random(16, 20))
                p:SetEndSize(0)
                p:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                p:SetAngleVelocity(Angle(math.random(5, 50), math.random(5, 50), math.random(5, 50)))
                p:SetVelocity(Vector(math.random(-velMax, velMax), math.random(-velMax, velMax), math.random(-velMax, velMax)))
                local randomColour = balloonColours[math.random(#balloonColours)]
                p:SetColor(randomColour.r, randomColour.g, randomColour.b)
                p:SetDieTime(math.random(4, 7))
                p:SetGravity(gravity)
                p:SetAirResistance(125)
                p.TF2LollichopParticle = true
            end

            emitter:Finish()
        end)

        local client = LocalPlayer()

        -- Make all sounds higher pitched!
        hook.Add("EntityEmitSound", "TF2LollichopHighPitch", function(SoundData)
            if not client or not client.TF2LollichopEffects then return end
            SoundData.Pitch = SoundData.Pitch * self.PitchMultiplier

            return true
        end)

        -- Increases colour saturation
        local colourParameters = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1.5,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        hook.Add("RenderScreenspaceEffects", "TF2LollichopHighSaturation", function()
            if not client or not client.TF2LollichopEffects then return end
            DrawColorModify(colourParameters)
        end)

        hook.Add("TTTPrepareRound", "TF2LollichopReset", function()
            for _, ply in player.Iterator() do
                ply.TF2LollichopEffects = nil
            end

            hook.Remove("EntityEmitSound", "TF2LollichopHighPitch")
            hook.Remove("RenderScreenspaceEffects", "TF2LollichopHighSaturation")
            hook.Remove("TTTPrepareRound", "TF2LollichopReset")
        end)
    end

    self.HooksSet = true
end

function SWEP:Initialize()
    -- SWEP:Deploy() isn't called if the player spawns on and picks up this weapon, and they haven't been given the crowbar yet
    -- So we have to check for that case here
    timer.Simple(1, function()
        if not IsValid(self) then return end
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        owner.TF2LollichopEffects = true
        self:SetHooks()
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    self:SetHooks()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("fa_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
    owner.TF2LollichopEffects = true

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:EmitSound(self.Primary.Sound)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence(self.Primary.Anims[math.random(#self.Primary.Anims)]))
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.Attack = 1
    self.AttackTimer = CurTime() + 0.2
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:Holster()
    for _, ent in ents.Iterator() do
        if ent.TF2LollichopParticle then
            ent:SetDieTime(0.1)
            ent:Remove()
        end
    end

    local owner = self:GetOwner()

    if IsValid(owner) then
        owner.TF2LollichopEffects = false
    end

    return self.BaseClass.Holster(self)
end

function SWEP:PreDrop()
    self:Holster()

    return self.BaseClass.PreDrop(self)
end

function SWEP:OnRemove()
    self:Holster()

    return self.BaseClass.OnRemove(self)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Attack == 1 and self.AttackTimer <= CurTime() then
        local tr = util.TraceLine({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
            filter = owner,
            mask = MASK_SHOT_HULL,
        })

        local victim = tr.Entity

        if not IsValid(victim) then
            tr = util.TraceHull({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
                filter = owner,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 0),
                mask = MASK_SHOT_HULL,
            })
        end

        if SERVER and IsValid(victim) then
            local dmg = DamageInfo()
            local attacker = owner

            if not IsValid(attacker) then
                attacker = self
            end

            dmg:SetAttacker(attacker)
            dmg:SetInflictor(self)
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
            dmg:SetDamageType(DMG_CLUB)

            if victim:IsPlayer() and victim:Alive() and not victim:IsSpec() then
                owner:EmitSound("Weapon_FireAxe.HitFlesh")
                net.Start("TF2LollichopConfetti")
                net.WriteEntity(victim)
                net.Send(owner)
            end

            victim:TakeDamageInfo(dmg)
        end

        self.Attack = 0
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("fa_idle"))
        end

        self.Idle = 1
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_lollichop/c_lollichop.mdl", RENDERGROUP_VIEWMODEL)
        end

        self.v_model:SetPos(vm:GetPos())
        self.v_model:SetAngles(vm:GetAngles())
        self.v_model:AddEffects(EF_BONEMERGE)
        self.v_model:SetNoDraw(true)
        self.v_model:SetParent(vm)
        self.v_model:DrawModel()
    end

    local borderMat = Material("rj/pyro_pink_border01")
    local frequency = 0.25

    function SWEP:DrawHUDBackground()
        surface.SetMaterial(borderMat)
        surface.SetAlphaMultiplier(TimedCos(frequency, 0.5, 1.5, 0))
        surface.SetDrawColor(255, 209, 255)
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW(), ScrH(), 0)
        surface.SetAlphaMultiplier(TimedCos(frequency, 0.5, 1.5, 10))
        surface.SetDrawColor(255, 209, 255)
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH(), ScrW(), 90)
        surface.SetAlphaMultiplier(TimedCos(frequency, 0.5, 1.5, 20))
        surface.SetDrawColor(255, 209, 255)
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW(), ScrH(), 180)
        surface.SetAlphaMultiplier(TimedCos(frequency, 0.5, 1.5, 30))
        surface.SetDrawColor(255, 209, 255)
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH(), ScrW(), 270)
        surface.SetAlphaMultiplier(TimedCos(frequency, 0.5, 1.5, 40))
        surface.SetDrawColor(255, 209, 255)
        surface.DrawTexturedRectRotated((ScrW() + 500) / 2, (ScrH() + 500) / 2, ScrW() + 500, ScrH() + 500, 0)
        surface.SetAlphaMultiplier(TimedCos(frequency, 0.5, 1.5, 50))
        surface.SetDrawColor(255, 209, 255)
        surface.DrawTexturedRectRotated((ScrW() - 500) / 2, (ScrH() - 500) / 2, ScrW() + 500, ScrH() + 500, 180)
        surface.SetAlphaMultiplier(1)
    end
end
SWEP.PrintName = "Rainblower"
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
SWEP.WorldModel = "models/weapons/w_models/w_flamethrower.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "crossbow"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = false

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A wonderful rainbow shooting flamethrower\n\nthat sends you to Pyroland!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_flamethrower.png"
end

SWEP.DoLoopingSound = false
SWEP.SoundTimer = 0
SWEP.IsAttacking = false
SWEP.IsAttackingTimer = 0
SWEP.ReloadingTimer = 0
SWEP.Idle = true
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("weapons/rainblower/rainblower_start.wav")
SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Damage = 3.5
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Delay = 0.08
SWEP.Primary.Force = 100
SWEP.Primary.AmmoLossRate = 0.1
SWEP.Primary.Range = 196
SWEP.Secondary.Sound = Sound("weapons/flame_thrower_airblast.wav")
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.TakeAmmo = 20
SWEP.Secondary.Delay = 0.75
SWEP.Secondary.Force = 2500
SWEP.PitchMultiplier = 1.5
SWEP.HooksSet = false

function SWEP:SetHooks()
    if self.HooksSet then return end

    if SERVER then
        util.AddNetworkString("TF2RainblowerConfetti")
    else
        -- Credit to Nick and Mal for making this function as part of the Custom Roles Jester confetti effect
        local confettiMat = Material("confetti.png")
        local sparkleMat = Material("effects/tp_sparkle2")

        local sparkleColours = {Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255), Color(255, 255, 0), Color(255, 0, 255), Color(0, 255, 255)}

        local confettiCount = 1
        local sparkleCount = 3

        -- Confetti and laughter effect on damaging a player
        net.Receive("TF2RainblowerConfetti", function()
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
                p.TF2RainblowerParticle = true
            end

            for _ = 1, sparkleCount do
                local p = emitter:Add(sparkleMat, pos)
                p:SetStartSize(math.random(8, 10))
                p:SetEndSize(0)
                p:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                p:SetAngleVelocity(Angle(math.random(5, 50), math.random(5, 50), math.random(5, 50)))
                p:SetVelocity(Vector(math.random(-velMax, velMax), math.random(-velMax, velMax), math.random(-velMax, velMax)))
                local randomColour = sparkleColours[math.random(#sparkleColours)]
                p:SetColor(randomColour.r, randomColour.g, randomColour.b)
                p:SetDieTime(math.random(4, 7))
                p:SetGravity(gravity)
                p:SetAirResistance(125)
                p.TF2RainblowerParticle = true
            end

            emitter:Finish()
        end)

        local client = LocalPlayer()

        -- Make all sounds higher pitched!
        hook.Add("EntityEmitSound", "TF2RainblowerHighPitch", function(SoundData)
            if not client or not client.TF2RainblowerEffects or SoundData.SoundName:StartsWith("weapons/rainblower/") then return end
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

        hook.Add("RenderScreenspaceEffects", "TF2RainblowerHighSaturation", function()
            if not client or not client.TF2RainblowerEffects then return end
            DrawColorModify(colourParameters)
        end)

        hook.Add("TTTPrepareRound", "TF2RainblowerReset", function()
            for _, ply in player.Iterator() do
                ply.TF2RainblowerEffects = nil
            end

            hook.Remove("EntityEmitSound", "TF2RainblowerHighPitch")
            hook.Remove("RenderScreenspaceEffects", "TF2RainblowerHighSaturation")
            hook.Remove("TTTPrepareRound", "TF2RainblowerReset")
        end)
    end

    self.HooksSet = true
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextIdle")
end

function SWEP:UpdateNextIdle()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

function SWEP:Initialize()
    local owner = self:GetOwner()

    if IsValid(owner) then
        owner.TF2RainblowerEffects = true
        self:SetHooks()
    end

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    self:SetHooks()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("ft_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
    owner.TF2RainblowerEffects = true

    if self:Clip1() > 0 then
        self:EmitSound("weapons/rainblower/rainblower_pilot.wav")
    end

    self:UpdateNextIdle()

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    if self.IsAttacking or not self:CanPrimaryAttack() then return end
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not self.FiresUnderwater and owner:WaterLevel() == 3 then return end

    if not self.IsAttacking then
        if SERVER then
            local flame = ents.Create("info_particle_system")
            flame:SetKeyValue("effect_name", "flamethrower_rainbow")
            flame:SetOwner(owner)
            local Forward = owner:EyeAngles():Forward()
            local Right = owner:EyeAngles():Right()
            local Up = owner:EyeAngles():Up()
            flame:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
            flame:SetAngles(owner:EyeAngles())
            flame:Spawn()
            flame:Activate()
            flame:Fire("start", "", 0)
            self.Flame = flame
        end

        self:EmitSound(self.Primary.Sound)
        local vm = owner:GetViewModel()
        if not IsValid(vm) then return end
        vm:SendViewModelMatchingSequence(vm:LookupSequence("ft_fire"))
        owner:SetAnimation(PLAYER_ATTACK1)
        self.DoLoopingSound = true
        self.SoundTimer = CurTime() + 1
    end

    self.IsAttacking = true
    self.Idle = false
    self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
end

function SWEP:SecondaryAttack()
    if self.IsAttacking then return end
    if self:Clip1() < 20 then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not self.FiresUnderwater and owner:WaterLevel() == 3 then return end

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 128,
        filter = owner,
        mask = MASK_SHOT_HULL,
    })

    local ent = tr.Entity

    if not IsValid(ent) then
        tr = util.TraceHull({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * 128,
            filter = owner,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 0),
            mask = MASK_SHOT_HULL,
        })
    end

    if SERVER then
        if IsValid(ent) then
            ent:SetVelocity(owner:GetAimVector() * Vector(self.Secondary.Force, self.Secondary.Force, 0) + Vector(0, 0, 200))
        end

        local blast = ents.Create("info_particle_system")
        blast:SetKeyValue("effect_name", "pyro_blast")
        blast:SetOwner(owner)
        local Forward = owner:EyeAngles():Forward()
        local Right = owner:EyeAngles():Right()
        local Up = owner:EyeAngles():Up()
        blast:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
        blast:SetAngles(owner:EyeAngles())
        blast:Spawn()
        blast:Activate()
        blast:Fire("start", "", 0)
    end

    if SERVER and IsValid(ent) then
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:ApplyForceOffset(owner:GetAimVector() * 16000, tr.HitPos)
        end
    end

    self:EmitSound(self.Secondary.Sound)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("ft_alt_fire"))
    owner:SetAnimation(PLAYER_ATTACK1)
    self:TakePrimaryAmmo(self.Secondary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    self.Idle = false
    self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
end

function SWEP:Holster()
    for _, ent in ents.Iterator() do
        if ent.TF2RainblowerParticle then
            ent:SetDieTime(0.1)
            ent:Remove()
        end
    end

    local owner = self:GetOwner()

    if IsValid(owner) then
        owner.TF2RainblowerEffects = false
    end

    self:StopSound("weapons/rainblower/rainblower_pilot.wav")

    return self.BaseClass.Holster(self)
end

function SWEP:PreDrop()
    self:Holster()

    return self.BaseClass.PreDrop(self)
end

function SWEP:OnRemove()
    self:Holster()

    if SERVER and IsValid(self.Flame) then
        self.Flame:Remove()
    end

    return self.BaseClass.OnRemove(self)
end

function SWEP:RemoveFlame()
    self:StopSound(self.Primary.Sound)
    self:StopSound("weapons/rainblower/rainblower_loop.wav")

    if SERVER and IsValid(self.Flame) then
        self.Flame:Remove()
    end

    self.DoLoopingSound = false
    self.IsAttacking = false
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self.DoLoopingSound and self.SoundTimer <= CurTime() then
        self:EmitSound("weapons/rainblower/rainblower_loop.wav")
        self.DoLoopingSound = false
    end

    if SERVER and self.IsAttacking then
        local Forward = owner:EyeAngles():Forward()
        local Right = owner:EyeAngles():Right()
        local Up = owner:EyeAngles():Up()
        self.Flame:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
        self.Flame:SetAngles(owner:EyeAngles())
    end

    if self.IsAttacking and (not owner:KeyDown(IN_ATTACK) or self:Clip1() <= 0 or owner:WaterLevel() == 3) then
        self:RemoveFlame()
    end

    if self.IsAttacking and self.IsAttackingTimer <= CurTime() then
        local tr = util.TraceLine({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
            filter = owner,
            mask = MASK_SHOT_HULL,
        })

        local ent = tr.Entity

        if not IsValid(ent) then
            tr = util.TraceHull({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
                filter = owner,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 0),
                mask = MASK_SHOT_HULL,
            })
        end

        if SERVER and IsValid(ent) and not (IsValid(ent) and ent:IsPlayer() and (not ent:Alive() or ent:IsSpec())) then
            local dmg = DamageInfo()
            local attacker = owner

            if not IsValid(attacker) then
                attacker = self
            end

            dmg:SetAttacker(attacker)
            dmg:SetInflictor(self)
            dmg:SetDamage(self.Primary.Damage)
            dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
            dmg:SetDamageType(DMG_BURN)
            ent:TakeDamageInfo(dmg)
            ent:Ignite(10)
            net.Start("TF2RainblowerConfetti")
            net.WriteEntity(ent)
            net.Send(owner)

            timer.Simple(0.1, function()
                if IsValid(ent) and ent:IsPlayer() and (not ent:Alive() or ent:IsSpec()) then
                    ent:Extinguish()
                end
            end)
        end

        self:TakePrimaryAmmo(1)
        self.IsAttackingTimer = CurTime() + 0.04
    end

    if not self.Idle and self.IdleTimer <= CurTime() then
        if SERVER then
            local vm = owner:GetViewModel()
            if not IsValid(vm) then return end
            vm:SendViewModelMatchingSequence(vm:LookupSequence("ft_idle"))
        end

        self.Idle = true
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_rainblower/c_rainblower.mdl", RENDERGROUP_VIEWMODEL)
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
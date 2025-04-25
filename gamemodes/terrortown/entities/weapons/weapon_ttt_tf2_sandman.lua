SWEP.PrintName = "Sandman"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Alt-Fire: Launches a ball"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_scout_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_wooden_bat/c_wooden_bat.mdl"
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
        desc = "A fast-hitting melee weapon!\nHigher DPS than the crowbar!\n\nRight-click to launch a slowing baseball!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_sandman.png"
end

SWEP.Primary.Sound = Sound("Weapon_Bat.Miss")
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.5
SWEP.Primary.Force = 2
SWEP.Primary.Range = 64
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 10
SWEP.Secondary.Damage = 25
SWEP.BallTimer = 0
SWEP.SlowMultiplier = 0.33
SWEP.SlowDuration = 7

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)

    hook.Add("DoPlayerDeath", "TF2SandmanBonkKillSound", function(_, attacker, dmg)
        if not IsValid(attacker) then return end
        local inflictor = dmg:GetInflictor()

        if IsValid(inflictor) and (inflictor:GetClass() == "weapon_ttt_tf2_sandman" or inflictor.TF2SandmanBall) then
            attacker:EmitSound("player/scout/bonk1.wav")
        end
    end)

    hook.Add("EntityTakeDamage", "TF2SandmanBallDamage", function(victim, dmg)
        local inflictor = dmg:GetInflictor()

        if IsValid(inflictor) and inflictor.TF2SandmanBall and IsValid(self) then
            inflictor.TF2SandmanBall = nil
            inflictor:EmitSound("Weapon_Baseball.HitWorld")
            inflictor:EmitSound("player/scout/bonk2.wav")
            local attacker = inflictor.Owner

            if not IsValid(attacker) then
                attacker = inflictor
            end

            local weapon = inflictor.Weapon

            if not IsValid(weapon) then
                weapon = inflictor
            end

            local newDmg = DamageInfo()
            newDmg:SetDamage(self.Secondary.Damage)
            newDmg:SetAttacker(attacker)
            newDmg:SetInflictor(weapon)
            newDmg:SetDamageType(DMG_CLUB)
            victim:TakeDamageInfo(newDmg)

            if IsValid(victim) and victim:IsPlayer() and victim:Alive() and not victim:IsSpec() then
                local slowMult = self.SlowMultiplier
                victim:SetLaggedMovementValue(victim:GetLaggedMovementValue() * (1 - slowMult))

                timer.Simple(self.SlowDuration, function()
                    if IsValid(victim) then
                        victim:SetLaggedMovementValue(victim:GetLaggedMovementValue() * (1 + slowMult))
                    end
                end)
            end

            return true
        end
    end)

    hook.Add("TTTPrepareRound", "TF2SandmanReset", function()
        hook.Remove("DoPlayerDeath", "TF2SandmanBonkKillSound")
        hook.Remove("EntityTakeDamage", "TF2SandmanBallDamage")
        hook.Remove("TTTPrepareRound", "TF2SandmanReset")
    end)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:Clip1() < 1 then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("wb_fire"))
    else
        vm:SendViewModelMatchingSequence(vm:LookupSequence("wb_draw"))
    end

    self:SetWeaponHoldType(self.HoldType)
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()

    return true
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:EmitSound(self.Primary.Sound)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:Clip1() < 1 then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("wb_fire"))
    else
        vm:SendViewModelMatchingSequence(vm:LookupSequence("wb_swing_a"))
    end

    owner:SetAnimation(PLAYER_ATTACK1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.Attack = 1
    self.AttackTimer = CurTime() + 0.2
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:SecondaryAttack()
    if self:Clip1() < 1 then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    owner:SetAnimation(PLAYER_ATTACK1)
    vm:SetSequence(vm:LookupSequence("wb_fire"))
    vm:SetPlaybackRate(1.0) -- Fix for the stupid sped up weapons thing
    self:EmitSound("Weapon_BaseballBat.HitBall")

    if SERVER then
        self.Baseball = ents.Create("prop_physics")
        if not IsValid(self.Baseball) then return end
        self.Baseball.TF2SandmanBall = true
        self.Baseball:SetModel("models/weapons/w_models/w_baseball.mdl")
        self.Baseball:SetPos(owner:EyePos() + (owner:GetAimVector() * 24))
        self.Baseball:SetAngles(owner:EyeAngles())
        self.Baseball:Spawn()
        self.Baseball.Owner = owner
        self.Baseball.Weapon = self

        timer.Simple(self.Secondary.Delay, function()
            if IsValid(self.Baseball) then
                self.Baseball:Remove()
            end
        end)

        local phys = self.Baseball:GetPhysicsObject()

        if not IsValid(phys) then
            self.Baseball:Remove()

            return
        end

        local velocity = owner:GetAimVector()
        velocity = velocity * 10000
        velocity = velocity + (VectorRand() * 10) -- a random element
        phys:ApplyForceCenter(velocity)
    end

    self:TakePrimaryAmmo(1)
    self.BallTimer = CurTime() + self.Secondary.Delay
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

        if not IsValid(tr.Entity) then
            tr = util.TraceHull({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
                filter = owner,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 0),
                mask = MASK_SHOT_HULL,
            })
        end

        if SERVER and IsValid(tr.Entity) then
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
            tr.Entity:TakeDamageInfo(dmg)
        end

        if SERVER and tr.Hit then
            if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
                owner:EmitSound("Weapon_BaseballBat.HitFlesh")
            end

            if not (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
                owner:EmitSound("Weapon_BaseballBat.HitWorld")
            end
        end

        self.Attack = 0
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() and self:Clip1() > 0 then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("wb_idle"))
        end

        self.Idle = 1
    end

    if self:Clip1() < 1 and self.BallTimer <= CurTime() then
        self:SetClip1(1)

        if SERVER then
            owner:EmitSound("player/scout/ball" .. math.random(5) .. ".wav")
        end

        vm:SetSequence(vm:LookupSequence("wb_grab"))
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel(self.WorldModel, RENDERGROUP_VIEWMODEL)
        end

        self.v_model:SetPos(vm:GetPos())
        self.v_model:SetAngles(vm:GetAngles())
        self.v_model:AddEffects(EF_BONEMERGE)
        self.v_model:SetNoDraw(true)
        self.v_model:SetParent(vm)
        self.v_model:DrawModel()

        if not IsValid(self.v_baseball) then
            self.v_baseball = ClientsideModel("models/weapons/v_models/v_baseball.mdl", RENDERGROUP_VIEWMODEL)
        end

        self.v_baseball:SetPos(vm:GetPos())
        self.v_baseball:SetAngles(vm:GetAngles())
        self.v_baseball:AddEffects(EF_BONEMERGE)
        self.v_baseball:SetNoDraw(true)
        self.v_baseball:SetParent(vm)
        self.v_baseball:DrawModel()
    end

    local w_model = ClientsideModel(SWEP.WorldModel)
    w_model:SetNoDraw(true)
    local offsetvec = Vector(2.596, 0, 0)
    local offsetang = Angle(180, 90, 0)

    function SWEP:DrawWorldModel(flags)
        local owner = self:GetOwner()

        if not IsValid(owner) then
            self:DrawModel(flags)

            return
        end

        local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneid then return end
        local matrix = owner:GetBoneMatrix(boneid)
        if not matrix then return end
        local newpos, newang = LocalToWorld(offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles())

        if not IsValid(self.w_model) then
            self.w_model = w_model
        end

        self.w_model:SetPos(newpos)
        self.w_model:SetAngles(newang)
        self.w_model:SetupBones()
        self.w_model:DrawModel()
    end
end
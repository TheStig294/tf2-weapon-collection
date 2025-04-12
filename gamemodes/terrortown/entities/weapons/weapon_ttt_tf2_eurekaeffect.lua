SWEP.PrintName = "Eureka Effect"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_engineer_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_drg_wrenchmotron/c_drg_wrenchmotron.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Higher DPS than the crowbar!\n\nPress Reload for a 1-time teleport to a spawn point!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_eurekaeffect.png"
end

SWEP.Primary.Sound = Sound("Weapon_Wrench.Miss")
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 48
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128

SWEP.Primary.Anims = {"spk_swing_a", "spk_swing_b", "spk_swing_c"}

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("spk_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()

    return self.BaseClass.Deploy(self)
end

function SWEP:Teleport()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self:Clip1() <= 0 then return end
    self:TakePrimaryAmmo(1)
    owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_TAUNT_CHEER, true)

    if SERVER then
        owner:EmitSound("weapons/drg_wrench_teleport.wav")
    end

    self.IsTeleporting = true
    local thirdPersonHookName = "TF2EurekaEffectThirdPerson" .. self:EntIndex()

    hook.Add("CalcView", thirdPersonHookName, function(_, pos, angles, fov, znear, zfar)
        if not IsValid(self) or not self.IsTeleporting then return end

        local view = {
            origin = pos - (angles:Forward() * 100),
            angles = angles,
            fov = fov,
            drawviewer = true,
            znear = znear,
            zfar = zfar
        }

        return view
    end)

    timer.Simple(1.9, function()
        if not IsValid(self) or not IsValid(owner) then return end
        owner:ScreenFade(SCREENFADE.OUT, COLOR_WHITE, 0.25, 0.125)
    end)

    timer.Simple(2, function()
        hook.Remove(thirdPersonHookName)
        if not IsValid(self) then return end
        self.IsTeleporting = false
        if not IsValid(owner) then return end
        owner:ScreenFade(SCREENFADE.PURGE, COLOR_WHITE, 0, 0)
        owner:ScreenFade(SCREENFADE.IN, COLOR_WHITE, 0.25, 0.125)

        for _, ent in ents.Iterator() do
            if IsValid(ent) and ent:GetClass() == "info_player_start" then
                owner:SetPos(ent:GetPos())

                return
            end
        end
    end)
end

function SWEP:SecondaryAttack()
    if not self.HasTeleported then
        self.HasTeleported = true
        self:Teleport()
    end
end

function SWEP:PrimaryAttack()
    if self.IsTeleporting then return end
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
    self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
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
                owner:EmitSound("Weapon_Wrench.HitFlesh")
            elseif not victim:IsPlayer() then
                owner:EmitSound("Weapon_Wrench.HitWorld")
            end

            victim:TakeDamageInfo(dmg)
        end

        self.Attack = 0
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("spk_idle_tap"))
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
            self.v_model = ClientsideModel("models/weapons/c_models/c_drg_wrenchmotron/c_drg_wrenchmotron.mdl", RENDERGROUP_VIEWMODEL)
        end

        self.v_model:SetPos(vm:GetPos())
        self.v_model:SetAngles(vm:GetAngles())
        self.v_model:AddEffects(EF_BONEMERGE)
        self.v_model:SetNoDraw(true)
        self.v_model:SetParent(vm)
        self.v_model:DrawModel()
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
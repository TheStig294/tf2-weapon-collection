SWEP.PrintName = "Tomislav"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/c_models/c_heavy_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_tomislav/c_tomislav.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 3
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = false
SWEP.IsSilent = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A 200 ammo minigun!\nAmmo cannot be refilled, completely silent and accurate"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_minigun.png"
end

SWEP.Sound = 0
SWEP.Spin = 0
SWEP.SpinTimer = 0
SWEP.Idle = 0
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("weapons/tomislav_shoot.wav")
SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Damage = 12
SWEP.Primary.Spread = 0
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self.Idle = 0
    self.IdleTimer = CurTime() + 1

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("m_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Sound = 0
    self.Spin = 0
    self.SpinTimer = CurTime() + 0.5
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()

    return self.BaseClass.Deploy(self)
end

function SWEP:Holster()
    self.Sound = 0
    self.Spin = 0
    self.SpinTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then
        owner:StopSound(self.Primary.Sound)
        owner:StopSound("weapons/tomislav_wind_up.wav")
        owner:SetLaggedMovementValue(1)
    end

    return self.BaseClass.Holster(self)
end

function SWEP:PreDrop()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then
        owner:SetLaggedMovementValue(1)
    end

    return self.BaseClass.PreDrop(self)
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:Holster()

    return self.BaseClass.PreDrop(self)
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Spin == 0 and self.SpinTimer <= CurTime() and owner:KeyDown(IN_ATTACK) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/tomislav_wind_up.wav")
        end

        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_up"))
        self.Spin = 1
        self.SpinTimer = CurTime() + 0.9
        self.Idle = 0
        self.IdleTimer = CurTime() + vm:SequenceDuration()
    end

    if self.Spin ~= 2 then return end
    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(1 * self.Primary.Spread, 1 * self.Primary.Spread, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    bullet.Inflictor = self
    owner:FireBullets(bullet)

    if self.Sound == 0 then
        if SERVER then
            owner:EmitSound(self.Primary.Sound)
        end

        self.Sound = 1
    end

    vm:SendViewModelMatchingSequence(vm:LookupSequence("m_fire"))
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:MuzzleFlash()
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.Idle = 1
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if owner:KeyDown(IN_ATTACK) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Spin == 0 and self.SpinTimer <= CurTime() and owner:KeyDown(IN_ATTACK2) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/tomislav_wind_up.wav")
        end

        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_up"))
        self.Spin = 1
        self.SpinTimer = CurTime() + 0.9
        self.Idle = 0
        self.IdleTimer = CurTime() + vm:SequenceDuration()
    end

    if self.Spin == 2 then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_idle"))
        self.Idle = 1
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:Think()
    self.Primary.Automatic = self:Clip1() > 0
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Spin == 1 and self.SpinTimer <= CurTime() then
        self.Spin = 2
    end

    if SERVER then
        if self.Spin == 1 then
            owner:SetLaggedMovementValue(0.75)
        elseif self.Spin == 2 then
            owner:SetLaggedMovementValue(0.5)
        else
            owner:SetLaggedMovementValue(1)
        end
    end

    if not owner:KeyDown(IN_ATTACK) then
        if SERVER then
            owner:StopSound(self.Primary.Sound)
            owner:StopSound("Weapon_Minigun.ClipEmpty")
        end

        self.Sound = 0
    end

    if self.Spin == 2 and ((not owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ATTACK2)) or self:Clip1() <= 0) then
        if SERVER then
            owner:StopSound(self.Primary.Sound)
            owner:EmitSound("weapons/tomislav_wind_down.wav")
        end

        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_down"))
        self.Sound = 0
        self.Spin = 0
        self.SpinTimer = CurTime() + 0.9
        self.Idle = 0
        self.IdleTimer = CurTime() + vm:SequenceDuration()
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            if self.Spin == 0 then
                vm:SendViewModelMatchingSequence(vm:LookupSequence("m_idle"))
            else
                vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_idle"))
            end
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
            self.v_model = ClientsideModel("models/weapons/c_models/c_tomislav/c_tomislav.mdl", RENDERGROUP_VIEWMODEL)
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
    local offsetang = Angle(180, 180, 0)

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
SWEP.PrintName = "Heavy Minigun"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_minigun_heavy.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_minigun.mdl"
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
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A 200 ammo minigun!\nAmmo cannot be refilled"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_minigun.png"
end

SWEP.Sound = 0
SWEP.Spin = 0
SWEP.SpinTimer = 0
SWEP.Idle = 0
SWEP.IdleTimer = 0
SWEP.SpinSpeed = 0
SWEP.SpinAcceleration = 0.5
SWEP.MaxSpinSpeed = 20
SWEP.SpinAngle = Angle(0, 0, 0)
SWEP.Primary.Sound = Sound("weapons/minigun_shoot.wav")
SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Damage = 2.5
SWEP.Primary.Spread = 0.03
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 4
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 1
SWEP.Secondary.Sound = Sound("weapons/minigun_spin.wav")
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
        owner:StopSound(self.Secondary.Sound)
        owner:StopSound("weapons/minigun_wind_up.wav")
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

    return self.BaseClass.OnRemove(self)
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Spin == 0 and self.SpinTimer <= CurTime() and owner:KeyDown(IN_ATTACK) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/minigun_wind_up.wav")
        end

        self:SendWeaponAnim(ACT_DEPLOY)
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

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
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
            owner:EmitSound("weapons/minigun_wind_up.wav")
        end

        self:SendWeaponAnim(ACT_DEPLOY)
        self.Spin = 1
        self.SpinTimer = CurTime() + 0.9
        self.Idle = 0
        self.IdleTimer = CurTime() + vm:SequenceDuration()
    end

    if self.Spin == 2 then
        if SERVER and self.Idle ~= 1 then
            owner:StopSound(self.Secondary.Sound)
            owner:EmitSound(self.Secondary.Sound)
        end

        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
        self.Idle = 1
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:Reload()
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
            owner:StopSound(self.Secondary.Sound)
            owner:EmitSound("weapons/minigun_wind_down.wav")
        end

        self:SendWeaponAnim(ACT_UNDEPLOY)
        self.Sound = 0
        self.Spin = 0
        self.SpinTimer = CurTime() + 0.9
        self.Idle = 0
        self.IdleTimer = CurTime() + vm:SequenceDuration()
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            if self.Spin == 0 then
                self:SendWeaponAnim(ACT_VM_IDLE)
            else
                self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
            end
        end

        self.Idle = 1
    end

    if CLIENT then
        if self.Spin == 0 then
            self.SpinSpeed = math.max(0, self.SpinSpeed - self.SpinAcceleration)
        else
            self.SpinSpeed = math.min(self.MaxSpinSpeed, self.SpinSpeed + self.SpinAcceleration)
        end

        self.SpinAngle.z = (self.SpinAngle.z + self.SpinSpeed) % 360

        if self.SpinSpeed > 0 then
            vm:ManipulateBoneAngles(2, self.SpinAngle)
        end
    end
end
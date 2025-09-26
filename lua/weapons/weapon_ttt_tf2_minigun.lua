SWEP.PrintName = "Heavy Minigun"
SWEP.Author = ""
SWEP.Contact = ""
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
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A 200 ammo minigun!\nAmmo cannot be refilled"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_minigun.png"
    SWEP.Instructions = SWEP.EquipMenuData.desc
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
SWEP.Primary.ClipSize = engine.ActiveGamemode() == "terrortown" and 200 or 9999
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 200 or 9999
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Damage = 4
SWEP.Primary.Spread = 0.03
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 4
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 1
SWEP.Secondary.Sound = Sound("weapons/minigun_spin.wav")
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
local SPIN_OFF = 0
local SPIN_UP = 1
local SPIN_SHOOT = 2

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", "ShootSound")
    self:NetworkVar("Int", "Spin")
    self:NetworkVar("Float", "SpinTimer")
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
end

local setHooks = false

function SWEP:Initialize()
    TF2WC:SandboxSetup(self)

    if not setHooks then
        if CR_VERSION then
            hook.Add("TTTSpeedMultiplier", "TF2WCMinigunMovementSpeed", function(ply, mults)
                if not IsValid(ply) then return end
                local wep = ply:GetActiveWeapon()
                if not IsValid(wep) or WEPS.GetClass(wep) ~= "weapon_ttt_tf2_minigun" or not wep.GetSpin then return end

                if wep:GetSpin() == SPIN_UP then
                    table.insert(mults, 0.75)
                elseif wep:GetSpin() == SPIN_SHOOT then
                    table.insert(mults, 0.5)
                end
            end)
        end

        setHooks = true
    end

    self:SetIdle(false)
    self:SetIdleTimer(CurTime() + 1)

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self.LastOwner = owner
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:SetShootSound(false)
    self:SetSpin(SPIN_OFF)
    self:SetSpinTimer(CurTime() + 0.5)
    self:SetIdle(false)
    self:SetIdleTimer(CurTime() + vm:SequenceDuration())

    return self.BaseClass.Deploy(self)
end

function SWEP:OwnerChanged()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self.LastOwner = owner
end

function SWEP:Holster()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        owner = self.LastOwner
    end

    self:SetShootSound(false)
    self:SetSpin(SPIN_OFF)
    self:SetSpinTimer(CurTime())
    self:SetIdle(false)
    self:SetIdleTimer(CurTime())
    if not IsValid(owner) then return end

    if SERVER then
        owner:StopSound(self.Primary.Sound)
        owner:StopSound(self.Secondary.Sound)
        owner:StopSound("weapons/minigun_wind_up.wav")

        if not CR_VERSION then
            owner:SetLaggedMovementValue(1)
        end
    end

    local vm = owner:GetViewModel()

    if IsValid(vm) then
        vm:ManipulateBoneAngles(2, Angle(0, 0, 0))
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

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:GetSpin() == SPIN_OFF and self:GetSpinTimer() <= CurTime() and owner:KeyDown(IN_ATTACK) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/minigun_wind_up.wav")
        end

        self:SendWeaponAnim(ACT_DEPLOY)
        self:SetSpin(SPIN_UP)
        self:SetSpinTimer(CurTime() + 0.9)
        self:SetIdle(false)
        self:SetIdleTimer(CurTime() + vm:SequenceDuration())
    end

    if self:GetSpin() ~= SPIN_SHOOT then return end
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

    if not self:GetShootSound() then
        if SERVER then
            owner:EmitSound(self.Primary.Sound)
        end

        self:SetShootSound(true)
    end

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:MuzzleFlash()
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:SetIdle(true)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if owner:KeyDown(IN_ATTACK) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:GetSpin() == SPIN_OFF and self:GetSpinTimer() <= CurTime() and owner:KeyDown(IN_ATTACK2) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/minigun_wind_up.wav")
        end

        self:SendWeaponAnim(ACT_DEPLOY)
        self:SetSpin(SPIN_UP)
        self:SetSpinTimer(CurTime() + 0.9)
        self:SetIdle(false)
        self:SetIdleTimer(CurTime() + vm:SequenceDuration())
    end

    if self:GetSpin() == SPIN_SHOOT then
        self:EmitSound(self.Secondary.Sound)
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
        self:SetIdle(true)
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
    self.LastOwner = owner
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:GetSpin() == SPIN_UP and self:GetSpinTimer() <= CurTime() then
        self:SetSpin(SPIN_SHOOT)
    end

    if not CR_VERSION and SERVER then
        if self:GetSpin() == SPIN_UP then
            owner:SetLaggedMovementValue(0.75)
        elseif self:GetSpin() == SPIN_SHOOT then
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

        self:SetShootSound(false)
    end

    if SERVER and not owner:KeyDown(IN_ATTACK2) then
        owner:StopSound(self.Secondary.Sound)
    end

    if self:GetSpin() == SPIN_SHOOT and ((not owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ATTACK2)) or self:Clip1() <= 0) then
        if SERVER then
            owner:StopSound(self.Primary.Sound)
            owner:StopSound(self.Secondary.Sound)
            owner:EmitSound("weapons/minigun_wind_down.wav")
        end

        self:SendWeaponAnim(ACT_UNDEPLOY)
        self:SetShootSound(false)
        self:SetSpin(SPIN_OFF)
        self:SetSpinTimer(CurTime() + 0.9)
        self:SetIdle(false)
        self:SetIdleTimer(CurTime() + vm:SequenceDuration())
    end

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() then
        if SERVER then
            if self:GetSpin() == SPIN_OFF then
                self:SendWeaponAnim(ACT_VM_IDLE)
            else
                self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
            end
        end

        self:SetIdle(true)
    end

    if CLIENT then
        if self:GetSpin() == SPIN_OFF then
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
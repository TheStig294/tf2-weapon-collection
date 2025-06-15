SWEP.PrintName = "Spy Revolver"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/v_models/v_revolver_spy.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_revolver.mdl"
SWEP.ViewModelFlip = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.UseHands = false
SWEP.HoldType = "Revolver"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_PISTOL
SWEP.Slot = 1
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A fast-shooting revolver!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_revolver.png"
end

SWEP.Primary.Sound = Sound("weapons/revolver_shoot.wav")
SWEP.Primary.Damage = 40
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 6
SWEP.Primary.Ammo = "AlyxGun"
SWEP.AmmoEnt = "item_ammo_revolver_ttt"
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 6 or 9999
SWEP.Primary.Spread = 0.2
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.5
SWEP.Primary.Force = 1
SWEP.ReloadAnimDelay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")

function SWEP:SecondaryAttack()
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
    self:NetworkVar("Bool", "Reload")
    self:NetworkVar("Float", "ReloadTimer")
end

function SWEP:ResetAnimations()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SetIdle(false)
    self:SetReload(false)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    local animDelay = vm:SequenceDuration()
    self:SetIdleTimer(CurTime() + animDelay)
    self:SetReloadTimer(CurTime() + self.ReloadAnimDelay)
end

function SWEP:Initialize()
    self:ResetAnimations()

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:ResetAnimations()

    return self.BaseClass.Deploy(self)
end

function SWEP:Holster()
    self:ResetAnimations()

    return self.BaseClass.Holster(self)
end

function SWEP:PrimaryAttack()
    self:ResetAnimations()

    return self.BaseClass.PrimaryAttack(self)
end

if engine.ActiveGamemode() ~= "terrortown" then
    function SWEP:PrimaryAttack()
        self:ResetAnimations()

        return TF2WC:PrimaryAttackSandbox(self)
    end
end

function SWEP:Reload()
    self:ResetAnimations()
    self:SetReload(true)

    return self.BaseClass.Reload(self)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() then
        if SERVER then
            self:SendWeaponAnim(ACT_VM_IDLE)
        end

        self:SetIdle(true)
    end

    if not self:GetReload() and self:GetReloadTimer() <= CurTime() and self:Clip1() < self:GetMaxClip1() and self.AutoReloadCvar:GetBool() then
        self:Reload()
    end
end
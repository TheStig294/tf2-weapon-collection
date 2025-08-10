SWEP.PrintName = "TF2 Pistol"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 55
SWEP.ViewModel = "models/weapons/v_models/v_pistol_scout.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_pistol.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.HoldType = "revolver"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_PISTOL
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.Slot = 1
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A fast shooting pistol"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_pistol.png"
end

SWEP.CSMuzzleFlashes = true
SWEP.Primary.Sound = Sound("weapons/pistol_shoot.wav")
SWEP.Primary.Damage = 15
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 12
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 12 or 9999
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.15
SWEP.Primary.Force = 0.3
SWEP.ReloadAnimDelay = 0.5
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")

function SWEP:Initialize()
    TF2WC:SetHoldType(self)
    self:ResetAnimations()

    return self.BaseClass.Initialize(self)
end

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
    self:SetReloadTimer(CurTime() + self.ReloadAnimDelay)
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
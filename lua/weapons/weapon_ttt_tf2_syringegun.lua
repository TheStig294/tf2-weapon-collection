SWEP.PrintName = "Syringe Gun"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_syringegun_medic.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_syringegun.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 4
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "ar2"
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
        desc = "Shoots high-damage syringes, with a limited range"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_syringegun.png"
    SWEP.Instructions = SWEP.EquipMenuData.desc
end

SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Reloading = 0
SWEP.ReloadingTimer = 0
SWEP.Idle = 0
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("Weapon_SyringeGun.Single")
SWEP.Primary.ClipSize = 40
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 40 or 9999
SWEP.Primary.Damage = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 1500
SWEP.ReloadAnimDelay = 0.5
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")

function SWEP:Initialize()
    TF2WC:SandboxSetup(self)
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
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    local animDelay = vm:SequenceDuration()
    self:SetIdleTimer(CurTime() + animDelay)
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
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    self:ResetAnimations()

    if SERVER then
        local entity = ents.Create("ttt_tf2_syringe")
        entity:SetOwner(owner)
        entity.Weapon = self

        if IsValid(entity) then
            local Forward = owner:EyeAngles():Forward()
            local Right = owner:EyeAngles():Right()
            local Up = owner:EyeAngles():Up()
            entity:SetPos(owner:GetShootPos() + Forward * 8 + Right * 4 + Up * -4)
            entity:SetAngles(owner:EyeAngles())
            entity.Damage = self.Primary.Damage
            entity:Spawn()
            local phys = entity:GetPhysicsObject()
            phys:SetVelocity(owner:GetAimVector() * self.Primary.Force)
        end
    end

    self:EmitSound(self.Primary.Sound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
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
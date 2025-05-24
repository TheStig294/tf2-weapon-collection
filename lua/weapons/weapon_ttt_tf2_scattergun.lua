SWEP.PrintName = "Scattergun"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "shotgun"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_models/v_scattergun_scout.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_scattergun.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 1
SWEP.UseHands = false
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = true

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A fast-shooting, tight-spread shotgun!"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_scattergun.png"
end

SWEP.Primary.Sound = Sound("weapons/scatter_gun_shoot.wav")
SWEP.Primary.Damage = 6
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 6
SWEP.Primary.Ammo = "Buckshot"
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.WeaponID = AMMO_SHOTGUN
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 6 or 9999
SWEP.Primary.Spread = 0.5
SWEP.Primary.NumberofShots = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.625
SWEP.Primary.Force = 10
SWEP.ReloadAnimDelay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:SecondaryAttack()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "Idle")
	self:NetworkVar("Float", "IdleTimer")
	self:NetworkVar("Bool", "Reload")
	self:NetworkVar("Float", "ReloadTimer")
	self:NetworkVar("Bool", "Reloading")
	self:NetworkVar("Float", "ReloadingTimer")
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
	if not self:CanPrimaryAttack() then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:ResetAnimations()
	self:EmitSound("weapons/scatter_gun_shoot.wav")
	self:SetNextPrimaryFire(CurTime() + 0.625)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:TakePrimaryAmmo(1)
	self.StartReload = false
	self:SetReloading(false)
	owner:ViewPunch(Angle(-1, 0, 0))
	local bullet = {}
	bullet.Num = self.Primary.NumberofShots
	bullet.Src = owner:GetShootPos()
	bullet.Dir = owner:GetAimVector()
	bullet.Spread = Vector(self.Primary.Spread * 0.1, self.Primary.Spread * 0.1, 0)
	bullet.Tracer = 1
	bullet.Force = self.Primary.Force
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = self.Primary.Ammo
	bullet.Inflictor = self
	owner:FireBullets(bullet)
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:ResetAnimations()
	self:SetReload(true)
	if self:GetReloading() then return end

	if self:Clip1() < self:GetMaxClip1() and owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self:SetReloading(true)
		owner:SetAnimation(PLAYER_RELOAD)
		self:SetReloadingTimer(CurTime() + 0.3)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if self:GetReloading() then
		if not self.StartReload then
			self.StartReload = true
			self.CanReload = false
			self:SendWeaponAnim(ACT_RELOAD_START)

			timer.Simple(0.3, function()
				self.CanReload = true
			end)
		end

		if self.CanReload and self:GetReloadingTimer() < CurTime() then
			if self:Clip1() >= self:GetMaxClip1() or owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
				self:ResetAnimations()
				self:SendWeaponAnim(ACT_RELOAD_FINISH)
				self:SetReloading(false)

				return
			end

			self:SendWeaponAnim(ACT_VM_RELOAD)
			self:SetReloadingTimer(CurTime() + 0.5)
			self:SetIdleTimer(CurTime() + 0.5)
			owner:RemoveAmmo(1, self.Primary.Ammo, false)
			self:SetClip1(self:Clip1() + 1)
		end
	else
		if not self:GetIdle() and self:GetIdleTimer() <= CurTime() then
			if SERVER then
				self:SendWeaponAnim(ACT_VM_IDLE)
			end

			self:SetIdle(true)
		end

		if not self:GetReload() and self:GetReloadTimer() <= CurTime() and self:Clip1() < self:GetMaxClip1() then
			self:Reload()
		end
	end
end
SWEP.PrintName = "Grenade Launcher"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/v_models/v_grenadelauncher_demo.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_grenadelauncher.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.WeaponID = AMMO_SHOTGUN
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.AutoSpawnable = true

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Shoots arcing explosive grenades!"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_grenadelauncher.png"
end

SWEP.Primary.Ammo = "Grenade"
SWEP.Primary.Sound = Sound("weapons/grenade_launcher_shoot.wav")
SWEP.Primary.Damage = 50
SWEP.Primary.Radius = 140
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 4
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 4 or 9999
SWEP.Primary.Spread = 0.05
SWEP.Primary.NumberofShots = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.Force = 5
SWEP.ReloadAnimDelay = 1
SWEP.ReloadHoldType = "revolver"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")

function SWEP:Initialize()
	timer.Simple(0, function()
		self:SetHoldType(self.HoldType)
	end)

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

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:ResetAnimations()
	self.StartReload = false

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
	self.StartReload = false
	self:SetReloading(false)
	self:SetNextPrimaryFire(CurTime() + 0.6)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:ShootGrenade()
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
end

function SWEP:ShootGrenade()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	owner:SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapons/grenade_launcher_shoot.wav")
	if CLIENT then return end
	local ent = ents.Create("ttt_tf2_grenade")
	if not IsValid(ent) then return end
	ent.Weapon = self
	ent.DamageOwner = owner
	ent:SetPos(owner:EyePos() + (owner:GetAimVector() * 16))
	ent:SetAngles(owner:EyeAngles())
	ent.Damage = self.Primary.Damage
	ent.Radius = self.Primary.Radius
	ent:Spawn()
	local phys = ent:GetPhysicsObject()

	if not IsValid(phys) then
		ent:Remove()

		return
	end

	local velocity = owner:GetAimVector()
	velocity = velocity * 7000
	velocity = velocity + (VectorRand() * 10)
	phys:ApplyForceCenter(velocity)
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

			timer.Simple(0.6, function()
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
			self:SetReloadingTimer(CurTime() + 0.6)
			self:SetIdleTimer(CurTime() + 0.6)
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

		if not self:GetReload() and self:GetReloadTimer() <= CurTime() and self:Clip1() < self:GetMaxClip1() and self.AutoReloadCvar:GetBool() then
			self:Reload()
		end
	end
end
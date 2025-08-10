SWEP.PrintName = "Rocket Launcher"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 55
SWEP.ViewModel = "models/weapons/v_models/v_rocketlauncher_soldier.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_rocketlauncher.mdl"
SWEP.ViewModelFlip = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 2
SWEP.UseHands = false
SWEP.HoldType = "rpg"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.ReloadSound = "sound/epicreload.wav"
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_EQUIP
SWEP.Slot = engine.ActiveGamemode() == "terrortown" and 6 or 5
SWEP.WeaponID = AMMO_SHOTGUN
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.AutoSpawnable = false

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A rocket launcher!\n\nJump and shoot your feet to rocket-jump!"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_rpg.png"
end

SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}

SWEP.Primary.Sound = Sound("weapons/rocket_shoot.wav")
SWEP.Primary.Damage = 40
SWEP.Primary.TakeAmmo = 0
SWEP.Primary.ClipSize = 4
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 32 or 9999
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.05
SWEP.Primary.Force = 562.5
SWEP.Primary.Radius = 169
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Sound = Sound("weapons/rocket_shoot.wav")
SWEP.ReloadAnimDelay = 1
SWEP.ReloadHoldType = "revolver"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")

function SWEP:Initialize()
	TF2WC:SetHoldType(self)
	self:ResetAnimations()

	hook.Add("OnDamagedByExplosion", "TF2RPGNoExplosionRinging", function(_, dmg)
		local inflictor = dmg:GetInflictor()
		if not IsValid(inflictor) then return end
		local class = inflictor:GetClass()
		if class == "ttt_tf2_rocket" or class == "weapon_ttt_tf2_rpg" then return true end
	end)

	return self.BaseClass.Initialize(self)
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
	self:EmitSound("weapons/rocket_shoot.wav")
	self:SetNextPrimaryFire(CurTime() + 0.8)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:FireRocket()
	self:TakePrimaryAmmo(1)
	self.StartReload = false
	self:SetReloading(false)
end

function SWEP:FireRocket()
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local aim = owner:GetAimVector()
	local pos = owner:GetShootPos() + aim * 10
	local rocket = ents.Create("ttt_tf2_rocket")
	rocket.Weapon = self
	rocket.Force = self.Primary.Force
	rocket.Radius = self.Primary.Radius
	rocket:SetSaveValue("m_flDamage", 90)
	if not rocket:IsValid() then return false end
	rocket:SetAngles(aim:Angle())
	rocket:SetPos(pos)
	rocket:SetOwner(owner)
	rocket:Spawn()
	rocket:Activate()
	rocket:SetVelocity(rocket:GetForward() * 1100)
	rocket.Damage = self.Primary.Damage
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
			self:SetReloadingTimer(CurTime() + 0.8)
			self:SetIdleTimer(CurTime() + 0.8)
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
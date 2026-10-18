SWEP.PrintName = "Stickybomb Laun."
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Alt-Fire: Detonate all stickybombs"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/v_models/v_stickybomb_launcher_demo.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_stickybomb_launcher.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_EQUIP
SWEP.Slot = 6
SWEP.SandboxSlot = 4
SWEP.AutoSpawnable = false

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Fires sticky bombs!\nExplode them with right-click\n\nYou can only have up to 8 at a time."
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_stickybomblauncher.png"
	SWEP.Instructions = SWEP.EquipMenuData.desc
end

SWEP.CanBuy = {ROLE_DETECTIVE, ROLE_TRAITOR}

SWEP.Primary.Sound = Sound("weapons/stickybomblauncher_shoot.wav")
SWEP.Primary.Damage = 60
SWEP.Primary.ClipSize = 8
SWEP.Primary.Ammo = "Buckshot"
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 32 or 9999
SWEP.Primary.Spread = 0.05
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.ChargeTime = 3
SWEP.Primary.Force = 750
SWEP.StickyQueue = {}
SWEP.MaxStickyCount = SWEP.Primary.ClipSize
SWEP.ReloadAnimDelay = 3
SWEP.ChargeMult = 1
SWEP.MaxChargeMult = 2
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")
SWEP.StartReload = false
SWEP.LastFireTime = CurTime()

function SWEP:Initialize()
	TF2WC:SandboxSetup(self)
	self:ResetAnimations()

	return self.BaseClass.Initialize(self)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "Idle")
	self:NetworkVar("Float", "IdleTimer")
	self:NetworkVar("Bool", "Reload")
	self:NetworkVar("Float", "ReloadTimer")
	self:NetworkVar("Bool", "Reloading")
	self:NetworkVar("Float", "ReloadingTimer")
	self:NetworkVar("Bool", "Attacking")
	self:NetworkVar("Float", "AttackingTimer")
end

function SWEP:ResetAnimations()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:SetIdle(false)
	self:SetReload(false)
	self:SetAttacking(false)
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end
	local animDelay = vm:SequenceDuration()
	self:SetIdleTimer(CurTime() + animDelay)
	self:SetReloadTimer(CurTime() + self.ReloadAnimDelay)
	self:SetAttackingTimer(CurTime() + self.Primary.ChargeTime)
end

function SWEP:Deploy()
	self:ResetAnimations()
	self.StartReload = false
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)

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
	self:SetAttacking(true)
	self:SendWeaponAnim(ACT_VM_IDLE)
	self:EmitSound("weapons/loose_cannon_charge.wav")
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetReloading(false)
	self.LastFireTime = CurTime()
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local stickyExploded = false

	for _, sticky in ipairs(self.StickyQueue) do
		if IsValid(sticky) and sticky.Activation then
			sticky:Remove()
			stickyExploded = true
		end
	end

	if stickyExploded then
		owner:EmitSound("Weapon_StickyBombLauncher.ModeSwitch")
	end
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
		self:SetReloadingTimer(CurTime() + 0.1)
	end
end

function SWEP:Overcharge()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:SetAttacking(false)
	self:EmitSound("weapons/loose_cannon_explode.wav")
	self:ShootStickyBomb()
end

function SWEP:ShootStickyBomb()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.StartReload = false
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetAttacking(false)
	self:EmitSound("weapons/stickybomblauncher_shoot.wav")
	self:TakePrimaryAmmo(1)
	owner:SetAnimation(PLAYER_ATTACK1)
	owner:ViewPunch(Angle(-1, 0, 0))
	if CLIENT then return end
	local ent = ents.Create("ttt_tf2_sticky")
	if not IsValid(ent) then return end
	ent.Weapon = self
	ent.StickyOwner = owner
	ent:SetPos(owner:EyePos() + owner:GetAimVector() * 16)
	ent:SetAngles(owner:EyeAngles())
	ent.Damage = self.Primary.Damage
	ent.DamageForce = self.Primary.Force
	ent:SetStickyJumper(false)
	ent:Spawn()
	local phys = ent:GetPhysicsObject()

	if not IsValid(phys) then
		ent:Remove()

		return
	end

	local velocity = owner:GetAimVector()
	velocity = velocity * 7000 * math.max(self.ChargeMult, 0.5)
	velocity = velocity + (VectorRand() * 10)
	phys:ApplyForceCenter(velocity)
	table.insert(self.StickyQueue, ent)

	if #self.StickyQueue > self.MaxStickyCount then
		local oldestSticky = self.StickyQueue[1]

		if IsValid(oldestSticky) then
			oldestSticky:Remove()
			owner:EmitSound("Weapon_StickyBombLauncher.ModeSwitch")
		end

		table.remove(self.StickyQueue, 1)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end
	self.ChargeMult = 0

	if self:GetAttacking() then
		self.ChargeMult = self.MaxChargeMult * (CurTime() - self.LastFireTime)

		if self:GetAttackingTimer() < CurTime() then
			self:Overcharge()
		elseif not owner:KeyDown(IN_ATTACK) then
			self:ShootStickyBomb()
		end
	elseif self:GetReloading() then
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
			self:SetReloadingTimer(CurTime() + 0.67)
			self:SetIdleTimer(CurTime() + 0.67)
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

if CLIENT and not game.SinglePlayer() then
	function SWEP:DrawHUD()
		draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Charge: " .. math.SnapTo(self.ChargeMult / 6 * 100, 10) .. "%", "TF2Font", color_black, color_white, TEXT_ALIGN_LEFT)
	end
end
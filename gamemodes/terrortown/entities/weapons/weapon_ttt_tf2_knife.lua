SWEP.PrintName = "Backstab Knife"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_knife_spy.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_knife.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 2
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP
SWEP.Slot = 6
SWEP.AutoSpawnable = false

SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Hit someone from behind for an instant kill!\n\nOtherwise deals regular damage"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_knife.png"
end

SWEP.Backstab = 0
SWEP.Attack = 0
SWEP.AttackTimer = 0
SWEP.Idle = 0
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("Weapon_Knife.Miss")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 40
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2000
SWEP.BackstabAngle = 30
SWEP.BackstabRange = 64

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.Idle = 0
	self.IdleTimer = CurTime() + 1
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end
	self:SetWeaponHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self.Attack = 0
	self.AttackTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()

	return true
end

function SWEP:Holster()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self.Backstab = 0
	self.Attack = 0
	self.AttackTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime()

	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	if self.Backstab == 1 then
		local tr = util.TraceLine({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.BackstabRange,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		if not IsValid(tr.Entity) then
			tr = util.TraceHull({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + owner:GetAimVector() * self.BackstabRange,
				filter = owner,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 0),
				mask = MASK_SHOT_HULL,
			})
		end

		if SERVER and IsValid(tr.Entity) then
			local dmg = DamageInfo()
			local attacker = owner

			if not IsValid(attacker) then
				attacker = self
			end

			dmg:SetAttacker(attacker)
			dmg:SetInflictor(self)
			local angle = owner:GetAngles().y - tr.Entity:GetAngles().y

			if angle < -180 then
				angle = 360 + angle
			end

			if angle <= self.BackstabAngle and angle >= -self.BackstabAngle then
				dmg:SetDamage(tr.Entity:Health() * 6)
			else
				dmg:SetDamage(self.Primary.Damage)
			end

			dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
			dmg:SetDamageType(DMG_SLASH)
			tr.Entity:TakeDamageInfo(dmg)

			timer.Simple(0.1, function()
				if IsValid(tr.Entity) and tr.Entity:IsPlayer() and (tr.Entity:Alive() or not tr.Entity:IsSpec()) then
					tr.Entity:Kill()
				end
			end)
		end

		if SERVER and tr.Hit then
			if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
				owner:EmitSound("Weapon_Knife.HitFlesh")
			end

			if not (tr.Entity:IsPlayer() or tr.Entity:IsNPC()) then
				owner:EmitSound("Weapon_Knife.HitWorld")
			end

			self.Attack = 2
			self.AttackTimer = CurTime() + 0.05
		end
	end

	owner:SetAnimation(PLAYER_ATTACK1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if self.Backstab == 0 then
		self:EmitSound(self.Primary.Sound)
		self:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Attack = 1
		self.AttackTimer = CurTime() + 0.2
	end

	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * self.BackstabRange,
		filter = owner,
		mask = MASK_SHOT_HULL,
	})

	if not IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.BackstabRange,
			filter = owner,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 0),
			mask = MASK_SHOT_HULL,
		})
	end

	if tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC()) then
		local angle = owner:GetAngles().y - tr.Entity:GetAngles().y

		if angle < -180 then
			angle = 360 + angle
		end

		if angle <= self.BackstabAngle and angle >= -self.BackstabAngle and self.Backstab == 0 then
			self:SendWeaponAnim(ACT_DEPLOY)
			self.Backstab = 1
			self.Idle = 0
			self.IdleTimer = CurTime() + vm:SequenceDuration()
		end

		if not (angle <= self.BackstabAngle and angle >= -self.BackstabAngle) and self.Backstab == 1 then
			self:SendWeaponAnim(ACT_UNDEPLOY)
			self.Backstab = 0
			self.Idle = 0
			self.IdleTimer = CurTime() + vm:SequenceDuration()
		end
	end

	if not (tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())) and self.Backstab == 1 then
		self:SendWeaponAnim(ACT_UNDEPLOY)
		self.Backstab = 0
		self.Idle = 0
		self.IdleTimer = CurTime() + vm:SequenceDuration()
	end

	if self.Attack == 2 and self.AttackTimer <= CurTime() then
		self:SendWeaponAnim(ACT_VM_SWINGHARD)
		self.Attack = 0
		self.Idle = 0
		self.IdleTimer = CurTime() + vm:SequenceDuration()
	end

	if self.Attack == 1 and self.AttackTimer <= CurTime() then
		local tr2 = util.TraceLine({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.BackstabRange,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		if not IsValid(tr2.Entity) then
			tr2 = util.TraceHull({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + owner:GetAimVector() * self.BackstabRange,
				filter = owner,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 0),
				mask = MASK_SHOT_HULL,
			})
		end

		if SERVER and IsValid(tr2.Entity) then
			local dmg = DamageInfo()
			local attacker = owner

			if not IsValid(attacker) then
				attacker = self
			end

			dmg:SetAttacker(attacker)
			dmg:SetInflictor(self)
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
			dmg:SetDamageType(DMG_SLASH)
			tr2.Entity:TakeDamageInfo(dmg)
		end

		if SERVER and tr2.Hit then
			if tr2.Entity:IsNPC() or tr2.Entity:IsPlayer() then
				owner:EmitSound("Weapon_Knife.HitFlesh")
			end

			if not (tr2.Entity:IsNPC() or tr2.Entity:IsPlayer()) then
				owner:EmitSound("Weapon_Knife.HitWorld")
			end
		end

		self.Attack = 0
	end

	if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			if self.Backstab == 0 then
				self:SendWeaponAnim(ACT_VM_IDLE)
			end

			if self.Backstab == 1 then
				self:SendWeaponAnim(ACT_DEPLOY_IDLE)
			end
		end

		self.Idle = 1
	end
end
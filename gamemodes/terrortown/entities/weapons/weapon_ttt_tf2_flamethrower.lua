SWEP.PrintName = "Flamethrower"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "crossbow"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_models/v_flamethrower_pyro.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_flamethrower.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "crossbow"
SWEP.FiresUnderwater = false
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
		desc = "High-damage, short range flamethower!\n\nRight-click to push players and objects away"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_flamethrower.png"
end

SWEP.DoLoopingSound = false
SWEP.SoundTimer = 0
SWEP.IsAttacking = false
SWEP.IsAttackingTimer = 0
SWEP.ReloadingTimer = 0
SWEP.Idle = true
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("weapons/flame_thrower_start.wav")
SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Damage = 3.5
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Delay = 0.08
SWEP.Primary.Force = 100
SWEP.Primary.AmmoLossRate = 0.1
SWEP.Primary.Range = 196
SWEP.Secondary.Sound = Sound("weapons/flame_thrower_airblast.wav")
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.TakeAmmo = 20
SWEP.Secondary.Delay = 0.75
SWEP.Secondary.Force = 2500

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
end

function SWEP:UpdateNextIdle()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if self:Clip1() > 0 then
		self:EmitSound("Weapon_FlameThrower.PilotLoop")
	end

	self:UpdateNextIdle()

	return self.BaseClass.Deploy(self)
end

function SWEP:Holster()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:StopSound("Weapon_FlameThrower.PilotLoop")

	return self.BaseClass.Holster(self)
end

function SWEP:OnRemove()
	if SERVER and IsValid(self.Flame) then
		self.Flame:Remove()
	end

	return self.BaseClass.OnRemove(self)
end

function SWEP:PrimaryAttack()
	if self.IsAttacking or not self:CanPrimaryAttack() then return end
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if not self.FiresUnderwater and owner:WaterLevel() == 3 then return end

	if not self.IsAttacking then
		if SERVER then
			local flame = ents.Create("info_particle_system")
			flame:SetKeyValue("effect_name", "flamethrower")
			flame:SetOwner(owner)
			local Forward = owner:EyeAngles():Forward()
			local Right = owner:EyeAngles():Right()
			local Up = owner:EyeAngles():Up()
			flame:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
			flame:SetAngles(owner:EyeAngles())
			flame:Spawn()
			flame:Activate()
			flame:Fire("start", "", 0)
			self.Flame = flame
		end

		self:EmitSound(self.Primary.Sound)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		owner:SetAnimation(PLAYER_ATTACK1)
		self.DoLoopingSound = true
		self.SoundTimer = CurTime() + 3.5
	end

	self.IsAttacking = true
	self.Idle = false
	self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
end

function SWEP:SecondaryAttack()
	if self.IsAttacking then return end
	if self:Clip1() < 20 then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if not self.FiresUnderwater and owner:WaterLevel() == 3 then return end

	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * 128,
		filter = owner,
		mask = MASK_SHOT_HULL,
	})

	local ent = tr.Entity

	if not IsValid(ent) then
		tr = util.TraceHull({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * 128,
			filter = owner,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 0),
			mask = MASK_SHOT_HULL,
		})
	end

	if SERVER then
		if IsValid(ent) then
			ent:SetVelocity(owner:GetAimVector() * Vector(self.Secondary.Force, self.Secondary.Force, 0) + Vector(0, 0, 200))
		end

		local blast = ents.Create("info_particle_system")
		blast:SetKeyValue("effect_name", "pyro_blast")
		blast:SetOwner(owner)
		local Forward = owner:EyeAngles():Forward()
		local Right = owner:EyeAngles():Right()
		local Up = owner:EyeAngles():Up()
		blast:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
		blast:SetAngles(owner:EyeAngles())
		blast:Spawn()
		blast:Activate()
		blast:Fire("start", "", 0)
	end

	if SERVER and IsValid(ent) then
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceOffset(owner:GetAimVector() * 16000, tr.HitPos)
		end
	end

	self:EmitSound(self.Secondary.Sound)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:TakePrimaryAmmo(self.Secondary.TakeAmmo)
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self.Idle = false
	self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
end

function SWEP:RemoveFlame()
	if SERVER and IsValid(self.Flame) then
		self.Flame:Remove()
	end

	self:StopSound(self.Primary.Sound)
	self:EmitSound("Weapon_FlameThrower.PilotLoop")
	self.DoLoopingSound = false
	self.IsAttacking = false
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if self.DoLoopingSound and self.SoundTimer <= CurTime() then
		self:EmitSound("weapons/flame_thrower_loop.wav")
		self.DoLoopingSound = false
	end

	if SERVER and self.IsAttacking then
		local Forward = owner:EyeAngles():Forward()
		local Right = owner:EyeAngles():Right()
		local Up = owner:EyeAngles():Up()
		self.Flame:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
		self.Flame:SetAngles(owner:EyeAngles())
	end

	if self.IsAttacking and (not owner:KeyDown(IN_ATTACK) or self:Clip1() <= 0 or owner:WaterLevel() == 3) then
		self:RemoveFlame()
	end

	if self.IsAttacking and self.IsAttackingTimer <= CurTime() then
		local tr = util.TraceLine({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		local ent = tr.Entity

		if not IsValid(ent) then
			tr = util.TraceHull({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
				filter = owner,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 0),
				mask = MASK_SHOT_HULL,
			})
		end

		if SERVER and IsValid(ent) and not (IsValid(ent) and ent:IsPlayer() and (not ent:Alive() or ent:IsSpec())) then
			local dmg = DamageInfo()
			local attacker = owner

			if not IsValid(attacker) then
				attacker = self
			end

			dmg:SetAttacker(attacker)
			dmg:SetInflictor(self)
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
			dmg:SetDamageType(DMG_BURN)
			ent:TakeDamageInfo(dmg)
			ent:Ignite(10)

			timer.Simple(0.1, function()
				if IsValid(ent) and ent:IsPlayer() and (not ent:Alive() or ent:IsSpec()) then
					ent:Extinguish()
				end
			end)
		end

		self:TakePrimaryAmmo(1)
		self.IsAttackingTimer = CurTime() + 0.04
	end

	if not self.Idle and self.IdleTimer <= CurTime() then
		if SERVER then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end

		self.Idle = true
	end
end
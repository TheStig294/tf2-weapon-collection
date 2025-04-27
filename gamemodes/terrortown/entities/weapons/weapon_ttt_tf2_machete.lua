SWEP.PrintName = "Kukri"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/v_models/v_machete_sniper.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_machete.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A heavy-hitting melee weapon!\nHigher DPS than the crowbar!"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_machete.png"
end

SWEP.Primary.Sound = Sound("Weapon_FireAxe.Miss")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 48
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.BleedDamage = 5
SWEP.BleedDamageTicks = 6
SWEP.BleedDamageDelay = 1

function SWEP:Deploy()
	self:SetWeaponHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self.Attack = 0
	self.AttackTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()

	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:EmitSound(self.Primary.Sound)
	local vm = owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("m_swing_a"))
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Attack = 1
	self.AttackTimer = CurTime() + 0.2
	self.Idle = 0
	self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
end

function SWEP:Think()
	if self.Attack == 1 and self.AttackTimer <= CurTime() then
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local tr = util.TraceLine({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * 64,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		local ent = tr.Entity

		if not IsValid(ent) then
			tr = util.TraceHull({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + owner:GetAimVector() * 64,
				filter = owner,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 0),
				mask = MASK_SHOT_HULL,
			})
		end

		if SERVER and IsValid(ent) then
			local dmg = DamageInfo()
			local attacker = owner

			if not IsValid(attacker) then
				attacker = self
			end

			dmg:SetAttacker(attacker)
			dmg:SetInflictor(self)
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
			dmg:SetDamageType(DMG_CLUB)
			ent:TakeDamageInfo(dmg)
			local timername = "TF2KukriBleedDamage" .. ent:EntIndex()

			timer.Create(timername, self.BleedDamageDelay, self.BleedDamageTicks, function()
				if not IsValid(ent) or GetRoundState() == ROUND_PREP or (ent:IsPlayer() and (not ent:Alive() or ent:IsSpec())) then
					timer.Remove(timername)

					return
				end

				dmg = DamageInfo()
				attacker = owner

				if not IsValid(attacker) then
					attacker = self
				end

				dmg:SetAttacker(attacker)
				dmg:SetInflictor(self)
				dmg:SetDamage(self.BleedDamage)
				dmg:SetDamageType(DMG_CLUB)
				ent:TakeDamageInfo(dmg)
			end)
		end

		if SERVER and tr.Hit then
			if ent:IsNPC() or ent:IsPlayer() then
				owner:EmitSound("Weapon_Club.HitFlesh")
			end

			if not (ent:IsNPC() or ent:IsPlayer()) then
				owner:EmitSound("Weapon_Club.HitWorld")
			end
		end

		self.Attack = 0
	end

	if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end

		self.Idle = 1
	end
end
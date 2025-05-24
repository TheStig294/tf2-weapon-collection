SWEP.PrintName = "Bone Saw"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/v_models/v_bonesaw_medic.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_bonesaw.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_MELEE
SWEP.AutoSpawnable = true

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A heavy-hitting melee weapon!\nHigher DPS than the crowbar, heals you while held out!"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_bonesaw.png"
end

SWEP.Primary.Sound = Sound("Weapon_FireAxe.Miss")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 30
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128
SWEP.HealAmount = 1
SWEP.HealDelay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:SecondaryAttack()
end

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
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Attack = 1
	self.AttackTimer = CurTime() + 0.2
	self.Idle = 0
	self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
end

function SWEP:DoHeal(ply)
	if not ply.TF2BonesawHealTime or ply.TF2BonesawHealTime < CurTime() then
		local health = ply:Health()
		local maxHP = ply:GetMaxHealth()
		-- Don't mess with a player's overheal
		if health >= maxHP then return end
		local newHP = health + self.HealAmount

		if newHP < maxHP then
			ply:SetHealth(newHP)
		else
			ply:SetHealth(maxHP)
		end

		ply.TF2BonesawHealTime = CurTime() + self.HealDelay
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:DoHeal(owner)

	if self.Attack == 1 and self.AttackTimer <= CurTime() then
		local tr = util.TraceLine({
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		if not IsValid(tr.Entity) then
			tr = util.TraceHull({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
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
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
			dmg:SetDamageType(DMG_CLUB)
			tr.Entity:TakeDamageInfo(dmg)
		end

		if SERVER and tr.Hit then
			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				owner:EmitSound("Weapon_Club.HitFlesh")

				timer.Simple(0, function()
					if not tr.Entity:Alive() or tr.Entity:IsSpec() then
						owner:EmitSound("player/medic/kill" .. math.random(3) .. ".wav")
					end
				end)
			end

			if not (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
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
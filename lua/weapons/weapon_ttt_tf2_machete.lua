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
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.ReloadSound = ""
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "A heavy-hitting melee weapon!\nHigher DPS than the crowbar!"
	}

	SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_machete.png"
	SWEP.Instructions = SWEP.EquipMenuData.desc
end

SWEP.Primary.Sound = Sound("Weapon_FireAxe.Miss")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 100
SWEP.BleedDamage = 5
SWEP.BleedDamageTicks = 6
SWEP.BleedDamageDelay = 1
SWEP.DamageType = DMG_CLUB
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	TF2WC:SandboxSetup(self)

	return self.BaseClass.Initialize(self)
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self.Attack = 0
	self.AttackTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()

	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(self.Primary.Sound)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Attack = 1
	self.AttackTimer = CurTime() + 0.2
	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:OnEntHit(ent)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if ent:IsNPC() or ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
		self:EmitSound("Weapon_Club.HitFlesh")

		timer.Simple(0, function()
			if SERVER and ent:IsPlayer() and (not ent:Alive() or ent:IsSpec()) then
				owner:EmitSound("player/sniper/kill" .. math.random(3) .. ".wav")
			end
		end)
	else
		self:EmitSound("Weapon_Club.HitWorld")
	end

	if SERVER then
		local dmg = DamageInfo()
		local attacker = owner

		if not IsValid(attacker) then
			attacker = self
		end

		local timername = "TF2KukriBleedDamage" .. ent:EntIndex()

		timer.Create(timername, self.BleedDamageDelay, self.BleedDamageTicks, function()
			if not IsValid(ent) or not IsValid(self) or (GetRoundState and GetRoundState() == ROUND_PREP) or (ent:IsPlayer() and (not ent:Alive() or ent:IsSpec())) then
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
			dmg:SetDamageType(self.DamageType)
			ent:TakeDamageInfo(dmg)
		end)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if self.Attack == 1 and self.AttackTimer <= CurTime() then
		if owner.LagCompensation then
			owner:LagCompensation(true)
		end

		local spos = owner:GetShootPos()
		local sdest = spos + (owner:GetAimVector() * self.Primary.Range)

		local tr_main = util.TraceLine({
			start = spos,
			endpos = sdest,
			filter = owner,
			mask = MASK_SHOT_HULL
		})

		local hitEnt = tr_main.Entity

		if IsValid(hitEnt) or tr_main.HitWorld and not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			edata:SetEntity(hitEnt)

			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", edata)
				owner:LagCompensation(false)

				owner:FireBullets({
					Num = 1,
					Src = spos,
					Dir = owner:GetAimVector(),
					Spread = Vector(0, 0, 0),
					Tracer = 0,
					Force = 1,
					Damage = 0
				})
			else
				util.Effect("Impact", edata)
			end

			self:OnEntHit(hitEnt)
		end

		if SERVER then
			owner:SetAnimation(PLAYER_ATTACK1)

			if hitEnt and hitEnt:IsValid() then
				local dmg = DamageInfo()
				dmg:SetDamage(self.Primary.Damage)
				dmg:SetAttacker(owner)
				dmg:SetInflictor(self)
				dmg:SetDamageForce(owner:GetAimVector() * 1500)
				dmg:SetDamagePosition(owner:GetPos())
				dmg:SetDamageType(DMG_CLUB)
				hitEnt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
			end
		end

		if owner.LagCompensation then
			owner:LagCompensation(false)
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
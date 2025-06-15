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
SWEP.Primary.Damage = 48
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 100
SWEP.HealAmount = 1
SWEP.HealDelay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end
	self:SetWeaponHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()

	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

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
	self:EmitSound(self.Primary.Sound)
	self:SendWeaponAnim(ACT_VM_HITCENTER)

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
			self:OnEntHit(hitEnt)
		end
	end

	self.Idle = 0
	self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()

	if owner.LagCompensation then
		owner:LagCompensation(false)
	end
end

function SWEP:OnEntHit(ent)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if ent:IsNPC() or ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
		owner:EmitSound("Weapon_Club.HitFlesh")

		timer.Simple(0, function()
			if ent:IsPlayer() and (not ent:Alive() or ent:IsSpec()) then
				owner:EmitSound("player/medic/kill" .. math.random(3) .. ".wav")
			end
		end)
	else
		self:EmitSound("Weapon_Club.HitWorld")
	end
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

	if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end

		self.Idle = 1
	end
end
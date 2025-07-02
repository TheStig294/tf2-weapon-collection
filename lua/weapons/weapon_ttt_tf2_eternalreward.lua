SWEP.PrintName = "Your Eternal Reward"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/c_models/c_spy_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 2
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_EQUIP
SWEP.Slot = engine.ActiveGamemode() == "terrortown" and 6 or 5
SWEP.AutoSpawnable = false

if CLIENT then
	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Hit someone from behind for an instant kill!\n\nDoesn't leave bodies, take on the appearance of your victims!"
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
SWEP.BackstabRange = 100

SWEP.Primary.Anims = {"eternal_stab_a", "eternal_stab_b", "eternal_stab_c"}

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:SecondaryAttack()
end

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
	vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_draw"))
	self:SetWeaponHoldType(self.HoldType)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self.Attack = 0
	self.AttackTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()

	return true
end

function SWEP:Holster()
	self.Backstab = 0
	self.Attack = 0
	self.AttackTimer = CurTime()
	self.Idle = 0
	self.IdleTimer = CurTime()

	return true
end

function SWEP:TakeAppearance(ply)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	timer.Simple(0, function()
		if not IsValid(ply) or not ply:IsPlayer() or ply:Alive() or not ply:IsSpec() then return end

		if SERVER then
			local rag = ply.server_ragdoll or ply:GetRagdollEntity()

			if IsValid(rag) then
				rag:Remove()
			end
		end

		-- From here onwards, this is code taken from the Spy role from Custom Roles
		-- (Which I originally contributed lol... guess I'm kinda stealing it back?)
		local SetModel = FindMetaTable("Entity").SetModel

		if not owner.TF2EternalRewardOGModel then
			owner.TF2EternalRewardOGModel = {
				model = ply:GetModel(),
				skin = ply:GetSkin(),
				bodygroups = {},
				color = ply:GetColor()
			}

			for _, value in pairs(owner:GetBodyGroups()) do
				owner.TF2EternalRewardOGModel.bodygroups[value.id] = owner:GetBodygroup(value.id)
			end
		end

		SetModel(owner, ply:GetModel())
		owner:SetSkin(ply:GetSkin())
		owner:SetColor(ply:GetColor())

		for _, value in pairs(ply:GetBodyGroups()) do
			owner:SetBodygroup(value.id, ply:GetBodygroup(value.id))
		end

		if SERVER then
			owner:SetupHands()
			owner:PrintMessage(HUD_PRINTCENTER, "Disguised as " .. ply:Nick())
		end

		-- This is where the fun ends for non-CR players, as there's no way to manipulate the target ID popup in base TTT...
		-- (Well... without extreme hacking... Hiding the target ID is close enough and follows the convention of other weapons that do this)
		if not CR_VERSION then
			owner:SetNWBool("disguised", true)
		else
			owner:SetNWString("TF2EternalRewardName", ply:Nick())

			if CLIENT then
				hook.Add("TTTTargetIDPlayerName", "TF2EternalRewardTargetIDName", function(p, cli, _, clr)
					local disguiseName = p:GetNWString("TF2EternalRewardName", "")
					if not disguiseName or #disguiseName == 0 then return end

					if p == cli or (cli:IsTraitorTeam() and ShouldShowTraitorExtraInfo()) then
						return LANG.GetParamTranslation("player_name_disguised", {
							name = p:Nick(),
							disguise = disguiseName
						}), clr
					end

					return disguiseName, clr
				end)

				local client

				hook.Add("TTTChatPlayerName", "TF2EternalRewardChatName", function(p, team_chat)
					local disguiseName = p:GetNWString("TF2EternalRewardName", "")
					if not disguiseName or #disguiseName == 0 then return end

					if not IsPlayer(client) then
						client = LocalPlayer()
					end

					if team_chat then return end

					if p == client or (client:IsTraitorTeam() and ShouldShowTraitorExtraInfo()) then
						return LANG.GetParamTranslation("player_name_disguised", {
							name = p:Nick(),
							disguise = disguiseName
						})
					end

					return disguiseName
				end)
			end
		end

		hook.Add("TTTPrepareRound", "TF2EternalRewardResetModels", function()
			for _, p in player.Iterator() do
				if p.TF2EternalRewardOGModel then
					local modelData = p.TF2EternalRewardOGModel
					SetModel(p, modelData.model)
					p:SetSkin(modelData.skin)
					p:SetColor(modelData.color)

					for id, value in pairs(modelData.bodygroups) do
						p:SetBodygroup(id, value)
					end

					if SERVER then
						p:SetupHands()
					end

					if CR_VERSION then
						p:SetNWString("TF2EternalRewardName", "")
					end

					p.TF2EternalRewardOGModel = nil
				end
			end

			hook.Remove("TTTPrepareRound", "TF2EternalRewardResetModels")

			if CLIENT then
				hook.Remove("TTTTargetIDPlayerName", "TF2EternalRewardTargetIDName")
				hook.Remove("TTTChatPlayerName", "TF2EternalRewardChatName")
			end
		end)
	end)
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	if owner.LagCompensation then
		owner:LagCompensation(true)
	end

	if self.Backstab == 1 then
		local spos = owner:GetShootPos()
		local sdest = spos + owner:GetAimVector() * self.BackstabRange

		local tr = util.TraceLine({
			start = spos,
			endpos = sdest,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		if not IsValid(tr.Entity) then
			tr = util.TraceHull({
				start = spos,
				endpos = sdest,
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
			self:TakeAppearance(tr.Entity)

			timer.Simple(0.1, function()
				if IsValid(tr.Entity) and tr.Entity:IsPlayer() and (tr.Entity:Alive() or not tr.Entity:IsSpec()) then
					tr.Entity:Kill()

					if IsValid(self) then
						self:TakeAppearance(tr.Entity)
					end
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
		vm:SendViewModelMatchingSequence(vm:LookupSequence(self.Primary.Anims[math.random(#self.Primary.Anims)]))
		self.Attack = 1
		self.AttackTimer = CurTime() + 0.2
	end

	self.Idle = 0
	self.IdleTimer = CurTime() + vm:SequenceDuration()

	if owner.LagCompensation then
		owner:LagCompensation(false)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local vm = owner:GetViewModel()
	if not IsValid(vm) then return end

	if owner.LagCompensation then
		owner:LagCompensation(true)
	end

	local spos = owner:GetShootPos()
	local sdest = spos + owner:GetAimVector() * self.BackstabRange

	local tr = util.TraceLine({
		start = spos,
		endpos = sdest,
		filter = owner,
		mask = MASK_SHOT_HULL,
	})

	if not IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = spos,
			endpos = sdest,
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
			vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_backstab_up"))
			self.Backstab = 1
			self.Idle = 0
			self.IdleTimer = CurTime() + vm:SequenceDuration()
		end

		if not (angle <= self.BackstabAngle and angle >= -self.BackstabAngle) and self.Backstab == 1 then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_backstab_down"))
			self.Backstab = 0
			self.Idle = 0
			self.IdleTimer = CurTime() + vm:SequenceDuration()
		end
	end

	if not (tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())) and self.Backstab == 1 then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_backstab_down"))
		self.Backstab = 0
		self.Idle = 0
		self.IdleTimer = CurTime() + vm:SequenceDuration()
	end

	if self.Attack == 2 and self.AttackTimer <= CurTime() then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_backstab"))
		self.Attack = 0
		self.Idle = 0
		self.IdleTimer = CurTime() + vm:SequenceDuration()
	end

	if self.Attack == 1 and self.AttackTimer <= CurTime() then
		local tr2 = util.TraceLine({
			start = spos,
			endpos = sdest,
			filter = owner,
			mask = MASK_SHOT_HULL,
		})

		if not IsValid(hitEnt) then
			tr2 = util.TraceHull({
				start = spos,
				endpos = sdest,
				filter = owner,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 0),
				mask = MASK_SHOT_HULL,
			})
		end

		if IsValid(tr2.Entity) or tr2.HitWorld and not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr2.HitPos)
			edata:SetNormal(tr2.Normal)
			edata:SetSurfaceProp(tr2.SurfaceProps)
			edata:SetHitBox(tr2.HitBox)
			edata:SetEntity(tr2.Entity)

			if tr2.Entity:IsPlayer() or tr2.Entity:GetClass() == "prop_ragdoll" then
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

			if tr2.Entity:IsNPC() or tr2.Entity:IsPlayer() or tr2.Entity:GetClass() == "prop_ragdoll" then
				self:EmitSound("Weapon_Knife.HitFlesh")
			else
				self:EmitSound("Weapon_Knife.HitWorld")
			end
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
			tr2.Entity:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
			self:TakeAppearance(tr2.Entity)
		end

		self.Attack = 0
	end

	if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			if self.Backstab == 0 then
				vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_idle"))
			end

			if self.Backstab == 1 then
				vm:SendViewModelMatchingSequence(vm:LookupSequence("eternal_backstab_idle"))
			end
		end

		self.Idle = 1
	end

	if owner.LagCompensation then
		owner:LagCompensation(false)
	end
end

if CLIENT then
	function SWEP:ViewModelDrawn(vm)
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		if not IsValid(vm) then return end

		if not IsValid(self.v_model) then
			self.v_model = ClientsideModel("models/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl", RENDERGROUP_VIEWMODEL)
		end

		self.v_model:SetPos(vm:GetPos())
		self.v_model:SetAngles(vm:GetAngles())
		self.v_model:AddEffects(EF_BONEMERGE)
		self.v_model:SetNoDraw(true)
		self.v_model:SetParent(vm)
		self.v_model:DrawModel()
	end

	local w_model = ClientsideModel(SWEP.WorldModel)
	w_model:SetNoDraw(true)
	local offsetvec = Vector(2.596, 0, 0)
	local offsetang = Angle(180, 90, 0)
	local client

	function SWEP:DrawWorldModel(flags)
		if not IsValid(client) then
			client = LocalPlayer()
		end

		local owner = self:GetOwner()
		local spectatedPlayer = client:GetObserverTarget()

		if not IsValid(owner) or (IsValid(spectatedPlayer) and spectatedPlayer == owner) then
			self:DrawModel(flags)

			return
		end

		local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newpos, newang = LocalToWorld(offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles())

		if not IsValid(self.w_model) then
			self.w_model = w_model
		end

		self.w_model:SetPos(newpos)
		self.w_model:SetAngles(newang)
		self.w_model:SetupBones()
		self.w_model:DrawModel()
	end
end
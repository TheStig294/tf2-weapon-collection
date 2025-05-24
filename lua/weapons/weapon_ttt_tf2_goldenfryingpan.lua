SWEP.PrintName = "Golden Frying Pan"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_heavy_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_frying_pan/c_frying_pan.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
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
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Higher DPS than the crowbar!\n\nTurns killed players into gold statues!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_goldfryingpan.png"
end

SWEP.Primary.Sound = Sound("Weapon_FireAxe.Miss")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 48
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128
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
    vm:SendViewModelMatchingSequence(vm:LookupSequence("melee_allclass_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:EmitSound(self.Primary.Sound)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("melee_allclass_swing"))
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.Attack = 1
    self.AttackTimer = CurTime() + 0.2
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
end

local addedBodySearchHook = false

function SWEP:EntToGold(rag)
    if not IsValid(rag) then return end
    rag:EmitSound("weapons/pan/pan_turn_to_gold.wav", 80, 100, 1, CHAN_WEAPON)
    rag:SetMaterial("models/player/shared/gold_player")

    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        rag:ManipulateBoneJiggle(i, 2)
        local phys = rag:GetPhysicsObjectNum(i)

        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end

    if not addedBodySearchHook then
        addedBodySearchHook = true

        if SERVER then
            hook.Add("TTTCanSearchCorpse", "TF2GoldenFryingPanBodySearch", function(p, body)
                if body:GetMaterial() == "models/player/shared/gold_player" then
                    p:ChatPrint("This body cannot be searched, it's solid gold!")

                    return false
                end
            end)

            util.AddNetworkString("TF2GoldenFryingPanPickupGoldWeapon")

            hook.Add("WeaponEquip", "TF2GoldenFryingPanPickupGoldGun", function(wep, owner)
                if IsValid(wep) and wep:GetMaterial() == "models/player/shared/gold_player" then
                    net.Start("TF2GoldenFryingPanPickupGoldWeapon")
                    net.WriteEntity(wep)
                    net.Send(owner)
                end
            end)
        else
            net.Receive("TF2GoldenFryingPanPickupGoldWeapon", function()
                local wep = net.ReadEntity()
                wep:SetMaterial("models/player/shared/gold_player")

                hook.Add("PreDrawViewModel", "TF2GoldenFryingPanGoldWeapon", function(vm, _, vmWeapon)
                    if IsValid(vmWeapon) and IsValid(wep) and vmWeapon == wep then
                        vm:SetMaterial("models/player/shared/gold_player")
                    else
                        vm:SetMaterial("")
                    end
                end)

                hook.Add("TTTPrepareRound", "TF2GoldenFryingPanGoldWeaponReset", function()
                    hook.Remove("PreDrawViewModel", "TF2GoldenFryingPanGoldWeapon")
                    hook.Remove("TTTPrepareRound", "TF2GoldenFryingPanGoldWeaponReset")
                end)
            end)
        end
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Attack == 1 and self.AttackTimer <= CurTime() then
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

        if IsValid(ent) then
            if ent:IsPlayer() and ent:Alive() and not ent:IsSpec() then
                self:EmitSound("FryingPan.HitFlesh")

                timer.Simple(0, function()
                    if not ent:Alive() or ent:IsSpec() then
                        local rag = ent.server_ragdoll or ent:GetRagdollEntity()
                        self:EntToGold(rag)
                    end
                end)
            elseif not ent:IsPlayer() then
                self:EmitSound("FryingPan.HitWorld")
                self:EntToGold(ent)
            end

            if SERVER then
                local attacker = owner

                if not IsValid(attacker) then
                    attacker = self
                end

                local dmg = DamageInfo()
                dmg:SetAttacker(attacker)
                dmg:SetInflictor(self)
                dmg:SetDamage(self.Primary.Damage)
                dmg:SetDamageForce(owner:GetForward() * self.Primary.Force)
                dmg:SetDamageType(DMG_CLUB)
                ent:TakeDamageInfo(dmg)
            end
        end

        self.Attack = 0
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("melee_allclass_idle"))
        end

        self.Idle = 1
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_frying_pan/c_frying_pan.mdl", RENDERGROUP_VIEWMODEL)
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

    function SWEP:DrawWorldModel(flags)
        local owner = self:GetOwner()

        if not IsValid(owner) then
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
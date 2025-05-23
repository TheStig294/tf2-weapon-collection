SWEP.PrintName = "The Escape Plan"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_soldier_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_pickaxe/c_pickaxe.mdl"
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
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_MELEE
SWEP.Slot = 0
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Higher DPS than the crowbar!\n\nYou speed increases as your health decreases!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_escapeplan.png"
end

SWEP.Primary.Sound = Sound("Weapon_PickAxe.Swing")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 48
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 2
SWEP.Primary.Range = 128

SWEP.Primary.Anims = {"s_swing_a", "s_swing_b", "s_swing_c"}

SWEP.MaxSpeedBoost = 1.3
SWEP.CurrentSpeedBoost = 1
SWEP.SpeedBoostActive = false

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("s_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
    self.SpeedBoostActive = true

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:EmitSound(self.Primary.Sound)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence(self.Primary.Anims[math.random(#self.Primary.Anims)]))
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self.Attack = 1
    self.AttackTimer = CurTime() + 0.2
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:ResetSpeed()
    local owner = self.TF2Owner

    if SERVER and self.SpeedBoostActive and IsValid(owner) then
        owner:SetLaggedMovementValue(1)
        self.SpeedBoostActive = false
    end
end

function SWEP:OwnerChanged()
    self:ResetSpeed()
    self.TF2Owner = self:GetOwner()
end

function SWEP:Holster()
    self:ResetSpeed()

    return self.BaseClass.Holster(self)
end

function SWEP:PreDrop()
    self:Holster()

    return self.BaseClass.PreDrop(self)
end

function SWEP:OnRemove()
    self:Holster()

    return self.BaseClass.OnRemove(self)
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

        local victim = tr.Entity

        if not IsValid(victim) then
            tr = util.TraceHull({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
                filter = owner,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 0),
                mask = MASK_SHOT_HULL,
            })
        end

        if SERVER and IsValid(victim) then
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

            if victim:IsPlayer() and victim:Alive() and not victim:IsSpec() then
                owner:EmitSound("Weapon_PickAxe.HitFlesh")

                timer.Simple(0, function()
                    if not victim:Alive() or victim:IsSpec() then
                        owner:EmitSound("player/soldier/kill" .. math.random(3) .. ".wav")
                    end
                end)
            elseif not victim:IsPlayer() then
                owner:EmitSound("Weapon_Shovel.HitWorld")
            end

            victim:TakeDamageInfo(dmg)
        end

        self.Attack = 0
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("s_idle"))
        end

        self.Idle = 1
    end

    if self.SpeedBoostActive then
        local healthFraction = owner:Health() / owner:GetMaxHealth()

        if healthFraction > 1 then
            healthFraction = 1
        end

        self.CurrentSpeedBoost = -self.MaxSpeedBoost * healthFraction + 1 + self.MaxSpeedBoost

        if SERVER then
            owner:SetLaggedMovementValue(self.CurrentSpeedBoost)
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        draw.WordBox(8, 265, ScrH() - 50, "Health Speed: x" .. math.Round(self.CurrentSpeedBoost, 1), "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end

    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_pickaxe/c_pickaxe.mdl", RENDERGROUP_VIEWMODEL)
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
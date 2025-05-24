SWEP.PrintName = "Loose Cannon"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = false

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Fires chargeable cannon balls!\nTime it right and hit a player just as it explodes for double damage!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_grenadelauncher.png"
end

SWEP.Primary.Sound = Sound("weapons/loose_cannon_shoot.wav")
SWEP.Primary.Damage = 60
SWEP.Primary.ExplosionDamage = 40
SWEP.Primary.Radius = 200
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "CombineCannon"
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 3 or 9999
SWEP.Primary.Spread = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.5
SWEP.Primary.ChargeTime = 1
SWEP.ReloadAnimDelay = 1
SWEP.ChargeMult = 1
SWEP.MaxChargeMult = 2
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:SecondaryAttack()
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

function SWEP:Initialize()
    self:ResetAnimations()

    -- Sound effect for hitting a player at the same time as the cannonball exploding!
    hook.Add("EntityTakeDamage", "TF2LooseCannonDoubleDonkSound", function(ent, dmg)
        if not IsValid(ent) or not ent:IsPlayer() or not dmg:IsExplosionDamage() then return end
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) then return end

        if inflictor:GetClass() == "weapon_ttt_tf2_loosecannon" and inflictor.ImpactDamageTime and CurTime() - inflictor.ImpactDamageTime < 0.5 then
            inflictor:EmitSound("player/doubledonk.wav")
        end
    end)

    hook.Add("TTTPrepareRound", "TF2LooseCannonReset", function()
        hook.Remove("EntityTakeDamage", "TF2LooseCannonDoubleDonkSound")
        hook.Remove("TTTPrepareRound", "TF2LooseCannonReset")
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("g_draw"))
    self:ResetAnimations()
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
    vm:SendViewModelMatchingSequence(vm:LookupSequence("g_auto_fire"))
    self:EmitSound("weapons/loose_cannon_charge.wav")
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self.StartReload = false
    self:SetReloading(false)
    self.LastFireTime = CurTime()
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
        self:SetReloadingTimer(CurTime() + 0.3)
    end
end

function SWEP:Overcharge()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SetAttacking(false)
    self:EmitSound("weapons/loose_cannon_explode.wav")
    self:TakePrimaryAmmo(1)
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:ViewPunch(Angle(-1, 0, 0))
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effect, true, true)
    util.BlastDamage(self, owner, self:GetPos(), self.Primary.Radius, self.Primary.ExplosionDamage)
    self:StopParticles()
end

function SWEP:FireCannon()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("g_fire"))
    self:SetAttacking(false)
    self:EmitSound("weapons/loose_cannon_explode.wav")
    self:TakePrimaryAmmo(1)
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:ViewPunch(Angle(-1, 0, 0))
    if CLIENT then return end
    local ent = ents.Create("ttt_tf2_cannonball")
    if not IsValid(ent) then return end
    ent.Weapon = self
    ent.DamageOwner = owner
    ent:SetPos(owner:EyePos() + (owner:GetAimVector() * 16))
    ent:SetAngles(owner:EyeAngles())
    ent.Damage = self.Primary.Damage
    ent.ExplosionDamage = self.Primary.ExplosionDamage
    ent.Radius = self.Primary.Radius
    ent.ExplodeTime = self:GetAttackingTimer()
    ent:Spawn()
    local phys = ent:GetPhysicsObject()

    if not IsValid(phys) then
        ent:Remove()

        return
    end

    local velocity = owner:GetAimVector()
    velocity = velocity * 7000 * self.ChargeMult
    velocity = velocity + (VectorRand() * 10)
    phys:ApplyForceCenter(velocity)
    self:StopParticles()
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
            self:FireCannon()
        end
    elseif self:GetReloading() then
        if not self.StartReload then
            self.StartReload = true
            self.CanReload = false
            vm:SendViewModelMatchingSequence(vm:LookupSequence("g_reload_start"))

            timer.Simple(0.3, function()
                self.CanReload = true
            end)
        end

        if self.CanReload and self:GetReloadingTimer() < CurTime() then
            if self:Clip1() >= self:GetMaxClip1() or owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
                self:ResetAnimations()
                vm:SendViewModelMatchingSequence(vm:LookupSequence("g_reload_end"))
                self:SetReloading(false)

                return
            end

            vm:SendViewModelMatchingSequence(vm:LookupSequence("g_reload_loop"))
            self:SetReloadingTimer(CurTime() + 0.5)
            self:SetIdleTimer(CurTime() + 0.5)
            owner:RemoveAmmo(1, self.Primary.Ammo, false)
            self:SetClip1(self:Clip1() + 1)
        end
    else
        if not self:GetIdle() and self:GetIdleTimer() <= CurTime() then
            if SERVER then
                vm:SendViewModelMatchingSequence(vm:LookupSequence("g_idle"))
            end

            self:SetIdle(true)
        end

        if not self:GetReload() and self:GetReloadTimer() <= CurTime() and self:Clip1() < self:GetMaxClip1() then
            self:Reload()
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Charge: " .. math.Round(self.ChargeMult / 2 * 100, 0) .. "%", "TF2Font", color_black, color_white, TEXT_ALIGN_LEFT)
    end

    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl", RENDERGROUP_VIEWMODEL)
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
    local offsetang = Angle(180, 180, 0)

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
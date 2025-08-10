SWEP.PrintName = "Force-A-Nature"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_scout_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_double_barrel.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
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
        desc = "A double barrel that launches players back!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_scattergun.png"
end

SWEP.Primary.Sound = Sound("weapons/scatter_gun_double_shoot.wav")
SWEP.Primary.Damage = 6
SWEP.Primary.ClipSize = 2
SWEP.Primary.Ammo = "Buckshot"
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.WeaponID = AMMO_SHOTGUN
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 2 or 9999
SWEP.Primary.Spread = 0.3
SWEP.Primary.NumberofShots = 12
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.3125
SWEP.Primary.Force = 250
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.AutoReloadCvar = GetConVar("tf2_weapon_collection_auto_reload")

function SWEP:Initialize()
    TF2WC:SetHoldType(self)

    return self.BaseClass.Initialize(self)
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("db_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Attack = 0
    self.AttackTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
    self.Reloading = 0
    self.ReloadingTimer = CurTime()

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then
        self:Reload()

        return
    end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("db_fire"))
    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(self.Primary.Spread * 0.1, self.Primary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    bullet.Inflictor = self

    bullet.Callback = function(_, tr, _)
        local ent = tr.Entity
        if not IsValid(ent) then return end
        local vel = (ent:GetPos() - owner:GetPos()) * self.Primary.Force / 2
        ent:SetVelocity(vel)
        if not ent:IsPlayer() then return end

        timer.Simple(0, function()
            local rag = ent.server_ragdoll or ent:GetRagdollEntity()
            if not IsValid(rag) then return end

            for i = 0, rag:GetPhysicsObjectCount() - 1 do
                local phys = rag:GetPhysicsObjectNum(i)

                if IsValid(phys) then
                    phys:AddVelocity(vel)
                end
            end
        end)
    end

    owner:FireBullets(bullet)
    owner:MuzzleFlash()
    owner:SetGroundEntity(nil)
    owner:SetVelocity(-owner:GetForward() * self.Primary.Force * 1.5)
    self:ShootEffects()
    self:EmitSound(self.Primary.Sound)
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self.ReloadingTimer = CurTime() + 1
end

function SWEP:Reload()
    if self:Ammo1() <= 0 then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("db_reload"))
    owner:SetAnimation(PLAYER_RELOAD)
    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
    self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
    self.Reloading = 1
    self.ReloadingTimer = CurTime() + vm:SequenceDuration()
    self.Idle = 0
    self.IdleTimer = CurTime() + vm:SequenceDuration()
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("db_idle"))
        end

        self.Idle = 1

        if self.Reloading == 1 then
            local reloadCount = math.min(self.Primary.ClipSize - self:Clip1(), self:Ammo1())
            owner:RemoveAmmo(reloadCount, self:GetPrimaryAmmoType())
            self:SetClip1(self:Clip1() + reloadCount)
            self.Reloading = 0
        end
    end

    if self.Reloading == 0 and self.ReloadingTimer <= CurTime() and self:Clip1() < self:GetMaxClip1() and self.AutoReloadCvar:GetBool() then
        self:Reload()
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_double_barrel.mdl", RENDERGROUP_VIEWMODEL)
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
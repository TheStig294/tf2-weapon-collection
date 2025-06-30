SWEP.PrintName = "Tomislav"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/c_models/c_heavy_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_tomislav/c_tomislav.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 3
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = false
SWEP.IsSilent = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A 200 ammo minigun!\nAmmo cannot be refilled, completely silent and accurate"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_minigun.png"
end

SWEP.Sound = 0
SWEP.Spin = 0
SWEP.SpinTimer = 0
SWEP.Idle = 0
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("weapons/tomislav_shoot.wav")
SWEP.Primary.ClipSize = engine.ActiveGamemode() == "terrortown" and 200 or 9999
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 200 or 9999
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Damage = 12
SWEP.Primary.Spread = 0
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
local SPIN_OFF = 0
local SPIN_UP = 1
local SPIN_SHOOT = 2

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", "ShootSound")
    self:NetworkVar("Int", "Spin")
    self:NetworkVar("Float", "SpinTimer")
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
end

local setHooks = false

function SWEP:Initialize()
    if not setHooks then
        if CR_VERSION then
            hook.Add("TTTSpeedMultiplier", "TF2WCTomislavMovementSpeed", function(ply, mults)
                if not IsValid(ply) then return end
                local wep = ply:GetActiveWeapon()
                if not IsValid(wep) or WEPS.GetClass(wep) ~= "weapon_ttt_tf2_tomislav" then return end

                if wep:GetSpin() == SPIN_UP then
                    table.insert(mults, 0.75)
                elseif wep:GetSpin() == SPIN_SHOOT then
                    table.insert(mults, 0.5)
                end
            end)
        end

        setHooks = true
    end

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("m_draw"))
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:SetShootSound(false)
    self:SetSpin(SPIN_OFF)
    self:SetSpinTimer(CurTime() + 0.5)
    self:SetIdle(false)
    self:SetIdleTimer(CurTime() + vm:SequenceDuration())

    return self.BaseClass.Deploy(self)
end

function SWEP:OwnerChanged()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self.LastOwner = owner
end

function SWEP:Holster()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        owner = self.LastOwner
    end

    self:SetShootSound(false)
    self:SetSpin(SPIN_OFF)
    self:SetSpinTimer(CurTime())
    self:SetIdle(false)
    self:SetIdleTimer(CurTime())
    if not IsValid(owner) then return end

    if SERVER then
        owner:StopSound(self.Primary.Sound)
        owner:StopSound("weapons/tomislav_wind_up.wav")

        if not CR_VERSION then
            owner:SetLaggedMovementValue(1)
        end
    end

    return self.BaseClass.Holster(self)
end

function SWEP:PreDrop()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER and not CR_VERSION then
        owner:SetLaggedMovementValue(1)
    end

    return self.BaseClass.PreDrop(self)
end

function SWEP:OnRemove()
    self:Holster()

    return self.BaseClass.OnRemove(self)
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:GetSpin() == SPIN_OFF and self:GetSpinTimer() <= CurTime() and owner:KeyDown(IN_ATTACK) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/tomislav_wind_up.wav")
        end

        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_up"))
        self:SetSpin(SPIN_UP)
        self:SetSpinTimer(CurTime() + 0.9)
        self:SetIdle(false)
        self:SetIdleTimer(CurTime() + vm:SequenceDuration())
    end

    if self:GetSpin() ~= SPIN_SHOOT then return end
    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(1 * self.Primary.Spread, 1 * self.Primary.Spread, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    bullet.Inflictor = self
    owner:FireBullets(bullet)

    if not self:GetShootSound() then
        if SERVER then
            owner:EmitSound(self.Primary.Sound)
        end

        self:SetShootSound(true)
    end

    vm:SendViewModelMatchingSequence(vm:LookupSequence("m_fire"))
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:MuzzleFlash()
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:SetIdle(true)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if owner:KeyDown(IN_ATTACK) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:GetSpin() == SPIN_OFF and self:GetSpinTimer() <= CurTime() and owner:KeyDown(IN_ATTACK2) and self:Clip1() > 0 then
        if SERVER then
            owner:EmitSound("weapons/tomislav_wind_up.wav")
        end

        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_up"))
        self:SetSpin(SPIN_UP)
        self:SetSpinTimer(CurTime() + 0.9)
        self:SetIdle(false)
        self:SetIdleTimer(CurTime() + vm:SequenceDuration())
    end

    if self:GetSpin() == SPIN_SHOOT then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_idle"))
        self:SetIdle(true)
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:Think()
    self.Primary.Automatic = self:Clip1() > 0
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self.LastOwner = owner
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self:GetSpin() == SPIN_UP and self:GetSpinTimer() <= CurTime() then
        self:SetSpin(SPIN_SHOOT)
    end

    if not CR_VERSION and SERVER then
        if self:GetSpin() == SPIN_UP then
            owner:SetLaggedMovementValue(0.75)
        elseif self:GetSpin() == SPIN_SHOOT then
            owner:SetLaggedMovementValue(0.5)
        else
            owner:SetLaggedMovementValue(1)
        end
    end

    if not owner:KeyDown(IN_ATTACK) then
        if SERVER then
            owner:StopSound(self.Primary.Sound)
            owner:StopSound("Weapon_Minigun.ClipEmpty")
        end

        self:SetShootSound(false)
    end

    if self:GetSpin() == SPIN_SHOOT and ((not owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ATTACK2)) or self:Clip1() <= 0) then
        if SERVER then
            owner:StopSound(self.Primary.Sound)
            owner:EmitSound("weapons/tomislav_wind_down.wav")
        end

        vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_down"))
        self:SetShootSound(false)
        self:SetSpin(SPIN_OFF)
        self:SetSpinTimer(CurTime() + 0.9)
        self:SetIdle(false)
        self:SetIdleTimer(CurTime() + vm:SequenceDuration())
    end

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() then
        if SERVER then
            if self:GetSpin() == SPIN_OFF then
                vm:SendViewModelMatchingSequence(vm:LookupSequence("m_idle"))
            else
                vm:SendViewModelMatchingSequence(vm:LookupSequence("m_spool_idle"))
            end
        end

        self:SetIdle(true)
    end
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_tomislav/c_tomislav.mdl", RENDERGROUP_VIEWMODEL)
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
SWEP.PrintName = "Sticky Jumper"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Alt-Fire: Detonate all stickybombs"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.HoldType = "shotgun"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_EQUIP
SWEP.Slot = engine.ActiveGamemode() == "terrortown" and 6 or 5
SWEP.AutoSpawnable = false
SWEP.Primary.Ammo = "Buckshot"
SWEP.AmmoEnt = "item_box_buckshot_ttt"

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A stickybomb launcher designed to sticky-jump!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_stickybomblauncher.png"
end

SWEP.WeaponID = AMMO_SHOTGUN
SWEP.Primary.Sound = Sound("weapons/sticky_jumper_shoot.wav")
SWEP.Primary.Damage = 90
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = engine.ActiveGamemode() == "terrortown" and 32 or 9999
SWEP.Primary.Spread = 0.05
SWEP.Primary.NumberofShots = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.Force = 2000
SWEP.ReloadTimer = 0
SWEP.Reloading = false
SWEP.StickyQueue = {}
SWEP.MaxStickyCount = SWEP.Primary.ClipSize
SWEP.ReloadAnimDelay = 1
SWEP.ReloadHoldType = "revolver"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    TF2WC:SetHoldType(self)
    self:ResetAnimations()

    hook.Add("EntityTakeDamage", "TF2StickyJumperNoFallDamage", function(ply, dmg)
        if not dmg:IsFallDamage() or not IsValid(ply) or not ply:IsPlayer() then return end
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_ttt_tf2_stickyjumper" then return true end
    end)

    hook.Add("TTTPrepareRound", "TF2StickyJumperReset", function()
        hook.Remove("GetFallDamage", "TF2StickyJumperNoFallDamage")
        hook.Remove("TTTPrepareRound", "TF2StickyJumperReset")
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
end

function SWEP:ResetAnimations()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SetIdle(false)
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    local animDelay = vm:SequenceDuration()
    self:SetIdleTimer(CurTime() + animDelay)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("sb_draw"))
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
    vm:SendViewModelMatchingSequence(vm:LookupSequence("sb_fire"))
    self:ResetAnimations()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self.StartReload = false
    self:TakePrimaryAmmo(1)
    owner:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/sticky_jumper_shoot.wav")

    if SERVER then
        local ent = ents.Create("ttt_tf2_sticky")
        if not IsValid(ent) then return end
        ent.Weapon = self
        ent.StickyOwner = owner
        ent:SetPos(owner:EyePos() + (owner:GetAimVector() * 16))
        ent:SetAngles(owner:EyeAngles())
        ent.Damage = self.Primary.Damage
        ent.SelfDamage = false
        ent.ExplodeSound = "weapons/sticky_jumper_explode1.wav"
        ent.DamageForce = self.Primary.Force
        ent:Spawn()

        if ent.SetPAPCamo then
            ent:SetPAPCamo()
        end

        local phys = ent:GetPhysicsObject()

        if not IsValid(phys) then
            ent:Remove()

            return
        end

        local velocity = owner:GetAimVector()
        velocity = velocity * 7000
        velocity = velocity + (VectorRand() * 10)
        phys:ApplyForceCenter(velocity)
        table.insert(self.StickyQueue, ent)

        if #self.StickyQueue > self.MaxStickyCount then
            local oldestSticky = self.StickyQueue[1]

            if IsValid(oldestSticky) then
                oldestSticky:Remove()
                owner:EmitSound("Weapon_StickyBombLauncher.ModeSwitch")
            end

            table.remove(self.StickyQueue, 1)
        end
    end
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local stickyExploded = false

    for _, sticky in ipairs(self.StickyQueue) do
        if IsValid(sticky) and sticky.Activation then
            sticky:Remove()
            stickyExploded = true
        end
    end

    if stickyExploded then
        owner:EmitSound("Weapon_StickyBombLauncher.ModeSwitch")
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    self:SetClip1(self.Primary.ClipSize)

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() then
        if SERVER then
            vm:SendViewModelMatchingSequence(vm:LookupSequence("sb_idle"))
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
            self.v_model = ClientsideModel("models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl", RENDERGROUP_VIEWMODEL)
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
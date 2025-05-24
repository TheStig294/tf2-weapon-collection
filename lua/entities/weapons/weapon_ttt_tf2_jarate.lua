SWEP.PrintName = "Jarate"
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_sniper_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/urinejar.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.Base = "weapon_tttbasegrenade"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = false

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Throw at players to make them temporarily take more damage!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_smg.png"
end

SWEP.Primary.Sound = Sound("weapons/jar_single.wav")
SWEP.HoldType = "grenade"

function SWEP:GetGrenadeName()
    return "ttt_tf2_jarate_proj"
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("pj_draw"))
    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())

    return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("pj_fire"))
    self:EmitSound(self.Primary.Sound)

    return self.BaseClass.PrimaryAttack(self)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("pj_idle"))
        end

        self.Idle = 1
    end

    return self.BaseClass.Think(self)
end

if CLIENT then
    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/urinejar.mdl", RENDERGROUP_VIEWMODEL)
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
    local offsetvec = Vector(8, -3, 0)
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
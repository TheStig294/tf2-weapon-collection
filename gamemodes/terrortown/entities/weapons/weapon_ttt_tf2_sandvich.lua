SWEP.PrintName = "Sandvich"
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_models/c_heavy_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_sandwich/c_sandwich.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.Base = "weapon_tttbasegrenade"
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Eat to temporarily fully heal!\nRight-click to throw at someone else!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_sandvich.png"
end

SWEP.Primary.Sound = Sound("player/heavy/sandvich_eat.wav")
SWEP.Primary.Delay = 1
SWEP.Secondary.Delay = 0.2
SWEP.HoldType = "grenade"
SWEP.Duration = 15
SWEP.FullHealthPrompt = false

function SWEP:GetGrenadeName()
    return "ttt_tf2_sandvich_proj"
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("sw_draw"))
    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
    self:EmitSound("weapons/draw_machete_sniper.wav")

    return self.BaseClass.Deploy(self)
end

function SWEP:ActivateSandvich(ply)
    ply.TF2SandvichHealth = ply:Health()
    ply.TF2SandvichSeconds = self.Duration

    if ply:Health() < ply:GetMaxHealth() then
        ply:SetHealth(ply:GetMaxHealth())
    end

    self:EmitSound("player/heavy/sandvich" .. math.random(12) .. ".wav")
    local timername = "TF2Sandvich" .. ply:SteamID64()

    timer.Create(timername, 1, self.Duration, function()
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or not ply.TF2SandvichHealth or not ply.TF2SandvichSeconds then
            ply.TF2SandvichHealth = nil
            ply.TF2SandvichSeconds = nil
            timer.Remove(timername)

            return
        end

        if timer.RepsLeft(timername) == 0 then
            if ply.TF2SandvichHealth > ply:Health() then return end
            ply:SetHealth(ply.TF2SandvichHealth)
            ply.TF2SandvichHealth = nil
            ply.TF2SandvichSeconds = nil
        else
            ply.TF2SandvichSeconds = ply.TF2SandvichSeconds - 1
        end
    end)

    if CLIENT then
        local client = LocalPlayer()

        hook.Add("HUDPaintBackground", "TF2SandvichHUDSeconds", function()
            if not client.TF2SandvichSeconds then return end
            draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Sandvich Time: " .. client.TF2SandvichSeconds, "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
        end)
    end

    hook.Add("TTTPrepareRound", "TF2SandvichHealthReset", function()
        for _, p in player.Iterator() do
            p.TF2SandvichHealth = nil
            p.TF2SandvichSeconds = nil
        end

        hook.Remove("TTTPrepareRound", "TF2SandvichHealthReset")
        hook.Remove("HUDPaintBackground", "TF2SandvichHUDSeconds")
    end)
end

function SWEP:PrimaryAttack()
    if self.IsEating then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if owner:Health() >= owner:GetMaxHealth() then
        self.FullHealthPrompt = true

        timer.Simple(5, function()
            if IsValid(self) then
                self.FullHealthPrompt = false
            end
        end)

        return
    end

    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    vm:SendViewModelMatchingSequence(vm:LookupSequence("item1_inspect_start"))
    self:EmitSound(self.Primary.Sound)
    self.IsEating = true

    timer.Simple(self.Primary.Delay, function()
        if not IsValid(self) or not IsValid(owner) then return end
        self:ActivateSandvich(owner)

        if SERVER then
            self:Remove()
        end
    end)
end

function SWEP:SecondaryAttack()
    if self.IsEating then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("throw_fire"))
    self:EmitSound("weapons/jar_single.wav")

    timer.Simple(self.Secondary.Delay, function()
        self.BaseClass.PrimaryAttack(self)
    end)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            vm:SetSequence(vm:LookupSequence("sw_idle"))
        end

        self.Idle = 1
    end

    return self.BaseClass.Think(self)
end

if CLIENT then
    function SWEP:DrawHUD()
        if not self.FullHealthPrompt then return end
        draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Full health, no need for Sandvich!", "TF2Font", COLOR_BLACK, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end

    function SWEP:ViewModelDrawn(vm)
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        if not IsValid(vm) then return end

        if not IsValid(self.v_model) then
            self.v_model = ClientsideModel("models/weapons/c_models/c_sandwich/c_sandwich.mdl", RENDERGROUP_VIEWMODEL)
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
SWEP.PrintName = "Invis Watch"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_watch_spy.mdl"
SWEP.WorldModel = "models/weapons/v_models/v_watch_spy.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 2
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "normal"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_EQUIP2
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.Slot = engine.ActiveGamemode() == "terrortown" and 7 or 5
SWEP.AutoSpawnable = false
SWEP.AllowDrop = false

SWEP.CanBuy = {ROLE_TRAITOR}

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Go invisible for 10 seconds at max charge, and recharges automatically!\n\nCan be activated without being fully charged\n\nCan be manually charged via pistol ammo, press 'R' to reload"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_inviswatch.png"
end

SWEP.CloakCostTimer = 0
SWEP.Cloak = 0
SWEP.CloakTimer = 0
SWEP.Idle = 0
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("player/spy_cloak.wav")
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Delay = 1
SWEP.Secondary.Sound = Sound("player/spy_uncloak.wav")
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 2

function SWEP:Initialize()
    timer.Simple(0, function()
        self:SetHoldType(self.HoldType)
    end)

    return self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.CloakCostTimer = CurTime()
    self.Cloak = 0
    self.CloakTimer = CurTime()
    self.Idle = 0
    self.IdleTimer = CurTime() + 0.3
    vm:SetMaterial("")
    owner:SetMaterial("")
    owner:DrawShadow(true)
    self:SetNWBool("CloakNormalMaterial", true)
    self:SetNWBool("CloakMaterial1", false)
    self:SetNWBool("CloakMaterial2", false)
    self:SetNWBool("CloakMaterial3", false)
    local hookname = "TTTInvisWatch" .. owner:SteamID64()

    hook.Add("Think", hookname, function()
        if not IsValid(owner) or not IsValid(self) or not IsValid(vm) then
            hook.Remove("Think", hookname)

            return
        end

        if self.Cloak == 1 or self.Cloak == 2 then
            if self.CloakCostTimer <= CurTime() then
                self:TakePrimaryAmmo(1)
                self.CloakCostTimer = CurTime() + 0.1
            end

            if self:Clip1() <= 0 then
                self:EmitSound(self.Secondary.Sound, 85, 100, 1, CHAN_STATIC)
                self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
                self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
                self.Cloak = 3
                self.CloakTimer = CurTime() + self.Secondary.Delay
                self.Idle = 1
                owner:SetMaterial("models/props_c17/fisheyelens")
                self:SetNWBool("CloakNormalMaterial", false)
                self:SetNWBool("CloakMaterial1", false)
                self:SetNWBool("CloakMaterial2", true)
                self:SetNWBool("CloakMaterial3", false)
            end
        end

        if self:Clip1() < 100 and not (self.Cloak == 2) and self.CloakCostTimer <= CurTime() then
            self:SetClip1(self:Clip1() + 1)
            self.CloakCostTimer = CurTime() + 0.3
        end

        if self:GetNWBool("CloakNormalMaterial", true) then
            vm:SetMaterial("")
        end

        if self:GetNWBool("CloakMaterial1", true) then
            vm:SetMaterial("models/player/spy/cloak_1")
        end

        if self:GetNWBool("CloakMaterial2", true) then
            vm:SetMaterial("models/player/spy/cloak_2")
        end

        if self:GetNWBool("CloakMaterial3", true) then
            vm:SetMaterial("models/player/spy/cloak_3")
        end

        if self.Cloak == 1 then
            if self.CloakTimer <= CurTime() + 1 and self.CloakTimer > CurTime() + 0.5 then
                owner:SetMaterial("models/player/spy/cloak_1")
                self:SetNWBool("CloakNormalMaterial", false)
                self:SetNWBool("CloakMaterial1", true)
                self:SetNWBool("CloakMaterial2", false)
                self:SetNWBool("CloakMaterial3", false)
            end

            if self.CloakTimer <= CurTime() + 0.5 and self.CloakTimer > CurTime() then
                owner:SetMaterial("models/player/spy/cloak_2")
                self:SetNWBool("CloakNormalMaterial", false)
                self:SetNWBool("CloakMaterial1", false)
                self:SetNWBool("CloakMaterial2", true)
                self:SetNWBool("CloakMaterial3", false)
            end

            if self.CloakTimer <= CurTime() then
                owner:SetMaterial("models/player/spy/cloak_3")
                self:SetNWBool("CloakNormalMaterial", false)
                self:SetNWBool("CloakMaterial1", false)
                self:SetNWBool("CloakMaterial2", false)
                self:SetNWBool("CloakMaterial3", true)
            end
        end

        if self.Cloak == 3 then
            if self.CloakTimer <= CurTime() + 2 and self.CloakTimer > CurTime() + 1 then
                owner:SetMaterial("models/player/spy/cloak_2")
                self:SetNWBool("CloakNormalMaterial", false)
                self:SetNWBool("CloakMaterial1", false)
                self:SetNWBool("CloakMaterial2", true)
                self:SetNWBool("CloakMaterial3", false)
            end

            if self.CloakTimer <= CurTime() + 1 and self.CloakTimer > CurTime() then
                owner:SetMaterial("models/player/spy/cloak_1")
                self:SetNWBool("CloakNormalMaterial", false)
                self:SetNWBool("CloakMaterial1", true)
                self:SetNWBool("CloakMaterial2", false)
                self:SetNWBool("CloakMaterial3", false)
            end

            if self.CloakTimer <= CurTime() then
                owner:SetMaterial("")
                owner:DrawShadow(true)
                self:SetNWBool("CloakNormalMaterial", true)
                self:SetNWBool("CloakMaterial1", false)
                self:SetNWBool("CloakMaterial2", false)
                self:SetNWBool("CloakMaterial3", false)
            end
        end

        if self.CloakTimer <= CurTime() then
            if self.Cloak == 1 then
                self.Cloak = 2
            end

            if self.Cloak == 3 then
                self.Cloak = 0
            end
        end

        if self.Idle == 0 and self.IdleTimer <= CurTime() then
            if SERVER then
                self:SendWeaponAnim(ACT_VM_IDLE)
            end

            self.Idle = 1
        end
    end)

    return self.BaseClass.Deploy(self)
end

function SWEP:OnRemove()
    self:Holster()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    if self.Cloak ~= 0 then
        self:EmitSound(self.Secondary.Sound, 85, 100, 1, CHAN_STATIC)
    end

    self.CloakCostTimer = CurTime()
    self.Cloak = 0
    self.CloakTimer = CurTime()
    vm:SetMaterial("")
    owner:SetMaterial("")
    owner:DrawShadow(true)
    self:SetNWBool("CloakNormalMaterial", true)
    self:SetNWBool("CloakMaterial1", false)
    self:SetNWBool("CloakMaterial2", false)
    self:SetNWBool("CloakMaterial3", false)
end

function SWEP:PreDrop()
    self:Remove()
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:DrawWorldModel(flags)
    if not IsValid(self:GetOwner()) then
        self:DrawModel(flags)
    end
end

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end

    if self.CloakTimer <= CurTime() then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local vm = owner:GetViewModel()
        if not IsValid(vm) then return end

        if self.Cloak == 0 then
            self:EmitSound(self.Primary.Sound, 85, 100, 1, CHAN_STATIC)
            self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
            self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
            self.Cloak = 1
            self.CloakTimer = CurTime() + self.Primary.Delay
            self.Idle = 0
            self.IdleTimer = CurTime() + vm:SequenceDuration()
            owner:SetMaterial("models/shadertest/predator")
            owner:DrawShadow(false)
            self:SetNWBool("CloakNormalMaterial", false)
            self:SetNWBool("CloakMaterial1", true)
            self:SetNWBool("CloakMaterial2", false)
            self:SetNWBool("CloakMaterial3", false)
        end

        if self.Cloak == 2 then
            self:EmitSound(self.Secondary.Sound, 85, 100, 1, CHAN_STATIC)
            self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
            self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
            self.Cloak = 3
            self.CloakTimer = CurTime() + self.Secondary.Delay
            self.Idle = 1
            owner:SetMaterial("models/props_c17/fisheyelens")
            self:SetNWBool("CloakNormalMaterial", false)
            self:SetNWBool("CloakMaterial1", false)
            self:SetNWBool("CloakMaterial2", true)
            self:SetNWBool("CloakMaterial3", false)
        end
    end
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end
SWEP.PrintName = "TF2 Sniper"
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_sniperrifle_sniper.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_sniperrifle.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 3
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "ar2"
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_HEAVY
SWEP.Slot = 2
SWEP.AutoSpawnable = true

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "A powerful sniper rifle!\n\nScope-in with right-click,\nand stay scoped-in to charge up a higher damage shot!\n\nDeals 50 damage unscoped, up to 80 scoped-in!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_sniper.png"
end

SWEP.Scoped = false
SWEP.ScopedTimer = 0
SWEP.Idle = false
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("weapons/sniper_shoot.wav")
SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SniperRound"
SWEP.Primary.Damage = 50
SWEP.Primary.FullChargeDamage = 80
SWEP.Primary.DamageOG = SWEP.Primary.Damage
SWEP.Primary.Spread = 0
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Delay = 1.5
SWEP.Primary.Force = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.25
SWEP.ScopedLaserAlpha = 0
SWEP.ScopedAlpha = 0
SWEP.MouseSensitivity = 1
SWEP.HasScoped = false
SWEP.ChargeHudOffset = 10
SWEP.RedDotSprite = nil

function SWEP:Initialize()
    self.IdleTimer = CurTime() + 1

    if SERVER then
        self.RedDotSprite = ents.Create("env_sprite")
        self.RedDotSprite:SetKeyValue("model", "sprites/laserdot.vmt")
        self.RedDotSprite:SetKeyValue("rendermode", "9")
        self.RedDotSprite:SetKeyValue("scale", "0.25")
        self.RedDotSprite:Spawn()
        self.RedDotSprite:Fire("HideSprite")
    end

    return self.BaseClass.Initialize(self)
end

function SWEP:DrawHUD()
    if self.Scoped then
        local x, y
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        if owner == LocalPlayer() and owner:ShouldDrawLocalPlayer() then
            local tr = util.GetPlayerTrace(owner)
            local trace = util.TraceLine(tr)
            local coords = trace.HitPos:ToScreen()
            x, y = coords.x, coords.y
        else
            x, y = ScrW() / 2, ScrH() / 2
        end

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetTexture(surface.GetTextureID("hud/scope_sniper_ll"))
        surface.DrawTexturedRect(x - ScrH() / 1.5, y - 0, ScrH() / 1.5, ScrH() / 2)
        surface.SetTexture(surface.GetTextureID("hud/scope_sniper_lr"))
        surface.DrawTexturedRect(x - 0, y - 0, ScrH() / 1.5, ScrH() / 2)
        surface.SetTexture(surface.GetTextureID("hud/scope_sniper_ul"))
        surface.DrawTexturedRect(x - ScrH() / 1.5, y - ScrH() / 2, ScrH() / 1.5, ScrH() / 2)
        surface.SetTexture(surface.GetTextureID("hud/scope_sniper_ur"))
        surface.DrawTexturedRect(x - 0, y - ScrH() / 2, ScrH() / 1.5, ScrH() / 2)
        surface.SetTexture(surface.GetTextureID("hud/black"))
        surface.DrawTexturedRect(x - ScrW() / 2, y - ScrH() / 2, ScrW() / 2 - ScrH() / 2, ScrH())
        surface.SetTexture(surface.GetTextureID("hud/black"))
        surface.DrawTexturedRect(x - -ScrH() / 2, y - ScrH() / 2, ScrW() / 2 - ScrH() / 2, ScrH())
        surface.SetTexture(surface.GetTextureID("sprites/redglow1"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x - 32, y - 32, 64, 64)
        draw.SimpleText("Damage: " .. math.Round((self.Primary.Damage / self.Primary.FullChargeDamage) * 100) .. "%", "HealthAmmo", ScrW() / 2, self.ChargeHudOffset, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    else
        return self.BaseClass.DrawHUD(self)
    end
end

function SWEP:AdjustMouseSensitivity()
    return self.MouseSensitivity or 1
end

function SWEP:SetScope(doScope)
    local owner = self:GetOwner()
    self.Scoped = doScope

    if doScope then
        self.ScopedTimer = CurTime() + 3
        self.MouseSensitivity = 0.2

        if IsValid(owner) then
            owner:SetFOV(owner:GetFOV() / 5, 0.1)
        end
    else
        self.ScopedTimer = CurTime()
        self.MouseSensitivity = 1

        if IsValid(owner) then
            owner:SetFOV(0, 0.1)
        end
    end
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SetWeaponHoldType(self.HoldType)
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Idle = false
    self.IdleTimer = CurTime() + owner:GetViewModel():SequenceDuration()
    self:SetScope(false)

    return self.BaseClass.Deploy(self)
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self.Idle = false
    self.IdleTimer = CurTime()
    self.HasScoped = false
    self:SetScope(false)

    return self.BaseClass.Holster(self)
end

function SWEP:PreDrop()
    self:Holster()

    return self.BaseClass.PreDrop(self)
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self:Clip1() <= 0 then
        self:EmitSound("Weapon_SniperRifle.ClipEmpty")
        self:SetNextPrimaryFire(CurTime() + 0.2)
        self:SetNextSecondaryFire(CurTime() + 0.2)
    end

    if self:Clip1() <= 0 then return end
    local bullet = {}
    bullet.Num = self.Primary.NumberofShots
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(1 * self.Primary.Spread, 1 * self.Primary.Spread, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = self.Primary.Ammo
    owner:FireBullets(bullet)

    if SERVER then
        owner:EmitSound(self.Primary.Sound, 94, 100, 1, CHAN_WEAPON)
    end

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:MuzzleFlash()
    self:TakePrimaryAmmo(self.Primary.TakeAmmo)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    local shootAnimationLength = owner:GetViewModel():SequenceDuration()
    self.Idle = false
    self.IdleTimer = CurTime() + shootAnimationLength

    if self.Scoped then
        self:SetScope(false)

        timer.Simple(shootAnimationLength, function()
            if not IsValid(self) or not IsValid(owner) or not self.HasScoped then return end
            local activeWep = owner:GetActiveWeapon()

            if IsValid(activeWep) and activeWep == self then
                self:SetScope(true)
            end
        end)
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    self.HasScoped = true
    self:SetScope(not self.Scoped)
end

function SWEP:Reload()
end

function SWEP:Think()
    local owner = self:GetOwner()

    if self.Scoped then
        if self.ScopedTimer > CurTime() then
            self.Primary.Damage = (1.5 / (self.ScopedTimer - CurTime() + 1.5)) * self.Primary.FullChargeDamage

            if SERVER then
                self.ScopedLaserAlpha = (1 / (self.ScopedTimer - CurTime() + 1)) * 255
            end
        end

        if CLIENT and self.ScopedTimer < CurTime() + 0.025 and self.ScopedTimer > CurTime() and IsValid(owner) then
            owner:EmitSound("player/recharged.wav", SNDLVL_75dB, PITCH_NORM, VOL_NORM, CHAN_STATIC)
        end

        if self.ScopedTimer <= CurTime() then
            self.Primary.Damage = self.Primary.FullChargeDamage
            self.ScopedLaserAlpha = 255
        end
    else
        self.Primary.Damage = self.Primary.DamageOG
    end

    if SERVER and IsValid(self.RedDotSprite) then
        if self.Scoped then
            self.RedDotSprite:Fire("ShowSprite")
            self.RedDotSprite:SetPos(owner:GetEyeTrace().HitPos)
        else
            self.RedDotSprite:Fire("HideSprite")
        end
    end

    if not self.Idle and self.IdleTimer <= CurTime() then
        if SERVER then
            self:SendWeaponAnim(ACT_VM_IDLE)
        end

        self.Idle = true
    end
end
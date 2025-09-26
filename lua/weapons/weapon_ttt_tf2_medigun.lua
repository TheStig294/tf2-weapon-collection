SWEP.PrintName = "Medi Gun"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Team Fortress 2"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.ViewModelFOV = 65
SWEP.ViewModel = "models/weapons/v_models/v_medigun_medic.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_medigun.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 3
SWEP.SlotPos = 0
SWEP.UseHands = false
SWEP.HoldType = "shotgun"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = engine.ActiveGamemode() == "terrortown" and "weapon_tttbase" or "weapon_base"
SWEP.Kind = WEAPON_EQUIP2
SWEP.Slot = 7
SWEP.SandboxSlot = 4
SWEP.AutoSpawnable = false
SWEP.LimitedStock = true

SWEP.CanBuy = {ROLE_DETECTIVE}

if CLIENT then
    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Ranged healing! Heals up to 100 HP, can over-heal up to 150\n\nAfter using all ammo, right-click to activate invincibility for 8 seconds,\nfor you and your healing target!"
    }

    SWEP.Icon = "vgui/ttt/weapon_ttt_tf2_medigun.png"
    SWEP.Instructions = SWEP.EquipMenuData.desc
end

SWEP.Uber = false
SWEP.UberTimer = 0
SWEP.Attack = false
SWEP.AttackTimer = 0
SWEP.Idle = false
SWEP.IdleTimer = 0
SWEP.Primary.Sound = Sound("WeaponMedigun.Healing")
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Thumper"
SWEP.Primary.Delay = 0.1
SWEP.Primary.AmmoDelay = 0.1
SWEP.Primary.HealDelay = 0.1
SWEP.Primary.NoTargetDelay = 0.8
SWEP.Primary.Range = 450
SWEP.Primary.RangeSquared = SWEP.Primary.Range * SWEP.Primary.Range
SWEP.Primary.Overheal = 50
SWEP.Secondary.Sound = Sound("WeaponMedigun.Charged")
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.UsedUber = false
SWEP.PlayedChargedSound = false
SWEP.ShowUberEffects = false
SWEP.ShowUberTargetEffects = false
SWEP.TargetPositionForgiveness = 100

function SWEP:Initialize()
    TF2WC:SandboxSetup(self)
    self.IdleTimer = CurTime() + 1

    return self.BaseClass.Initialize(self)
end

function SWEP:DrawHUD()
    if CLIENT then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local x, y

        if owner == LocalPlayer() and owner:ShouldDrawLocalPlayer() then
            local tr = util.GetPlayerTrace(owner)
            local trace = util.TraceLine(tr)
            local coords = trace.HitPos:ToScreen()
            x, y = coords.x, coords.y
        else
            x, y = ScrW() / 2, ScrH() / 2
        end

        surface.SetTexture(surface.GetTextureID("sprites/crosshair_4"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x - 16, y - 16, 32, 32)
    end
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self.Uber = false
    self.UberTimer = CurTime()
    self.Attack = false
    self.AttackTimer = CurTime()
    self.Idle = false
    local vm = owner:GetViewModel()

    if IsValid(vm) then
        self.IdleTimer = CurTime() + vm:SequenceDuration()
        vm:SetMaterial("")
    end

    owner:SetMaterial("")

    if IsValid(self.Target) then
        self.Target:SetMaterial("")
    end

    self.ShowUberEffects = false
    self.ShowUberTargetEffects = false

    return self.BaseClass.Deploy(self)
end

function SWEP:SetInvulnerable(ply, makeInvulnerable)
    if CLIENT or not IsValid(ply) then return end

    if ply.SetInvulnerable then
        ply:SetInvulnerable(makeInvulnerable, true)
    elseif makeInvulnerable then
        ply:GodEnable()
    else
        ply:GodDisable()
    end
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

    self:StopSound(self.Primary.Sound)
    if not IsValid(owner) then return end

    if SERVER then
        owner:StopSound(self.Secondary.Sound)
    end

    if self.Uber then
        self:SetInvulnerable(self.Target, false)
        self:SetInvulnerable(owner, false)
    end

    if SERVER and self.Attack then
        self.Beam:Fire("kill", "", 0)
    end

    self.Uber = false
    self.UberTimer = CurTime()
    self.Attack = false
    self.AttackTimer = CurTime()
    self.Idle = false
    self.IdleTimer = CurTime()
    owner:SetMaterial("")
    local vm = owner:GetViewModel()

    if IsValid(vm) then
        vm:SetMaterial("")
    end

    if IsValid(self.Target) then
        self.Target:SetMaterial("")
    end

    owner:ConCommand("pp_mat_overlay 0")
    self.ShowUberEffects = false
    self.ShowUberTargetEffects = false

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

function SWEP:PrimaryAttack()
    if self.UsedUber and self:Clip1() <= 0 then
        self:SetNextPrimaryFire(CurTime() + self.Primary.NoTargetDelay)
        self:SetNextSecondaryFire(CurTime() + self.Primary.NoTargetDelay)

        if CLIENT then
            self:EmitSound("WeaponMedigun.NoTarget")
        end

        return
    end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
        filter = owner,
        mask = MASK_SHOT_HULL,
    })

    if not IsValid(tr.Entity) then
        tr = util.TraceHull({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range,
            filter = owner,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 0),
            mask = MASK_SHOT_HULL,
        })
    end

    if not self.Attack then
        if self:IsTargetBehindWall(true) or not (tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer())) or tr.Entity:Health() <= 0 then
            if CLIENT then
                self:EmitSound("WeaponMedigun.NoTarget")
            end

            self:SetNextPrimaryFire(CurTime() + self.Primary.NoTargetDelay)
            self:SetNextSecondaryFire(CurTime() + self.Primary.NoTargetDelay)
        else
            if SERVER then
                local beam = ents.Create("info_particle_system")
                beam:SetKeyValue("effect_name", "medicgun_beam_red")
                beam:SetOwner(owner)
                local Forward = owner:EyeAngles():Forward()
                local Right = owner:EyeAngles():Right()
                local Up = owner:EyeAngles():Up()
                beam:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
                beam:SetAngles(owner:EyeAngles())
                local beamtarget = ents.Create("ttt_tf2_target_medigun")
                beamtarget:SetOwner(owner)
                beamtarget:SetPos(tr.Entity:GetPos() + Vector(0, 0, 50))
                beamtarget:Spawn()
                beam:SetKeyValue("cpoint1", beamtarget:GetName())
                beam:Spawn()
                beam:Activate()
                beam:Fire("start", "", 0)
                self.Beam = beam
                self.BeamTarget = beamtarget
            end

            self:EmitSound(self.Primary.Sound)
            owner:SetAnimation(PLAYER_ATTACK1)
            self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
            self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
            self.Target = tr.Entity

            if self.Uber then
                self:SetInvulnerable(self.Target, true)
                self.ShowUberTargetEffects = true
            end

            self.Attack = true
            self.AttackTimer = CurTime()
            self.Idle = false
            self.IdleTimer = CurTime()
        end
    end
end

function SWEP:SecondaryAttack()
    if self.UsedUber then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self:Clip1() <= 0 and not self.Uber then
        self:SetClip1(self:GetMaxClip1())
        self.UsedUber = true

        if SERVER then
            owner:EmitSound(self.Secondary.Sound)
        end

        self:SetInvulnerable(owner, true)

        if self.Attack then
            self:SetInvulnerable(self.Target, true)
        end

        self.Uber = true
        owner:ConCommand("pp_mat_overlay effects/invuln_overlay_red")
        self.ShowUberEffects = true

        if self.Attack then
            self.ShowUberTargetEffects = true
        end
    end
end

function SWEP:IsTargetBehindWall(ignoreTarget)
    local owner = self:GetOwner()
    if not IsValid(owner) then return not ignoreTarget end
    if not IsValid(self.Target) then return not ignoreTarget end
    local targetPos = self.Target:GetPos()

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = targetPos,
        filter = owner,
        mask = MASK_SOLID_BRUSHONLY
    })

    -- Avert your eyes...
    -- All this is supposed to do is check if the target's current position is within an allowable range
    -- Because the target pos on server/client can be different due to lag/prediction
    -- Thus, if the HitPos is different, we don't necessarily have a player behind a wall
    local xMin = tr.HitPos.x - self.TargetPositionForgiveness
    local xMax = tr.HitPos.x + self.TargetPositionForgiveness
    local yMin = tr.HitPos.y - self.TargetPositionForgiveness
    local yMax = tr.HitPos.y + self.TargetPositionForgiveness
    local zMin = tr.HitPos.z - self.TargetPositionForgiveness
    local zMax = tr.HitPos.z + self.TargetPositionForgiveness
    local withinX = xMin < targetPos.x and xMax > targetPos.x
    local withinY = yMin < targetPos.y and yMax > targetPos.y
    local withinZ = zMin < targetPos.z and zMax > targetPos.z

    return not (withinX and withinY and withinZ)
end

function SWEP:IsTargetTooFar()
    local owner = self:GetOwner()
    if not IsValid(owner) then return true end
    if not IsValid(self.Target) then return true end
    local targetPos = self.Target:GetPos()
    local ownerPos = owner:GetPos()

    return ownerPos:DistToSqr(targetPos) > self.Primary.RangeSquared
end

function SWEP:ShouldDisableBeam()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    if self.UsedUber and self:Clip1() <= 0 then return true end
    if not IsValid(self.Target) or self.Target:Health() <= 0 or not owner:KeyDown(IN_ATTACK) then return true end
    if self:IsTargetBehindWall() or self:IsTargetTooFar() then return true end

    return false
end

function SWEP:UberChargeReady()
    return not self.UsedUber and self:Clip1() <= 0 and IsValid(self.Target)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self.ShowUberEffects then
        owner:SetMaterial("effects/invun_red")
        local vm = owner:GetViewModel()

        if IsValid(vm) then
            vm:SetMaterial("effects/invun_red")
        end
    else
        owner:SetMaterial("")
        local vm = owner:GetViewModel()

        if IsValid(vm) then
            vm:SetMaterial("")
        end
    end

    if IsValid(self.Target) then
        if self.ShowUberTargetEffects then
            self.Target:SetMaterial("effects/invun_red")
        else
            self.Target:SetMaterial("")
        end
    end

    if SERVER and self:UberChargeReady() and not self.PlayedChargedSound then
        owner:EmitSound("player/medic_charge_ready" .. math.random(2) .. ".wav")
        self.PlayedChargedSound = true
    end

    if self.Uber then
        if self:Clip1() > 0 and self.UberTimer <= CurTime() then
            self:TakePrimaryAmmo(1)
            self.UberTimer = CurTime() + 0.08
        end

        if self:Clip1() <= 0 then
            if SERVER then
                owner:StopSound(self.Secondary.Sound)
            end

            self:SetInvulnerable(owner, false)
            self:SetInvulnerable(self.Target, false)
            self.Uber = false
            owner:SetMaterial("")
            local vm = owner:GetViewModel()

            if IsValid(vm) then
                vm:SetMaterial("")
            end

            if IsValid(self.Target) then
                self.Target:SetMaterial("")
            end

            owner:ConCommand("pp_mat_overlay 0")
            self.ShowUberEffects = false
            self.ShowUberTargetEffects = false
        end
    end

    if IsValid(self.Target) and self.Target:Health() > 0 and self.Attack then
        if self.AttackTimer <= CurTime() then
            if SERVER then
                local Forward = owner:EyeAngles():Forward()
                local Right = owner:EyeAngles():Right()
                local Up = owner:EyeAngles():Up()
                self.Beam:SetPos(owner:GetShootPos() + Forward * 24 + Right * 8 + Up * -6)
                self.Beam:SetAngles(owner:EyeAngles())
                self.BeamTarget:SetPos(self.Target:GetPos() + Vector(0, 0, 50))
            end

            if self:Clip1() > 0 and not self.Uber and self.Target:Health() < self.Target:GetMaxHealth() + self.Primary.Overheal then
                self.Target:SetHealth(self.Target:Health() + 1)
            end

            self.AttackTimer = CurTime() + self.Primary.HealDelay
        end

        if not self.Uber and self.UberTimer <= CurTime() then
            self:TakePrimaryAmmo(1)
            self.UberTimer = CurTime() + self.Primary.AmmoDelay
        end
    end

    if self.Attack and self:ShouldDisableBeam() then
        if SERVER then
            self.Beam:Fire("kill", "", 0)
            self.BeamTarget:Remove()
        end

        self:StopSound(self.Primary.Sound)

        if self.Uber then
            self:SetInvulnerable(self.Target, false)
            self.ShowUberTargetEffects = false
        end

        owner:SetAnimation(PLAYER_ATTACK1)
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
        self.Attack = false
        self.AttackTimer = CurTime()
        self.Idle = false
        self.IdleTimer = CurTime()
    end

    if not self.Idle and self.IdleTimer <= CurTime() then
        if SERVER then
            if not self.Attack then
                self:SendWeaponAnim(ACT_VM_IDLE)
            end

            if self.Attack then
                self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
            end
        end

        self.Idle = true
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        if self:UberChargeReady() then
            draw.WordBox(8, TF2WC:GetXHUDOffset(), ScrH() - 50, "Right-Click for ÜberCharge", "TF2Font", color_black, color_white, TEXT_ALIGN_LEFT)
        end
    end
end
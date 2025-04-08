AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "TF2 sentry"
ENT.Category = "TF2"
ENT.Damage = 10
ENT.Force = 100
ENT.AmmoType = "AirboatGun"
ENT.Tracer = "AirboatGunTracer"
ENT.Spread = 0.2
ENT.Delay = 0.2
ENT.Angle = 45
ENT.Range = 500
ENT.Range = ENT.Range * ENT.Range
ENT.SearchDelay = 0.5
ENT.Accuracy = 0.3
ENT.BeepTime = 3.57

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
    self:NetworkVar("Bool", "FullyPlaced")
    self:NetworkVar("Entity", "Target")
    self:NetworkVar("Bool", "Attacking")
    self:NetworkVar("Float", "NextFire")
    self:NetworkVar("Angle", "OriginalAngles")
    self:NetworkVar("Float", "BeepTimer")
end

function ENT:Initialize()
    self:SetModel("models/buildables/sentry1_heavy.mdl")
    self:ResetSequence("build")
    self:SetPlaybackRate(0.5)
    self:SetIdle(false)
    self:SetIdleTimer(CurTime() + 5 * 1 / self:GetPlaybackRate())
    self:SetFullyPlaced(false)
    self:SetTarget(NULL)
    self:SetAttacking(false)
    self:SetNextFire(CurTime())
    self:SetOriginalAngles(self:GetAngles())
    self:SetBeepTimer(CurTime())
end

function ENT:IsValidTarget(target)
    if CLIENT then return IsValid(self:GetTarget()) end
    target = target or self:GetTarget()
    local owner = self:GetOwner()
    if not IsValid(target) or not target:IsPlayer() or not target:Alive() or target:IsSpec() or (IsValid(owner) and owner == target) then return false end

    return self:Visible(target) and target:GetPos():DistToSqr(self:GetPos()) < self.Range
end

function ENT:Think()
    self:NextThink(CurTime())

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() and not self:GetFullyPlaced() then
        self:SetModel("models/buildables/sentry1.mdl")
        self:SetFullyPlaced(true)
        self:ResetSequence("aim_nat")
        self:SetIdle(true)
        self:EmitSound("weapons/sentry_scan.wav", 80, 100, 1, CHAN_ITEM)
        self:SetBeepTimer(CurTime() + self.BeepTime)
    end

    if self:GetFullyPlaced() then
        if self:GetIdle() then
            self:FindTarget()
        elseif self:IsValidTarget() then
            self:Attack()
        else
            self:Reset()
        end
    end

    return true
end

function ENT:FindTarget()
    if self:GetIdleTimer() > CurTime() then return end
    self:SetIdleTimer(CurTime() + self.SearchDelay)

    if self:GetBeepTimer() < CurTime() then
        self:EmitSound("weapons/sentry_scan.wav", 80, 100, 1, CHAN_ITEM)
        self:SetBeepTimer(CurTime() + self.BeepTime)
        self:ResetSequence("aim_nat")
    end

    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Range)) do
        if self:IsValidTarget(ent) then
            self:SetTarget(ent)
            self:SetIdle(false)
            self:EmitSound("weapons/sentry_spot.wav", 80, 100, 1, CHAN_ITEM)
        end
    end
end

local angleOffset = Angle(0, 90, 80)

function ENT:Attack()
    local target = self:GetTarget()

    if not self:GetAttacking() then
        self:ResetSequence("fire")
        self:GetAttacking(true)
    end

    if SERVER then
        self:PointAtEntity(target)
    end

    if self:GetNextFire() <= CurTime() then
        local bullet = {}
        bullet.Attacker = self:GetOwner() or self
        bullet.Inflictor = self
        bullet.Src = self:GetPos()
        bullet.Dir = self:GetForward()
        bullet.Spread = Vector(1 * self.Spread, 1 * self.Spread, 0)
        bullet.Force = self.Force
        bullet.Damage = self.Damage
        bullet.AmmoType = self.AmmoType
        bullet.TracerName = self.Tracer
        bullet.Num = 5
        self:FireBullets(bullet)
        self:SetNextFire(CurTime() + self.Delay)
        self:EmitSound("weapons/sentry_shoot.wav", 80, 100, 1, CHAN_WEAPON)
        -- For some reason, traces don't seem to work when fired from this entity, including bullet traces...
        -- So, we have to manually damage the target here, all bullets shot are just for effect
        local randomNum = math.random()

        if SERVER and randomNum < self.Accuracy then
            local dmg = DamageInfo()
            dmg:SetDamage(self.Damage)
            dmg:SetDamageType(DMG_BULLET)
            dmg:SetInflictor(self)
            local owner = self:GetOwner()

            if not IsValid(owner) then
                owner = self
            end

            dmg:SetAttacker(owner)
            target:TakeDamageInfo(dmg)
        end
    end

    if SERVER then
        self:SetAngles(self:GetAngles() + angleOffset)
    end
end

function ENT:Reset()
    self:ResetSequence("aim_nat")
    self:SetAttacking(false)
    self:SetTarget(NULL)
    self:SetIdle(true)
    self:SetAngles(self:GetOriginalAngles())
    self:EmitSound("weapons/sentry_scan.wav", 80, 100, 1, CHAN_ITEM)
    self:SetBeepTimer(CurTime() + self.BeepTime)
end
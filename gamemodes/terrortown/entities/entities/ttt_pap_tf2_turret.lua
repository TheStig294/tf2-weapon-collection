AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "TF2 Turret"
ENT.Category = "TF2"
ENT.Damage = 60
ENT.Force = 100
ENT.AmmoType = "AirboatGun"
ENT.Tracer = "AirboatGunTracer"
ENT.Spread = 0
ENT.Delay = 0.5

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
    self:NetworkVar("Bool", "FullyPlaced")
    self:NetworkVar("Entity", "Target")
    self:NetworkVar("Bool", "Attacking")
    self:NetworkVar("Float", "NextFire")
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
end

function ENT:IsValidTarget(target)
    if not IsValid(target) or not target:IsPlayer() or not target:Alive() or target:IsSpec() then return false end
    local trace = {}
    trace.start = self:GetPos()
    trace.endpos = target:GetPos()
    trace.mask = MASK_SHOT
    trace.filter = self
    local tr = util.TraceLine(trace)
    local hitEnt = tr.Entity

    return IsValid(hitEnt) and hitEnt == target
end

function ENT:Think()
    self:NextThink(CurTime())

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() and not self:GetFullyPlaced() then
        self:SetModel("models/buildables/sentry1.mdl")
        self:SetFullyPlaced(true)
        -- self:ResetSequence("disabled")
        self:SetIdle(true)
    end

    if self:GetFullyPlaced() then
        -- print("IsIdle:", self:GetIdle())
        if self:GetIdle() then
            self:FindTarget()
        elseif self:IsValidTarget(self:GetTarget()) then
            self:Attack()
        end
        -- else
        --     self:Reset()
    end

    return true
end

function ENT:FindTarget()
    for _, ent in ipairs(ents.FindInCone(self:GetPos(), self:GetForward(), 1000, math.cos(math.rad(45)))) do
        if self:IsValidTarget(ent) then
            -- self:GetOwner():ChatPrint(tostring(ent))
            self:SetTarget(ent)
            self:SetIdle(false)
        end
    end
end

local angleOffset = Angle(0, 90, 90)

function ENT:Attack()
    if not self:GetAttacking() then
        self:ResetSequence("fire")
        self:GetAttacking(true)
    end

    local target = self:GetTarget()

    -- print("Attack target:", target)
    if not self:IsValidTarget(target) then
        self:SetTarget(NULL)
        -- self:ResetSequence("disabled")
        self:SetIdle(true)

        return
    end

    if SERVER then
        self:PointAtEntity(target)
    end

    if self:GetNextFire() <= CurTime() then
        -- local forward = self:GetForward()
        -- forward:Rotate(forwardOffset)
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
        self:FireBullets(bullet)
        self:SetNextFire(CurTime() + self.Delay)
    end

    if SERVER then
        self:SetAngles(self:GetAngles() + angleOffset)
    end
end

function ENT:Reset()
    self:ResetSequence("idle")
    self:SetAngles(self:GetAngles() - angleOffset)
    self:SetAttacking(false)
    self:SetTarget(NULL)
    self:SetIdle(true)
end
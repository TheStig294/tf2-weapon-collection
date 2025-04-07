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
ENT.Spread = 0.1
ENT.Delay = 0.2
ENT.Angle = 45
ENT.Range = 500
ENT.Range = ENT.Range * ENT.Range

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "Idle")
    self:NetworkVar("Float", "IdleTimer")
    self:NetworkVar("Bool", "FullyPlaced")
    self:NetworkVar("Entity", "Target")
    self:NetworkVar("Bool", "Attacking")
    self:NetworkVar("Float", "NextFire")
    self:NetworkVar("Angle", "OriginalAngles")
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
    -- timer.Create("TF2TurretTest", 1, 0, function()
    --     if not IsValid(self) then return end
    --     if not self:GetIdle() and self:GetIdleTimer() <= CurTime() and not self:GetFullyPlaced() then
    --         self:SetModel("models/buildables/sentry1.mdl")
    --         self:SetFullyPlaced(true)
    --         self:ResetSequence("aim_nat")
    --         self:SetIdle(true)
    --     end
    --     if self:GetFullyPlaced() then
    --         if self:GetIdle() then
    --             self:FindTarget()
    --         elseif self:IsValidTarget() then
    --             self:Attack()
    --         else
    --             self:Reset()
    --         end
    --     end
    -- end)
end

function ENT:IsValidTarget()
    -- print("Is valid target called")
    local target = self:GetTarget()
    -- print("Is valid:", IsValid(target), "Is player:", target:IsPlayer(), "Alive:", target:Alive(), "IsSpec:", target:IsSpec())
    if not IsValid(target) or not target:IsPlayer() or not target:Alive() or target:IsSpec() then return false end
    -- local pos = self:GetPos()
    -- local targetPos = target:GetPos()
    -- print("Target Pos:", targetPos)
    -- print("Target within distance:", targetPos:DistToSqr(pos) < self.Range)
    -- return targetPos:DistToSqr(pos) < self.Range

    return target:GetPos():DistToSqr(self:GetPos()) < self.Range
end

function ENT:Think()
    self:NextThink(CurTime())

    if not self:GetIdle() and self:GetIdleTimer() <= CurTime() and not self:GetFullyPlaced() then
        self:SetModel("models/buildables/sentry1.mdl")
        self:SetFullyPlaced(true)
        self:ResetSequence("aim_nat")
        self:SetIdle(true)
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
    -- print("Calling FindTarget")
    for _, ent in ipairs(ents.FindInCone(self:GetPos(), self:GetForward(), self.Range, math.cos(math.rad(self.Angle)))) do
        if IsValid(ent) and ent:IsPlayer() and ent:Alive() and not ent:IsSpec() then
            self:SetTarget(ent)
            self:SetIdle(false)
        end
    end
end

local angleOffset = Angle(0, 90, 80)

function ENT:Attack()
    -- print("Calling Attack")
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
    end

    if SERVER then
        self:SetAngles(self:GetAngles() + angleOffset)
    end
end

function ENT:Reset()
    -- print("Calling Reset")
    self:ResetSequence("aim_nat")
    self:SetAttacking(false)
    self:SetTarget(NULL)
    self:SetIdle(true)
    self:SetAngles(self:GetOriginalAngles())
end
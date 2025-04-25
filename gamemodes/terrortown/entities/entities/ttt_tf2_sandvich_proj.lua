AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/c_models/c_sandwich/c_sandwich.mdl")
ENT.Duration = 15

function ENT:Initialize()
    return self.BaseClass.Initialize(self)
end

function ENT:ActivateSandvich(ply)
    ply.TF2SandvichHealth = ply:Health()

    if ply:Health() < ply:GetMaxHealth() then
        ply:SetHealth(ply:GetMaxHealth())
    end

    if SERVER and IsFirstTimePredicted() then
        ply:EmitSound("player/heavy/sandvich" .. math.random(12) .. ".wav")
    end

    timer.Simple(self.Duration, function()
        if not IsValid(ply) or not ply.TF2SandvichHealth or ply.TF2SandvichHealth > ply:Health() then return end
        ply:SetHealth(ply.TF2SandvichHealth)
        ply.TF2SandvichHealth = nil
    end)

    hook.Add("TTTPrepareRound", "TF2SandvichHealthReset", function()
        for _, p in player.Iterator() do
            p.TF2SandvichHealth = nil
        end

        hook.Remove("TTTPrepareRound", "TF2SandvichHealthReset")
    end)
end

function ENT:PhysicsCollide(collisionData)
    self:Explode(collisionData.HitEntity)
end

function ENT:Explode(ent)
    if IsValid(ent) and ent:IsPlayer() then
        self:ActivateSandvich(ent)
    end

    self:EmitSound("weapons/blade_hit" .. math.random(4) .. ".wav")
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("AntlionGib", effect, true, true)

    if SERVER then
        self:Remove()
    end
end
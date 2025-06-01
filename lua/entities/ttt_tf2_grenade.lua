AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "TF2 Grenade"
ENT.Damage = 25
ENT.Range = 140

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_NONE)

    timer.Simple(0.5, function()
        if IsValid(self) then
            self:SetSolid(SOLID_VPHYSICS)
        end
    end)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:DrawShadow(false)
    ParticleEffectAttach("pipebombtrail_red", PATTACH_POINT_FOLLOW, self, 0)
    self.ExplodeTimer = CurTime() + 3
end

function ENT:Think()
    if SERVER and self.ExplodeTimer <= CurTime() then
        self:Remove()
    end
end

function ENT:PhysicsCollide(data)
    if SERVER then
        if data.Speed > 50 then
            self:EmitSound("physics/metal/metal_grenade_impact_hard1.wav")
        end

        local ent = data.HitEntity

        if ent:IsNPC() or ent:IsPlayer() then
            self:SetMoveType(MOVETYPE_NONE)
            self:SetSolid(SOLID_NONE)
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
            self:Remove()
        end
    end
end

function ENT:OnRemove()
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effect, true, true)
    self:EmitSound("weapons/rocket_explosion.wav", 100, math.random(75, 125))

    if SERVER then
        local inflictor = self.Weapon

        if not IsValid(inflictor) then
            inflictor = self
        end

        local owner = self.DamageOwner

        if not IsValid(owner) then
            owner = self
        end

        util.BlastDamage(inflictor, owner, self:GetPos(), self.Radius, self.Damage)
    end
end
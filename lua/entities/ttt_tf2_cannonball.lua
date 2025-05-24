AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Cannonball"
ENT.Damage = 60
ENT.ExplosionDamage = 40
ENT.Radius = 200
ENT.ExplodeTime = 0

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_cannonball.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:DrawShadow(false)
    ParticleEffectAttach("loose_cannon_sparks", PATTACH_POINT_FOLLOW, self, 1)
    self:EmitSound("misc/halloween/hwn_bomb_fuse.wav")
end

function ENT:Think()
    if SERVER and self.ExplodeTime <= CurTime() then
        self:Remove()
    end
end

function ENT:PhysicsCollide(data)
    if SERVER then
        if data.Speed > 50 then
            self:EmitSound("weapons/loose_cannon_ball_impact.wav")
        end

        if not self.DealtImpactDamage and (data.HitEntity:IsNPC() or data.HitEntity:IsPlayer()) then
            local dmg = DamageInfo()
            dmg:SetDamage(self.Damage)
            dmg:SetDamageType(DMG_CLUB)
            local inflictor = self.Weapon

            if not IsValid(inflictor) then
                inflictor = self
            end

            inflictor.ImpactDamageTime = CurTime()
            self.DealtImpactDamage = true
            local owner = self.DamageOwner

            if not IsValid(owner) then
                owner = self
            end

            dmg:SetInflictor(inflictor)
            dmg:SetAttacker(owner)
            data.HitEntity:TakeDamageInfo(dmg)
        end
    end
end

function ENT:OnRemove()
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effect, true, true)
    self:StopSound("misc/halloween/hwn_bomb_fuse.wav")
    self:EmitSound("weapons/loose_cannon_explode.wav", 100, math.random(75, 125))

    if SERVER then
        local inflictor = self.Weapon

        if not IsValid(inflictor) then
            inflictor = self
        end

        local owner = self.DamageOwner

        if not IsValid(owner) then
            owner = self
        end

        util.BlastDamage(inflictor, owner, self:GetPos(), self.Radius, self.ExplosionDamage)
    end
end
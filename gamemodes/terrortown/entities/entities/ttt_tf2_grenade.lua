AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.PrintName = "Grenade-Launcher Grenade"

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
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

        if data.HitEntity:IsNPC() or data.HitEntity:IsPlayer() then
            self:SetMoveType(MOVETYPE_NONE)
            self:SetSolid(SOLID_NONE)
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
            self:Remove()
        end
    end
end

function ENT:OnRemove()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        owner = self
    end

    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effect, true, true)
    self:EmitSound("weapons/rocket_explosion.wav", 100, math.random(75, 125))

    if SERVER then
        local inflictor = self.Weapon

        if not IsValid(inflictor) then
            inflictor = self
        end

        local dmg = DamageInfo()
        dmg:SetDamageType(DMG_BLAST)
        dmg:SetAttacker(owner)
        dmg:SetInflictor(inflictor)
        dmg:SetDamage(self.Damage or 30)

        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Range or 140)) do
            if IsValid(ent) then
                ent:TakeDamageInfo(dmg)
            end
        end
    end
end
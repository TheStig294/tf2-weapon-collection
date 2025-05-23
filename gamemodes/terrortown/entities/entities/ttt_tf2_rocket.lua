AddCSLuaFile()
ENT.Type = "anim"
ENT.Size = 0.4
ENT.PrintName = "TF2 Rocket"
ENT.Force = 562.5
ENT.Radius = 169

--[[---------------------------------------------------------
Initialize
---------------------------------------------------------]]
function ENT:Initialize()
    ParticleEffectAttach("rockettrail", PATTACH_POINT_FOLLOW, self, 0)
    self:SetModel("models/weapons/w_models/w_rocket.mdl")
    self:SetMoveType(MOVETYPE_FLY)
    self:SetSolid(SOLID_BBOX)
    self:DrawShadow(true)
    self.StopExp = false
    self:SetCollisionBounds(Vector(-self.Size, -self.Size, -self.Size), Vector(self.Size, self.Size, self.Size))
    -- Don't collide with the player
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:SetNWString("Owner", "World")
    local class = self:GetClass()

    -- Disable the explosion sound for being hit by a TF2 rocket
    hook.Add("OnDamagedByExplosion", "TF2WeaponCollectionDisableRocketJumpSound", function(_, dmg)
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) then return end
        if inflictor:GetClass() == class then return true end
    end)
end

function ENT:Explode()
    self.StopExp = true
    self:EmitSound("weapons/rocket_explosion.wav", 100, math.random(75, 125))
    -- Create explosion effect
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    util.Effect("HelicopterMegaBomb", effect, true, true)
    -- Apply blast damage
    local owner = self:GetOwner()

    if not IsValid(owner) then
        owner = self
    end

    local inflictor = self.Weapon

    if not IsValid(inflictor) then
        inflictor = self
    end

    local dmg = DamageInfo()
    dmg:SetDamageType(DMG_BLAST)
    dmg:SetDamage(self.Damage or 40)
    dmg:SetAttacker(owner)
    dmg:SetInflictor(inflictor)
    -- Owner takes less damage from own rockets to allow for rocket-jumping!
    local ownerHit = false

    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 169)) do
        if IsValid(ent) then
            if ent == owner then
                ownerHit = true
                continue
            end

            ent:TakeDamageInfo(dmg)
        end
    end

    if ownerHit then
        dmg:SetDamage(dmg:GetDamage() / 4)
        owner:TakeDamageInfo(dmg)
    end

    for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.Radius)) do
        if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
            local direction = (ent:GetPos() - self:GetPos()):GetNormalized()
            direction.z = 1
            ent:SetVelocity(direction * self.Force)
        end
    end

    self:Remove()
end

function ENT:Touch(ent)
    if SERVER and self.StopExp == false and not (IsValid(self:GetOwner()) and self:GetOwner() == ent) then
        self:Explode()
    end
end